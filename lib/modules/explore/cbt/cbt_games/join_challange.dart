import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class ModernChallengeScreen extends StatefulWidget {
  const ModernChallengeScreen({super.key});

  @override
  State<ModernChallengeScreen> createState() => _ModernChallengeScreenState();
}

class _ModernChallengeScreenState extends State<ModernChallengeScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  int _selectedFilter = 0;

  final List<String> _filters = ['All', 'Daily', 'Weekly', 'Popular'];

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
      endDate: DateTime.now().add(Duration(days: 1)),
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
      endDate: DateTime.now().add(Duration(days: 7)),
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
      endDate: DateTime.now().add(Duration(days: 3)),
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
      endDate: DateTime.now().add(Duration(days: 5)),
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
      endDate: DateTime.now().add(Duration(days: 10)),
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
      endDate: DateTime.now().add(Duration(days: 7)),
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
      endDate: DateTime.now().add(Duration(days: 14)),
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
      endDate: DateTime.now().add(Duration(days: 6)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          final isSelected = _selectedFilter == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              child: FilterChip(
                                label: Text(_filters[index]),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = index;
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Color(0xFF6366F1).withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Color(0xFF6366F1)
                                      : Colors.grey[700],
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected
                                        ? Color(0xFF6366F1)
                                        : Colors.grey[300]!,
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
                    height: 200,
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
                      child: _buildChallengeCard(_challenges[index]),
                    );
                  },
                  childCount: _challenges.length,
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Create challenge
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
      height: 210,
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
                padding: const EdgeInsets.all(16),
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
                    
                    Text(
                      challenge.title,
                      style: TextStyle(
                        fontSize: 18,
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
                    SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM dd').format(challenge.startDate)} - ${DateFormat('MMM dd').format(challenge.endDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
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
                        ElevatedButton(
                          onPressed: () {},
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
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 10,
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
            SizedBox(height: 4),
            Text(
              '${(challenge.progress * 100).toInt()}% Complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3),
            Text(
              '${DateFormat('MMM dd').format(challenge.startDate)} - ${DateFormat('MMM dd').format(challenge.endDate)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
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
                Spacer(),
                ElevatedButton(
                  onPressed: () {},
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
      ),
    );
  }
}

class ChallengeModel {
  final String title;
  final String description;
  final IconData icon;
  final int xp;
  final double progress;
  final List<Color> gradient;
  final int participants;
  final String difficulty;
  final DateTime startDate;
  final DateTime endDate;

  ChallengeModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.xp,
    this.progress = 0.0,
    required this.gradient,
    required this.participants,
    required this.difficulty,
    required this.startDate,
    required this.endDate,
  });
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




// import 'package:flutter/material.dart';
// import 'package:gif_view/gif_view.dart';

// class JoinChallengeScreen extends StatelessWidget {
//   const JoinChallengeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<Map<String, dynamic>> forYou = [
//       {
//         'title': 'Daily Math Challenge',
//         'description': 'Solve 10 math problems to improve your skills',
//         'icon': Icons.calculate,
//         'xp': 50,
//         'backgroundImage': 'assets/images/Gaming.gif',
//       },
//       {
//         'title': 'Science Reading Challenge',
//         'description': 'Read and summarize 2 science articles',
//         'icon': Icons.science,
//         'xp': 30,
//         'backgroundImage': 'assets/images/Gaming.gif',
//       },
//     ];

//     final List<Map<String, dynamic>> challenges = [
//       {
//         'title': 'Complete 5 History Quizzes',
//         'description': 'Test your knowledge of historical events',
//         'icon': Icons.history,
//         'xp': 40,
//         'progress': 0.6,
//         'backgroundImage': 'assets/images/Gaming.gif',
//       },
//       {
//         'title': 'Write a 300-word Essay',
//         'description': 'Compose an essay on a given topic',
//         'icon': Icons.edit,
//         'xp': 50,
//         'progress': 0.3,
//         'backgroundImage': 'assets/images/Gaming.gif',
//       },
//       {
//         'title': 'Learn 15 New Vocabulary Words',
//         'description': 'Expand your English vocabulary',
//         'icon': Icons.book,
//         'xp': 25,
//         'progress': 0.8,
//         'backgroundImage': 'assets/images/Gaming.gif',
//       },
//       {
//         'title': 'Practice Coding Exercises',
//         'description': 'Solve programming challenges',
//         'icon': Icons.code,
//         'xp': 60,
//         'progress': 0.2,
//         'backgroundImage': 'assets/images/Gaming.gif',
//       },
//       {
//         'title': 'Review Biology Notes',
//         'description': 'Study and review biology concepts',
//         'icon': Icons.biotech,
//         'xp': 35,
//         'progress': 0.5,
//         'backgroundImage': 'assets/images/Gaming.gif',
//       },
//     ];

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ---------------- "For You" Title ----------------
//                 const Text(
//                   'For You',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 // ---------------- Carousel ----------------
//                 SizedBox(
//                   height: 150,
//                   child: PageView.builder(
//                     itemCount: forYou.length,

//                     controller: PageController(viewportFraction: 0.85),
//                     itemBuilder: (context, index) {
//                       final item = forYou[index];
//                       return Container(
//                         margin: const EdgeInsets.only(right: 12),
//                         child: Container(
//                           height: 150,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(16),
//                             child: Stack(
//                               fit: StackFit.expand,
//                               children: [
//                                 GifView.asset(
//                                   item['backgroundImage'],
//                                   fit: BoxFit.cover,
//                                   imageRepeat: ImageRepeat.noRepeat,
//                                   frameRate: 30,
//                                   loop: false,
//                                 ),
//                                 Container(
//                                   color: Colors.blue.withOpacity(0.35),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         item['title'],
//                                         style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w800,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         item['description'],
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.white70,
//                                         ),
//                                       ),
//                                      // const SizedBox(height: 10),
//                                       Row(
//                                         children: [
//                                           const Spacer(),
//                                           ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: Colors.white,
//                                               foregroundColor: Colors.deepPurple,
//                                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(14),
//                                               ),
//                                             ),
//                                             onPressed: () {},
//                                             child: const Text(
//                                               "Join",
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.blue,
//                                                 fontSize: 14,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // ---------------- "Challenges" Title ----------------
//                 const Text(
//                   'Challenges',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 // ---------------- Challenges List ----------------
//                 ...challenges.map((item) {
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     child: Container(
//                       height: 151,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             GifView.asset(
//                               item['backgroundImage'],
//                               fit: BoxFit.cover,
//                               imageRepeat: ImageRepeat.noRepeat,
//                               frameRate: 30,
//                               loop: false,
//                             ),
//                             Container(
//                               color: Colors.blue.withOpacity(0.35),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     item['title'],
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w800,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     item['description'],
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.white70,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   LinearProgressIndicator(
//                                     value: item['progress'],
//                                     color: Colors.white,
//                                     backgroundColor: Colors.white.withOpacity(0.3),
//                                     minHeight: 6,
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Row(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withOpacity(0.2),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: Text(
//                                           '${item['xp']} XP',
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                       const Spacer(),
//                                       ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.white,
//                                           foregroundColor: Colors.deepPurple,
//                                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(14),
//                                           ),
//                                         ),
//                                         onPressed: () {},
//                                         child: const Text(
//                                           "Join",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.blue,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),
//         ),
//       ),

//       // ---------------- Floating Create Button ----------------
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Navigate to create challenge
//         },
//         backgroundColor: Colors.purple,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
