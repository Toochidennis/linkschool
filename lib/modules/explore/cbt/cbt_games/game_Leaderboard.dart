import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/back_navigation_interstitial_helper.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/gamify_ad_manager.dart';
import 'package:linkschool/modules/services/explore/gamify_leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final bool? fromChallenge;
  final bool? fromGameDashboard;
  final int? challengeId;

  const LeaderboardScreen({
    super.key,
    this.fromChallenge,
    this.fromGameDashboard,
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
  bool _loading = true;
  List<GamifyLeaderboardEntry> _entries = const [];
  bool _allowRoutePop = false;
  bool _isHandlingBackNavigation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await GamifyAdManager.instance.preloadAll(context);
      await _loadLeaderboard();
    });
  }

  Future<void> _loadLeaderboard() async {
    final entries = await _leaderboardService.getEntries();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowRoutePop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _allowRoutePop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
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
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No gamify scores yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ..._entries.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildLeaderboardItem(
                                rank: index + 1,
                                entry: item,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required GamifyLeaderboardEntry entry,
  }) {
    final isTopThree = rank <= 3;
    final accent = switch (rank) {
      1 => const Color(0xFFFFB800),
      2 => const Color(0xFFB8C2CC),
      3 => const Color(0xFFE38B2C),
      _ => const Color(0xFF8B5CF6),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: 0.28),
          width: isTopThree ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: accent.withValues(alpha: 0.14),
            child: Text(
              '$rank',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subjectSummary,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMetaChip('Overall ${entry.score}'),
                    _buildMetaChip('Level ${entry.levelReached}'),
                    _buildMetaChip('Correct ${entry.correctAnswers}'),
                    _buildMetaChip('Subjects ${entry.subjectsPlayedCount}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
