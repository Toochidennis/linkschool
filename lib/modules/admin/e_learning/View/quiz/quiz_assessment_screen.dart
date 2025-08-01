import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/admin/e_learning/View/quiz/preview_quiz_assessment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';


class QuizAssessmentScreen extends StatefulWidget {
    final List<Map<String, dynamic>> questions;
  final Question question;

  const QuizAssessmentScreen({super.key, required this.question, required this.questions});

  @override
  _QuizAssessmentScreenState createState() => _QuizAssessmentScreenState();
}

class _QuizAssessmentScreenState extends State<QuizAssessmentScreen> {
  bool _isTimerStopped = false;
  int _currentQuestionIndex = 0;
  String? _selectedOption;
  bool _isAnswered = false;
  bool _isCorrect = false;
  late double opacity;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    // Use the passed-in questions
    final currentQuestionData = widget.questions.isNotEmpty ? widget.questions[_currentQuestionIndex] : null;

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
        title: Text(widget.question.title,
            style: const TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: widget.questions.isEmpty
          ? const Center(child: Text('No questions available.', style: TextStyle(color: Colors.white)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTimerRow(),
              const SizedBox(height: 16),
              _buildProgressSection(),
              const SizedBox(height: 16),
              if (currentQuestionData != null) _buildQuestionCard(currentQuestionData),
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
            SvgPicture.asset(
              'assets/icons/e_learning/stopwatch_icon.svg',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.question.duration.inMinutes}:00',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            _showStopTimerDialog();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isTimerStopped ? Colors.grey : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Stop Timer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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
                onPressed: () => Navigator.of(context).pop(),
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
              Text('${_currentQuestionIndex + 1} of ${widget.questions.length}',
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
              value: (_currentQuestionIndex + 1) / widget.questions.length,
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

  Widget _buildQuestionCard(Map<String, dynamic> questionData) {
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
          Text('Topic: ${widget.question.topic}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Handle image display if available
          if (questionData['question_files'] != null && (questionData['question_files'] as List).isNotEmpty)
            Image.network(
              // Assuming the file is a URL, adjust if it's base64 or a local path
              "https://your-base-url.com/${questionData['question_files'][0]['file_name']}",
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Text(questionData['question_text'] ?? 'No question text'),
          const SizedBox(height: 16),
          _buildOptions(questionData),
        ],
      ),
    );
  }

  Widget _buildOptions(Map<String, dynamic> questionData) {
    final questionType = questionData['question_type'];
    final options = (questionData['options'] as List<dynamic>?) ?? [];

    if (questionType == 'multiple_choice' && options.isNotEmpty) {
      return Column(
        children: options.map((option) {
          final optionText = option['text']?.toString() ?? '';
          return RadioListTile<String>(
            title: Text(optionText),
            value: optionText,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
                _isAnswered = true;
                _isCorrect = (questionData['correct']?['text'] == value);
              });
            },
            tileColor: _getOptionColor(optionText),
          );
        }).toList(),
      );
    } else if (questionType == 'short_answer') {
      return const TextField(
        decoration: InputDecoration(
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
    bool isLastQuestion = _currentQuestionIndex == widget.questions.length - 1;
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
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _resetQuestionState();
      });
    }
  }

  void _resetQuestionState() {
    _selectedOption = null;
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
                            builder: (context) => PreviewQuizAssessmentScreen(
                              correctAnswers: [],
                              question:[], 
                              userAnswer: [],
                             // You need to define and maintain this map/list in your state to track correct answers
                            ),
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
