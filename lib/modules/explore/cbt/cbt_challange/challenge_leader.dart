import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_leader_provider.dart';
import 'package:provider/provider.dart';

class ChallengeLeader extends StatefulWidget {
  final bool? fromChallenge;
  final bool? fromGameDashboard;
  final int? challengeId;
  final bool? fromChallengeCompletion; // New parameter to track if coming from challenge completion

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

class _ChallengeLeaderState extends State<ChallengeLeader> {
  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (widget.fromChallengeCompletion == true) {
              // Coming from StartChallenge after completing challenge - pop 3 times to reach join_challange
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            } else if (widget.fromChallenge == true) {
              // Coming directly from join_challange (viewing leaderboard) - pop once
              Navigator.of(context).pop();
            } else {
              // Other cases - pop 3 times
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
        ),
        title:  Text(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          // Separate top 3 and rest
          final top3 = leaderboard.take(3).toList();
          final rest = leaderboard.skip(3).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top 3 Winners
                  if (top3.length >= 3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTopWinner(
                          rank: 2,
                          name: top3[1].username,
                          points: '${top3[1].score} points',
                          image: '',
                          borderColor: Colors.grey[300]!,
                        ),
                        _buildTopWinner(
                          rank: 1,
                          name: top3[0].username,
                          points: '${top3[0].score} points',
                          image: '',
                          borderColor: const Color(0xFF8B5CF6),
                        ),
                        _buildTopWinner(
                          rank: 3,
                          name: top3[2].username,
                          points: '${top3[2].score} points',
                          image: '',
                          borderColor: Colors.orange,
                        ),
                      ],
                    )
                  else if (top3.isNotEmpty)
                    // Show available top winners
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: top3
                          .map((entry) => _buildTopWinner(
                                rank: entry.position,
                                name: entry.username,
                                points: '${entry.score} points',
                                image: '',
                                borderColor: entry.position == 1
                                    ? const Color(0xFF8B5CF6)
                                    : entry.position == 2
                                        ? Colors.grey[300]!
                                        : Colors.orange,
                              ))
                          .toList(),
                    ),

                  const SizedBox(height: 24),

                  // Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 40,
                            child: Text('Rank',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12))),
                        Expanded(
                            child: Text('Player',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12))),
                        Text('Points',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),

                  // Leaderboard List
                  ...rest
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildLeaderboardItem(
                              entry.position,
                              entry.username,
                              '${entry.score} points',
                              '',
                            ),
                          ))
                      ,
                ],
              ),
            ),
          );
        },
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
                top: -10,
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
