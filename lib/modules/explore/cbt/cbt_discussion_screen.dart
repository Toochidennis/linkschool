import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linkschool/modules/explore/cbt/back_navigation_interstitial_helper.dart';
import 'package:linkschool/modules/explore/cbt/cbt_dashboard.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/explore/cbt/discussion_ad_manager.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/explore/cbt/cbt_updates_service.dart';

const String _unsetEnvValue = '__SET_VIA_DART_DEFINE__';

bool _isDiscussionAdUnitConfigured(String adUnitId) =>
    adUnitId.isNotEmpty && adUnitId != _unsetEnvValue;

List<String> _discussionBannerAdUnitIds() {
  final units = <String>[];
  for (final adUnitId in [
    EnvConfig.discussionBannerAdKey,
    EnvConfig.homeBannerAdKey,
    EnvConfig.googleBannerAdsApiKey,
  ]) {
    if (_isDiscussionAdUnitConfigured(adUnitId) && !units.contains(adUnitId)) {
      units.add(adUnitId);
    }
  }
  return units;
}

class CbtDiscussionScreen extends StatefulWidget {
  final String boardName;

  const CbtDiscussionScreen({
    super.key,
    required this.boardName,
  });

  @override
  State<CbtDiscussionScreen> createState() => _CbtDiscussionScreenState();
}

class _CbtDiscussionScreenState extends State<CbtDiscussionScreen>
    with WidgetsBindingObserver {
  final CbtUpdatesService _updatesService = CbtUpdatesService();
  bool _shouldShowAdOnResume = false;
  bool _isNavigatingAway = false;
  final List<CbtDiscussionUpdateItem> _updates = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasNextPage = false;
  bool _isHandlingBackNavigation = false;
  bool _allowRoutePop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DiscussionAdManager.instance.preloadAll(context);
      _fetchDiscussionUpdates(reset: true);
    });
  }

  Future<void> _fetchDiscussionUpdates({required bool reset}) async {
    if (reset) {
      if (_isLoadingInitial) return;
      setState(() => _isLoadingInitial = true);
    } else {
      if (_isLoadingMore || !_hasNextPage) return;
      setState(() => _isLoadingMore = true);
    }

    final nextPage = reset ? 1 : _currentPage + 1;
    final response = await _updatesService.fetchUpdates(page: nextPage);
    if (!response.success) {
      debugPrint('CBT updates fetch failed: ${response.message}');
      if (!mounted) return;
      setState(() {
        _isLoadingInitial = false;
        _isLoadingMore = false;
      });
      return;
    }

    final root = response.data ?? response.rawData ?? <String, dynamic>{};
    final data = _asMap(root['data']);
    final rows = _asList(data['data']);
    final pagination = _asMap(data['pagination']);

    final parsed = rows
        .map((item) => _fromServer(_asMap(item)))
        .whereType<CbtDiscussionUpdateItem>()
        .toList();

    if (!mounted) return;
    setState(() {
      if (reset) {
        _updates
          ..clear()
          ..addAll(parsed);
      } else {
        _updates.addAll(parsed);
      }

      _currentPage = _asInt(pagination['current_page']) ?? nextPage;
      _lastPage = _asInt(pagination['last_page']) ?? _currentPage;
      _hasNextPage =
          _asBool(pagination['has_next']) ?? (_currentPage < _lastPage);
      _isLoadingInitial = false;
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshDiscussionUpdates() {
    return _fetchDiscussionUpdates(reset: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _fetchDiscussionUpdates(reset: false);
    }
  }

  CbtDiscussionUpdateItem? _fromServer(Map<String, dynamic> json) {
    final id = _asInt(json['id']);
    final title = _asString(json['title']);
    if (id == null || title.isEmpty) {
      return null;
    }

    return CbtDiscussionUpdateItem(
      id: id,
      title: title,
      body: _asString(json['content']),
      commentsCount: _asInt(json['comments_count']) ?? 0,
      icon: Icons.notifications_none_rounded,
      accentColor: const Color(0xFF2563EB),
      badge: _asString(json['tag']).isEmpty ? 'Update' : _asString(json['tag']),
      timeLabel: _formatDiscussionDate(_asString(json['notified_at'])).isEmpty
          ? 'Now'
          : _formatDiscussionDate(_asString(json['notified_at'])),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry('$k', v));
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    return const [];
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  bool? _asBool(dynamic value) {
    if (value is bool) return value;
    final text = '$value'.trim().toLowerCase();
    if (text == 'true' || text == '1' || text == 'yes') return true;
    if (text == 'false' || text == '0' || text == 'no') return false;
    return null;
  }

  String _asString(dynamic value) {
    if (value == null) return '';
    return '$value'.trim();
  }

  String _formatDiscussionDate(String raw) {
    if (raw.isEmpty) return '';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    return DateFormat('d MMM yyyy, h:mm a').format(parsed.toLocal());
  }

  Future<void> _handleBackNavigation() async {
    if (_isHandlingBackNavigation) return;
    _isHandlingBackNavigation = true;
    _isNavigatingAway = true;
    if (mounted) {
      setState(() => _allowRoutePop = true);
    }
    Navigator.of(context).pop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

    if (state == AppLifecycleState.paused) {
      if (!_isNavigatingAway && isCurrentRoute) {
        _shouldShowAdOnResume = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldShowAdOnResume) {
        if (!isCurrentRoute) {
          _shouldShowAdOnResume = false;
          _isNavigatingAway = false;
          return;
        }
        DiscussionAdManager.instance.showAppOpenIfEligible(context: context);
        _shouldShowAdOnResume = false;
      }
      _isNavigatingAway = false;
    }
  }

  Widget _buildAdsStrip() {
    final adUnitIds = _discussionBannerAdUnitIds();
    if (adUnitIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: _CompactSponsoredAdCard(adUnitIds: adUnitIds),
    );
  }

  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.eLearningBtnColor1.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.eLearningBtnColor1,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Updates',
            style: AppTextStyles.normal700(
              fontSize: 18,
              color: AppColors.text4Light,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(CbtDiscussionUpdateItem item) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.icon,
              color: item.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.normal700(
                          fontSize: 15,
                          color: AppColors.text4Light,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: item.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.badge,
                        style: AppTextStyles.normal600(
                          fontSize: 11,
                          color: item.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.timeLabel,
                  style: AppTextStyles.normal500(
                    fontSize: 11,
                    color: AppColors.text8Light,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.previewText,
                  style: AppTextStyles.normal400(
                    fontSize: 13,
                    color: AppColors.text7Light,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${item.commentsCount} ${item.commentsCount == 1 ? 'comment' : 'comments'}',
                      style: AppTextStyles.normal500(
                        fontSize: 12,
                        color: AppColors.text7Light,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Open',
                      style: AppTextStyles.normal600(
                        fontSize: 12,
                        color: item.accentColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: item.accentColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowRoutePop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _allowRoutePop) return;
        await _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FC),
        appBar: AppBar(
          backgroundColor: AppColors.eLearningBtnColor1,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _handleBackNavigation,
          ),
          title: Text(
            'Discussion',
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshDiscussionUpdates,
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: <Widget>[
              _buildAdsStrip(),
              _buildSectionLabel(),
              if (_isLoadingInitial)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_updates.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      'No updates available yet.',
                      style: AppTextStyles.normal500(
                        fontSize: 14,
                        color: AppColors.text7Light,
                      ),
                    ),
                  ),
                )
              else ...[
                ..._updates.map(
                  (item) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CbtDiscussionDetailScreen(
                            updateId: item.id,
                          ),
                        ),
                      );
                    },
                    child: _buildUpdateCard(item),
                  ),
                ),
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_hasNextPage)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextButton(
                      onPressed: () => _fetchDiscussionUpdates(reset: false),
                      child: const Text('Load more updates'),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactSponsoredAdCard extends StatelessWidget {
  final List<String> adUnitIds;

  const _CompactSponsoredAdCard({
    required this.adUnitIds,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.text2Light.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF8FAFC),
                        Color(0xFFFFFFFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Center(
                child: _CompactBannerAd(adUnitIds: adUnitIds),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactBannerAd extends StatefulWidget {
  final List<String> adUnitIds;

  const _CompactBannerAd({
    required this.adUnitIds,
  });

  @override
  State<_CompactBannerAd> createState() => _CompactBannerAdState();
}

class _CompactBannerAdState extends State<_CompactBannerAd> {
  BannerAd? _ad;
  bool _isLoaded = false;
  bool _hasNoFillAcrossUnits = false;
  int _activeAdUnitIndex = 0;
  int _retryAttempt = 0;

  String get _activeAdUnitId => widget.adUnitIds[_activeAdUnitIndex];

  void _loadAd() {
    _ad?.dispose();
    _ad = BannerAd(
      adUnitId: _activeAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _ad = ad as BannerAd;
            _isLoaded = true;
            _hasNoFillAcrossUnits = false;
            _retryAttempt = 0;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;

          debugPrint(
            'Discussion banner failed (${error.code}) on $_activeAdUnitId: ${error.message}',
          );

          // Try the next configured banner unit before delaying retries.
          if (_activeAdUnitIndex < widget.adUnitIds.length - 1) {
            setState(() {
              _activeAdUnitIndex++;
              _ad = null;
              _isLoaded = false;
            });
            _loadAd();
            return;
          }

          setState(() {
            _ad = null;
            _isLoaded = false;
            _hasNoFillAcrossUnits = true;
          });

          final retryDelaySeconds = (_retryAttempt + 1) * 8;
          _retryAttempt++;
          Future<void>.delayed(Duration(seconds: retryDelaySeconds), () {
            if (!mounted) return;
            _activeAdUnitIndex = 0;
            _loadAd();
          });
        },
      ),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(covariant _CompactBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitIds.join('|') != widget.adUnitIds.join('|')) {
      _activeAdUnitIndex = 0;
      _retryAttempt = 0;
      _isLoaded = false;
      _hasNoFillAcrossUnits = false;
      _loadAd();
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_isLoaded || ad == null) {
      return Container(
        width: 320,
        height: 50,
        alignment: Alignment.center,
        child: Text(
          _hasNoFillAcrossUnits
              ? 'No sponsor card available right now'
              : 'Loading sponsor card...',
          style: AppTextStyles.normal600(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}

class _DiscussionInlineBannerAd extends StatefulWidget {
  final List<String> adUnitIds;
  final AdSize size;

  const _DiscussionInlineBannerAd({
    required this.adUnitIds,
    required this.size,
  });

  @override
  State<_DiscussionInlineBannerAd> createState() =>
      _DiscussionInlineBannerAdState();
}

class _DiscussionInlineBannerAdState extends State<_DiscussionInlineBannerAd> {
  BannerAd? _ad;
  bool _isLoaded = false;
  int _activeAdUnitIndex = 0;

  String get _activeAdUnitId => widget.adUnitIds[_activeAdUnitIndex];

  void _loadAd() {
    _ad?.dispose();
    _ad = BannerAd(
      adUnitId: _activeAdUnitId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _ad = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;

          debugPrint(
            'Discussion detail banner failed (${error.code}) on $_activeAdUnitId: ${error.message}',
          );

          if (_activeAdUnitIndex < widget.adUnitIds.length - 1) {
            setState(() {
              _activeAdUnitIndex++;
              _ad = null;
              _isLoaded = false;
            });
            _loadAd();
            return;
          }

          setState(() {
            _ad = null;
            _isLoaded = false;
          });
        },
      ),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(covariant _DiscussionInlineBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitIds.join('|') != widget.adUnitIds.join('|') ||
        oldWidget.size != widget.size) {
      _activeAdUnitIndex = 0;
      _isLoaded = false;
      _loadAd();
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_isLoaded || ad == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      alignment: Alignment.center,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}

class CbtDiscussionUpdateItem {
  final int id;
  final String title;
  final String body;
  final int commentsCount;
  final IconData icon;
  final Color accentColor;
  final String badge;
  final String timeLabel;

  String get previewText {
    final text = body
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return text;
  }

  String get plainTitle {
    return title
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  const CbtDiscussionUpdateItem({
    required this.id,
    required this.title,
    required this.body,
    required this.commentsCount,
    required this.icon,
    required this.accentColor,
    required this.badge,
    required this.timeLabel,
  });
}

class _CbtDiscussionComment {
  final int id;
  final int updateId;
  final int userId;
  final String username;
  final String body;
  final String createdAt;

  const _CbtDiscussionComment({
    required this.id,
    required this.updateId,
    required this.userId,
    required this.username,
    required this.body,
    required this.createdAt,
  });

  factory _CbtDiscussionComment.fromJson(Map<String, dynamic> json) {
    return _CbtDiscussionComment(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      updateId: json['update_id'] is int
          ? json['update_id'] as int
          : int.tryParse('${json['update_id']}') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse('${json['user_id']}') ?? 0,
      username: json['username'] is String ? json['username'] as String : '',
      body: json['body'] is String ? json['body'] as String : '',
      createdAt:
          json['created_at'] is String ? json['created_at'] as String : '',
    );
  }
}

class CbtDiscussionDetailScreen extends StatefulWidget {
  final int updateId;

  const CbtDiscussionDetailScreen({
    super.key,
    required this.updateId,
  });

  @override
  State<CbtDiscussionDetailScreen> createState() =>
      _CbtDiscussionDetailScreenState();
}

class _CbtDiscussionDetailScreenState extends State<CbtDiscussionDetailScreen>
    with WidgetsBindingObserver {
  final CbtUpdatesService _updatesService = CbtUpdatesService();
  final ScrollController _scrollController = ScrollController();
  bool _shouldShowAdOnResume = false;
  bool _isNavigatingAway = false;
  bool _isHandlingBackNavigation = false;
  bool _isLoadingDetail = false;

  // Comments state
  final List<_CbtDiscussionComment> _comments = [];
  int _commentsPage = 1;
  int _commentsLastPage = 1;
  bool _hasNextCommentPage = false;
  bool _isLoadingComments = false;
  int _totalComments = 0;

  int get _displayCommentCount =>
      _totalComments > 0 ? _totalComments : _activeUpdate.commentsCount;
  bool _allowRoutePop = false;
  late CbtDiscussionUpdateItem _activeUpdate;

  @override
  void initState() {
    super.initState();
    _activeUpdate = _fallbackUpdateForId(widget.updateId);
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DiscussionAdManager.instance.preloadAll(context);
      _fetchDiscussionUpdateDetail();
      _fetchComments(reset: true);
    });
  }

  CbtDiscussionUpdateItem _fallbackUpdateForId(int id) {
    return CbtDiscussionUpdateItem(
      id: id,
      title: '',
      body: '',
      commentsCount: 0,
      icon: Icons.notifications_none_rounded,
      accentColor: const Color(0xFF2563EB),
      badge: '',
      timeLabel: '',
    );
  }

  Future<void> _fetchDiscussionUpdateDetail() async {
    final id = widget.updateId;
    setState(() => _isLoadingDetail = true);

    final response = await _updatesService.fetchUpdateById(id);
    final rawResponse =
        response.data ?? response.rawData ?? <String, dynamic>{};

    if (!response.success) {
      debugPrint(
          'CBT update detail fetch failed (id=$id): ${response.message}');
      if (mounted) {
        setState(() => _isLoadingDetail = false);
      }
      return;
    }

    final root = rawResponse;
    final payload = _extractDetailPayload(root);

    final parsed = _fromServer(payload, fallback: _activeUpdate);
    if (!mounted) return;
    if (parsed == null) {
      setState(() => _isLoadingDetail = false);
      return;
    }
    setState(() {
      _activeUpdate = parsed;
      _isLoadingDetail = false;
    });
  }

  String _linkifyContent(String rawContent) {
    if (rawContent.isEmpty) return rawContent;

    final tagRegex = RegExp(r'(<[^>]+>)');
    final buffer = StringBuffer();
    var cursor = 0;

    for (final match in tagRegex.allMatches(rawContent)) {
      if (match.start > cursor) {
        buffer.write(
          _linkifyPlainTextSegment(rawContent.substring(cursor, match.start)),
        );
      }
      buffer.write(match.group(0));
      cursor = match.end;
    }

    if (cursor < rawContent.length) {
      buffer.write(_linkifyPlainTextSegment(rawContent.substring(cursor)));
    }

    return buffer.toString();
  }

  String _linkifyPlainTextSegment(String text) {
    final urlRegex = RegExp(
      r'((https?:\/\/|www\.)[^\s<]+)',
      caseSensitive: false,
    );

    return text.replaceAllMapped(urlRegex, (match) {
      final rawUrl = match.group(0) ?? '';
      if (rawUrl.isEmpty) return rawUrl;

      final uriTarget =
          rawUrl.toLowerCase().startsWith('http') ? rawUrl : 'https://$rawUrl';
      return '<a href="$uriTarget">$rawUrl</a>';
    });
  }

  Future<void> _openLink(String url) async {
    final normalized =
        url.toLowerCase().startsWith('http') ? url : 'https://$url';
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      debugPrint('Unable to open link: $normalized');
    }
  }

  Future<void> _refreshDiscussionDetail() {
    return Future.wait([
      _fetchDiscussionUpdateDetail(),
      _fetchComments(reset: true),
    ]);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300 && _hasNextCommentPage) {
      _fetchComments();
    }
  }

  Future<void> _fetchComments({bool reset = false}) async {
    if (_isLoadingComments) return;
    final nextPage = reset ? 1 : _commentsPage + 1;
    if (!reset && nextPage > _commentsLastPage) return;

    setState(() => _isLoadingComments = true);

    final response = await _updatesService.fetchComments(
      widget.updateId,
      page: nextPage,
      limit: 20,
    );

    if (!mounted) return;

    if (!response.success) {
      setState(() => _isLoadingComments = false);
      return;
    }

    final root = _asMap(response.data ?? response.rawData ?? {});
    final dataObj = _asMap(root['data']);
    final items = _asList(dataObj['data']);
    final pagination = _asMap(dataObj['pagination']);

    final parsed = items
        .whereType<Map>()
        .map((e) => _CbtDiscussionComment.fromJson(_asMap(e)))
        .toList();

    setState(() {
      if (reset) {
        _comments
          ..clear()
          ..addAll(parsed);
      } else {
        _comments.addAll(parsed);
      }
      _commentsPage = _asInt(pagination['current_page']) ?? nextPage;
      _commentsLastPage = _asInt(pagination['last_page']) ?? _commentsPage;
      _totalComments = _asInt(pagination['total']) ?? _comments.length;
      _hasNextCommentPage =
          pagination['has_next'] == true || _commentsPage < _commentsLastPage;
      _isLoadingComments = false;
    });
  }

  void _showComposeCommentSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CbtCommentComposeSheet(
        onSend: _postComment,
      ),
    );
  }

  Future<String?> _postComment(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return 'Please enter a comment before posting.';
    }

    final cbtUser =
        Provider.of<CbtUserProvider>(context, listen: false).currentUser;
    final userId = cbtUser?.id?.toString() ?? '';
    final username = cbtUser?.displayName ?? 'user';

    final response = await _updatesService.postComment(
      _activeUpdate.id,
      body: trimmedText,
      userId: userId,
      username: username,
    );

    if (!mounted) {
      return response.success ? null : response.message;
    }

    if (!response.success) {
      return response.message;
    }

    await _fetchComments(reset: true);
    await _fetchDiscussionUpdateDetail();

    if (!mounted) return null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment posted successfully.')),
    );
    return null;
  }

  Widget _buildCommentTile(_CbtDiscussionComment comment, int index) {
    final initials = comment.username.trim().isNotEmpty
        ? comment.username.trim()[0].toUpperCase()
        : '?';
    final dateLabel = _formatDiscussionDate(comment.createdAt);
    return Column(
      children: [
        if (index > 0) const Divider(height: 1, indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    _activeUpdate.accentColor.withValues(alpha: 0.12),
                child: Text(
                  initials,
                  style: AppTextStyles.normal700(
                    fontSize: 14,
                    color: _activeUpdate.accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            comment.username,
                            style: AppTextStyles.normal600(
                              fontSize: 13,
                              color: AppColors.text4Light,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (dateLabel.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            dateLabel,
                            style: AppTextStyles.normal400(
                              fontSize: 11,
                              color: AppColors.text7Light,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.body,
                      style: AppTextStyles.normal500(
                        fontSize: 14,
                        color: AppColors.text4Light,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  CbtDiscussionUpdateItem? _fromServer(
    Map<String, dynamic> json, {
    CbtDiscussionUpdateItem? fallback,
  }) {
    final id = _asInt(json['id']) ?? fallback?.id;
    final title = _firstNonEmptyString(
      [
        json['title'],
        json['name'],
        fallback?.title,
      ],
    );
    if (id == null) return null;

    return CbtDiscussionUpdateItem(
      id: id,
      title: title,
      body: _firstNonEmptyString(
        [
          json['content'],
        ],
      ),
      commentsCount:
          _asInt(json['comments_count']) ?? fallback?.commentsCount ?? 0,
      icon: Icons.notifications_none_rounded,
      accentColor: const Color(0xFF2563EB),
      badge: _firstNonEmptyString(
        [
          json['tag'],
          fallback?.badge,
          'Update',
        ],
      ),
      timeLabel: _firstNonEmptyString(
        [
          _formatDiscussionDate(_asString(json['notified_at'])),
          _formatDiscussionDate(_asString(json['created_at'])),
          fallback?.timeLabel,
          'Now',
        ],
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry('$k', v));
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    return const [];
  }

  Map<String, dynamic> _extractDetailPayload(Map<String, dynamic> root) {
    final data = _asMap(root['data']);

    // Single-detail payload is expected directly in `data`.
    if (_asInt(data['id']) != null || _asString(data['content']).isNotEmpty) {
      return data;
    }

    final nestedMap = _asMap(data['data']);
    if (_asInt(nestedMap['id']) != null ||
        _asString(nestedMap['content']).isNotEmpty) {
      return nestedMap;
    }

    final nestedList = _asList(data['data']);
    if (nestedList.isNotEmpty) {
      return _asMap(nestedList.first);
    }

    if (data.isNotEmpty) return data;
    return root;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  String _asString(dynamic value) {
    if (value == null) return '';
    return '$value'.trim();
  }

  String _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = _asString(value);
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  String _formatDiscussionDate(String raw) {
    if (raw.isEmpty) return '';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    return DateFormat('d MMM yyyy, h:mm a').format(parsed.toLocal());
  }

  void _openPracticeSubjectSelection() {
    // Pop back to the existing CBTDashboard if it's in the stack (normal flow),
    // otherwise push a fresh one (deep-link / notification flow).
    bool foundDashboard = false;
    Navigator.of(context).popUntil((route) {
      if (route.settings.name == CBTDashboard.routeName) {
        foundDashboard = true;
        return true; // stop here, keep the dashboard
      }
      return route.isFirst; // also stop at root to avoid over-popping
    });

    if (!foundDashboard && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          settings: const RouteSettings(name: CBTDashboard.routeName),
          builder: (_) => const CBTDashboard(),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _handleBackNavigation() async {
    if (_isHandlingBackNavigation) return;
    _isHandlingBackNavigation = true;
    _isNavigatingAway = true;
    if (mounted) {
      setState(() => _allowRoutePop = true);
    }
    await popThenShowInterstitial(
      popNavigation: () => Navigator.of(context).pop(),
      showInterstitial: (targetContext) =>
          DiscussionAdManager.instance.showInterstitialIfEligible(
        context: targetContext,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

    if (state == AppLifecycleState.paused) {
      if (!_isNavigatingAway && isCurrentRoute) {
        _shouldShowAdOnResume = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldShowAdOnResume) {
        if (!isCurrentRoute) {
          _shouldShowAdOnResume = false;
          _isNavigatingAway = false;
          return;
        }
        DiscussionAdManager.instance.showAppOpenIfEligible(context: context);
        _shouldShowAdOnResume = false;
      }
      _isNavigatingAway = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final update = _activeUpdate;
    final hasBodyContent = update.previewText.isNotEmpty;
    final detailBannerAdUnitIds = _discussionBannerAdUnitIds();

    return PopScope(
      canPop: _allowRoutePop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _allowRoutePop) return;
        await _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openPracticeSubjectSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.eLearningBtnColor1,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Start Practice',
                  style: AppTextStyles.normal700(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshDiscussionDetail,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: update.accentColor,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onPressed: _handleBackNavigation,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          update.accentColor,
                          update.accentColor.withValues(alpha: 0.85),
                          const Color(0xFF0F172A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 92, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              update.badge,
                              style: AppTextStyles.normal600(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            update.plainTitle.isEmpty && _isLoadingDetail
                                ? ''
                                : update.plainTitle,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.normal700(
                              fontSize: 22,
                              color: Colors.white,
                            ).copyWith(height: 1.25),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 15,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                update.timeLabel,
                                style: AppTextStyles.normal500(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Body + comment-count header ──────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (detailBannerAdUnitIds.isNotEmpty) ...[
                        _DiscussionInlineBannerAd(
                          adUnitIds: detailBannerAdUnitIds,
                          size: AdSize.mediumRectangle,
                        ),
                        const SizedBox(height: 18),
                      ],
                      if (hasBodyContent)
                        Html(
                          data: _linkifyContent(update.body),
                          onLinkTap: (url, attributes, element) {
                            if (url == null || url.trim().isEmpty) return;
                            _openLink(url.trim());
                          },
                          style: {
                            'body': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(16),
                              color: AppColors.text4Light,
                              lineHeight: LineHeight.number(1.6),
                            ),
                            'p': Style(
                              margin: Margins.only(bottom: 14),
                              fontSize: FontSize(16),
                              color: AppColors.text4Light,
                              lineHeight: LineHeight.number(1.6),
                            ),
                          },
                        )
                      else if (_isLoadingDetail)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        Text(
                          'This update has no content available yet.',
                          style: AppTextStyles.normal500(
                            fontSize: 14,
                            color: AppColors.text7Light,
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Comment count row + compose button
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: AppColors.text7Light,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_displayCommentCount '
                            '${_displayCommentCount == 1 ? 'comment' : 'comments'}',
                            style: AppTextStyles.normal600(
                              fontSize: 14,
                              color: AppColors.text4Light,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: _showComposeCommentSheet,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.mode_comment_outlined,
                                    size: 18,
                                    color: update.accentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Comment',
                                    style: AppTextStyles.normal600(
                                      fontSize: 13,
                                      color: update.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                    ],
                  ),
                ),
              ),

              // ── Comments list ────────────────────────────────────────────
              if (_isLoadingComments && _comments.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (!_isLoadingComments && _comments.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 32,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 40,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No comments yet.\nBe the first to comment!',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.normal500(
                              fontSize: 14,
                              color: AppColors.text7Light,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _comments.length) {
                        if (_hasNextCommentPage) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      return _buildCommentTile(_comments[index], index);
                    },
                    childCount: _comments.length + 1,
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Compose comment bottom sheet ─────────────────────────────────────────────

class _CbtCommentComposeSheet extends StatefulWidget {
  final Future<String?> Function(String text) onSend;

  const _CbtCommentComposeSheet({required this.onSend});

  @override
  State<_CbtCommentComposeSheet> createState() =>
      _CbtCommentComposeSheetState();
}

class _CbtCommentComposeSheetState extends State<_CbtCommentComposeSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add a comment',
              style: AppTextStyles.normal700(
                fontSize: 16,
                color: AppColors.text4Light,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Write your comment…',
                hintStyle: AppTextStyles.normal500(
                  fontSize: 14,
                  color: AppColors.text7Light,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textFieldBorderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textFieldBorderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final canSend =
                      value.text.trim().isNotEmpty && !_isSubmitting;
                  return ElevatedButton(
                    onPressed: canSend
                        ? () async {
                            final navigator = Navigator.of(context);
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _isSubmitting = true;
                              _errorText = null;
                            });
                            try {
                              final errorMessage =
                                  await widget.onSend(_controller.text.trim());
                              if (!mounted) return;

                              if (errorMessage == null) {
                                navigator.pop();
                                return;
                              }

                              setState(() => _errorText = errorMessage);
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eLearningBtnColor1,
                      disabledBackgroundColor:
                          AppColors.eLearningBtnColor1.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Post Comment',
                            style: AppTextStyles.normal600(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: AppTextStyles.normal500(
                  fontSize: 13,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
