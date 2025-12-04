// ignore_for_file: deprecated_member_use
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'dart:math' as math;

import 'package:linkschool/modules/explore/cbt/cbt_games/game_Leaderboard.dart';
import 'package:vibration/vibration.dart';

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

    late AudioPlayer _correctSoundPlayer;
  late AudioPlayer _wrongSoundPlayer;
  late AudioPlayer _buttonSoundPlayer;


   final int _correctVibrationDuration = 200;
  final int _wrongVibrationDuration = 500;
  final List<int> _streakVibrationPattern = [100, 200, 100];


    void _initializeAudio() async {
    _correctSoundPlayer = AudioPlayer();
    _wrongSoundPlayer = AudioPlayer();
    _buttonSoundPlayer = AudioPlayer();
    
    // Preload sounds (optional - for better performance)
    try {
      await _correctSoundPlayer.setSource(AssetSource('sounds/correct.wav'));
      await _wrongSoundPlayer.setSource(AssetSource('sounds/wrong.wav'));
      await _buttonSoundPlayer.setSource(AssetSource('sounds/completed.wav'));
    } catch (e) {
      print('Error loading sounds: $e');
    }
  }

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
  bool _showAnswerPopup = false;
  bool _isCountdownComplete = false;

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

    _initializeAudio();
    
    // Show countdown dialog before starting the game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGameCountdown();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
  _progressController.dispose();
  _correctSoundPlayer.dispose();
  _wrongSoundPlayer.dispose();
  _buttonSoundPlayer.dispose();
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

  void _showGameCountdown() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _GameCountdownDialog(
        onComplete: () {
          Navigator.of(context).pop();
          setState(() {
            _isCountdownComplete = true;
          });
          _startTimer(); // Start the timer after countdown
        },
      ),
    );
  }

  void _selectAnswer(int optionIndex) {
    if (_isAnswered) return;

     _playButtonSound();
  _vibrateButton();

    setState(() {
      _userAnswers[_currentQuestionIndex] = optionIndex;
      _isAnswered = true;

      // Check if answer is correct
       if (optionIndex == _questions[_currentQuestionIndex]['correctAnswer']) {
      _score += _questions[_currentQuestionIndex]['points'] as int;
      _streak++;
      
      // Play correct sound and vibration
      _playCorrectSound();
      _vibrateCorrect();
      
      // Special vibration for high streaks
      if (_streak >= 3) {
        _vibrateStreak();
      }
      
      if (_streak > _highestStreak) {
        _highestStreak = _streak;
      }
      _showAnswerPopup = true;
    } else {
      _streak = 0;
      
      // Play wrong sound and vibration
      _playWrongSound();
      _vibrateWrong();
      
      _showAnswerPopup = true;
    }
  });

    // Note: User can now close popup manually
    // The popup will handle the advancement when closed
  }
  
  void _closeAnswerPopup() {
    setState(() {
      _showAnswerPopup = false;
    });
    
    // Auto-advance after popup is closed
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        if (_currentQuestionIndex < _questions.length - 1) {
          _nextQuestion();
        } else {
          _finishQuiz();
        }
      }
    });
  }

  void _playCorrectSound() async {
  try {
    await _correctSoundPlayer.stop(); // Stop any ongoing playback
    await _correctSoundPlayer.play(AssetSource('sounds/correct.wav'));
  } catch (e) {
    print('Error playing correct sound: $e');
  }
}

void _playWrongSound() async {
  try {
    await _wrongSoundPlayer.stop();
    await _wrongSoundPlayer.play(AssetSource('sounds/wrong.wav'));
  } catch (e) {
    print('Error playing wrong sound: $e');
  }
}

void _playButtonSound() async {
  try {
    await _buttonSoundPlayer.stop();
    await _buttonSoundPlayer.play(AssetSource('sounds/completed.wav'));
  } catch (e) {
    print('Error playing button sound: $e');
  }
}

void _vibrateCorrect() async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: _correctVibrationDuration);
  }
}

void _vibrateWrong() async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: _wrongVibrationDuration);
  }
}

void _vibrateStreak() async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(pattern: _streakVibrationPattern);
  }
}

void _vibrateButton() async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: 50);
  }
}

 void _nextQuestion() {
  _playButtonSound();
  _vibrateButton();
  
  if (_currentQuestionIndex < _questions.length - 1) {
    setState(() {
      _currentQuestionIndex++;
      _isAnswered = false;
      _showAnswerPopup = false;
    });
    _progressController.forward(from: 0);
  }
}

void _previousQuestion() {
  _playButtonSound();
  _vibrateButton();
  
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
    if (!_isCountdownComplete) {
      return Scaffold(
        backgroundColor: AppColors.eLearningBtnColor1,
        body: Container(),
      );
    }
    
    final question = _questions[_currentQuestionIndex];
    final selectedAnswer = _userAnswers[_currentQuestionIndex];
    final isCorrect = selectedAnswer == question['correctAnswer'];

    return Scaffold(
      body: Stack(
        children: [
          Container(
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

          // Answer Popup Overlay
          if (_showAnswerPopup && _isAnswered)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: _AnswerPopup(
                  isCorrect: isCorrect,
                  points: _questions[_currentQuestionIndex]['points'] as int,
                  onClose: _closeAnswerPopup,
                ),
              ),
            ),
              ]),
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

class _AnswerPopup extends StatefulWidget {
  final bool isCorrect;
  final int points;
  final VoidCallback onClose;

  const _AnswerPopup({
    required this.isCorrect,
    required this.points,
    required this.onClose,
  });

  @override
  State<_AnswerPopup> createState() => _AnswerPopupState();
}

class _AnswerPopupState extends State<_AnswerPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Main scale animation with bounce
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    // Slide up animation
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    );

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    // Pulse animation for icon
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    // Rotate animation for wrong answers
    _rotateController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    // Particle burst animation
    _particleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));

    // Start animations in sequence
    _scaleController.forward();
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) _slideController.forward();
    });
    
    if (widget.isCorrect) {
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          _confettiController.forward();
          _particleController.forward();
        }
      });
      Future.delayed(Duration(milliseconds: 400), () {
        if (mounted) {
          _pulseController.repeat(reverse: true);
        }
      });
    } else {
      // Shake animation for wrong answers
      Future.delayed(Duration(milliseconds: 400), () {
        if (mounted) {
          _rotateController.repeat(reverse: true);
          Future.delayed(Duration(milliseconds: 600), () {
            if (mounted) _rotateController.stop();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleController,
        _slideController,
        _rotateController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * MediaQuery.of(context).size.width,
              _slideAnimation.value.dy * MediaQuery.of(context).size.height,
            ),
            child: Transform.rotate(
              angle: widget.isCorrect ? 0 : _rotateAnimation.value,
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                margin: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isCorrect
                        ? [
                            Colors.green.shade50,
                            Colors.white,
                            Colors.green.shade50,
                          ]
                        : [
                            Colors.red.shade50,
                            Colors.white,
                            Colors.red.shade50,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: widget.isCorrect 
                        ? Colors.green.shade300 
                        : Colors.red.shade300,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isCorrect ? Colors.green : Colors.red)
                          .withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Confetti overlay for correct answers
                    if (widget.isCorrect) _buildConfettiOverlay(),
                    
                    // Particle burst overlay
                    if (widget.isCorrect) _buildParticleBurstOverlay(),

                    // Main content
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated Icon
                          _buildAnimatedIcon(),
                          SizedBox(height: 24),

                          // Title with shimmer effect
                          _buildAnimatedTitle(),
                          SizedBox(height: 12),

                          // Points display for correct answers
                          if (widget.isCorrect) _buildPointsCounter(),

                          // Subtitle
                          SizedBox(height: 12),
                          _buildSubtitle(),
                        ],
                      ),
                    ),

                    // Floating stars for correct answers
                    if (widget.isCorrect) _buildFloatingStars(),

                    // Close button at top right - MUST BE LAST to be on top
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color: widget.isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                            size: 24,
                          ),
                        ),
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

  Widget _buildConfettiOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _confettiController,
        builder: (context, child) {
          return CustomPaint(
            painter: _ConfettiPainter(_confettiController.value),
          );
        },
      ),
    );
  }

  Widget _buildParticleBurstOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticleBurstPainter(_particleController.value),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isCorrect ? _pulseAnimation.value : 1.0,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.rotate(
                  angle: (1 - value) * (widget.isCorrect ? 2 : -2),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isCorrect
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.red.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isCorrect ? Colors.green : Colors.red)
                              .withOpacity(0.5),
                          blurRadius: 25,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: widget.isCorrect
                      ? [Colors.green.shade700, Colors.green.shade900]
                      : [Colors.red.shade700, Colors.red.shade900],
                ).createShader(bounds);
              },
              child: Text(
                widget.isCorrect ? 'Correct!' : 'Wrong! 😔',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsCounter() {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: widget.points),
      duration: Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade300, Colors.orange.shade400],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.5),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+$value',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                ),
              ),
              SizedBox(width: 8),
              Text(
                '⭐',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Text(
            widget.isCorrect
                ? 'Amazing! Keep the streak going! 🔥'
                : 'Don\'t give up! Try the next one! 💪',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingStars() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: _FloatingStarsPainter(_particleController.value),
          );
        },
      ),
    );
  }
}

// Enhanced confetti painter with more particles
class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final colors = [
      Colors.amber,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.teal,
    ];

    for (int i = 0; i < 50; i++) {
      final x = (i * 23 + math.sin(i * 0.5) * 50) % size.width;
      final y = (progress * size.height * 1.8) - (i * 25 % 150);
      final rotation = (progress * 4 * math.pi + i * 0.5);

      if (y > -30 && y < size.height + 30) {
        paint.color = colors[i % colors.length].withOpacity(0.8);
        
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotation);
        
        // Draw different shapes
        if (i % 3 == 0) {
          // Rectangle
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: 8, height: 4),
            paint,
          );
        } else if (i % 3 == 1) {
          // Circle
          canvas.drawCircle(Offset.zero, 4, paint);
        } else {
          // Triangle
          final path = Path();
          path.moveTo(0, -4);
          path.lineTo(-3, 4);
          path.lineTo(3, 4);
          path.close();
          canvas.drawPath(path, paint);
        }
        
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

// Particle burst painter
class _ParticleBurstPainter extends CustomPainter {
  final double progress;

  _ParticleBurstPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * math.pi;
      final distance = progress * 150;
      final x = centerX + math.cos(angle) * distance;
      final y = centerY + math.sin(angle) * distance;
      final opacity = 1.0 - progress;

      paint.color = Colors.amber.withOpacity(opacity * 0.8);
      canvas.drawCircle(
        Offset(x, y),
        6 * (1 - progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticleBurstPainter oldDelegate) => true;
}

// Floating stars painter
class _FloatingStarsPainter extends CustomPainter {
  final double progress;

  _FloatingStarsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final radius = 60 + (progress * 100);
      final x = size.width / 2 + math.cos(angle) * radius;
      final y = size.height / 2 + math.sin(angle) * radius;
      final scale = 1.0 - progress;

      if (scale > 0) {
        _drawStar(canvas, Offset(x, y), 8 * scale, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - (math.pi / 2);
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FloatingStarsPainter oldDelegate) => true;
}
class _GameCountdownDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _GameCountdownDialog({
    required this.onComplete,
  });

  @override
  State<_GameCountdownDialog> createState() => _GameCountdownDialogState();
}

class _GameCountdownDialogState extends State<_GameCountdownDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (_countdown > 1) {
          setState(() {
            _countdown--;
          });
          _controller.reset();
          _controller.forward();
          _startCountdown();
        } else {
          widget.onComplete();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.eLearningBtnColor1,
              AppColors.eLearningBtnColor1.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Starting Game',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 12),
            
            // Message
            const Text(
              'Get ready to play!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 32),
            
            // Countdown container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Text(
                          '$_countdown',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Progress indicator
            Text(
              'Get ready...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontStyle: FontStyle.italic,
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
      ),
    );
  }
}