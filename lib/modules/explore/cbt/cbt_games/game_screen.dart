// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'dart:math' as math;

import 'package:linkschool/modules/explore/cbt/cbt_games/game_Leaderboard.dart';

class GameTestScreen extends StatefulWidget {
  final String subject;
  final List<String> topics;

  const GameTestScreen({
    Key? key,
    required this.subject,
    required this.topics,
  }) : super(key: key);

  @override
  State<GameTestScreen> createState() => _GameTestScreenState();
}

class _GameTestScreenState extends State<GameTestScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  Map<int, int> _userAnswers = {};
  int _score = 0;
  int _streak = 0;
  int _highestStreak = 0;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _celebrationController;

  // Static quiz data
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the powerhouse of the cell?',
      'options': ['Nucleus', 'Mitochondria', 'Ribosome', 'Chloroplast'],
      'correctAnswer': 1,
      'points': 2,
    },
    {
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      'correctAnswer': 1,
      'points': 10,
    },
    {
      'question': 'What is the chemical symbol for gold?',
      'options': ['Go', 'Gd', 'Au', 'Ag'],
      'correctAnswer': 2,
      'points': 6,
    },
    {
      'question': 'Who wrote "Romeo and Juliet"?',
      'options': [
        'Charles Dickens',
        'William Shakespeare',
        'Jane Austen',
        'Mark Twain'
      ],
      'correctAnswer': 1,
      'points': 8,
    },
    {
      'question': 'What is the largest ocean on Earth?',
      'options': [
        'Atlantic Ocean',
        'Indian Ocean',
        'Arctic Ocean',
        'Pacific Ocean'
      ],
      'correctAnswer': 3,
      'points': 10,
    },
    {
      'question': 'What is the square root of 144?',
      'options': ['10', '11', '12', '13'],
      'correctAnswer': 2,
      'points': 5,
    },
    {
      'question': 'Which gas do plants absorb from the atmosphere?',
      'options': ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
      'correctAnswer': 2,
      'points': 10,
    },
    {
      'question': 'What is the capital of France?',
      'options': ['London', 'Berlin', 'Paris', 'Madrid'],
      'correctAnswer': 2,
      'points': 10,
    },
  ];

  int _remainingTime = 600; // 10 minutes
  bool _isAnswered = false;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _startTimer();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
        _startTimer();
      } else if (_remainingTime == 0) {
        _finishQuiz();
      }
    });
  }

  void _selectAnswer(int optionIndex) {
    if (_isAnswered) return;

    setState(() {
      _userAnswers[_currentQuestionIndex] = optionIndex;
      _isAnswered = true;

      // Check if answer is correct
      if (optionIndex == _questions[_currentQuestionIndex]['correctAnswer']) {
        _score += _questions[_currentQuestionIndex]['points'] as int;
        _streak++;
        if (_streak > _highestStreak) {
          _highestStreak = _streak;
        }
        _showCelebration = true;
        _celebrationController.forward(from: 0);
      } else {
        _streak = 0;
      }
    });

    // Auto advance after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (_currentQuestionIndex < _questions.length - 1) {
          _nextQuestion();
        } else {
          _finishQuiz();
        }
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _showCelebration = false;
      });
      _progressController.forward(from: 0);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _isAnswered = _userAnswers.containsKey(_currentQuestionIndex);
      });
    }
  }

  void _finishQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ResultDialog(
        score: _score,
        totalQuestions: _questions.length,
        answeredQuestions: _userAnswers.length,
        highestStreak: _highestStreak,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final selectedAnswer = _userAnswers[_currentQuestionIndex];
    final isCorrect = selectedAnswer == question['correctAnswer'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.eLearningBtnColor1,
              AppColors.eLearningBtnColor1.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Game Header
              _buildGameHeader(),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Question Card
                      _buildQuestionCard(question),
                      const SizedBox(height: 20),

                      // Options
                      _buildOptionsGrid(question, selectedAnswer, isCorrect),
                    ],
                  ),
                ),
              ),

              // Navigation Buttons
             // _buildNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.subject,
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                   
                  ],
                ),
              ),
            
            ],
          ),
          //SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  label: 'Score',
                  value: '$_score',
                  color: Colors.amber,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '$_streak',
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  label: 'Best',
                  value: '$_highestStreak',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
        
          SizedBox(height: 2),
          Row(
            children: [
               Text(
            label,
            style: AppTextStyles.normal400(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
              SizedBox(width: 4),
              Text(
                value,
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 4),
                Icon(icon, color: color, size: 20),
            ],
          ),
         
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                question['question'],
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.text4Light,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 20,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.eLearningBtnColor1,
                  AppColors.eLearningBtnColor1.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.eLearningBtnColor1.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${question['points']}',
                  style: AppTextStyles.normal600(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '⭐',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        if (_showCelebration && _isAnswered)
          Positioned(
            top: 0,
            right: 20,
            child: TweenAnimationBuilder(
              duration: Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.rotate(
                    angle: value * math.pi * 2,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildOptionsGrid(
      Map<String, dynamic> question, int? selectedAnswer, bool isCorrect) {
    final options = question['options'] as List<String>;
    final correctAnswer = question['correctAnswer'] as int;

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedAnswer == index;
        final isCorrectOption = index == correctAnswer;
        final showCorrect = _isAnswered && isCorrectOption;
        final showWrong = _isAnswered && isSelected && !isCorrect;

        Color backgroundColor = Colors.white;
        Color borderColor = Colors.grey.shade300;
        Color textColor = AppColors.text4Light;

        if (showCorrect) {
          backgroundColor = Colors.green.shade50;
          borderColor = Colors.green;
          textColor = Colors.green.shade900;
        } else if (showWrong) {
          backgroundColor = Colors.red.shade50;
          borderColor = Colors.red;
          textColor = Colors.red.shade900;
        } else if (isSelected) {
          backgroundColor = AppColors.eLearningBtnColor1.withOpacity(0.1);
          borderColor = AppColors.eLearningBtnColor1;
        }

        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () => _selectAnswer(index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withOpacity(0.2),
                    blurRadius: isSelected ? 8 : 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: showCorrect
                          ? Colors.green
                          : showWrong
                              ? Colors.red
                              : isSelected
                                  ? AppColors.eLearningBtnColor1
                                  : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: showCorrect || showWrong || isSelected
                            ? Colors.transparent
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: showCorrect
                          ? Icon(Icons.check, color: Colors.white, size: 20)
                          : showWrong
                              ? Icon(Icons.close, color: Colors.white, size: 20)
                              : isSelected
                                  ? Icon(Icons.check,
                                      color: Colors.white, size: 20)
                                  : Text(
                                      String.fromCharCode(65 + index),
                                      style: AppTextStyles.normal600(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (showCorrect)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${question['points']} ⭐',
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
      }).toList(),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  _currentQuestionIndex > 0 ? _previousQuestion : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _currentQuestionIndex > 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Previous',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: _currentQuestionIndex > 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _finishQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Finish Quiz',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: _currentQuestionIndex < _questions.length - 1 &&
                      !_isAnswered
                  ? _nextQuestion
                  : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _currentQuestionIndex < _questions.length - 1 &&
                          !_isAnswered
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Skip',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: _currentQuestionIndex < _questions.length - 1 &&
                          !_isAnswered
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int answeredQuestions;
  final int highestStreak;

  const _ResultDialog({
    required this.score,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.highestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (answeredQuestions / totalQuestions * 100).round();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.eLearningBtnColor1,
              AppColors.eLearningBtnColor1.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.amber,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Quiz Complete!',
              style: AppTextStyles.normal600(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Great job! Here\'s your result',
              style: AppTextStyles.normal400(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Score', '$score ⭐', Colors.amber),
                      _buildStatItem(
                          'Answered', '$answeredQuestions/$totalQuestions', Colors.greenAccent),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          'Accuracy', '$percentage%', Colors.lightBlueAccent),
                      _buildStatItem('Best Streak', '$highestStreak 🔥', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
               Navigator.pushReplacement(context,
               MaterialPageRoute(builder: (context) => LeaderboardScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Done',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'Urbanist',
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontFamily: 'Urbanist',
          ),
        ),
      ],
    );
  }
}