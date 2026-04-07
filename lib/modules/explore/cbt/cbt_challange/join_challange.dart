import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_instruction.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_modal.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challenge_leader.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/create_challenge.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:linkschool/modules/explore/cbt/cbt_challange/start_challenge.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_provider.dart';
import 'package:linkschool/modules/services/explore/manage_storage.dart';
import 'package:provider/provider.dart';

class _ChallengePill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ChallengePill({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: 120,
      alignment: Alignment.center ,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6366F1)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

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
      final seconds = difference.inSeconds % 60;

      if (days > 0) {
        return 'Starts in ${days}d ${hours}h ${minutes}m ${seconds}s';
      } else if (hours > 0) {
        return 'Starts in ${hours}h ${minutes}m ${seconds}s';
      } else {
        return 'Starts in ${minutes}m ${seconds}s';
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
      return '${days}d ${hours}h ${minutes}m ${seconds}s';
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
    savedChallenges.sort((a, b) => DateTime.parse(b['createdAt'])
        .compareTo(DateTime.parse(a['createdAt'])));

    // Convert saved challenges to ChallengeModel
    final List<ChallengeModel> convertedChallenges =
        savedChallenges.map((challenge) {
      final rawItems = challenge['items'];
      final rawSubjects = challenge['subjects'];

      return ChallengeModel(
        id: challenge['id'],
        title: challenge['title'],
        description: challenge['description'],
        icon: Icons.emoji_events, // Default icon for custom challenges
        xp: challenge['points'] ?? 0,
        gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Default gradient
        participants: challenge['participants'] ?? 0,
        difficulty: challenge['difficulty'] ?? 'Medium',
        startDate: DateTime.tryParse(
              challenge['startDate']?.toString() ??
                  challenge['start_date']?.toString() ??
                  '',
            ) ??
            DateTime.now(),
        endDate: DateTime.tryParse(
              challenge['endDate']?.toString() ??
                  challenge['end_date']?.toString() ??
                  '',
            ) ??
            DateTime.now().add(const Duration(days: 1)),
        subjects: rawItems is List
            ? rawItems.map((item) {
                final years = item is Map<String, dynamic> &&
                        item['years'] is List
                    ? (item['years'] as List)
                        .map((year) => year.toString())
                        .toList()
                    : <String>[];
                final firstYear = years.isNotEmpty ? years.first : '';
                final firstExamId = firstYear.isNotEmpty ? firstYear : '';
                final questionCount = item is Map<String, dynamic>
                    ? (item['question_count'] ??
                            item['question_limit'] ??
                            challenge['questionLimit'] ??
                            challenge['count_per_exam'] ??
                            40)
                        .toString()
                    : '40';

                return SelectedSubject(
                  subjectName: (item is Map<String, dynamic>
                          ? item['course_name'] ?? item['subjectName']
                          : 'Unknown Subject')
                      .toString(),
                  subjectId: (item is Map<String, dynamic>
                          ? item['course_id'] ?? item['subjectId']
                          : '')
                      .toString(),
                  year: firstYear,
                  examId: firstExamId,
                  icon: 'default',
                  questionCount: int.tryParse(questionCount) ?? 40,
                  selectedYears: years
                      .map((year) => YearModel(id: year, year: year))
                      .toList(),
                );
              }).toList()
            : (rawSubjects is List
                ? rawSubjects.map((subject) {
                    final years = subject['selectedYears'] is List
                        ? (subject['selectedYears'] as List)
                            .map((year) => year.toString())
                            .toList()
                        : <String>[];
                    return SelectedSubject(
                      subjectName: subject['subjectName'],
                      subjectId: subject['subjectId'],
                      year: subject['year'],
                      examId: subject['examId'],
                      icon: subject['icon'],
                      questionCount: subject['questionCount'] is int
                          ? subject['questionCount']
                          : int.tryParse(
                                  subject['questionCount']?.toString() ?? '',
                                ) ??
                              40,
                      selectedYears: years
                          .map((year) => YearModel(id: year, year: year))
                          .toList(),
                    );
                  }).toList()
                : const <SelectedSubject>[]),
        isCustomChallenge: true, // Mark as custom challenge
        timeInMinutes: challenge['timeInMinutes'] ??
            challenge['duration'] ??
            challenge['time_limit'],
        questionLimit: challenge['questionLimit'],
      );
    }).toList();

    setState(() {
      _savedChallenges = convertedChallenges;
    });

  }

  Future<void> _openCreateChallenge() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChallengeScreen(
          userName: widget.userName,
          userId: widget.userId,
          examTypeId: widget.examTypeId,
        ),
      ),
    );

    if (!mounted) return;
    final provider = Provider.of<ChallengeProvider>(context, listen: false);
    provider.loadChallenges(widget.userId, int.tryParse(widget.examTypeId) ?? 0);
  }

  Widget _buildEmptyChallengeState() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: Colors.black87,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Challenges',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[900],
                      ),
                    ),
                  
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.08),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.emoji_events_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'No challenges yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create the first challenge for your class or join one when it becomes available. Keep it simple and let the challenge be built around the subjects you pick.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _ChallengePill(label: 'Create', icon: Icons.add),
                        _ChallengePill(label: 'Join', icon: Icons.login),
                        _ChallengePill(
                            label: 'Leaderboard', icon: Icons.leaderboard),
                      ],
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
            return _buildEmptyChallengeState();
          }

          return CustomScrollView(slivers: [
         SliverToBoxAdapter(
  child: Container(
    padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
    color: Colors.grey[50], // matches scaffold background — no visual separation
    child: Row(
      children: [
        // Back button
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        const SizedBox(width: 4),

        // Title & subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Challenges',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Level up your skills',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),
        
            // For You Section
            if (activeRecommended.isNotEmpty) ...[
              SliverToBoxAdapter(child: SizedBox(height: 12)),
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
            ],

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
        onPressed: _openCreateChallenge,
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
                  color: challenge.gradient[0].withValues(alpha: 0.4),
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
                            color: Colors.white.withValues(alpha: 0.25),
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
                            color: Colors.white.withValues(alpha: 0.25),
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
                                  color: Colors.white.withValues(alpha: 0.9),
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
                    const SizedBox(height: 10),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Modern Countdown Timer
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
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
                            color: Colors.white.withValues(alpha: 0.25),
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
  final gradientColors =
      isEnded ? [Colors.grey[400]!, Colors.grey[500]!] : challenge.gradient;
  final isExpired = isEnded || challenge.isExpired;
  final dateLabel = isExpired
      ? 'Ended'
      : (_canStartChallenge(challenge) ? 'Ends in' : 'Starts in');
  final dateBgColor = isExpired
      ? Colors.grey[100]
      : challenge.gradient[0].withValues(alpha: 0.10);
  final dateBorderColor = isExpired
      ? Colors.grey[300]!
      : challenge.gradient[0].withValues(alpha: 0.18);
  final dateTextColor = isExpired ? Colors.grey[600]! : challenge.gradient[0];

  return Container(
    margin: EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (isEnded || !_canStartChallenge(challenge))
                  ? null
                  : () => _joinChallenge(challenge),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradientColors),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(challenge.icon, color: Colors.white, size: 26),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                challenge.title.isNotEmpty
                                    ? '${challenge.title[0].toUpperCase()}${challenge.title.substring(1)}'
                                    : challenge.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isEnded ? Colors.grey[600] : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (challenge.authorId == widget.userId)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isExpired
                                  ? Colors.grey[100]
                                  : challenge.gradient[0].withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isExpired
                                    ? Colors.grey[300]!
                                    : challenge.gradient[0].withValues(alpha: 0.18),
                              ),
                            ),
                            child: Text(
                              isEnded
                                  ? 'Ended'
                                  : ((challenge.status ?? '').isNotEmpty
                                      ? '${challenge.status![0].toUpperCase()}${challenge.status!.substring(1)}'
                                      : ''),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isExpired ? Colors.grey[600] : challenge.gradient[0],
                              ),
                            ),
                          ),
                       // const SizedBox(width: 20),
                        if (challenge.authorId == widget.userId)
                          PopupMenuButton<String>(
                            position: PopupMenuPosition.under,
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) => _handleMenuSelection(value, challenge),
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')]),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(children: [Icon(Icons.delete, size: 20), SizedBox(width: 8), Text('Delete')]),
                              ),
                              if (challenge.status != null)
                                PopupMenuItem<String>(
                                  value: (challenge.status?.toLowerCase() == 'draft' ||
                                          challenge.status?.toLowerCase() == 'archived')
                                      ? 'publish'
                                      : 'archive',
                                  child: Row(
                                    children: [
                                      Icon(
                                        (challenge.status?.toLowerCase() == 'draft' ||
                                                challenge.status?.toLowerCase() == 'archived')
                                            ? Icons.publish
                                            : Icons.archive,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        (challenge.status?.toLowerCase() == 'draft' ||
                                                challenge.status?.toLowerCase() == 'archived')
                                            ? 'Publish'
                                            : 'Archive',
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      challenge.description.isNotEmpty
                          ? '${challenge.description[0].toUpperCase()}${challenge.description.substring(1)}'
                          : challenge.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: isEnded ? Colors.grey[500] : Colors.grey[700],
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: dateBgColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: dateBorderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: dateTextColor.withValues(alpha: 0.75),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatCountdown(
                                    challenge.endDate,
                                    startDate: challenge.startDate,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: dateTextColor,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isExpired
                                  ? Colors.grey[100]
                                  : challenge.gradient[0].withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isExpired
                                    ? Colors.grey[300]!
                                    : challenge.gradient[0].withValues(alpha: 0.18),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Participants',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: dateTextColor.withValues(alpha: 0.75),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${challenge.participants}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: dateTextColor,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                   // SizedBox(height: 8),

                    // Container(
                    //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    //   decoration: BoxDecoration(
                    //     color: Colors.amber[50],
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Icon(Icons.star, color: Colors.amber[700], size: 14),
                    //       SizedBox(width: 4),
                    //       Text(
                    //         '${challenge.xp} XP',
                    //         style: TextStyle(
                    //           color: Colors.amber[900],
                    //           fontSize: 12,
                    //           fontWeight: FontWeight.w700,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),

          // Full-width Leaderboard footer bar
          InkWell(
            onTap: isEnded
                ? null
                : () {
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
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 13),
           
              decoration: BoxDecoration(
                color: isEnded ? Colors.grey[400]! : Color(0xFF6366F1),
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 15,
                      color: isEnded ? Colors.grey[200] : Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isEnded ? Colors.grey[200] : Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16,
                      color: isEnded ? Colors.grey[200] : Colors.grey[500]),
                ],
              ),
            ),
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


    // Priority 1: Custom challenges with subjects field (locally created)
    if (challenge.subjects != null && challenge.subjects!.isNotEmpty) {
      for (var subject in challenge.subjects!) {
        examIds.add(subject.subjectId);
        subjectNames.add(subject.subjectName);
        years.add(
          subject.selectedYears.isNotEmpty
              ? subject.selectedYears.first.year
              : subject.year,
        );
      }
    }
    // Priority 2: API challenges with examIds field
    else if (challenge.examIds != null && challenge.examIds!.isNotEmpty) {
      examIds = List<String>.from(challenge.examIds!);

      // Try to extract subject names from details
      if (challenge.details is List && (challenge.details as List).isNotEmpty) {
        for (var detail in challenge.details as List) {
          if (detail is Map) {
            String subjectName = detail['subject_name']?.toString() ??
                detail['subjectName']?.toString() ??
                'Subject ${subjectNames.length + 1}';
            String year = detail['year']?.toString() ?? '2024';

            subjectNames.add(subjectName);
            years.add(year);

          }
        }
      } else {
        // No details, use generic names
        for (int i = 0; i < examIds.length; i++) {
          subjectNames.add('${challenge.title} - Part ${i + 1}');
          years.add('2024');
        }
      }
    }
    // Priority 3: Predefined challenges (like _forYouChallenges, _challenges)
    else {
      // These are demonstration challenges without real exam data
      // Create mock exam IDs based on challenge type
      examIds = ['mock_exam_${challenge.title.hashCode}'];
      subjectNames = [challenge.title];
      years = ['2024'];

    }

    // Validate array lengths match
    int maxLength = [examIds.length, subjectNames.length, years.length]
        .reduce((a, b) => a > b ? a : b);


    // Pad arrays to match lengths if needed
    while (examIds.length < maxLength) {
      examIds.add('default_exam_${examIds.length}');
    }

    while (subjectNames.length < maxLength) {
      subjectNames.add('Subject ${subjectNames.length + 1}');
    }

    while (years.length < maxLength) {
      years.add('2024');
    }


    // Final validation - ensure we have at least one exam
    if (examIds.isEmpty) {
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
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.0),
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
