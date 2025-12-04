import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_Leaderboard.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_subject_modal.dart';

class GameDashboardScreen extends StatefulWidget {
  const GameDashboardScreen({super.key});

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
                    _buildCoinCard(),
                    _buildLanyardStreak(),
                  ],
                ),

                const SizedBox(height: 20),

                // ---------------- MAIN BANNER (SWIPEABLE) ----------------
                _buildSwipeableBanner(),

                const SizedBox(height: 25),

                // ---------------- MISSIONS HEADER ----------------
                Row(
                  children: const [
                    Icon(Icons.flag, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      "Missions",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ---------------- MISSIONS LIST ----------------
                _buildMissionTile(
                    title: "Complete 3 questions",
                    xp: 20,
                    progress: 0.33,
                    icon: Icons.check_circle,
                    missionColor: const Color(0xFF6366F1)),
                _buildMissionTile(
                    title: "Earn 10 XP today",
                    xp: 10,
                    progress: 0.5,
                    icon: Icons.bolt,
                    missionColor: const Color(0xFF10B981)),
                _buildMissionTile(
                    title: "Review one wrong answer",
                    xp: 15,
                    progress: 0.1,
                    icon: Icons.refresh,
                    missionColor: const Color(0xFFF59E0B)),
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
              ..._subjectLeaderboards.map((subjectData) => 
                _buildSubjectLeaderboardCard(subjectData)
              ).toList(),
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
                          builder: (context) => const GameSubjectModal(),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        builder: (context) => const LeaderboardScreen(
                         fromGameDashboard: true
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            (leader['name'] as String).split(' ').map((e) => e[0]).join(),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
}
