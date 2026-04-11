import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/back_navigation_interstitial_helper.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_Leaderboard.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_subject_download_screen.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/gamify_ad_manager.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/explore/gamify_leaderboard_service.dart';
import 'package:provider/provider.dart';

class GameDashboardScreen extends StatefulWidget {
  final List<SubjectModel> subjects;
  final int examTypeId;

  const GameDashboardScreen({
    super.key,
    required this.subjects,
    required this.examTypeId,
  });

  @override
  State<GameDashboardScreen> createState() => _GameDashboardScreenState();
}

class _GameDashboardScreenState extends State<GameDashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const int _startingLives = 5;

  final GamifyLeaderboardService _leaderboardService =
      GamifyLeaderboardService();

  late final AnimationController _ambientController;
  late final AnimationController _startCardController;
  late final AnimationController _startButtonConfettiController;

  bool _shouldShowAppOpenOnResume = false;
  bool _loading = true;
  bool _allowRoutePop = false;
  bool _isHandlingBackNavigation = false;

  String _playerName = 'Player';
  int _playerScore = 0;
  int _gamesPlayed = 0;
  int _playerRank = 0;
  List<GamifyLeaderboardEntry> _leaderboardEntries = const [];
  List<_SubjectArenaCardData> _subjectCards = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _startCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _startButtonConfettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await GamifyAdManager.instance.preloadAll(context);
      await _loadDashboardData();
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ambientController.dispose();
    _startCardController.dispose();
    _startButtonConfettiController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final playerName = _resolvePlayerName();
    final entries = await _leaderboardService.getEntries();

    if (!mounted) return;

    final playerIndex = entries.indexWhere(
      (entry) => _normalized(entry.playerName) == _normalized(playerName),
    );
    final playerEntry = playerIndex >= 0 ? entries[playerIndex] : null;

    setState(() {
      _playerName = playerName;
      _leaderboardEntries = entries;
      _playerScore = playerEntry?.score ?? 0;
      _gamesPlayed = playerEntry?.gamesPlayed ?? 0;
      _playerRank = playerIndex >= 0 ? playerIndex + 1 : 0;
      _subjectCards = _buildSubjectCards(entries);
      _loading = false;
    });
  }

  String _resolvePlayerName() {
    final user =
        Provider.of<CbtUserProvider>(context, listen: false).currentUser;
    return user?.displayName ?? 'Player';
  }

  String _normalized(String value) => value.trim().toLowerCase();

  List<_SubjectArenaCardData> _buildSubjectCards(
    List<GamifyLeaderboardEntry> entries,
  ) {
    final subjectScores = <String, List<int>>{};

    for (final entry in entries) {
      final scoreMap = entry.subjectScores.isNotEmpty
          ? entry.subjectScores
          : <String, int>{entry.subject: entry.score};

      for (final item in scoreMap.entries) {
        final subject = item.key.trim();
        if (subject.isEmpty) continue;
        subjectScores.putIfAbsent(subject, () => <int>[]).add(item.value);
      }
    }

    final subjectNames = <String>{
      ...widget.subjects.map((subject) => subject.name.trim()).where(
            (value) => value.isNotEmpty,
          ),
      ...subjectScores.keys,
    }.toList(growable: false);

    final cards = subjectNames.map((subject) {
      final scores = List<int>.from(subjectScores[subject] ?? const <int>[])
        ..sort((a, b) => b.compareTo(a));
      final theme = _subjectTheme(subject);

      return _SubjectArenaCardData(
        subject: subject,
        color: theme.color,
        icon: theme.icon,
        topScores: List<int?>.generate(
          3,
          (index) => index < scores.length ? scores[index] : null,
          growable: false,
        ),
        championScore: scores.isEmpty ? 0 : scores.first,
        contenders: scores.length,
      );
    }).toList(growable: false)
      ..sort((a, b) {
        if (a.hasLeaderboardData != b.hasLeaderboardData) {
          return a.hasLeaderboardData ? -1 : 1;
        }
        return a.subject.toLowerCase().compareTo(b.subject.toLowerCase());
      });

    return cards;
  }

  _SubjectTheme _subjectTheme(String subject) {
    final value = subject.toLowerCase();

    if (value.contains('math')) {
      return const _SubjectTheme(Icons.calculate_rounded, Color(0xFF4F46E5));
    }
    if (value.contains('english')) {
      return const _SubjectTheme(Icons.menu_book_rounded, Color(0xFF059669));
    }
    if (value.contains('physics')) {
      return const _SubjectTheme(Icons.science_rounded, Color(0xFFF59E0B));
    }
    if (value.contains('chem')) {
      return const _SubjectTheme(Icons.biotech_rounded, Color(0xFFEC4899));
    }
    if (value.contains('bio')) {
      return const _SubjectTheme(Icons.eco_rounded, Color(0xFF22C55E));
    }
    if (value.contains('government')) {
      return const _SubjectTheme(
          Icons.account_balance_rounded, Color(0xFF0EA5E9));
    }
    if (value.contains('econ')) {
      return const _SubjectTheme(Icons.attach_money_rounded, Color(0xFF14B8A6));
    }
    if (value.contains('history')) {
      return const _SubjectTheme(Icons.history_edu_rounded, Color(0xFFF97316));
    }

    return const _SubjectTheme(
        Icons.videogame_asset_rounded, Color(0xFF8B5CF6));
  }

  Future<void> _openLeaderboard() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LeaderboardScreen(fromGameDashboard: true),
      ),
    );

    if (!mounted) return;
    await _loadDashboardData();
  }

  Future<void> _openStartGame() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameSubjectDownloadScreen(
          subjects: widget.subjects,
          examTypeId: widget.examTypeId,
        ),
      ),
    );

    if (!mounted) return;
    await _loadDashboardData();
  }

  Future<void> _handleBackNavigation() async {
    if (_isHandlingBackNavigation) return;
    _isHandlingBackNavigation = true;
    if (mounted) {
      setState(() => _allowRoutePop = true);
    }
    await popThenShowInterstitial(
      popNavigation: () => Navigator.pop(context),
      showInterstitial: (targetContext) =>
          GamifyAdManager.instance.showInterstitialIfEligible(
        context: targetContext,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowRoutePop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _allowRoutePop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5EF),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFAF4),
                Color(0xFFF8F5EF),
                Color(0xFFF4F8FF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                  child: _buildHeader(),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadDashboardData,
                    color: const Color(0xFFFBBF24),
                    backgroundColor: const Color(0xFF132238),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroSection(),
                          const SizedBox(height: 20),
                          _buildStartGameCard(),
                          const SizedBox(height: 28),
                          _buildSectionHeader(
                            title: 'Top Podium',
                            subtitle:
                                'Trophy slots light up from real gamify scores.',
                            actionLabel: 'Full leaderboard',
                            onTap: _openLeaderboard,
                          ),
                          const SizedBox(height: 14),
                          _buildTopPodium(),
                          const SizedBox(height: 28),
                          _buildSectionHeader(
                            title: 'Subject Arenas',
                            subtitle:
                                'Each card uses your actual downloaded subjects.',
                          ),
                          const SizedBox(height: 14),
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else
                            _buildSubjectArenaGrid(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildGlassButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: _handleBackNavigation,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Gamify Arena',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        _buildPlayerBadge(),
      ],
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final glow =
            0.55 + (math.sin(_ambientController.value * math.pi * 2) * 0.12);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF0DF),
                Color(0xFFFDE7EF),
                Color(0xFFEAF3FF),
              ],
            ),
            border: Border.all(
              color: Color(0xFFECD9C7),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B)
                    .withValues(alpha: 0.08 + glow * 0.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned(
                  left: -20,
                  top: -18,
                  child: _buildGlowOrb(
                    diameter: 140,
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  ),
                ),
                Positioned(
                  right: -35,
                  bottom: -42,
                  child: _buildGlowOrb(
                    diameter: 170,
                    color: const Color(0xFF60A5FA).withValues(alpha: 0.12),
                  ),
                ),
                Positioned(
                  right: 22,
                  top: 18,
                  child: Transform.rotate(
                    angle: _ambientController.value * math.pi * 2,
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE5D5C6),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: Color(0xFFFBBF24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _gamesPlayed == 0
                                  ? 'First run waiting'
                                  : '$_gamesPlayed runs completed',
                              style: const TextStyle(
                                color: Color(0xFF92400E),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildPrimaryStatCard(
                              icon: Icons.stars_rounded,
                              label: 'Score',
                              value: '$_playerScore',
                              accent: const Color(0xFFFBBF24),
                              helper: _gamesPlayed == 0
                                  ? 'Finish a run to bank points'
                                  : 'All saved gamify points',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                _buildCompactStatCard(
                                  icon: Icons.favorite_rounded,
                                  label: 'Lives',
                                  value: '$_startingLives',
                                  accent: const Color(0xFFFB7185),
                                ),
                                const SizedBox(height: 12),
                                _buildCompactStatCard(
                                  icon: Icons.emoji_events_rounded,
                                  label: 'Rank',
                                  value:
                                      _playerRank == 0 ? '--' : '#$_playerRank',
                                  accent: const Color(0xFF60A5FA),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartGameCard() {
    return AnimatedBuilder(
      animation: _startCardController,
      builder: (context, child) {
        final bob = math.sin(_startCardController.value * math.pi) * 7;
        final glow =
            0.26 + (math.sin(_startCardController.value * math.pi) * 0.12);

        return Transform.translate(
          offset: Offset(0, -bob),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: _openStartGame,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFFDB2777),
                    Color(0xFFF97316),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDB2777).withValues(alpha: glow),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -18,
                    top: -18,
                    child: _buildGlowOrb(
                      diameter: 120,
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  Positioned(
                    right: 28,
                    bottom: 20,
                    child: Transform.rotate(
                      angle: -0.18,
                      child: Icon(
                        Icons.sports_esports_rounded,
                        size: 92,
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Drop into a new run',
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFF8F1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.subjects.isEmpty
                            ? 'No downloaded subjects found yet.'
                            : 'Pick from ${widget.subjects.length} downloaded subjects, build streaks, and feed the leaderboard.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 74),
                      _buildStartGameButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopPodium() {
    final topThree = List<GamifyLeaderboardEntry?>.generate(
      3,
      (index) => index < _leaderboardEntries.length
          ? _leaderboardEntries[index]
          : null,
      growable: false,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildPodiumCard(
            rank: 2,
            height: 168,
            entry: topThree[1],
            trophyColor: const Color(0xFFD1D5DB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPodiumCard(
            rank: 1,
            height: 196,
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
    final compactCard = height <= 168;

    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(
        compactCard ? 10 : 14,
        compactCard ? 12 : 18,
        compactCard ? 10 : 14,
        compactCard ? 10 : 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
        boxShadow: [
          BoxShadow(
            color: trophyColor.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final small = constraints.maxHeight < 132;
          return Column(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: trophyColor,
                size: small ? (rank == 1 ? 24 : 22) : (rank == 1 ? 34 : 30),
              ),
              SizedBox(height: small ? 4 : 10),
              Text(
                '#$rank',
                style: TextStyle(
                  color: const Color(0xFF1F2937),
                  fontSize:
                      small ? (rank == 1 ? 18 : 16) : (rank == 1 ? 24 : 20),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  hasEntry ? '${entry.score}' : '--',
                  style: TextStyle(
                    color: trophyColor,
                    fontSize:
                        small ? (rank == 1 ? 22 : 20) : (rank == 1 ? 28 : 24),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: small ? 2 : 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    hasEntry ? 'points' : 'open slot',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontSize: small ? 10 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubjectArenaGrid() {
    if (_subjectCards.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE7DFD3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          'No subject arenas available yet. Download a subject and start your first run.',
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 14,
            height: 1.45,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;
        final columns = isWide ? 2 : 1;
        const spacing = 14.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _subjectCards.map((card) {
            return SizedBox(
              width: itemWidth,
              child: _buildSubjectArenaCard(card),
            );
          }).toList(growable: false),
        );
      },
    );
  }

  Widget _buildSubjectArenaCard(_SubjectArenaCardData card) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            card.color.withValues(alpha: 0.14),
            Colors.white,
          ],
        ),
        border: Border.all(
          color: card.color.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: card.color.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return Padding(
            padding: EdgeInsets.all(compact ? 14 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: compact ? 40 : 46,
                      height: compact ? 40 : 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(compact ? 14 : 16),
                        color: card.color.withValues(alpha: 0.20),
                      ),
                      child: Icon(
                        card.icon,
                        color: card.color,
                        size: compact ? 20 : 24,
                      ),
                    ),
                    SizedBox(width: compact ? 10 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            card.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF1F2937),
                              fontSize: compact ? 15 : 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            card.hasLeaderboardData
                                ? '${card.contenders} players have posted here'
                                : 'No scores saved for this arena yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF6B7280),
                              fontSize: compact ? 11 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 12 : 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildArenaMetaCard(
                        label: 'Champion',
                        value: card.hasLeaderboardData
                            ? '${card.championScore}'
                            : '--',
                        compact: compact,
                      ),
                    ),
                    SizedBox(width: compact ? 8 : 10),
                    Expanded(
                      child: _buildArenaMetaCard(
                        label: 'Contenders',
                        value: '${card.contenders}',
                        compact: compact,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 10 : 14),
                Row(
                  children: List<Widget>.generate(3, (index) {
                    final medalColor = switch (index) {
                      0 => const Color(0xFFFBBF24),
                      1 => const Color(0xFFD1D5DB),
                      _ => const Color(0xFFFB923C),
                    };

                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index == 2 ? 0 : (compact ? 6 : 8),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: compact ? 8 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: medalColor.withValues(alpha: 0.10),
                          borderRadius:
                              BorderRadius.circular(compact ? 12 : 16),
                          border: Border.all(
                            color: medalColor.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: medalColor,
                              size: compact ? 16 : 20,
                            ),
                            SizedBox(height: compact ? 4 : 6),
                            Text(
                              card.topScores[index]?.toString() ?? '--',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF1F2937),
                                fontSize: compact ? 11 : 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFBBF24),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DFD3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFFFB86C),
            child: Text(
              _initials(_playerName),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _firstName(_playerName),
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7DFD3)),
          ),
          child: Icon(icon, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }

  Widget _buildPrimaryStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
    required String helper,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartGameButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _startCardController,
        _startButtonConfettiController,
      ]),
      builder: (context, child) {
        final pulse =
            1 + (math.sin(_startCardController.value * math.pi) * 0.03);
        final iconShift = math.sin(_startCardController.value * math.pi) * 3;

        return Transform.scale(
          scale: pulse,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openStartGame,
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.85),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.35),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                      blurRadius: 48,
                      offset: const Offset(0, 24),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _StartButtonConfettiPainter(
                              progress: _startButtonConfettiController.value,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Text(
                                'Start Game',
                                style: TextStyle(
                                  color: Color(0xFF78350F),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 26,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(iconShift, 0),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF78350F),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color(0xFFFBBF24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArenaMetaCard({
    required String label,
    required String value,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF1F2937),
              fontSize: compact ? 15 : 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: compact ? 1 : 2),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb({
    required double diameter,
    required Color color,
  }) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return 'PL';
    if (parts.length == 1) {
      return parts.first
          .substring(0, math.min(2, parts.first.length))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  String _firstName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Player';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}

class _SubjectTheme {
  final IconData icon;
  final Color color;

  const _SubjectTheme(this.icon, this.color);
}

class _SubjectArenaCardData {
  final String subject;
  final Color color;
  final IconData icon;
  final List<int?> topScores;
  final int championScore;
  final int contenders;

  const _SubjectArenaCardData({
    required this.subject,
    required this.color,
    required this.icon,
    required this.topScores,
    required this.championScore,
    required this.contenders,
  });

  bool get hasLeaderboardData => topScores.any((score) => score != null);
}

class _StartButtonConfettiPainter extends CustomPainter {
  final double progress;

  const _StartButtonConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final colors = [
      const Color(0xFFF59E0B),
      const Color(0xFFF97316),
      const Color(0xFFDB2777),
      const Color(0xFF7C3AED),
    ];

    for (int i = 0; i < 16; i++) {
      final lane = i % 8;
      final x = ((lane + 0.5) / 8) * size.width;
      final offset = (i * 0.13) % 1.0;
      final y = ((progress + offset) % 1.0) * (size.height + 28) - 20;
      final drift = math.sin((progress * math.pi * 2) + i) * 8;
      final alpha = (0.18 + ((i % 4) * 0.08)).clamp(0.0, 1.0);

      paint.color = colors[i % colors.length].withValues(alpha: alpha);

      canvas.save();
      canvas.translate(x + drift, y);
      canvas.rotate((progress * math.pi * 2) + (i * 0.35));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-3, -6, 6, 12),
          const Radius.circular(3),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _StartButtonConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
