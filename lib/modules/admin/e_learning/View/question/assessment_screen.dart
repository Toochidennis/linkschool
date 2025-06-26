
// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/timer_widget.dart';
import 'package:linkschool/modules/admin/e_learning/View/quiz/preview_quiz_assessment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';

import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AssessmentScreen extends StatefulWidget {
  final Duration? timer;
  const AssessmentScreen({super.key, this.timer});
  

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {


  bool _isTimerStopped = false;
  int _currentQuestionIndex = 0;
  late int _totalQuestions;
  String? _selectedOption;
  String? _typedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  late double opacity;
  

  List<QuizQuestion> questions = [];

  @override
  void initState() {
    super.initState();
  
    _loadQuestions();
   
  }

  String _formatTime(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

   

//  String _formatTime(int seconds) {
//     int minutes = seconds ~/ 60;
//     int remainingSeconds = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

  Future<void> _loadQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? questionsJson = prefs.getString('created_questions');
      if (questionsJson != null) {
        final List<dynamic> questionsData = json.decode(questionsJson);
        setState(() {
          questions = questionsData.map((q) {
            final String topic = q['topic'] ?? "General Knowledge";
            final String questionText = q['title']?.isNotEmpty == true ? q['title'] : '';
            final String? imagePath = q['file']?.isNotEmpty == true ? q['file'][0]['file'] : null;
            final List<dynamic> correctAnswers = q['correct'] ?? [];
            if (q['type'] == 'multiple_choice') {
              return TextQuestion(
                topic: topic,
                questionText: questionText,
                imageUrl: imagePath,
                options: (q['options'] as List).map((opt) => ({
                      'text': opt['text'],
                      'imageUrl': opt['options_file']?['base64'],
                    })).toList(),
                correctAnswers: correctAnswers.map((e) => e['text'] as String).toList(),
              );
            } else {
              return TypedAnswerQuestion(
                topic: topic,
                questionText: questionText,
                imageUrl: imagePath,
                correctAnswer: correctAnswers.isNotEmpty ? correctAnswers[0]['text'] : null,
              );
            }
          }).toList();
          _totalQuestions = questions.length;
        });
      } else {
        setState(() {
          questions = [
            TextQuestion(
              topic: "Anti-corruption in the world",
              questionText: "What is the main reason for corruption in Nigeria?",
              options: [
                {'text': "Poverty", 'imageUrl': null},
                {'text': "Lack of education", 'imageUrl': null},
                {'text': "Weak institutions", 'imageUrl': null},
                {'text': "Cultural norms", 'imageUrl': null},
              ],
              correctAnswers: ["Weak institutions"],
            ),
            ImageQuestion(
              topic: "Geography",
              questionText: "Which country does this flag belong to?",
              imageUrl: "assets/images/e-learning/france_flag.png",
              options: [
                {'text': "France", 'imageUrl': null},
                {'text': "Italy", 'imageUrl': null},
                {'text': "Germany", 'imageUrl': null},
                {'text': "Spain", 'imageUrl': null},
              ],
              correctAnswers: ["France"],
            ),
            TypedAnswerQuestion(
              topic: "History",
              questionText: "In which year did World War II end?",
              imageUrl: "assets/images/e-learning/ww2.jpg",
              correctAnswer: "1945",
            ),
          ];
          _totalQuestions = questions.length;
        });
      }
    } catch (e) {
      debugPrint('Error loading questions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      backgroundColor: AppColors.eLearningBtnColor1,
      appBar: AppBar(
        backgroundColor: AppColors.eLearningBtnColor1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: const Text(
          '2nd Continuous Assessment',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTimerRow(),
                    const SizedBox(height: 16),
                    _buildProgressSection(),
                    const SizedBox(height: 16),
                    _buildQuestionCard(),
                    const SizedBox(height: 16),
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTimerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            
            const SizedBox(width: 8),
           TimerWidget(
          initialSeconds: widget.timer?.inSeconds ?? 3600, // Default to 1 hour
          onTimeUp: _submitQuiz,
        ),
          ],
        ),
        // TextButton(
        //  onPressed: _isTimerStopped ? null : () {
        //     _showStopTimerDialog();},
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //     decoration: BoxDecoration(
        //       color: _isTimerStopped ? Colors.grey : Colors.red,
        //       borderRadius: BorderRadius.circular(4),
        //     ),
        //     child: const Text(
        //       'Stop Timer',
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  void _showStopTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you Sure?'),
        content: const Text('Stopping the timer will end and submit your quiz'),
        actions: [
          Row(
            children: [
              CustomOutlineButton(
                onPressed: (){
                   Navigator.of(context).pop();
                
                  _submitQuiz();
                 
                } ,
                text: 'End and Submit',
                borderColor: AppColors.eLearningBtnColor3,
                textColor: AppColors.eLearningBtnColor3,
              ),
              CustomMediumElevatedButton(
                text: 'Continue Quiz',
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: AppColors.eLearningBtnColor5,
                textStyle: AppTextStyles.normal600(
                    fontSize: 14, color: AppColors.backgroundLight),
                padding: const EdgeInsets.all(8.0),
              ),
            ],
          ),
        ],
      ),
    ).then((_) {
      setState(() {
        _isTimerStopped = true;
      });
    });
  }

  Widget _buildProgressSection() {
    return Container(
      width: 400,
      height: 65,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.eLearningContColor1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${_currentQuestionIndex + 1} of $_totalQuestions',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(width: 8),
              const Text('Completed',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(64),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _totalQuestions,
              backgroundColor: AppColors.eLearningContColor2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.eLearningContColor3),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = questions[_currentQuestionIndex];
    return Container(
      width: 400,
      height: 400,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
  
          const SizedBox(height: 8),
          if (question.imageUrl != null)
            Image.memory(
              base64Decode(question.imageUrl ?? ''),
              height: 100,
              width:double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/e-learning/placeholder.png',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 8),
          Text(question.questionText),
          const SizedBox(height: 16),
          Expanded(child: _buildOptions(question)),
        ],
      ),
    );
  }

  Widget _buildOptions(QuizQuestion question) {
    if (question is OptionsQuestion && question.options.isNotEmpty) {
      return ListView(
        children: question.options.map((option) {
          return RadioListTile<String>(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option['text']),
                if (option['imageUrl'] != null)
                  Image.memory(
                    base64Decode(option['imageUrl']),
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/e-learning/placeholder.png',
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            value: option['text'],
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
                _isAnswered = true;
                _isCorrect = question is TextQuestion &&
                    (question as TextQuestion).correctAnswers.contains(value);
              });
            },
            tileColor: _getOptionColor(option['text']),
          );
        }).toList(),
      );
    } else if (question is TypedAnswerQuestion) {
      return TextField(
        onChanged: (value) {
          setState(() {
            _typedAnswer = value;
            _isAnswered = value.isNotEmpty;
            _isCorrect = question.correctAnswer != null &&
                value.trim().toLowerCase() == question.correctAnswer!.toLowerCase();
          });
        },
        decoration: const InputDecoration(
          labelText: 'Enter answer',
          border: OutlineInputBorder(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _getOptionColor(String option) {
    if (_selectedOption == option && _isAnswered) {
      return _isCorrect
          ? AppColors.eLearningBtnColor6
          : AppColors.eLearningBtnColor7;
    }
    return Colors.transparent;
  }

  Widget _buildNavigationButtons() {
    bool isLastQuestion = _currentQuestionIndex == _totalQuestions - 1;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
                _currentQuestionIndex > 0 ? _navigateToPreviousQuestion : null,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child:
                const Text('Previous', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLastQuestion ? _submitQuiz : _navigateToNextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eLearningBtnColor5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(isLastQuestion ? 'Submit' : 'Next',
                style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  void _navigateToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _resetQuestionState();
      });
    }
  }

  void _navigateToNextQuestion() {
    if (_currentQuestionIndex < _totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _resetQuestionState();
      });
    }
  }

  void _resetQuestionState() {
    _selectedOption = null;
    _typedAnswer = null;
    _isAnswered = false;
    _isCorrect = false;
  }

  void _submitQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Image.asset(
                'assets/icons/arrow_back.png',
                color: AppColors.primaryLight,
                width: 34.0,
                height: 34.0,
              ),
            ),
            title: Text(
              'Quiz Completed',
              style: AppTextStyles.normal600(
                fontSize: 24.0,
                color: AppColors.primaryLight,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
            backgroundColor: AppColors.backgroundLight,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: opacity,
                      child: Image.asset(
                        'assets/images/background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          body: Container(
            decoration: Constants.customBoxDecoration(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Good Job!',
                    style: AppTextStyles.normal600(
                        fontSize: 34, color: AppColors.eLearningContColor2),
                  ),
                  Text(
                    'Your test has been recorded and will be marked by your tutor soon.',
                    style: AppTextStyles.normal500(
                        fontSize: 18, color: AppColors.textGray),
                  ),
                  const SizedBox(
                    height: 48.0,
                  ),
                  CustomLongElevatedButton(
                    text: 'Back to Home',
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    backgroundColor: AppColors.eLearningContColor2,
                    textStyle: AppTextStyles.normal600(
                        fontSize: 22, color: AppColors.backgroundLight),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  CustomOutlineButton(
                      width: double.infinity,
                      height: 50,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PreviewQuizAssessmentScreen(),
                          ),
                        );
                      },
                      text: 'Preview Result',
                      borderColor: AppColors.eLearningContColor2,
                      textColor: AppColors.eLearningContColor2)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract class QuizQuestion {
  final String topic;
  final String questionText;
  final String? imageUrl;

  QuizQuestion({
    required this.topic,
    required this.questionText,
    this.imageUrl,
  });
}

class OptionsQuestion extends QuizQuestion {
  final List<Map<String, dynamic>> options;

  OptionsQuestion({
    required super.topic,
    required super.questionText,
    required this.options,
    super.imageUrl,
  });
}

class TextQuestion extends OptionsQuestion {
  final List<String> correctAnswers;

  TextQuestion({
    required super.topic,
    required super.questionText,
    required super.options,
    super.imageUrl,
    required this.correctAnswers,
  });
}

class ImageQuestion extends OptionsQuestion {
  final List<String> correctAnswers;

  ImageQuestion({
    required super.topic,
    required super.questionText,
    required super.options,
    required super.imageUrl,
    required this.correctAnswers,
  });
}

class TypedAnswerQuestion extends QuizQuestion {
  final String? correctAnswer;

  TypedAnswerQuestion({
    required super.topic,
    required super.questionText,
    super.imageUrl,
    this.correctAnswer,
  });
}



