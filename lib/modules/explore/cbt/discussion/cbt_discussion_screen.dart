import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/discussion/cbt_discussion_detail_screen.dart';
import 'package:linkschool/modules/explore/cbt/discussion/discussion_ad_manager.dart';
import 'package:linkschool/modules/explore/cbt/discussion/models/cbt_discussion_update_item.dart';
import 'package:linkschool/modules/explore/cbt/discussion/widgets/discussion_ad_widgets.dart';
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
  final CbtUpdatesService _updatesService = CbtUpdatesService();
  final List<CbtDiscussionUpdateItem> _updates = [];
  final ScrollController _scrollController = ScrollController();
  bool _shouldShowAdOnResume = false;
  bool _isNavigatingAway = false;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  bool _isHandlingBackNavigation = false;
  bool _allowRoutePop = false;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasNextPage = false;

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
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

  Future<void> _handleBackNavigation() async {
    if (_isHandlingBackNavigation) return;
    _isHandlingBackNavigation = true;
    _isNavigatingAway = true;
    if (mounted) {
      setState(() => _allowRoutePop = true);
    }
    Navigator.of(context).pop();
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

  Widget _buildAdsStrip() {
    final adUnitIds = discussionBannerAdUnitIds();
    if (adUnitIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: DiscussionSponsoredAdCard(adUnitIds: adUnitIds),
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
