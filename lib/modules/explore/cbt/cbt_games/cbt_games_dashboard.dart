import 'dart:math';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_Leaderboard.dart';

class GameDashboardScreen extends StatefulWidget {
  const GameDashboardScreen({super.key});

  @override
  State<GameDashboardScreen> createState() => _GameDashboardScreenState();
}

class _GameDashboardScreenState extends State<GameDashboardScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _rotation;

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
  }

  @override
  void dispose() {
    _controller.dispose();
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

                // ---------------- MAIN BANNER ----------------
                _buildStartBanner(),

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
          Image.asset(
            "assets/images/Gaming.gif",
            fit: BoxFit.cover,
          ),

          /// --- DARK OVERLAY (optional for readability) ---
          Container(
            color: Colors.blue.withOpacity(0.35),
          ),

          /// --- CONTENT ---
      
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      const Text(
                        "Start Your Daily Game!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaderboardScreen(),
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
                      )
                    ],
                  ),
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
}
