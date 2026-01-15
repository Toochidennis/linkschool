import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_instruction.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_modal.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challenge_leader.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/create_challenge.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:linkschool/modules/explore/cbt/cbt_challange/start_challenge.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_provider.dart';
import 'package:linkschool/modules/services/explore/manage_storage.dart';
import 'package:provider/provider.dart';

class ModernChallengeScreen extends StatefulWidget {
  final String userName;
  final int userId;
  final String examTypeId;
  const ModernChallengeScreen(
      {super.key,
      required this.userName,
      required this.userId,
      required this.examTypeId});

  @override
  State<ModernChallengeScreen> createState() => _ModernChallengeScreenState();
}

class _ModernChallengeScreenState extends State<ModernChallengeScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Timer _countdownTimer;
  final int _selectedFilter = 0;
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

    Future.microtask(() {
      final provider = Provider.of<ChallengeProvider>(context, listen: false);
      provider.loadChallenges(
          widget.userId, int.tryParse(widget.examTypeId) ?? 0);
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  String _formatCountdown(DateTime endDate, {DateTime? startDate}) {
    final now = DateTime.now();

    // Check if challenge hasn't started yet
    if (startDate != null && now.isBefore(startDate)) {
      final difference = startDate.difference(now);
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;

      if (days > 0) {
        return 'Starts in ${days}d ${hours}h';
      } else if (hours > 0) {
        return 'Starts in ${hours}h ${minutes}m';
      } else {
        return 'Starts in ${minutes}m';
      }
    }

    // Check if challenge has ended
    final difference = endDate.difference(now);
    if (difference.isNegative) {
      return 'Ended';
    }

    // Challenge has started and is ongoing - show "Ends in"
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    if (days > 0) {
      return 'Ends in ${days}d ${hours}h';
    } else if (hours > 0) {
      return 'Ends in ${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return 'Ends in ${minutes}m ${seconds}s';
    } else {
      return 'Ends in ${seconds}s';
    }
  }

  Future<void> _loadSavedChallenges() async {
    final savedChallenges = await ChallengeService.getChallenges();

    // Sort challenges by creation date (most recent first)
    savedChallenges.sort((a, b) => DateTime.parse(b['createdAt'])
        .compareTo(DateTime.parse(a['createdAt'])));

    // Convert saved challenges to ChallengeModel
    final List<ChallengeModel> convertedChallenges =
        savedChallenges.map((challenge) {
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
      _savedChallenges = [];
    });

    print('📥 Loaded ${_savedChallenges.length} saved challenges');
  }

  @override
  Widget build(BuildContext context) {
    final allChallenges = [..._savedChallenges];
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(child: Consumer<ChallengeProvider>(
        builder: (context, value, child) {
          final provider = Provider.of<ChallengeProvider>(context);

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  Text("Error: ${provider.error}"),
                  ElevatedButton(
                    onPressed: () => provider.loadChallenges(
                        widget.userId, int.tryParse(widget.examTypeId) ?? 0),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final recommended = provider.recommended;
          final active = provider.active;
          final upcoming = provider.upcoming;
          final personal = provider.personal;

          // Filter out ended challenges
          final activeRecommended =
              recommended.where((c) => !c.isExpired).toList();
          final activeActive = active.where((c) => !c.isExpired).toList();
          final activeUpcoming = upcoming.where((c) => !c.isExpired).toList();
          final activePersonal = personal.where((c) => !c.isExpired).toList();

          // Collect all ended challenges
          final endedChallenges = [
            ...recommended.where((c) => c.isExpired),
            ...active.where((c) => c.isExpired),
            ...upcoming.where((c) => c.isExpired),
            ...personal.where((c) => c.isExpired),
          ];

          final allChallenges = [
            ...activePersonal,
            ...activeActive,
            ...activeUpcoming,
            ...activeRecommended,
            ...endedChallenges,
          ];

          if (allChallenges.isEmpty) {
            return Center(
              child: Text(
                'No challenges available at the moment.\nPlease check back later!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return CustomScrollView(slivers: [
            // Modern App Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // morden back button
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              size: 30, color: Colors.black87),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),

                        SizedBox.fromSize(size: Size(10, 0)),

                        Container(
                          padding: const EdgeInsets.all(8),
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
                        SizedBox(width: 10),
                        Expanded(
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Challenges',
                                  style: TextStyle(
                                    fontSize: 20,
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
                        ),
                        SizedBox(width: 16),
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
                              Icon(Icons.star,
                                  color: Colors.amber[700], size: 20),
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
                    // SizedBox(height: 20),
                    // Modern Filter Chips
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: List.generate(_filters.length, (index) {
                    //       final isSelected = _selectedFilter == index;
                    //       return Padding(
                    //         padding: const EdgeInsets.only(right: 12),
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             setState(() {
                    //               _selectedFilter = index;
                    //             });
                    //           },
                    //           child: AnimatedContainer(
                    //             duration: Duration(milliseconds: 300),
                    //             padding: EdgeInsets.symmetric(
                    //               horizontal: 20,
                    //               vertical: 5,
                    //             ),
                    //             decoration: BoxDecoration(
                    //               gradient: isSelected
                    //                   ? LinearGradient(
                    //                       colors: [
                    //                         Color(0xFF6366F1),
                    //                         Color(0xFF8B5CF6),
                    //                       ],
                    //                     )
                    //                   : null,
                    //               color: isSelected ? null : Colors.white,
                    //               borderRadius: BorderRadius.circular(25),
                    //               border: Border.all(
                    //                 color: isSelected
                    //                     ? Colors.transparent
                    //                     : Colors.grey[300]!,
                    //                 width: 1.5,
                    //               ),
                    //               boxShadow: isSelected
                    //                   ? [
                    //                       BoxShadow(
                    //                         color: Color(0xFF6366F1).withOpacity(0.3),
                    //                         blurRadius: 8,
                    //                         offset: Offset(0, 4),
                    //                       ),
                    //                     ]
                    //                   : [
                    //                       BoxShadow(
                    //                         color: Colors.black.withOpacity(0.05),
                    //                         blurRadius: 4,
                    //                         offset: Offset(0, 2),
                    //                       ),
                    //                     ],
                    //             ),
                    //             child: Text(
                    //               _filters[index],
                    //               style: TextStyle(
                    //                 color: isSelected ? Colors.white : Colors.grey[700],
                    //                 fontWeight: FontWeight.w600,
                    //                 fontSize: 14,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     }),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            // For You Section
            if (activeRecommended.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.amber[700], size: 20),
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
                        itemCount: activeRecommended.length,
                        itemBuilder: (context, index) {
                          return _buildForYouCard(
                              activeRecommended[index], index);
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Active Challenges Section
            if (activeActive.isNotEmpty) ...[
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
                        child: _buildChallengeCard(activeActive[index]),
                      );
                    },
                    childCount: activeActive.length,
                  ),
                ),
              ),
            ],

            // Active Challenges Section
            if (activePersonal.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          color: Colors.orange[700], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'My Challenges',
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
                        child: _buildChallengeCard(activePersonal[index]),
                      );
                    },
                    childCount: activePersonal.length,
                  ),
                ),
              ),
            ],

            if (activeUpcoming.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.blue[700], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Upcoming Challenges',
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
                        child: _buildChallengeCard(activeUpcoming[index]),
                      );
                    },
                    childCount: activeUpcoming.length,
                  ),
                ),
              ),
            ],

            // Ended Challenges Section
            if (endedChallenges.isNotEmpty) ...[
              SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Colors.grey[500], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ended Challenges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
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
                        child: _buildChallengeCard(endedChallenges[index],
                            isEnded: true),
                      );
                    },
                    childCount: endedChallenges.length,
                  ),
                ),
              ),
            ],

            SliverToBoxAdapter(child: SizedBox(height: 100)),
          ]);
        },
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Create challenge action
          print('Navigating to: ${widget.userName}, userId: ${widget.userId}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateChallengeScreen(
                userName: widget.userName,
                userId: widget.userId,
                examTypeId: widget.examTypeId,
              ),
            ),
          ).then((_) {
            // Refresh challenges after editing
            final provider =
                Provider.of<ChallengeProvider>(context, listen: false);
            provider.loadChallenges(
                widget.userId, int.tryParse(widget.examTypeId) ?? 0);
          });
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
    return SizedBox(
      width: 300,
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            _formatCountdown(challenge.endDate,
                                startDate: challenge.startDate),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.people, color: Colors.white, size: 14),
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
                                // View leaderboard for this challenge
                                final challengeId =
                                    int.tryParse(challenge.id ?? '');
                                if (challengeId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChallengeLeader(
                                        fromChallenge: true,
                                        challengeId: challengeId,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Challenge ID not available'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
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
                                'Leaderboard',
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
                                    builder: (context) =>
                                        ChallengeInstructionsScreen(
                                      challenge: challenge,
                                      onContinue: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StartChallenge(),
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

  bool _canStartChallenge(ChallengeModel challenge) {
    final now = DateTime.now();
    final start = challenge.startDate;
    return now.isAfter(start) || now.isAtSameMomentAs(start);
  }

  String _getStartButtonText(ChallengeModel challenge) {
    return 'Start';
  }

  Widget _buildChallengeCard(ChallengeModel challenge, {bool isEnded = false}) {
    // Use gray colors for ended challenges content only, keep card white
    final gradientColors =
        isEnded ? [Colors.grey[400]!, Colors.grey[500]!] : challenge.gradient;

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
                      colors: gradientColors,
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
                          color: isEnded ? Colors.grey[600] : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        challenge.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isEnded ? Colors.grey[500] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isEnded ? 'Ended' : (challenge.status ?? ''),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isEnded
                              ? Colors.grey[600]
                              : challenge.gradient[0],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    if (challenge.authorId == widget.userId)
                      PopupMenuButton<String>(
                        // Position popup below the button (horizontal alignment)
                        position: PopupMenuPosition.under,
                        icon: Icon(Icons.more_horiz),
                        onSelected: (value) {
                          _handleMenuSelection(value, challenge);
                          // Handle selection
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),

                            // update status option
                            if (challenge.status != null)
                              PopupMenuItem<String>(
                                value: (challenge.status?.toLowerCase() ==
                                            'draft' ||
                                        challenge.status?.toLowerCase() ==
                                            'archived')
                                    ? 'publish'
                                    : 'archive',
                                child: Row(
                                  children: [
                                    Icon(
                                      (challenge.status?.toLowerCase() ==
                                                  'draft' ||
                                              challenge.status?.toLowerCase() ==
                                                  'archived')
                                          ? Icons.publish
                                          : Icons.archive,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      (challenge.status?.toLowerCase() ==
                                                  'draft' ||
                                              challenge.status?.toLowerCase() ==
                                                  'archived')
                                          ? 'Publish'
                                          : 'Archive',
                                    ),
                                  ],
                                ),
                              ),
                          ];
                        },
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

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
                        color:
                            isEnded ? Colors.grey[500] : challenge.gradient[0],
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        _formatCountdown(challenge.endDate,
                            startDate: challenge.startDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: isEnded
                              ? Colors.grey[600]
                              : challenge.gradient[0],
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
                      onPressed: () {
                        // View leaderboard for this challenge
                        final challengeId = int.tryParse(challenge.id ?? '');
                        if (challengeId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChallengeLeader(
                                fromChallenge: true,
                                challengeId: challengeId,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Challenge ID not available'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Leaderboard',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (isEnded || !_canStartChallenge(challenge))
                          ? null
                          : () => _joinChallenge(challenge),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEnded
                            ? Colors.grey[400]
                            : (_canStartChallenge(challenge)
                                ? challenge.gradient[0]
                                : Colors.grey[400]),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _getStartButtonText(challenge),
                        style: TextStyle(
                          color: _canStartChallenge(challenge)
                              ? Colors.white
                              : Colors.black,
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

  void _handleMenuSelection(String value, ChallengeModel challenge) async {
    switch (value) {
      case 'edit':
        _editChallenge(challenge);
        break;
      case 'delete':
        await _deleteChallenge(challenge);
        break;
      case 'publish':
        await _updateChallengeStatus(challenge, 'published');
        break;
      case 'archive':
        await _updateChallengeStatus(challenge, 'archived');
        break;
    }
  }

  void _editChallenge(ChallengeModel challenge) {
    // Navigate to edit screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChallengeScreen(
          userName: widget.userName,
          userId: widget.userId,
          examTypeId: widget.examTypeId,
          challengeToEdit: challenge, // Pass challenge to edit
          isEditing: true,
        ),
      ),
    ).then((_) {
      // Refresh challenges after editing
      final provider = Provider.of<ChallengeProvider>(context, listen: false);
      provider.loadChallenges(
          widget.userId, int.tryParse(widget.examTypeId) ?? 0);
    });
  }

  Future<void> _deleteChallenge(ChallengeModel challenge) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Challenge'),
        content: Text(
            'Are you sure you want to delete "${challenge.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Call delete API
        final provider = Provider.of<ChallengeProvider>(context, listen: false);
        await provider.deleteChallenge(
          challengeId: int.parse(
            challenge.id!,
          ),
          authorId: widget.userId,
          examTypeId: int.tryParse(widget.examTypeId) ?? 0,
        );

        // Hide loading
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challenge deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        // Hide loading
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete challenge: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _updateChallengeStatus(
      ChallengeModel challenge, String newStatus) async {
    try {
      final provider = Provider.of<ChallengeProvider>(context, listen: false);

      // Update status locally first (instant UI update)
      provider.updateChallengeStatusLocally(
        int.parse(challenge.id!),
        newStatus,
      );

      // Then update on server in background
      await provider.updateChallengeStatus(
        challengeId: int.parse(challenge.id!),
        status: newStatus,
      );

      // Show a subtle success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'published'
                ? 'Challenge published successfully'
                : 'Challenge archived',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // If server update fails, reload to get correct state
      final provider = Provider.of<ChallengeProvider>(context, listen: false);
      await provider.loadChallenges(
        widget.userId,
        int.tryParse(widget.examTypeId) ?? 0,
      );

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _joinChallenge(ChallengeModel challenge) async {
    List<String> examIds = [];
    List<String> subjectNames = [];
    List<String> years = [];

    print('\n🎯 Starting _joinChallenge:');
    print('   Challenge Title: ${challenge.title}');
    print('   Has Subjects: ${challenge.subjects != null}');
    print('   Subjects Length: ${challenge.subjects?.length ?? 0}');
    print('   Has ExamIds: ${challenge.examIds != null}');
    print('   ExamIds Length: ${challenge.examIds?.length ?? 0}');
    print('   Has Details: ${challenge.details != null}');
    print('   Is Custom: ${challenge.isCustomChallenge ?? false}');

    // Priority 1: Custom challenges with subjects field (locally created)
    if (challenge.subjects != null && challenge.subjects!.isNotEmpty) {
      print('   ✅ Route 1: Using subjects field (custom challenge)');
      for (var subject in challenge.subjects!) {
        examIds.add(subject.examId);
        subjectNames.add(subject.subjectName);
        years.add(subject.year);
      }
    }
    // Priority 2: API challenges with examIds field
    else if (challenge.examIds != null && challenge.examIds!.isNotEmpty) {
      print('   ✅ Route 2: Using examIds field (API challenge)');
      examIds = List<String>.from(challenge.examIds!);

      // Try to extract subject names from details
      if (challenge.details is List && (challenge.details as List).isNotEmpty) {
        print('   ✅ Details available, extracting subject info');
        for (var detail in challenge.details as List) {
          if (detail is Map) {
            String subjectName = detail['subject_name']?.toString() ??
                detail['subjectName']?.toString() ??
                'Subject ${subjectNames.length + 1}';
            String year = detail['year']?.toString() ?? '2024';

            subjectNames.add(subjectName);
            years.add(year);

            print('   📝 Added: $subjectName ($year)');
          }
        }
      } else {
        print('   ⚠️ No details, using fallback names');
        // No details, use generic names
        for (int i = 0; i < examIds.length; i++) {
          subjectNames.add('${challenge.title} - Part ${i + 1}');
          years.add('2024');
        }
      }
    }
    // Priority 3: Predefined challenges (like _forYouChallenges, _challenges)
    else {
      print('   ⚠️ Route 3: No exam data, using mock/fallback');
      // These are demonstration challenges without real exam data
      // Create mock exam IDs based on challenge type
      examIds = ['mock_exam_${challenge.title.hashCode}'];
      subjectNames = [challenge.title];
      years = ['2024'];

      print('   ℹ️ This is a demonstration challenge without real exam data');
    }

    // Validate array lengths match
    int maxLength = [examIds.length, subjectNames.length, years.length]
        .reduce((a, b) => a > b ? a : b);

    print('\n📊 Before Validation:');
    print('   Exam IDs: ${examIds.length}');
    print('   Subject Names: ${subjectNames.length}');
    print('   Years: ${years.length}');

    // Pad arrays to match lengths if needed
    while (examIds.length < maxLength) {
      examIds.add('default_exam_${examIds.length}');
      print('   ⚠️ Padded examIds');
    }

    while (subjectNames.length < maxLength) {
      subjectNames.add('Subject ${subjectNames.length + 1}');
      print('   ⚠️ Padded subjectNames');
    }

    while (years.length < maxLength) {
      years.add('2024');
      print('   ⚠️ Padded years');
    }

    print('\n✅ After Validation:');
    print('   Exam IDs (${examIds.length}): $examIds');
    print('   Subject Names (${subjectNames.length}): $subjectNames');
    print('   Years (${years.length}): $years');
    print('─' * 50);

    // Final validation - ensure we have at least one exam
    if (examIds.isEmpty) {
      print('   ❌ FATAL: No exam IDs available after processing!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No subjects available for this challenge'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to instruction screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeInstructionsScreen(
          challenge: challenge,
          onContinue: () async {
            // Navigate to StartChallenge with validated data
            final challengeResult = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StartChallenge(
                  challenge: challenge,
                  examIds: examIds,
                  subjectNames: subjectNames,
                  years: years,
                  totalDurationInSeconds: (challenge.timeInMinutes ?? 60) * 60,
                  questionLimit: challenge.questionLimit,
                  challengeId: int.tryParse(challenge.id ?? ''),
                ),
              ),
            );
            // No need to reload challenges after returning from leaderboard
            // User already sees the updated leaderboard with their score
          },
        ),
      ),
    );

    // No need to reload challenges when returning from instruction screen
    // Challenges remain the same, only user's participation has changed
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
