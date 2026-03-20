import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/explore/courses/course_leaderboard_model.dart';
import 'package:linkschool/modules/providers/explore/courses/leaderboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFFFF8EE);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEE5D6);
  static const accent = Color(0xFFE8954A);
  static const accentSoft = Color(0xFFFFF3E8);
  static const gold = Color(0xFFFFB800);
  static const silver = Color(0xFFB0BEC5);
  static const bronze = Color(0xFFCD7F32);
  static const text = Color(0xFF2C1F0E);
  static const textSub = Color(0xFF8C7A60);
  static const textMut = Color(0xFFBBAA90);
  static const line = Color(0xFFF0E4D4);
  static const up = Color(0xFF4CAF50);
  static const neutral = Color(0xFFBBBBBB);
}

// ─── Screen ─────────────────────────────────────────────────────────────────
class LeaderboardScreen extends StatefulWidget {
  final String cohortId;
  final int? profileId;

  const LeaderboardScreen({
    super.key,
    required this.cohortId,
    this.profileId,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  bool _isExiting = false;
  String? _persistedProfileName;

  //int _selectedTab = 2;

  late AnimationController _podiumCtrl;
  late Animation<double> _podiumFade;

  @override
  void initState() {
    super.initState();
    _podiumCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _podiumFade = CurvedAnimation(parent: _podiumCtrl, curve: Curves.easeOut);

    _loadInterstitialAd();
    _loadPersistedProfileName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileId = widget.profileId;
      if (profileId == null) return;
      context.read<CourseLeaderboardProvider>().loadLeaderboard(
            cohortId: widget.cohortId,
            profileId: profileId,
          );
    });
  }

  @override
  void dispose() {
    _podiumCtrl.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _loadPersistedProfileName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? persistedName = prefs.getString('active_profile_name')?.trim();
      if (persistedName != null && persistedName.isEmpty) {
        persistedName = null;
      }
      if (mounted) {
        setState(() {
          _persistedProfileName = persistedName;
        });
      }
    } catch (_) {}
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: EnvConfig.programInterstitialAdsApiKey,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          if (mounted) setState(() => _isInterstitialAdLoaded = true);
        },
        onAdFailedToLoad: (_) {
          if (mounted) setState(() => _isInterstitialAdLoaded = false);
        },
      ),
    );
  }

  Future<void> _restoreSystemUi() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _handleExit() async {
    if (_isExiting) return;
    _isExiting = true;

    void popScreen() {
      if (mounted) Navigator.of(context).pop();
    }

    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) async {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
          await _restoreSystemUi();
          popScreen();
        },
        onAdFailedToShowFullScreenContent: (ad, _) async {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
          await _restoreSystemUi();
          popScreen();
        },
      );
      _interstitialAd!.show();
      return;
    }
    popScreen();
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleExit();
        return false;
      },
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: Consumer<CourseLeaderboardProvider>(
            builder: (context, provider, _) {
              return RefreshIndicator(
                color: _C.accent,
                onRefresh: () => provider.refresh(),
                child: _buildBody(provider),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(CourseLeaderboardProvider provider) {
    final profileId = widget.profileId;
    final entries = provider.leaderboard;
    final currentUserEntry = _buildCurrentUserEntry(provider, entries);

    final rankingEntries = entries.map((e) {
      if (currentUserEntry != null && e.position == currentUserEntry.position) {
        return currentUserEntry;
      }
      return e;
    }).toList();

    if (currentUserEntry != null &&
        !rankingEntries.any((e) => e.position == currentUserEntry.position)) {
      rankingEntries.add(currentUserEntry);
    }

    final top3 = rankingEntries.where((e) => e.position <= 3).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final rest = rankingEntries.where((e) => e.position > 3).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final showCurrentUserAtBottom =
        currentUserEntry != null && currentUserEntry.position > 3;
    final bool userIsInList = currentUserEntry != null &&
    rest.any((e) => e.position == currentUserEntry.position);

final visibleRest = rest.toList(); // keep natural sort always

if (showCurrentUserAtBottom && !userIsInList) {
  visibleRest.add(currentUserEntry!); // only pin to bottom if NOT already in the list
}

    // ── Error / empty / loading states ───────────────────────────────────
    if (profileId == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _topBar(),
          _messageState(
            icon: Icons.person_off_outlined,
            title: 'Profile not available',
            subtitle: 'A valid profile is required to load the leaderboard.',
          ),
        ],
      );
    }

    if (provider.isLoading && provider.leaderboardData == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _topBar(),
          const SizedBox(height: 260),
          const Center(child: CircularProgressIndicator(color: _C.accent)),
        ],
      );
    }

    if (provider.error != null && provider.leaderboardData == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _topBar(),
          _messageState(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load leaderboard',
            subtitle: provider.error!,
            action: TextButton(
              onPressed: provider.refresh,
              child: const Text('Retry', style: TextStyle(color: _C.accent)),
            ),
          ),
        ],
      );
    }

    if (entries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _topBar(),
          _messageState(
            icon: Icons.leaderboard_outlined,
            title: 'No leaderboard data yet',
            subtitle: 'Ranks will appear here when learner activity is available.',
          ),
        ],
      );
    }

    // ── Main content ─────────────────────────────────────────────────────
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        _topBar(),
        FadeTransition(
          opacity: _podiumFade,
          child: _podiumSection(top3, currentUserEntry),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 0, 0, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                      //  SizedBox(width: 74),
                        Expanded(
                          child: Text(
                            'Name',
                            style: TextStyle(
                              color: _C.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Text(
                            'Rank',
                            style: TextStyle(
                              color: _C.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(height: 1, thickness: 1.2, color: _C.line),
                  ],
                ),
              ),
              for (var i = 0; i < visibleRest.length; i++) ...[
               _listRow(
  visibleRest[i],
  isMe: currentUserEntry != null &&
      visibleRest[i].position == currentUserEntry.position,
  index: i,
  isCurrentPositionRow: !userIsInList &&        // ← add this condition
      showCurrentUserAtBottom &&
      i == visibleRest.length - 1 &&
      currentUserEntry != null &&
      visibleRest[i].position == currentUserEntry.position,
),
                if (i != visibleRest.length - 1)
                  const Divider(height: 1, color: _C.line),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─── Top Bar ─────────────────────────────────────────────────────────────

  Widget _topBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        child: Row(
          children: [
            GestureDetector(
              onTap: _handleExit,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: _C.border),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: _C.textSub,
                ),
              ),
            ),
            const Expanded(
              child: Text(
                'Leaderboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _C.text,
                  fontSize: 17,         // standard mobile title
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 38), // symmetry spacer
          ],
        ),
      );

  // ─── Podium ──────────────────────────────────────────────────────────────

  Widget _podiumSection(
      List<LeaderboardEntry> top3, LeaderboardEntry? currentUser) {
    final ordered = <LeaderboardEntry?>[null, null, null];
    for (final e in top3) {
      if (e.position == 1) ordered[1] = e;
      if (e.position == 2) ordered[0] = e;
      if (e.position == 3) ordered[2] = e;
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      color: const Color(0xFFFFF3E0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(child: CustomPaint(painter: _ConfettiPainter())),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2nd — slightly shorter avatar + bar
                _podiumSlot(
                  entry: ordered[0],
                  rank: 2,
                  avatarSize: 58,
                  barHeight: 58,
                  isMe: currentUser != null &&
                      ordered[0]?.position == currentUser.position,
                ),
                const SizedBox(width: 10),
                // 1st — tallest
                _podiumSlot(
                  entry: ordered[1],
                  rank: 1,
                  avatarSize: 74,
                  barHeight: 80,
                  isMe: currentUser != null &&
                      ordered[1]?.position == currentUser.position,
                ),
                const SizedBox(width: 10),
                // 3rd — smallest
                _podiumSlot(
                  entry: ordered[2],
                  rank: 3,
                  avatarSize: 52,
                  barHeight: 42,
                  isMe: currentUser != null &&
                      ordered[2]?.position == currentUser.position,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _podiumSlot({
    required LeaderboardEntry? entry,
    required int rank,
    required double avatarSize,
    required double barHeight,
    required bool isMe,
  }) {
    if (entry == null) return const SizedBox(width: 90);

    final rankColor = rank == 1
        ? _C.gold
        : rank == 2
            ? _C.silver
            : _C.bronze;

    final barColor = rank == 1
        ? const Color(0xFFFFD54F)
        : rank == 2
            ? const Color(0xFFCFD8DC)
            : const Color(0xFFD7A97E);

    return SizedBox(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown above 1st, blank space for others
          if (rank == 1)
            const Text('👑', style: TextStyle(fontSize: 16))
          else
            const SizedBox(height: 22),

          const SizedBox(height: 4),

          // Avatar circle + rank badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rankColor.withOpacity(0.14),
                  border: Border.all(color: rankColor, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    _initials(entry.name),
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 12,  // always proportional
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Container(
                width: 19,
                height: 19,
                decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$rank ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,      // tiny badge numeral
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // First name
          Text(
            _capitalizeName(entry.name),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _C.text,
              fontSize: 14,       // caption size — compact
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // Podium bar
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,     // compact label on bar
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── List Row ────────────────────────────────────────────────────────────

  Widget _listRow(
  LeaderboardEntry player, {
  required bool isMe,
  required int index,
  bool isCurrentPositionRow = false,
}) {
  final avatarColor = _avatarColor(player.position);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: isMe
        ? BoxDecoration(
            color: const Color(0xFFFFF3E8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _C.accent.withOpacity(0.45),
              width: 1.5,
            ),
          )
        : null,
    child: Stack(
      children: [
        // Left accent bar — only for current user
        if (isMe)
          Positioned(
            left: 0,
            top: 6,
            bottom: 6,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: _C.accent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

        Padding(
          padding: EdgeInsets.only(left: isMe ? 10 : 0),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Solid fill for "me", tinted for others
                  color: isMe
                      ? _C.accent
                      : avatarColor.withOpacity(0.13),
                  border: Border.all(
                    color: isMe ? Colors.white : avatarColor.withOpacity(0.4),
                    width: isMe ? 2 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials(player.name),
                    style: TextStyle(
                      color: isMe ? Colors.white : avatarColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Name block
              Expanded(
                child: isMe
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                          Text(
                            isCurrentPositionRow
                                ? 'Your current position'
                                : _capitalizeName(player.name),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                               color: _C.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                           Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _C.accent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'You',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                        ],
                      )
                    : Text(
                        _capitalizeName(player.name),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _C.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(width: 10),

              // Rank
              Text(
                '#${player.position}',
                style: TextStyle(
                  color: isMe ? _C.accent : _C.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // ─── My Rank Footer ──────────────────────────────────────────────────────

  Widget _myRankFooter(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.accent.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _C.accent.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.accentSoft,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _C.accent.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              '${entry.position}',
              style: const TextStyle(
                color: _C.accent,
                fontSize: 13,     // standard
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Your current rank',
              style: TextStyle(
                color: _C.text,
                fontSize: 14,     // standard body
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // if (entry.score != null)
          //   Text(
          //     '${entry.score} pts',
          //     style: const TextStyle(
          //       color: _C.accent,
          //       fontSize: 12,
          //       fontWeight: FontWeight.w700,
          //     ),
          //   ),
        ],
      ),
    );
  }

  // ─── Empty / Error State ─────────────────────────────────────────────────

  Widget _messageState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
      child: Column(
        children: [
          Icon(icon, color: _C.accent, size: 44),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _C.text,
              fontSize: 16,       // standard headline
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _C.textSub,
              fontSize: 13,       // standard body
              height: 1.4,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 16), action],
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  LeaderboardEntry? _buildCurrentUserEntry(
      CourseLeaderboardProvider provider,
    List<LeaderboardEntry> entries,
  ) {
    final profilePosition = provider.profilePosition;
    if (profilePosition == null) return null;

    for (final entry in entries) {
      if (entry.position == profilePosition) {
        if (entry.name.trim().isNotEmpty) {
          return entry;
        }
        final fallbackName = _persistedProfileName?.trim();
        if (fallbackName == null || fallbackName.isEmpty) {
          return entry;
        }
        return LeaderboardEntry(
          position: entry.position,
          name: fallbackName,
        );
      }
    }

    final fallbackName = _persistedProfileName?.trim();
    return LeaderboardEntry(
      position: profilePosition,
      name: (fallbackName == null || fallbackName.isEmpty)
          ? 'Your current position'
          : fallbackName,
    );
  }

  // String _profileName(CbtUserProfile profile) {
  //   final first = profile.firstName?.trim() ?? '';
  //   final last = profile.lastName?.trim() ?? '';
  //   final name = '$first $last'.trim();
  //   if (name.isNotEmpty) return _capitalizeName(name);
  //   if (profile.id != null) return 'Profile ${profile.id}';
  //   return 'Profile';
  // }

  String _capitalizeName(String name) {
    return name
        .trim()
        .split(' ')
        .map((w) => w.isEmpty
            ? ''
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _avatarColor(int position) {
    const palette = [
      Color(0xFF5B5FEF),
      Color(0xFFE8954A),
      Color(0xFF00C9A7),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF0EA5E9),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
    ];
    return palette[position % palette.length];
  }
}

// ─── Confetti Painter ────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dots = <List<double>>[
      [0.08, 0.15, 0xFFFFB800, 3.0],
      [0.18, 0.55, 0xFF5B5FEF, 2.5],
      [0.88, 0.12, 0xFFFF7A3D, 3.0],
      [0.78, 0.60, 0xFF00C9A7, 2.5],
      [0.50, 0.08, 0xFFEF4444, 2.5],
      [0.93, 0.40, 0xFFFFB800, 2.0],
      [0.05, 0.75, 0xFF00C9A7, 2.0],
      [0.35, 0.20, 0xFF5B5FEF, 2.0],
      [0.65, 0.70, 0xFFFF7A3D, 2.0],
    ];

    for (final d in dots) {
      final paint = Paint()
        ..color = Color(d[2].toInt()).withOpacity(0.38)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(size.width * d[0], size.height * d[1]),
        d[3],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
