import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top 3 Winners
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTopWinner(
                    rank: 2,
                    name: 'Emma Wilson',
                    points: '1430 points',
                    image: 'assets/emma.jpg',
                    borderColor: Colors.grey[300]!,
                  ),
                  _buildTopWinner(
                    rank: 1,
                    name: 'David Chen',
                    points: '1800 points',
                    image: 'assets/david.jpg',
                    borderColor: const Color(0xFF8B5CF6),
                  ),
                  _buildTopWinner(
                    rank: 3,
                    name: 'Sarah Johnson',
                    points: '1200 points',
                    image: 'assets/sarah.jpg',
                    borderColor: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Stats Grid
             
              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text('Rank', style: TextStyle(color: Colors.grey, fontSize: 12))),
                    Expanded(child: Text('Player', style: TextStyle(color: Colors.grey, fontSize: 12))),
                    Text('Points', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              
              // Leaderboard List
              _buildLeaderboardItem(4, 'Michael Rodriguez', '1000 points', 'assets/michael.jpg'),
              const SizedBox(height: 8),
              _buildLeaderboardItem(5, 'Lisa Anderson', '900 points', 'assets/lisa.jpg'),
              const SizedBox(height: 8),
              _buildLeaderboardItem(6, 'James Thompson', '800 points', 'assets/james.jpg'),
              const SizedBox(height: 8),
              _buildLeaderboardItem(7, 'Maria Garcia', '750 points', 'assets/maria.jpg'),
              const SizedBox(height: 8),
              _buildLeaderboardItem(8, 'Robert Kim', '720 points', 'assets/robert.jpg'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopWinner({
    required int rank,
    required String name,
    required String points,
    required String image,
    required Color borderColor,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Text(
                  name.split(' ').map((e) => e[0]).join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (rank == 1)
              Positioned(
               top:-10 ,
                right: 25,
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
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          points,
          style: TextStyle(
            fontSize: 11,
            color: rank == 1 ? const Color(0xFF8B5CF6) : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, String points, String image) {
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