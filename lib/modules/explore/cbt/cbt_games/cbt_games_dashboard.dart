import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_Leaderboard.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_subject_modal.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late PageController _pageController;
  int _currentPage = 0;

  final bool fromGameDashboard = true;

  // Sample subject leaderboard data
  final List<Map<String, dynamic>> _subjectLeaderboards = [
    {
      'subject': 'Mathematics',
      'icon': Icons.calculate,
      'color': const Color(0xFF6366F1),
      'leaders': [
        {'name': 'David Chen', 'points': 2400, 'rank': 1},
        {'name': 'Sarah Johnson', 'points': 2200, 'rank': 2},
        {'name': 'Emma Wilson', 'points': 2100, 'rank': 3},
        {'name': 'Michael Brown', 'points': 1950, 'rank': 4},
      ],
    },
    {
      'subject': 'English',
      'icon': Icons.menu_book,
      'color': const Color(0xFF10B981),
      'leaders': [
        {'name': 'Emma Wilson', 'points': 2300, 'rank': 1},
        {'name': 'Lisa Anderson', 'points': 2150, 'rank': 2},
        {'name': 'James Thompson', 'points': 2000, 'rank': 3},
        {'name': 'Maria Garcia', 'points': 1880, 'rank': 4},
      ],
    },
    {
      'subject': 'Physics',
      'icon': Icons.science,
      'color': const Color(0xFFF59E0B),
      'leaders': [
        {'name': 'Robert Kim', 'points': 2500, 'rank': 1},
        {'name': 'David Chen', 'points': 2350, 'rank': 2},
        {'name': 'Michael Brown', 'points': 2100, 'rank': 3},
        {'name': 'Sarah Johnson', 'points': 1990, 'rank': 4},
      ],
    },
    {
      'subject': 'Chemistry',
      'icon': Icons.biotech,
      'color': const Color(0xFFEC4899),
      'leaders': [
        {'name': 'Lisa Anderson', 'points': 2280, 'rank': 1},
        {'name': 'Emma Wilson', 'points': 2180, 'rank': 2},
        {'name': 'Robert Kim', 'points': 2050, 'rank': 3},
        {'name': 'James Thompson', 'points': 1920, 'rank': 4},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();

    // Lanyard swing animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // fast swing
    )..repeat(reverse: true);

    _rotation = Tween<double>(begin: -0.10, end: 0.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Initialize PageController for swipeable cards
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- HEADER ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // morden back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 30, color: Colors.black87),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildCoinCard(),
                    _buildLanyardStreak(),
                  ],
                ),

                const SizedBox(height: 20),

                // ---------------- MAIN BANNER (SWIPEABLE) ----------------
                _buildSwipeableBanner(),

                const SizedBox(height: 25),

                // ---------------- GENERAL LEADERBOARD HEADER ----------------
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "General Leaderboard",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---------------- General Leaderboard Card ----------------
                _buildGeneralLeaderboard(),

                // _buildMissionTile(
                //     title: "Complete 3 questions",
                //     xp: 20,
                //     progress: 0.33,
                //     icon: Icons.check_circle,
                //     missionColor: const Color(0xFF6366F1)),
                // _buildMissionTile(
                //     title: "Earn 10 XP today",
                //     xp: 10,
                //     progress: 0.5,
                //     icon: Icons.bolt,
                //     missionColor: const Color(0xFF10B981)),
                // _buildMissionTile(
                //     title: "Review one wrong answer",
                //     xp: 15,
                //     progress: 0.1,
                //     icon: Icons.refresh,
                //     missionColor: const Color(0xFFF59E0B)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  //                     WIDGETS
  // ==========================================================

  Widget _buildCoinCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.monetization_on, color: Colors.amber, size: 26),
          SizedBox(width: 6),
          Text(
            "250",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          )
        ],
      ),
    );
  }

  // ---------------- LANYARD STREAK ----------------

  Widget _buildLanyardStreak() {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (_, child) {
        return Transform.rotate(
          angle: _rotation.value,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: Column(
        children: [
          Container(
            width: 3,
            height: 26,
            color: Colors.deepOrangeAccent,
          ),
          const SizedBox(height: 2),
          Container(
            width: 3,
            height: 26,
            color: Colors.deepOrangeAccent,
          ),
          const SizedBox(height: 6),

          // Badge circle
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.shade400,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: const Text(
              "🔥 4",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- MAIN START BANNER ----------------

  Widget _buildSwipeableBanner() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildStartBanner(),
              ..._subjectLeaderboards
                  .map((subjectData) =>
                      _buildSubjectLeaderboardCard(subjectData))
                  .toList(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(1 + _subjectLeaderboards.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.deepPurple
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStartBanner() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// --- GIF BACKGROUND ---
            GifView.asset(
              'assets/images/Gaming.gif',
              fit: BoxFit.cover,
              imageRepeat: ImageRepeat.noRepeat,
              frameRate: 30,
              loop: false,
            ),
            // Image.asset(
            //   "assets/images/Gaming.gif",
            //   fit: BoxFit.cover,
            // ),

            /// --- DARK OVERLAY (optional for readability) ---
            Container(
              color: Colors.blue.withOpacity(0.35),
            ),

            /// --- CONTENT ---

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Start Your Daily Game!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => GameSubjectModal(
                              subjects: widget.subjects,
                              examTypeId: widget.examTypeId,
                            ),
                          );
                        },
                        child: const Text(
                          " Start",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
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
  }

  // ---------------- MISSION TILE ----------------

  Widget _buildMissionTile({
    required String title,
    required int xp,
    required double progress,
    required IconData icon,
    required Color missionColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: missionColor,
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 12),

          // Text + Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: missionColor,
                  minHeight: 6,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // XP Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: missionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "+$xp XP",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: missionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SUBJECT LEADERBOARD CARD ----------------

  Widget _buildSubjectLeaderboardCard(Map<String, dynamic> subjectData) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            subjectData['color'] as Color,
            (subjectData['color'] as Color).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (subjectData['color'] as Color).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with subject name and icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    subjectData['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${subjectData['subject']} Leaders',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Top performers this week',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LeaderboardScreen(fromGameDashboard: true),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: subjectData['color'] as Color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top 3 leaders
            Expanded(
              child: ListView.builder(
                // physics: FixedExtentScrollPhysics(),
                itemCount: min(3, (subjectData['leaders'] as List).length),
                itemBuilder: (context, index) {
                  final leader = (subjectData['leaders'] as List)[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Rank badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${leader['rank']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: subjectData['color'] as Color,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Avatar
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Text(
                            (leader['name'] as String)
                                .split(' ')
                                .map((e) => e[0])
                                .join(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Name
                        Expanded(
                          child: Text(
                            leader['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Points
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${leader['points']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- GENERAL LEADERBOARD (TOP 3 STYLE) ----------------

  Widget _buildGeneralLeaderboard() {
    // Sample general leaderboard data
    final List<Map<String, dynamic>> topPlayers = [
      {
        'name': 'David Chen',
        'points': 7200,
        'avatar': '🏆',
        'rank': 1,
        'color': const Color(0xFFFFD700), // Gold
      },
      {
        'name': 'Emma Wilson',
        'points': 6800,
        'avatar': '🥈',
        'rank': 2,
        'color': const Color(0xFFC0C0C0), // Silver
      },
      {
        'name': 'Robert Kim',
        'points': 6500,
        'avatar': '🥉',
        'rank': 3,
        'color': const Color(0xFFCD7F32), // Bronze
      },
    ];

    final List<Map<String, dynamic>> otherPlayers = [
      {'name': 'Sarah Johnson', 'points': 6200, 'rank': 4},
      {'name': 'Michael Brown', 'points': 5950, 'rank': 5},
      {'name': 'Lisa Anderson', 'points': 5800, 'rank': 6},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top 3 Winners Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 2nd Place
              _buildTopWinner(
                rank: 2,
                name: topPlayers[1]['name'] as String,
                points: '${topPlayers[1]['points']} pts',
                avatar: topPlayers[1]['avatar'] as String,
                borderColor: topPlayers[1]['color'] as Color,
                isFirst: false,
              ),
              // 1st Place (larger)
              _buildTopWinner(
                rank: 1,
                name: topPlayers[0]['name'] as String,
                points: '${topPlayers[0]['points']} pts',
                avatar: topPlayers[0]['avatar'] as String,
                borderColor: topPlayers[0]['color'] as Color,
                isFirst: true,
              ),
              // 3rd Place
              _buildTopWinner(
                rank: 3,
                name: topPlayers[2]['name'] as String,
                points: '${topPlayers[2]['points']} pts',
                avatar: topPlayers[2]['avatar'] as String,
                borderColor: topPlayers[2]['color'] as Color,
                isFirst: false,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Divider
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),

          // Other Players Section
          ...otherPlayers.map((player) {
            return TweenAnimationBuilder(
              duration:
                  Duration(milliseconds: 400 + (player['rank'] as int) * 50),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${player['rank']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Text(
                        (player['name'] as String)
                            .split(' ')
                            .map((e) => e[0])
                            .join(),
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name
                    Expanded(
                      child: Text(
                        player['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Points with star icon
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${player['points']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 16),

          // Small "View All" button at bottom right
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LeaderboardScreen(fromGameDashboard: true),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopWinner({
    required int rank,
    required String name,
    required String points,
    required String avatar,
    required Color borderColor,
    required bool isFirst,
  }) {
    final double size = isFirst ? 80.0 : 70.0;
    final double fontSize = isFirst ? 15.0 : 13.0;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            TweenAnimationBuilder(
              duration: Duration(milliseconds: 600 + (rank * 150)),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 3),
                  gradient: LinearGradient(
                    colors: [
                      borderColor,
                      borderColor.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: TextStyle(fontSize: isFirst ? 32 : 28),
                  ),
                ),
              ),
            ),
            if (isFirst)
              Positioned(
                top: -8,
                right: size / 2 - 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name.split(' ')[0], // First name only
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          points,
          style: TextStyle(
            fontSize: fontSize - 2,
            color: borderColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
