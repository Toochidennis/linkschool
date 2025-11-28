import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_screen.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study_screen.dart';
import 'dart:math' as math;

class GameSubjectModal extends StatefulWidget {
  const GameSubjectModal({Key? key}) : super(key: key);

  @override
  State<GameSubjectModal> createState() => _GameSubjectModalState();
}

class _GameSubjectModalState extends State<GameSubjectModal>
    with TickerProviderStateMixin {
  String? _selectedSubject;
  List<String> _selectedTopics = [];
  bool _showTopics = false;
  bool _isTransitioning = false;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Static subjects for study mode
  final List<Map<String, dynamic>> _subjects = [
    {
      'id': 'chemistry',
      'name': 'Chemistry',
      'icon': Icons.science,
      'color': Color(0xFF6366F1),
      'emoji': '⚗️',
    },
    {
      'id': 'physics',
      'name': 'Physics',
      'icon': Icons.bolt,
      'color': Color(0xFF10B981),
      'emoji': '⚡',
    },
    {
      'id': 'biology',
      'name': 'Biology',
      'icon': Icons.biotech,
      'color': Color(0xFFEC4899),
      'emoji': '🧬',
    },
    {
      'id': 'mathematics',
      'name': 'Mathematics',
      'icon': Icons.calculate,
      'color': Color(0xFFF59E0B),
      'emoji': '🔢',
    },
    {
      'id': 'english',
      'name': 'English',
      'icon': Icons.menu_book,
      'color': Color(0xFF8B5CF6),
      'emoji': '📚',
    },
    {
      'id': 'geography',
      'name': 'Geography',
      'icon': Icons.public,
      'color': Color(0xFF06B6D4),
      'emoji': '🌍',
    },
  ];

  // Topics for each subject
  final Map<String, List<String>> _topicsBySubject = {
    'chemistry': [
      'Organic Chemistry',
      'Inorganic Chemistry',
      'Physical Chemistry',
      'Chemical Bonding',
      'Acids and Bases',
      'Redox Reactions',
    ],
    'physics': [
      'Mechanics',
      'Electricity',
      'Magnetism',
      'Optics',
      'Thermodynamics',
      'Waves',
    ],
    'biology': [
      'Cell Biology',
      'Genetics',
      'Ecology',
      'Human Anatomy',
      'Evolution',
      'Plant Biology',
    ],
    'mathematics': [
      'Algebra',
      'Calculus',
      'Geometry',
      'Trigonometry',
      'Statistics',
      'Probability',
    ],
    'english': [
      'Grammar',
      'Literature',
      'Comprehension',
      'Essay Writing',
      'Poetry',
      'Drama',
    ],
    'geography': [
      'Physical Geography',
      'Human Geography',
      'Map Reading',
      'Climate',
      'Resources',
      'Population',
    ],
  };

  void _onSubjectSelected(String subjectId) {
    setState(() {
      _selectedSubject = subjectId;
      _isTransitioning = true;
    });

    _slideController.reset();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showTopics = true;
          _isTransitioning = false;
        });
        _slideController.forward();
      }
    });
  }

  void _onTopicSelected(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  void _onContinue() {
    if (_selectedTopics.isNotEmpty) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameTestScreen(
            subject: _subjects
                .firstWhere((s) => s['id'] == _selectedSubject)['name'],
            topics: _selectedTopics,
          ),
        ),
      );
    }
  }

  void _goBack() {
    if (_showTopics) {
      setState(() {
        _isTransitioning = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showTopics = false;
            _selectedSubject = null;
            _selectedTopics = [];
            _isTransitioning = false;
          });
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showTopics) {
          _goBack();
          return false;
        }
        return true;
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              _showTopics
                  ? (_subjects
                          .firstWhere((s) => s['id'] == _selectedSubject)['color']
                      as Color)
                      .withOpacity(0.08)
                  : Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            // Animated background particles
            AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_sparkleController.value),
                  size: Size.infinite,
                );
              },
            ),
            Column(
              children: [
                // Header with game-style design
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _goBack,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _showTopics ? 'Choose Your Topics' : 'Pick a Subject',
                              style: AppTextStyles.normal600(
                                fontSize: 20,
                                color: AppColors.text4Light,
                              ),
                            ),
                            Text(
                              _showTopics
                                  ? '${_selectedTopics.length} selected'
                                  : 'Start your learning adventure',
                              style: AppTextStyles.normal400(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showTopics)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (_subjects.firstWhere((s) =>
                                    s['id'] == _selectedSubject)['color'] as Color),
                                (_subjects.firstWhere((s) =>
                                        s['id'] == _selectedSubject)['color']
                                    as Color)
                                    .withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (_subjects.firstWhere((s) =>
                                        s['id'] == _selectedSubject)['color']
                                    as Color)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '⭐',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${_selectedTopics.length * 10}',
                                style: AppTextStyles.normal600(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _showTopics ? _buildTopicsList() : _buildSubjectsList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300 + (index * 100)),
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
          child: GestureDetector(
            onTap: () => _onSubjectSelected(subject['id']),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (subject['color'] as Color).withOpacity(0.15),
                        (subject['color'] as Color).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (subject['color'] as Color).withOpacity(0.3),
                        blurRadius: 12 + (_pulseController.value * 4),
                        offset: Offset(0, 4 + (_pulseController.value * 2)),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Hero(
                      tag: 'subject_${subject['id']}',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              subject['color'] as Color,
                              (subject['color'] as Color).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (subject['color'] as Color).withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          subject['emoji'],
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject['name'],
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.text4Light,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap to explore',
                            style: AppTextStyles.normal400(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (subject['color'] as Color).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: subject['color'] as Color,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopicsList() {
    final topics = _topicsBySubject[_selectedSubject] ?? [];
    final subject = _subjects.firstWhere((s) => s['id'] == _selectedSubject);
    final subjectColor = subject['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            subjectColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                final isSelected = _selectedTopics.contains(topic);

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Interval(
                      index * 0.1,
                      (index + 1) * 0.1,
                      curve: Curves.easeOut,
                    ),
                  )),
                  child: GestureDetector(
                    onTap: () => _onTopicSelected(topic),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  subjectColor.withOpacity(0.2),
                                  subjectColor.withOpacity(0.1),
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? subjectColor
                              : Colors.grey.shade200,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: subjectColor.withOpacity(0.3),
                                  blurRadius: 12,
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
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.all(isSelected ? 4 : 0),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        subjectColor,
                                        subjectColor.withOpacity(0.7),
                                      ],
                                    )
                                  : null,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected ? Colors.white : Colors.grey,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              topic,
                              style: AppTextStyles.normal600(
                                fontSize: 16,
                                color: isSelected
                                    ? subjectColor
                                    : AppColors.text4Light,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: subjectColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+10 ⭐',
                                style: AppTextStyles.normal600(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _selectedTopics.isNotEmpty
                      ? 1.0 + (_pulseController.value * 0.02)
                      : 1.0,
                  child: child,
                );
              },
              child: ElevatedButton(
                onPressed: _selectedTopics.isNotEmpty ? _onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: subjectColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _selectedTopics.isNotEmpty ? 8 : 0,
                  shadowColor: subjectColor.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedTopics.isEmpty
                          ? 'Select topics to continue'
                          : 'Start Learning',
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    if (_selectedTopics.isNotEmpty) ...[
                      SizedBox(width: 8),
                      Icon(Icons.rocket_launch, color: Colors.white, size: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for particle effects
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = baseY + (animationValue * 50) % size.height;
      
      final opacity = (math.sin(animationValue * math.pi * 2 + i) + 1) / 2;
      paint.color = Colors.blue.withOpacity(opacity * 0.15);
      
      canvas.drawCircle(
        Offset(x, y % size.height),
        2 + (random.nextDouble() * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}