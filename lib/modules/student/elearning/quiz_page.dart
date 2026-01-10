import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/student/elearningcontent_model.dart';
import 'package:linkschool/modules/model/student/quiz_submission_model.dart';
import 'package:linkschool/modules/services/student/quiz_submission_service.dart';

import '../../admin/e_learning/View/question/timer_widget.dart';
import '../../common/app_colors.dart';
import '../../common/buttons/custom_long_elevated_button.dart';
import '../../common/buttons/custom_medium_elevated_button.dart';
import '../../common/buttons/custom_outline_button..dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';

class AssessmentScreen extends StatefulWidget {
  final Duration? timer;
  final Duration? duration;
  final String? quizTitle;
  final ChildContent? childContent;
  final List<Question>? questions;
  final correctAnswer;
  const AssessmentScreen(
      {super.key,
      this.timer,
      this.questions,
      this.duration,
      this.correctAnswer,
      this.quizTitle,
      this.childContent});

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
  final String networkImage =
      'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

  List<QuizQuestion> questions = [];
  double? totalscore;

  // List to keep track of user answers
  List<dynamic> userAnswers = [];

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

  getuserdata() {
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData =
        storedUserData is String ? json.decode(storedUserData) : storedUserData;
    final response = processedData['response'] ?? processedData;
    final data = response['data'] ?? response;
    return data;
  }

  Future<void> _loadQuestions() async {
    try {
      if (widget.questions != null && widget.questions!.isNotEmpty) {
        setState(() {
          questions = widget.questions!.map((q) {
            final String topic = "General Knowledge";
            final String questionText = q.questionText ?? '';
            final List<dynamic> questionFiles = q.questionFiles ?? [];

            final String? imagePath = questionFiles.isNotEmpty
                ? questionFiles[0]['file_name'] as String?
                : null;

            final CorrectAnswer correct = q.correct;

            if (q.questionType == 'multiple_choice') {
              final List<Option> options = q.options ?? [];

              return TextQuestion(
                topic: topic,
                questionText: questionText,
                imageUrl: imagePath,
                options: options.map((opt) {
                  final String? optionImage = opt.optionFiles.isNotEmpty
                      ? opt.optionFiles[0]['file_name'] as String?
                      : null;

                  return {
                    'text': opt.text,
                    'imageUrl': optionImage,
                  };
                }).toList(),
                correctAnswers: correct != null ? [correct.text] : [],
              );
            } else {
              // Handles 'short_answer'
              return TypedAnswerQuestion(
                topic: topic,
                questionText: questionText,
                imageUrl: imagePath,
                correctAnswer: correct.text ?? '',
              );
            }
          }).toList();

          _totalQuestions = questions.length;
          userAnswers =
              List<dynamic>.filled(_totalQuestions, null, growable: false);
        });
      } else {
        // fallback demo questions
        setState(() {
          questions = [
            TextQuestion(
              topic: "Anti-corruption in the world",
              questionText:
                  "What is the main reason for corruption in Nigeria?",
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
          userAnswers =
              List<dynamic>.filled(_totalQuestions, null, growable: false);
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
        title: Text(
          widget.quizTitle ?? 'No title',
          style: TextStyle(color: Colors.white, fontSize: 16),
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
              initialSeconds:
                  widget.duration?.inSeconds ?? 3600, // Default to 1 hour
              onTimeUp: _submitQuiz,
            ),
          ],
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
                onPressed: () {
                  Navigator.of(context).pop();
                  _submitQuiz();
                },
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
              Text('$_currentQuestionIndex  of $_totalQuestions',
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
              value: (_currentQuestionIndex) / _totalQuestions,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            leading: IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            title: Text("Image View"),
                          ),
                          body: Center(
                            child: Image.network(
                              'https://linkskool.net/${question.imageUrl}',
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                      "https://linkskool.net/${question.imageUrl!}",
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.network(
                            networkImage,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            question.questionText,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
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
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: _getOptionColor(option['text']),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedOption == option['text']
                    ? Colors.blue
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: RadioListTile<String>(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (option['imageUrl'] == null)
                    Text(
                      option['text'],
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  if (option['imageUrl'] != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                leading: IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                title: Text("Image View"),
                              ),
                              body: Center(
                                child: Image.network(
                                  'https://linkskool.net/${option['imageUrl']}',
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        'https://linkskool.net/${option['imageUrl']}',
                        height: 60,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.network(
                          'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg',
                          height: 100,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
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
                      (question).correctAnswers.contains(value);

                  userAnswers[_currentQuestionIndex] = value;
                });
              },
              activeColor: Colors.blue, // Radio color when selected
              tileColor: Colors.transparent, // Let container handle color
            ),
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
                value.trim().toLowerCase() ==
                    question.correctAnswer!.toLowerCase();
            userAnswers[_currentQuestionIndex] = value;
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
    if (_selectedOption == option) {
      // Highlight in blue if selected
      return Colors.blue.shade100; // Or use your theme color
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

  Future<void> _submitQuiz() async {
    final List<Map<String, dynamic>> answers =
        widget.questions!.asMap().entries.map((entry) {
      int index = entry.key;
      var q = entry.value;
      return {
        "question_id": q.questionId,
        "question": q.questionText,
        "correct": q.correct.text,
        "answer": userAnswers[index] ?? "",
        "type": q.questionType
      };
    }).toList();
    QuizSubmissionService service = QuizSubmissionService();
    Map<String, dynamic> quizpayload = {
      "quiz_id": widget.childContent?.settings!.id,
      "student_id": getuserdata()['profile']['id'],
      "student_name": getuserdata()['profile']['name'],
      "answers": answers,
      "mark": 0,
      "score": 0,
      "level_id": getuserdata()['profile']['level_id'],
      "course_id": widget.childContent?.id ?? 0,
      "class_id": getuserdata()['profile']['class_id'],
      "course_name": widget.childContent!.title ?? "No title",
      "class_name": (widget.childContent?.classes != null &&
              widget.childContent!.classes!.isNotEmpty)
          ? widget.childContent!.classes![0].name
          : "No class name",
      "term": getuserdata()['settings']['term'],
      "year": int.parse(getuserdata()['settings']['year']),
      "_db": "aalmgzmy_linkskoo_practice"
    };

    bool success = await service
        .submitAssignment(QuizSubmissionModel.fromJson(quizpayload));
    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog.fullscreen(
          child: Scaffold(
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
                        Navigator.of(context)
                          ..pop()
                          ..pop()
                          ..pop();
                      },
                      backgroundColor: AppColors.eLearningContColor2,
                      textStyle: AppTextStyles.normal600(
                          fontSize: 22, color: AppColors.backgroundLight),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
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
