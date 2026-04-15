import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/explore/cbt/back_navigation_interstitial_helper.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/gamify_ad_manager.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/services/explore/gamify_leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final bool? fromChallenge;
  final bool? fromGameDashboard;
  final bool? fromPostGameFlow;
  final int? challengeId;
  final int examTypeId;
  final List<SubjectModel> subjects;

  const LeaderboardScreen({
    super.key,
    required this.examTypeId,
    this.subjects = const <SubjectModel>[],
    this.fromChallenge,
    this.fromGameDashboard,
    this.fromPostGameFlow,
    this.challengeId,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with WidgetsBindingObserver {
  final GamifyLeaderboardService _leaderboardService =
      GamifyLeaderboardService();

  bool _shouldShowAppOpenOnResume = false;
  bool _allowRoutePop = false;
  bool _isHandlingBackNavigation = false;

  bool _loading = true;
  bool _loadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasNextPage = false;

  int? _selectedCourseId;
  List<GamifyLeaderboardEntry> _entries = const <GamifyLeaderboardEntry>[];
  late final List<SubjectModel> _tabs;

  // Banner ad — loaded once and kept alive across tab switches
  BannerAd? _bannerAd;
  bool _bannerAdLoaded = false;
  int _bannerAdUnitIndex = 0;
  int _bannerAdRetry = 0;

  static const List<String> _unsetEnvValue = ['__SET_VIA_DART_DEFINE__'];

  List<String> get _bannerAdUnitIds {
    return [
      EnvConfig.gamifyBannerAdKey,
      EnvConfig.discussionBannerAdKey,
      EnvConfig.homeBannerAdKey,
      EnvConfig.googleBannerAdsApiKey,
    ].where((id) => id.isNotEmpty && !_unsetEnvValue.contains(id)).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs(widget.subjects);
    WidgetsBinding.instance.addObserver(this);
    _loadBannerAd();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await GamifyAdManager.instance.preloadAll(context);
      await _loadLeaderboard(reset: true);
    });
  }

  void _loadBannerAd() {
    final ids = _bannerAdUnitIds;
    if (ids.isEmpty) return;
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: ids[_bannerAdUnitIndex],
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _bannerAdLoaded = true;
            _bannerAdRetry = 0;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          final ids = _bannerAdUnitIds;
          if (_bannerAdUnitIndex < ids.length - 1) {
            _bannerAdUnitIndex++;
            _loadBannerAd();
            return;
          }
          final delay = Duration(seconds: (_bannerAdRetry + 1) * 8);
          _bannerAdRetry++;
          Future<void>.delayed(delay, () {
            if (!mounted) return;
            _bannerAdUnitIndex = 0;
            _loadBannerAd();
          });
        },
      ),
    )..load();
  }

  List<SubjectModel> _buildTabs(List<SubjectModel> source) {
    final seen = <String>{};
    final tabs = <SubjectModel>[];

    for (final item in source) {
      final courseId = int.tryParse(item.id) ?? 0;
      if (courseId <= 0) continue;
      if (seen.contains(item.id)) continue;
      seen.add(item.id);
      tabs.add(item);
    }

    return tabs;
  }

  Future<void> _loadLeaderboard({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _currentPage = 1;
        _lastPage = 1;
        _hasNextPage = false;
      });
    } else {
      if (_loadingMore || !_hasNextPage) return;
      setState(() => _loadingMore = true);
    }

    final page = reset ? 1 : _currentPage + 1;
    final result = await _leaderboardService.fetchLeaderboard(
      examTypeId: widget.examTypeId,
      courseId: _selectedCourseId,
      page: page,
      limit: 25,
    );

    if (!mounted) return;

    setState(() {
      if (reset) {
        _entries = result.entries;
      } else {
        _entries = List<GamifyLeaderboardEntry>.from(_entries)
          ..addAll(result.entries);
      }

      _currentPage = result.pagination.currentPage;
      _lastPage = result.pagination.lastPage;
      _hasNextPage = result.pagination.hasNext || _currentPage < _lastPage;
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _onTabSelected(int? courseId) async {
    if (_selectedCourseId == courseId) return;
    setState(() {
      _selectedCourseId = courseId;
    });
    await _loadLeaderboard(reset: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) &&
        !GamifyAdManager.instance.isPresentingFullscreenAd) {
      _shouldShowAppOpenOnResume = true;
    } else if (state == AppLifecycleState.resumed &&
        _shouldShowAppOpenOnResume) {
      _shouldShowAppOpenOnResume = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await GamifyAdManager.instance.showAppOpenIfEligible(context: context);
      });
    }
  }

  Future<void> _handleBack() async {
    if (_isHandlingBackNavigation) return;
    _isHandlingBackNavigation = true;
    if (mounted) {
      setState(() => _allowRoutePop = true);
    }

    await popThenShowInterstitial(
      popNavigation: () => Navigator.of(context).pop(),
      showInterstitial: (targetContext) =>
          GamifyAdManager.instance.showInterstitialIfEligible(
        context: targetContext,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topThree = List<GamifyLeaderboardEntry?>.generate(
      3,
      (index) => index < _entries.length ? _entries[index] : null,
      growable: false,
    );

    return PopScope(
      canPop: _allowRoutePop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _allowRoutePop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5EF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F5EF),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _handleBack,
          ),
          title: const Text(
            'Gamify Leaderboard',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _loadLeaderboard(reset: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _buildFilterTabs(),
                    const SizedBox(height: 14),
                    _buildTopThree(topThree),
                    const SizedBox(height: 12),
                    _buildBannerAdCard(),
                    const SizedBox(height: 18),
                    if (_entries.isEmpty)
                      _buildEmptyState()
                    else ...[
                      const Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._entries.skip(3).map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildLeaderboardItem(entry: item),
                            ),
                          ),
                      if (_loadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_hasNextPage)
                        TextButton(
                          onPressed: () => _loadLeaderboard(reset: false),
                          child: const Text('Load more'),
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBannerAdCard() {
    if (!_bannerAdLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: Center(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final chips = <Widget>[
      _buildFilterChip(
        label: 'All',
        selected: _selectedCourseId == null,
        onTap: () => _onTabSelected(null),
      ),
      ..._tabs.map((subject) {
        final courseId = int.tryParse(subject.id);
        return _buildFilterChip(
          label: subject.name,
          selected: courseId != null && _selectedCourseId == courseId,
          onTap: () => _onTabSelected(courseId),
        );
      }),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  selected ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF374151),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopThree(List<GamifyLeaderboardEntry?> topThree) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildPodiumCard(
            rank: 2,
            height: 164,
            entry: topThree[1],
            trophyColor: const Color(0xFFD1D5DB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPodiumCard(
            rank: 1,
            height: 190,
            entry: topThree[0],
            trophyColor: const Color(0xFFFBBF24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPodiumCard(
            rank: 3,
            height: 148,
            entry: topThree[2],
            trophyColor: const Color(0xFFFB923C),
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumCard({
    required int rank,
    required double height,
    required GamifyLeaderboardEntry? entry,
    required Color trophyColor,
  }) {
    final hasEntry = entry != null;

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            trophyColor.withValues(alpha: 0.16),
            Colors.white,
          ],
        ),
        border: Border.all(
          color: trophyColor.withValues(alpha: 0.30),
          width: 1.4,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, color: trophyColor),
          const SizedBox(height: 6),
          Text(
            '#$rank',
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          Text(
            hasEntry ? '${entry.score}' : '--',
            style: TextStyle(
              color: trophyColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            hasEntry ? entry.playerName : 'open slot',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required GamifyLeaderboardEntry entry,
  }) {
    final rank = entry.rank > 0 ? entry.rank : (_entries.indexOf(entry) + 1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFEEF2FF),
            child: Text(
              '$rank',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF3730A3),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.subjectSummary,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.score}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'points',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.leaderboard, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No scores yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Finish a game run to appear on the leaderboard.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
