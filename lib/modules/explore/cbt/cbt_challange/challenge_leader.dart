import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/explore/cbt/back_navigation_interstitial_helper.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challenge_ad_manager.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_leader_provider.dart';
import 'package:provider/provider.dart';

class ChallengeLeader extends StatefulWidget {
  final bool? fromChallenge;
  final bool? fromGameDashboard;
  final int? challengeId;
  final bool?
      fromChallengeCompletion; // New parameter to track if coming from challenge completion

  const ChallengeLeader({
    super.key,
    this.fromChallenge,
    this.fromGameDashboard,
    this.challengeId,
    this.fromChallengeCompletion,
  });

  @override
  State<ChallengeLeader> createState() => _ChallengeLeaderState();
}

class _ChallengeLeaderState extends State<ChallengeLeader>
    with WidgetsBindingObserver {
  bool _shouldShowAppOpenOnResume = false;
  bool _allowRoutePop = false;
  bool _isHandlingBackNavigation = false;

  // Banner ad — loaded once, persisted for the lifetime of the screen
  BannerAd? _bannerAd;
  bool _bannerAdLoaded = false;
  int _bannerAdUnitIndex = 0;
  int _bannerAdRetry = 0;

  static const String _unsetEnvValue = '__SET_VIA_DART_DEFINE__';

  List<String> get _bannerAdUnitIds {
    return [
      EnvConfig.challengeBannerAdKey,
      EnvConfig.discussionBannerAdKey,
      EnvConfig.homeBannerAdKey,
      EnvConfig.googleBannerAdsApiKey,
    ].where((id) => id.isNotEmpty && id != _unsetEnvValue).toList();
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBannerAd();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ChallengeAdManager.instance.preloadAll(context);
    });

    // Load leaderboard data when screen opens
    if (widget.challengeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<LeaderboardProvider>()
            .loadLeaderboard(widget.challengeId!);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) &&
        !ChallengeAdManager.instance.isPresentingFullscreenAd) {
      _shouldShowAppOpenOnResume = true;
    } else if (state == AppLifecycleState.resumed &&
        _shouldShowAppOpenOnResume) {
      _shouldShowAppOpenOnResume = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await ChallengeAdManager.instance.showAppOpenIfEligible(
          context: context,
        );
      });
    }
  }

  Future<void> _handleBack() async {
    if (_isHandlingBackNavigation) return;
    _isHandlingBackNavigation = true;
    if (mounted) {
      setState(() => _allowRoutePop = true);
    }

    final navigator = Navigator.of(context);
    await popThenShowInterstitial(
      popNavigation: () {
        if (widget.fromChallengeCompletion == true) {
          navigator.pop();
          navigator.pop();
          navigator.pop();
        } else if (widget.fromChallenge == true) {
          navigator.pop();
        } else {
          navigator.pop();
          navigator.pop();
          navigator.pop();
        }
      },
      showInterstitial: (targetContext) =>
          ChallengeAdManager.instance.showInterstitialIfEligible(
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
            onPressed: () async {
              await _handleBack();
            },
          ),
          title: Text(
            'Leaderboard',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<LeaderboardProvider>(
          builder: (context, provider, child) {
            if (provider.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load leaderboard',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.challengeId != null) {
                          provider.loadLeaderboard(widget.challengeId!);
                        }
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final leaderboard = provider.leaderboard;

            if (leaderboard.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No leaderboard data yet',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }

            // Separate top 3 and rest
            final top3 = leaderboard.take(3).toList();
            final rest = leaderboard.skip(3).toList();

            final topThree = List.generate(
              3,
              (i) => i < top3.length ? top3[i] : null,
            );

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    // Top 3 podium
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _buildPodiumCard(
                            rank: 2,
                            height: 164,
                            name: topThree[1]?.username,
                            score: topThree[1]?.score,
                            trophyColor: const Color(0xFFD1D5DB),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPodiumCard(
                            rank: 1,
                            height: 190,
                            name: topThree[0]?.username,
                            score: topThree[0]?.score,
                            trophyColor: const Color(0xFFFBBF24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPodiumCard(
                            rank: 3,
                            height: 148,
                            name: topThree[2]?.username,
                            score: topThree[2]?.score,
                            trophyColor: const Color(0xFFFB923C),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    _buildBannerAdCard(),
                    const SizedBox(height: 20),

                    // Header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              'Rank',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Player',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          Text(
                            'Points',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // Leaderboard List
                    ...rest.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildLeaderboardItem(
                            entry.position,
                            entry.username,
                            '${entry.score} points',
                            '',
                          ),
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPodiumCard({
    required int rank,
    required double height,
    required String? name,
    required int? score,
    required Color trophyColor,
  }) {
    final hasEntry = name != null && score != null;

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
            hasEntry ? '$score' : '--',
            style: TextStyle(
              color: trophyColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            hasEntry ? name : 'open slot',
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

  Widget _buildBannerAdCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
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
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: _bannerAdLoaded && _bannerAd != null
              ? Center(
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                )
              : const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
      int rank, String name, String points, String image) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Text(
              name.split(' ').map((e) => e[0]).join(),
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
