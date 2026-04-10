import 'dart:math' as math;

import 'package:flutter/material.dart';
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

  bool _shouldShowAppOpenOnResume = false;
  bool _loading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111F),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF081120),
              Color(0xFF0C1830),
              Color(0xFF09101C),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: const Color(0xFFFBBF24),
            backgroundColor: const Color(0xFF132238),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildHeroSection(),
                  const SizedBox(height: 20),
                  _buildStartGameCard(),
                  const SizedBox(height: 28),
                  _buildSectionHeader(
                    title: 'Top Podium',
                    subtitle: 'Trophy slots light up from real gamify scores.',
                    actionLabel: 'Full leaderboard',
                    onTap: _openLeaderboard,
                  ),
                  const SizedBox(height: 14),
                  _buildTopPodium(),
                  const SizedBox(height: 28),
                  _buildSectionHeader(
                    title: 'Subject Arenas',
                    subtitle: 'Each card uses your actual downloaded subjects.',
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
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildGlassButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gamify Arena',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                'Play offline. Climb the local board.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
                Color(0xFF12233A),
                Color(0xFF10213C),
                Color(0xFF191A39),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8)
                    .withValues(alpha: 0.10 + glow * 0.10),
                blurRadius: 32,
                offset: const Offset(0, 16),
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
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                  ),
                ),
                Positioned(
                  right: -35,
                  bottom: -42,
                  child: _buildGlowOrb(
                    diameter: 170,
                    color: const Color(0xFFF472B6).withValues(alpha: 0.16),
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
                          color: Colors.white.withValues(alpha: 0.10),
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
                          color: Colors.white.withValues(alpha: 0.08),
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
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _gamesPlayed == 0
                            ? 'Let us get your first streak started.'
                            : 'Welcome back, ${_firstName(_playerName)}.',
                        style: const TextStyle(
                          fontSize: 28,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Score and life stats stay pinned up top while the arena cards below pull from your real gamify data.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
                        ),
                        child: const Text(
                          'START GAME',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Drop into a new run',
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.subjects.isEmpty
                            ? 'No downloaded subjects found yet.'
                            : 'Pick from ${widget.subjects.length} downloaded subjects, build streaks, and feed the leaderboard.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildStartChip(
                            icon: Icons.grid_view_rounded,
                            label: '${widget.subjects.length} subjects ready',
                          ),
                          _buildStartChip(
                            icon: Icons.favorite_rounded,
                            label: '$_startingLives lives per run',
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.subjects.isEmpty
                                    ? 'Download subjects to unlock the arena'
                                    : 'Choose a subject and launch',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            trophyColor.withValues(alpha: 0.22),
            const Color(0xFF101C2D),
          ],
        ),
        border: Border.all(
          color: trophyColor.withValues(alpha: 0.30),
          width: 1.4,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: trophyColor,
            size: rank == 1 ? 34 : 30,
          ),
          const SizedBox(height: 10),
          Text(
            '#$rank',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.96),
              fontSize: rank == 1 ? 24 : 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            hasEntry ? '${entry.score}' : '--',
            style: TextStyle(
              color: trophyColor,
              fontSize: rank == 1 ? 28 : 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasEntry ? 'points' : 'open slot',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectArenaGrid() {
    if (_subjectCards.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Text(
          'No subject arenas available yet. Download a subject and start your first run.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 14,
            height: 1.45,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _subjectCards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 2 : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 196,
          ),
          itemBuilder: (context, index) {
            return _buildSubjectArenaCard(_subjectCards[index]);
          },
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
            card.color.withValues(alpha: 0.28),
            const Color(0xFF0E182A),
          ],
        ),
        border: Border.all(
          color: card.color.withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: card.color.withValues(alpha: 0.20),
                  ),
                  child: Icon(card.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        card.hasLeaderboardData
                            ? '${card.contenders} players have posted here'
                            : 'No scores saved for this arena yet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.66),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: _buildArenaMetaCard(
                    label: 'Champion',
                    value: card.hasLeaderboardData
                        ? '${card.championScore}'
                        : '--',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildArenaMetaCard(
                    label: 'Contenders',
                    value: '${card.contenders}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: List<Widget>.generate(3, (index) {
                final medalColor = switch (index) {
                  0 => const Color(0xFFFBBF24),
                  1 => const Color(0xFFD1D5DB),
                  _ => const Color(0xFFFB923C),
                };

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
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
                          size: 20,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          card.topScores[index]?.toString() ?? '--',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.64),
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
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF60A5FA),
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
              color: Colors.white,
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
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: Colors.white),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 24),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            helper,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.54),
              fontSize: 12,
              height: 1.35,
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
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
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

  Widget _buildStartChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArenaMetaCard({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 11,
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
