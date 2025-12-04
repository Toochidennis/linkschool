import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_instruction.dart' ;
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_modal.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/create_challenge.dart';
import 'dart:math' as math;
import 'dart:async';

import 'package:linkschool/modules/explore/cbt/cbt_challange/start_challenge.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_Leaderboard.dart';
import 'package:linkschool/modules/services/explore/manage_storage.dart';

class ModernChallengeScreen extends StatefulWidget {
  const ModernChallengeScreen({super.key});

  @override
  State<ModernChallengeScreen> createState() => _ModernChallengeScreenState();
}

class _ModernChallengeScreenState extends State<ModernChallengeScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Timer _countdownTimer;
  int _selectedFilter = 0;
  final bool fromChallenge = true;

  final List<String> _filters = ['All', 'Daily', 'Weekly', 'Popular'];
    List<ChallengeModel> _savedChallenges = [];

  final List<ChallengeModel> _forYouChallenges = [
    ChallengeModel(
      title: 'Daily Math Challenge',
      description: 'Solve 10 math problems to improve your skills',
      icon: Icons.calculate,
      xp: 50,
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      participants: 1250,
      difficulty: 'Easy',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(hours: 23, minutes: 45)),
    ),
    ChallengeModel(
      title: 'Science Reading Challenge',
      description: 'Read and summarize 2 science articles',
      icon: Icons.science,
      xp: 30,
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
      participants: 890,
      difficulty: 'Medium',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 6, hours: 12, minutes: 30)),
    ),
    ChallengeModel(
      title: 'Speed Typing Master',
      description: 'Type 50 words per minute for 2 minutes',
      icon: Icons.keyboard,
      xp: 40,
      gradient: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      participants: 2100,
      difficulty: 'Hard',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 2, hours: 8, minutes: 15)),
    ),
  ];

  final List<ChallengeModel> _challenges = [
    ChallengeModel(
      title: 'Complete 5 History Quizzes',
      description: 'Test your knowledge of historical events',
      icon: Icons.history_edu,
      xp: 40,
      progress: 0.6,
      gradient: [Color(0xFFEC4899), Color(0xFFF97316)],
      participants: 678,
      difficulty: 'Medium',
      startDate: DateTime.now().subtract(Duration(days: 2)),
      endDate: DateTime.now().add(Duration(days: 4, hours: 18, minutes: 25)),
    ),
    ChallengeModel(
      title: 'Write a 300-word Essay',
      description: 'Compose an essay on a given topic',
      icon: Icons.edit_note,
      xp: 50,
      progress: 0.3,
      gradient: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
      participants: 445,
      difficulty: 'Hard',
      startDate: DateTime.now().subtract(Duration(days: 1)),
      endDate: DateTime.now().add(Duration(days: 9, hours: 5, minutes: 40)),
    ),
    ChallengeModel(
      title: 'Learn 15 New Vocabulary',
      description: 'Expand your English vocabulary',
      icon: Icons.menu_book,
      xp: 25,
      progress: 0.8,
      gradient: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
      participants: 1520,
      difficulty: 'Easy',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 6, hours: 14, minutes: 50)),
    ),
    ChallengeModel(
      title: 'Practice Coding Exercises',
      description: 'Solve programming challenges',
      icon: Icons.code,
      xp: 60,
      progress: 0.2,
      gradient: [Color(0xFF10B981), Color(0xFF14B8A6)],
      participants: 3200,
      difficulty: 'Hard',
      startDate: DateTime.now().subtract(Duration(days: 3)),
      endDate: DateTime.now().add(Duration(days: 13, hours: 22, minutes: 10)),
    ),
    ChallengeModel(
      title: 'Review Biology Notes',
      description: 'Study and review biology concepts',
      icon: Icons.biotech,
      xp: 35,
      progress: 0.5,
      gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      participants: 920,
      difficulty: 'Medium',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 5, hours: 10, minutes: 30)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Update countdown every second
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
       _loadSavedChallenges();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  String _formatCountdown(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return 'Ended';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

    Future<void> _loadSavedChallenges() async {
    final savedChallenges = await ChallengeService.getChallenges();
    
    // Sort challenges by creation date (most recent first)
    savedChallenges.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
    
    // Convert saved challenges to ChallengeModel
    final List<ChallengeModel> convertedChallenges = savedChallenges.map((challenge) {
      return ChallengeModel(
        id: challenge['id'],
        title: challenge['title'],
        description: challenge['description'],
        icon: Icons.emoji_events, // Default icon for custom challenges
        xp: challenge['points'] ?? 0,
        gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Default gradient
        participants: challenge['participants'] ?? 0,
        difficulty: challenge['difficulty'] ?? 'Medium',
        startDate: DateTime.parse(challenge['startDate']),
        endDate: DateTime.parse(challenge['endDate']),
        subjects: (challenge['subjects'] as List<dynamic>).map((subject) {
          return SelectedSubject(
            subjectName: subject['subjectName'],
            subjectId: subject['subjectId'],
            year: subject['year'],
            examId: subject['examId'],
            icon: subject['icon'],
          );
        }).toList(),
        isCustomChallenge: true, // Mark as custom challenge
        timeInMinutes: challenge['timeInMinutes'],
        questionLimit: challenge['questionLimit'],
      );
    }).toList();

    setState(() {
      _savedChallenges = convertedChallenges;
    });

    print('📥 Loaded ${_savedChallenges.length} saved challenges');
  }

  @override
  Widget build(BuildContext context) {
     final allChallenges = [ ..._savedChallenges];
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Challenges',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Level up your skills',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[700], size: 20),
                              SizedBox(width: 4),
                              Text(
                                '1,250',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber[900],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Modern Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          final isSelected = _selectedFilter == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            Color(0xFF6366F1),
                                            Color(0xFF8B5CF6),
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Color(0xFF6366F1).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Text(
                                  _filters[index],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // For You Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amber[700], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Recommended for You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _forYouChallenges.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder(
                          duration: Duration(milliseconds: 400 + (index * 100)),
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
                            margin: EdgeInsets.only(
                              right: index == _forYouChallenges.length - 1 ? 0 : 16,
                            ),
                            child: _buildForYouCard(
                              _forYouChallenges[index],
                              index,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Active Challenges Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Active Challenges',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Challenges List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 400 + (index * 100)),
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
                      child: _buildChallengeCard(allChallenges[index]),
                    );
                  },
                  childCount: allChallenges.length,
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Create challenge action
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateChallengeScreen(),
            ),
          ).then((_) => _loadSavedChallenges());
        },
        backgroundColor: Color(0xFF6366F1),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Create',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildForYouCard(ChallengeModel challenge, int index) {
    return Container(
      width: 310,
      height: 200,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: challenge.gradient,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: challenge.gradient[0].withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ShimmerPainter(
                    animation: _shimmerController,
                    gradient: challenge.gradient,
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            challenge.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${challenge.xp}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'XP',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      challenge.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    // Modern Countdown Timer
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            _formatCountdown(challenge.endDate),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.people,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                '${challenge.participants}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Join challenge action
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeaderboardScreen( fromChallenge: true,),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: challenge.gradient[0],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'leaderboard',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                 Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChallengeInstructionsScreen(
                              challenge: challenge,
                               onContinue: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StartChallenge(),
              ),
            );
          },
                            ),
                          ),
                        );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: challenge.gradient[0],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Join',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                challenge.difficulty,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: challenge.gradient[0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeModel challenge) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: challenge.gradient,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    challenge.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        challenge.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    challenge.difficulty,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: challenge.gradient[0],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: challenge.progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: challenge.gradient,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${(challenge.progress * 100).toInt()}% Complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            // Modern Countdown Timer
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: challenge.gradient[0],
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Ends in: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatCountdown(challenge.endDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: challenge.gradient[0],
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people, color: Colors.grey[700], size: 14),
                      SizedBox(width: 4),
                      Text(
                        '${challenge.participants}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[700], size: 14),
                      SizedBox(width: 4),
                      Text(
                        '${challenge.xp} XP',
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                
                Spacer(),
                Row(
                  children: [

                    ElevatedButton(
                      onPressed: (){
                        // Start challenge action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaderboardScreen(fromChallenge: true,),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'leaderboard',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (){
                        // Start challenge action
                        _joinChallenge(challenge);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: challenge.gradient[0],
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _joinChallenge(ChallengeModel challenge) {
    // Extract exam IDs from subjects (for custom challenges) or use default
    final examIds = challenge.subjects?.map((subject) => subject.examId).toList() ?? 
                   ['default_exam_id']; // Fallback for predefined challenges
    
    final subjectNames = challenge.subjects?.map((subject) => subject.subjectName).toList() ?? 
                       [challenge.title]; // Fallback
    
    final years = challenge.subjects?.map((subject) => subject.year).toList() ?? 
                 ['2024']; // Fallback
    
    print('\n🎯 Joining Challenge:');
    print('   Title: ${challenge.title}');
    print('   Subjects: ${subjectNames.length}');
    print('   Exam IDs: $examIds');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeInstructionsScreen(
          challenge: challenge,
          onContinue: () {
            // Navigate to StartChallenge with exam data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StartChallenge(
                  challenge: challenge,
                  examIds: examIds,
                  subjectNames: subjectNames,
                  years: years,
                  totalDurationInSeconds: (challenge.timeInMinutes ?? 60) * 60,
                  questionLimit: challenge.questionLimit,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


 


class ShimmerPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> gradient;

  ShimmerPainter({required this.animation, required this.gradient})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.0),
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        transform: GradientRotation(animation.value * math.pi * 2),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(ShimmerPainter oldDelegate) => true;
}