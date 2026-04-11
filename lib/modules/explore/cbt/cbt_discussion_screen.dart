import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/explore/cbt/discussion_ad_manager.dart';
import 'package:linkschool/modules/explore/cbt/subject_selection_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/explore/cbt/cbt_updates_service.dart';

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
  static const String _unsetEnvValue = '__SET_VIA_DART_DEFINE__';
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

  bool _isAdUnitConfigured(String adUnitId) =>
      adUnitId.isNotEmpty && adUnitId != _unsetEnvValue;

  List<String> get _bannerAdUnitIds {
    final units = <String>[];
    for (final adUnitId in [
      EnvConfig.discussionBannerAdKey,
      EnvConfig.homeBannerAdKey,
      EnvConfig.googleBannerAdsApiKey,
    ]) {
      if (_isAdUnitConfigured(adUnitId) && !units.contains(adUnitId)) {
        units.add(adUnitId);
      }
    }
    return units;
  }

  Future<void> _handleBackNavigation() async {
    if (_isHandlingBackNavigation) return;
    _isHandlingBackNavigation = true;
    _isNavigatingAway = true;
    await DiscussionAdManager.instance.showInterstitialIfEligible(
      context: context,
    );
    if (mounted) {
      setState(() => _allowRoutePop = true);
      Navigator.of(context).pop();
    }
    _isHandlingBackNavigation = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      if (!_isNavigatingAway) {
        _shouldShowAdOnResume = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldShowAdOnResume) {
        DiscussionAdManager.instance.showAppOpenIfEligible(context: context);
        _shouldShowAdOnResume = false;
      }
      _isNavigatingAway = false;
    }
  }

  Widget _buildAdsStrip() {
    final adUnitIds = _bannerAdUnitIds;
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
                      item.timeLabel,
                      style: AppTextStyles.normal500(
                        fontSize: 11,
                        color: AppColors.text8Light,
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
        body: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
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
                          update: item,
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
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Sponsored',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ),
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

class CbtDiscussionUpdateItem {
  final int id;
  final String title;
  final String body;
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

  const CbtDiscussionUpdateItem({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.accentColor,
    required this.badge,
    required this.timeLabel,
  });
}

class CbtDiscussionDetailScreen extends StatefulWidget {
  final CbtDiscussionUpdateItem? update;
  final int? updateId;

  const CbtDiscussionDetailScreen({
    super.key,
    this.update,
    this.updateId,
  }) : assert(update != null || updateId != null);

  @override
  State<CbtDiscussionDetailScreen> createState() =>
      _CbtDiscussionDetailScreenState();
}

class _CbtDiscussionDetailScreenState extends State<CbtDiscussionDetailScreen>
    with WidgetsBindingObserver {
  final CbtUpdatesService _updatesService = CbtUpdatesService();
  bool _shouldShowAdOnResume = false;
  bool _isNavigatingAway = false;
  bool _isHandlingBackNavigation = false;
  bool _isLoadingDetail = false;
  bool _allowRoutePop = false;
  late CbtDiscussionUpdateItem _activeUpdate;

  @override
  void initState() {
    super.initState();
    _activeUpdate = widget.update ?? _fallbackUpdateForId(widget.updateId ?? 0);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DiscussionAdManager.instance.preloadAll(context);
      _fetchDiscussionUpdateDetail();
    });
  }

  CbtDiscussionUpdateItem _fallbackUpdateForId(int id) {
    return CbtDiscussionUpdateItem(
      id: id,
      title: 'CBT Update #$id',
      body:
          '<p>Update details will appear here once loaded from the server.</p>',
      icon: Icons.notifications_none_rounded,
      accentColor: const Color(0xFF2563EB),
      badge: 'Update',
      timeLabel: 'Now',
    );
  }

  Future<void> _fetchDiscussionUpdateDetail() async {
    final id = widget.updateId;
    if (id == null) return;
    setState(() => _isLoadingDetail = true);

    final response = await _updatesService.fetchUpdateById(id);
    if (!response.success) {
      debugPrint(
          'CBT update detail fetch failed (id=$id): ${response.message}');
      if (mounted) {
        setState(() => _isLoadingDetail = false);
      }
      return;
    }

    final root = response.data ?? response.rawData ?? <String, dynamic>{};
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
    if (id == null || title.isEmpty) return null;

    return CbtDiscussionUpdateItem(
      id: id,
      title: title,
      body: _firstNonEmptyString(
        [
          json['content'],
          json['body'],
          json['description'],
          json['details'],
          fallback?.body,
        ],
      ),
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
    if (_asInt(data['id']) != null) {
      return data;
    }

    final nestedMap = _asMap(data['data']);
    if (nestedMap.isNotEmpty) {
      return nestedMap;
    }

    final nestedList = _asList(data['data']);
    if (nestedList.isNotEmpty) {
      return _asMap(nestedList.first);
    }

    final rootList = _asList(root['data']);
    if (rootList.isNotEmpty) {
      return _asMap(rootList.first);
    }

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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubjectSelectionScreen(),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _handleBackNavigation() async {
    if (_isHandlingBackNavigation) return;
    _isHandlingBackNavigation = true;
    _isNavigatingAway = true;
    await DiscussionAdManager.instance.showInterstitialIfEligible(
      context: context,
    );
    if (mounted) {
      setState(() => _allowRoutePop = true);
      Navigator.of(context).pop();
    }
    _isHandlingBackNavigation = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      if (!_isNavigatingAway) {
        _shouldShowAdOnResume = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldShowAdOnResume) {
        DiscussionAdManager.instance.showAppOpenIfEligible(context: context);
        _shouldShowAdOnResume = false;
      }
      _isNavigatingAway = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final update = _activeUpdate;
    final hasBodyContent = update.previewText.isNotEmpty &&
        !update.previewText.startsWith('Update details will appear here');

    return PopScope(
      canPop: _allowRoutePop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _allowRoutePop) return;
        await _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
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
                          update.title,
                          style: AppTextStyles.normal700(
                            fontSize: 24,
                            color: Colors.white,
                          ),
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasBodyContent)
                      Html(
                        data: update.body,
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
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Text(
                        'This update has no content available yet.',
                        style: AppTextStyles.normal500(
                          fontSize: 14,
                          color: AppColors.text7Light,
                        ),
                      ),
                    const Spacer(),
                    const SizedBox(height: 18),
                    SizedBox(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
