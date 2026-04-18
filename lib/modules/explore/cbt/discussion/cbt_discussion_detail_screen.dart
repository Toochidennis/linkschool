import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/back_navigation_interstitial_helper.dart';
import 'package:linkschool/modules/explore/cbt/cbt_dashboard.dart';
import 'package:linkschool/modules/explore/cbt/discussion/discussion_ad_manager.dart';
import 'package:linkschool/modules/explore/cbt/discussion/models/cbt_discussion_comment.dart';
import 'package:linkschool/modules/explore/cbt/discussion/models/cbt_discussion_update_item.dart';
import 'package:linkschool/modules/explore/cbt/discussion/widgets/discussion_ad_widgets.dart';
import 'package:linkschool/modules/explore/cbt/discussion/widgets/discussion_comment_compose_sheet.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/explore/cbt/cbt_updates_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final List<CbtDiscussionComment> _comments = [];
  int _commentsPage = 1;
  int _commentsLastPage = 1;
  bool _hasNextCommentPage = false;
  bool _isLoadingComments = false;
  int _totalComments = 0;
  bool _allowRoutePop = false;
  late CbtDiscussionUpdateItem _activeUpdate;

  int get _displayCommentCount =>
      _totalComments > 0 ? _totalComments : _activeUpdate.commentsCount;

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
        'CBT update detail fetch failed (id=$id): ${response.message}',
      );
      if (mounted) {
        setState(() => _isLoadingDetail = false);
      }
      return;
    }

    final payload = _extractDetailPayload(rawResponse);
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

  Future<void> _refreshDiscussionDetail() {
    return Future.wait([
      _fetchDiscussionUpdateDetail(),
      _fetchComments(reset: true),
    ]);
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
        .map((item) => CbtDiscussionComment.fromJson(_asMap(item)))
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

  void _showComposeCommentSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DiscussionCommentComposeSheet(onSend: _postComment),
    );
  }

  void _openPracticeSubjectSelection() {
    bool foundDashboard = false;
    Navigator.of(context).popUntil((route) {
      if (route.settings.name == CBTDashboard.routeName) {
        foundDashboard = true;
        return true;
      }
      return route.isFirst;
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

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300 &&
        _hasNextCommentPage) {
      _fetchComments();
    }
  }

  Widget _buildCommentTile(CbtDiscussionComment comment, int index) {
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

  CbtDiscussionUpdateItem? _fromServer(
    Map<String, dynamic> json, {
    CbtDiscussionUpdateItem? fallback,
  }) {
    final id = _asInt(json['id']) ?? fallback?.id;
    final title = _firstNonEmptyString([
      json['title'],
      json['name'],
      fallback?.title,
    ]);
    if (id == null) return null;

    return CbtDiscussionUpdateItem(
      id: id,
      title: title,
      body: _firstNonEmptyString([
        json['content'],
      ]),
      commentsCount:
          _asInt(json['comments_count']) ?? fallback?.commentsCount ?? 0,
      icon: Icons.notifications_none_rounded,
      accentColor: const Color(0xFF2563EB),
      badge: _firstNonEmptyString([
        json['tag'],
        fallback?.badge,
        'Update',
      ]),
      timeLabel: _firstNonEmptyString([
        _formatDiscussionDate(_asString(json['notified_at'])),
        _formatDiscussionDate(_asString(json['created_at'])),
        fallback?.timeLabel,
        'Now',
      ]),
    );
  }

  Map<String, dynamic> _extractDetailPayload(Map<String, dynamic> root) {
    final data = _asMap(root['data']);

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

  @override
  Widget build(BuildContext context) {
    final update = _activeUpdate;
    final hasBodyContent = update.previewText.isNotEmpty;
    final detailBannerAdUnitIds = discussionBannerAdUnitIds();

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
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (detailBannerAdUnitIds.isNotEmpty) ...[
                        DiscussionInlineBannerAd(
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
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: AppColors.text7Light,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_displayCommentCount ${_displayCommentCount == 1 ? 'comment' : 'comments'}',
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
