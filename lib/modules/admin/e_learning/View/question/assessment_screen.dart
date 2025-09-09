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
import 'package:linkschool/modules/model/e-learning/quiz_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AssessmentScreen extends StatefulWidget {
  final Duration? timer;
  final Duration? duration;
  final List<Map<String, dynamic>>? questions;
  final String? mark;
  final String? title;
  final correctAnswer;
  const AssessmentScreen({
    super.key,
    this.timer,
    this.questions,
    this.duration,
    this.correctAnswer,
     this.mark,
     this.title
  });

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
 dynamic _tempAnswer;

  List<QuizQuestion> questions = [];
  List<dynamic> userAnswers = [];
   final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose(){
    _textController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    if (hours == 0 ) {
      return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
    }else {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

 Future<void> _loadQuestions() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? savedQuestions = prefs.getString('preview_questions');

    if (savedQuestions != null && savedQuestions.isNotEmpty) {
      final List<dynamic> questionsJson = jsonDecode(savedQuestions);
      print('Loaded questions from SharedPreferences: $questionsJson');
      setState(() {
        questions = questionsJson.map((q) {
          final String topic = q['topic'] ?? "General Knowledge";
          final String questionText = q['question_text'] ?? '';
          final int questionGrade = int.tryParse(q['question_grade'].toString()) ?? 0;
          final List<dynamic> questionFiles = q['question_files'] as List<dynamic>? ?? [];
          final String? imagePath = questionFiles.isNotEmpty
              ? questionFiles[0]['file_name'] as String?
              : null;
          final Map<String, dynamic>? correct = q['correct'] is List && (q['correct'] as List).isNotEmpty
              ? (q['correct'] as List).first as Map<String, dynamic>?
              : q['correct'] as Map<String, dynamic>?;

          if (q['question_type'] == 'multiple_choice') {
            final List<dynamic> options = q['options'] as List<dynamic>? ?? [];
            return TextQuestion(
              topic: topic,
              questionGrade: questionGrade,
              questionText: questionText,
              imageUrl: imagePath,
              options: options.map((opt) {
                final List<dynamic> optionFiles = opt['option_files'] as List<dynamic>? ?? [];
                return {
                  'text': opt['text'] as String? ?? '',
                  'imageUrl': optionFiles.isNotEmpty
                      ? optionFiles[0]['file_name'] as String?
                      : null,
                  'order': opt['order']?.toString(),
                };
              }).toList(),
              correctAnswers: correct != null && correct['text'] != null
                  ? [correct['text'] as String]
                  : [],
            );
          } else {
            return TypedAnswerQuestion(
              topic: topic,
              questionGrade: questionGrade,
              questionText: questionText,
              imageUrl: imagePath,
              correctAnswer: correct != null ? correct['text'] as String? : null,
            );
          }
        }).toList();
        _totalQuestions = questions.length;
        userAnswers = List<dynamic>.filled(_totalQuestions, null, growable: false);
      });
    } else if (widget.questions != null && widget.questions!.isNotEmpty) {
      print('Falling back to widget.questions: ${widget.questions}');
      setState(() {
        questions = widget.questions!.map((q) {
          final String topic = q['topic'] ?? "General Knowledge";
          final String questionText = q['question_text'] ?? '';
          final int questionGrade = int.tryParse(q['question_grade'].toString()) ?? 0;
          final List<dynamic> questionFiles = q['question_files'] as List<dynamic>? ?? [];
          final String? imagePath = questionFiles.isNotEmpty
              ? questionFiles[0]['file_name'] as String?
              : null;
          final Map<String, dynamic>? correct = q['correct'] as Map<String, dynamic>?;
          if (q['question_type'] == 'multiple_choice') {
            final List<dynamic> options = q['options'] as List<dynamic>? ?? [];
            return TextQuestion(
              topic: topic,
              questionGrade: questionGrade,
              questionText: questionText,
              imageUrl: imagePath,
              options: options.map((opt) {
                final List<dynamic> optionFiles = opt['option_files'] as List<dynamic>? ?? [];
                return {
                  'text': opt['text'] as String? ?? '',
                  'imageUrl': optionFiles.isNotEmpty
                      ? optionFiles[0]['file_name'] as String?
                      : null,
                  'order': opt['order']?.toString(),
                };
              }).toList(),
              correctAnswers: correct != null && correct['text'] != null
                  ? [correct['text'] as String]
                  : [],
            );
          } else {
            return TypedAnswerQuestion(
              topic: topic,
              questionGrade: questionGrade,
              questionText: questionText,
              imageUrl: imagePath,
              correctAnswer: correct != null ? correct['text'] as String? : null,
            );
          }
        }).toList();
        _totalQuestions = questions.length;
        userAnswers = List<dynamic>.filled(_totalQuestions, null, growable: false);
      });
    } else {
      print('No questions available');
      setState(() {
        questions = [];
        _totalQuestions = questions.length;
        userAnswers = List<dynamic>.filled(_totalQuestions, null, growable: false);
      });
    }
  } catch (e) {
    print('Error loading questions: $e');
    setState(() {
      questions = [];
      _totalQuestions = questions.length;
      userAnswers = List<dynamic>.filled(_totalQuestions, null, growable: false);
    });
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
          onPressed: () async {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('preview_questions');
      // Navigate back
      Navigator.of(context).pop();
    },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title:  Text(
       widget.title ?? '2nd Continuous Assessment',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, fontFamily:"urbanist"),
        ),
        elevation: 0,
      ),
      body: questions.isEmpty
          ? const Center(child:Text("no Questions Available",style: TextStyle( color:Colors.white,fontSize: 20),))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTimerRow(),
                  const SizedBox(height: 16),
                  _buildProgressSection(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildQuestionCard()),
                  const SizedBox(height: 16),
                  _buildNavigationButtons(),
                ],
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
              initialSeconds: widget.duration?.inSeconds ?? 3600, // Default to 1 hour
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
  // Count the number of answered questions (non-null entries in userAnswers)
  int answeredQuestions = userAnswers.where((answer) => answer != null).length;

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
            Text('$answeredQuestions of $_totalQuestions',
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
            // Use answeredQuestions instead of _currentQuestionIndex
            value: _totalQuestions > 0 ? answeredQuestions / _totalQuestions : 0,
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
    final questionImage = question.imageUrl != null
        ? NetworkImage("https://linkskool.net/${question.imageUrl}")
        : null;

    return SingleChildScrollView(
      child: Container(
          width: 400,
        
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        backgroundColor: AppColors.eLearningBtnColor1,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      body: Center(
                        child: Image.network(
                          "https://linkskool.net/${question.imageUrl}",
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Image.network(
                            'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
                  child: Image.network(
                    "https://linkskool.net/${question.imageUrl}",
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg',
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(question.questionText[0].toUpperCase() + question.questionText.substring(1),style:TextStyle(fontSize: 23),),
              const SizedBox(height: 16),
              _buildOptions(question),
            ],
          ),
        ),
    
    );
    
  }

Widget _buildOptions(QuizQuestion question) {
  if (question is OptionsQuestion && question.options.isNotEmpty) {
    print(question.options);
    return Column(
      children: question.options.map((option) {
        // Check if the option is an image (has imageUrl and is not null)
        final bool isImage = option['imageUrl'] != null;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: _getOptionColor(option['text']),
            borderRadius: BorderRadius.circular(8),
            border: isImage
          ? null // Remove border if it's an image
          : Border.all(
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
          if (!isImage)
            Text(option['text']),
          if (isImage)
            GestureDetector(
              onTap: () {
                Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  backgroundColor: AppColors.eLearningBtnColor1,
                  leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: Center(
                  child: Image.network(
              'https://linkskool.net/${option['imageUrl']}',
              fit: BoxFit.cover,
            height: double.infinity,
                          width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Image.network(
                'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg',
                fit: BoxFit.cover,
              ),
                  ),
                ),
              ),
            ),
                );
              },
              child: SizedBox(
                width: 400,
                height: 100,
                child: Image.network(
            'https://linkskool.net/${option['imageUrl']}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.network(
              'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 120,
            ),
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
          _tempAnswer = value; // Store in _tempAnswer instead of userAnswers
          _isAnswered = true;
          _isCorrect = question is TextQuestion &&
              (question as TextQuestion).correctAnswers.contains(value);
              });
            },
            activeColor: Colors.blue,
            tileColor: Colors.transparent,
          ),
        );
            }).toList(),
          );
        } else if (question is TypedAnswerQuestion) {
          return TextField(
            controller: _textController,
            onChanged: (value) {
        setState(() {
          _typedAnswer = value;
          _tempAnswer = value;
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
      // return _isCorrect
      //     ? const Color.fromARGB(255, 230, 236, 255)
      //     : AppColors.eLearningBtnColor7;

      return  const Color.fromARGB(255, 230, 236, 255);
          // Red for incorrect
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
        _restoreUserAnswer();
      });
    }
  }

  void _navigateToNextQuestion() {
    if (_currentQuestionIndex < _totalQuestions - 1) {
      setState(() {
        if (_isAnswered) {
        userAnswers[_currentQuestionIndex] = _tempAnswer;
      }
        _currentQuestionIndex++;
        _restoreUserAnswer();
      });
    }
  }

 void _restoreUserAnswer() {
  // Restore the answer for the current question
  final answer = userAnswers[_currentQuestionIndex];
  final question = questions[_currentQuestionIndex];
  if (question is OptionsQuestion) {
    _selectedOption = answer as String?;
    _typedAnswer = null;
    _textController.clear(); // Clear the text field
    _isAnswered = _selectedOption != null;
    _isCorrect = question is TextQuestion &&
        (question as TextQuestion).correctAnswers.contains(_selectedOption);
  } else if (question is TypedAnswerQuestion) {
    _typedAnswer = answer as String?;
    _selectedOption = null;
    _textController.text = _typedAnswer ?? ''; // Restore previous answer or clear
    _isAnswered = _typedAnswer != null && _typedAnswer!.isNotEmpty;
    _isCorrect = question.correctAnswer != null &&
        _typedAnswer != null &&
        _typedAnswer!.trim().toLowerCase() == question.correctAnswer!.toLowerCase();
  } else {
    _selectedOption = null;
    _typedAnswer = null;
    _textController.clear(); // Clear the text field
    _isAnswered = false;
    _isCorrect = false;
  }
}

  void _resetQuestionState() {
    // This is now handled by _restoreUserAnswer when navigating
    _restoreUserAnswer();
  }

 void _submitQuiz() {
  // Save current answer if user is answering
  if (_isAnswered) {
    userAnswers[_currentQuestionIndex] = _tempAnswer;
  }

int totalScore = 0;
  for (int i = 0; i < questions.length; i++) {
    final question = questions[i];
    final userAnswer = userAnswers[i];
    final correctAnswer = question is TextQuestion
        ? question.correctAnswers.first
        : (question as TypedAnswerQuestion).correctAnswer;
    if (userAnswer != null &&
        userAnswer.toString().trim().toLowerCase() == correctAnswer?.toLowerCase()) {
      totalScore += question.questionGrade;
    }
  }
  // Process user answers to check for image extensions and get corresponding image URLs
  List<dynamic> processedAnswers = [];
  
  for (int i = 0; i < userAnswers.length; i++) {
    dynamic answer = userAnswers[i];
    if (answer != null && answer is String) {
      // Check if answer ends with common image extensions
      bool endsWithImageExtension = answer.toLowerCase().endsWith('.jpg') ||
                                   answer.toLowerCase().endsWith('.jpeg') ||
                                   answer.toLowerCase().endsWith('.png') ||
                                   answer.toLowerCase().endsWith('.gif') ||
                                   answer.toLowerCase().endsWith('.webp') ||
                                   answer.toLowerCase().endsWith('.bmp');
      
      if (endsWithImageExtension) {
        // Find the corresponding option's image URL
        final question = questions[i];
        if (question is OptionsQuestion) {
          // Look for the option that matches this answer
          bool foundMatch = false;
          for (var option in question.options) {
            if (option['text'] == answer && option['imageUrl'] != null) {
              // Replace the text answer with the image URL
              processedAnswers.add(option['imageUrl']);
              foundMatch = true;
              break;
            }
          }
          // If no matching option found, keep the original answer
          if (!foundMatch) {
            processedAnswers.add(answer);
          }
        } else {
          processedAnswers.add(answer);
        }
      } else {
        // Answer doesn't end with image extension, keep as is
        processedAnswers.add(answer);
      }
    } else {
      // Answer is null or not a string, keep as is
      processedAnswers.add(answer);
    }
  }

  // Process correct answers separately
 List<Map<String, dynamic>> processedCorrectAnswers = [];
  
  for (int i = 0; i < questions.length; i++) {
    final question = questions[i];
    
    if (question is TextQuestion) {
      // For TextQuestion, get the first correct answer
      final correctAnswer = question.correctAnswers.isNotEmpty 
          ? question.correctAnswers.first 
          : null;
      
      if (correctAnswer != null && correctAnswer is String) {
        // Check if it's an image file name
        bool endsWithImageExtension = correctAnswer.toLowerCase().endsWith('.jpg') ||
                                     correctAnswer.toLowerCase().endsWith('.jpeg') ||
                                     correctAnswer.toLowerCase().endsWith('.png') ||
                                     correctAnswer.toLowerCase().endsWith('.gif') ||
                                     correctAnswer.toLowerCase().endsWith('.webp') ||
                                     correctAnswer.toLowerCase().endsWith('.bmp');
        
        if (endsWithImageExtension) {
          // Find the corresponding option's image URL
          bool foundMatch = false;
          for (var option in question.options) {
            if (option['text'] == correctAnswer && option['imageUrl'] != null) {
              processedCorrectAnswers.add({
                'text': correctAnswer,
                'imageUrl': option['imageUrl']
              });
              foundMatch = true;
              break;
            }
          }
          if (!foundMatch) {
            processedCorrectAnswers.add({
              'text': correctAnswer,
              'imageUrl': null
            });
          }
        } else {
          processedCorrectAnswers.add({
            'text': correctAnswer,
            'imageUrl': null
          });
        }
      } else {
        processedCorrectAnswers.add({
          'text': '',
          'imageUrl': null
        });
      }
    } else if (question is TypedAnswerQuestion) {
      final correctAnswer = question.correctAnswer;
      if (correctAnswer != null && correctAnswer is String) {
        processedCorrectAnswers.add({
          'text': correctAnswer,
          'imageUrl': null
        });
      } else {
        processedCorrectAnswers.add({
          'text': '',
          'imageUrl': null
        });
      }
    } else {
      // Default case
      processedCorrectAnswers.add({
        'text': '',
        'imageUrl': null
      });
    }
  }

  // Navigate to preview screen with processed answers
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => PreviewQuizAssessmentScreen(
        userAnswer: processedAnswers,
        question: questions,
        correctAnswers: processedCorrectAnswers,
        mark:totalScore.toString(),
        duration: widget.duration,
      ),
    ),
  );
}
}

abstract class QuizQuestion {
  final String topic;
  final String questionText;
  final String? imageUrl;
    final int questionGrade;

  QuizQuestion({
    required this.topic,
    required this.questionText,
    this.imageUrl,
  required this.questionGrade,
  });
}

class OptionsQuestion extends QuizQuestion {
  final List<Map<String, dynamic>> options;

  OptionsQuestion({
    required super.topic,
    required super.questionText,
    required this.options,
    super.imageUrl,
    required super.questionGrade,
  });
}

class TextQuestion extends OptionsQuestion {
  final List<String> correctAnswers;

  TextQuestion({
    required super.topic,
    required super.questionText,
    required super.options,
    super.imageUrl,
    required this.correctAnswers, required super.questionGrade,
  });
}

class ImageQuestion extends OptionsQuestion {
  final List<String> correctAnswers;

  ImageQuestion({
    required super.topic,
    required super.questionText,
    required super.options,
    required super.imageUrl,
    required this.correctAnswers, required super.questionGrade,
  });
}

class TypedAnswerQuestion extends QuizQuestion {
  final String? correctAnswer;
  // Removed duplicate questionGrade field and moved required super.questionGrade to constructor initializer list

  TypedAnswerQuestion({
    required super.topic,
    required super.questionText,
    super.imageUrl,
    required super.questionGrade,
    this.correctAnswer,
  });
}