// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/model/e-learning/question_model.dart';

// class QuizAssessmentScreen extends StatefulWidget {
//   final Question question;

//   const QuizAssessmentScreen({Key? key, required this.question})
//       : super(key: key);

//   @override
//   _QuizAssessmentScreenState createState() => _QuizAssessmentScreenState();
// }

// class _QuizAssessmentScreenState extends State<QuizAssessmentScreen> {
//   bool _isTimerStopped = false;
//   int _currentQuestionIndex = 0;
//   int _totalQuestions = 15;
//   int currentQuestionIndex = 0;
//   bool isTimerStopped = false;
//   int? _selectedOption;
//   bool _isAnswered = false;
//   bool _isCorrect = false;

//   List<QuizQuestion> questions = [
//     TextQuestion(
//       topic: "Anti-corruption in the world",
//       questionText: "What is the main reason for corruption in Nigeria?",
//       options: [
//         "Poverty",
//         "Lack of education",
//         "Weak institutions",
//         "Cultural norms"
//       ],
//     ),
//     ImageQuestion(
//       topic: "Geography",
//       questionText: "Which country does this flag belong to?",
//       imageUrl: "assets/images/flag.png",
//       options: ["France", "Italy", "Germany", "Spain"],
//     ),
//     TypedAnswerQuestion(
//       topic: "History",
//       questionText: "In which year did World War II end?",
//       imageUrl: "assets/images/ww2.png",
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.eLearningBtnColor1,
//       appBar: AppBar(
//         backgroundColor: AppColors.eLearningBtnColor1,
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.backgroundLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: const Text('2nd Continuous Assessment',
//             style: TextStyle(color: Colors.white)),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 16),
//               _buildTimerRow(),
//               const SizedBox(height: 16),
//               _buildProgressSection(),
//               const SizedBox(height: 16),
//               _buildQuestionCard(),
//               const SizedBox(height: 16),
//               _buildNavigationButtons(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTimerRow() {
//     return Row(
//       children: [
//         // ... other timer row contents
//         TextButton(
//           onPressed: () {
//             // Show the stop timer confirmation dialog
//             _showStopTimerDialog();
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: _isTimerStopped ? Colors.grey : Colors.red,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: const Text(
//               'Stop Timer',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showStopTimerDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Are you Sure?'),
//         content: const Text('Stopping the timer will end and submit your quiz'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               // End and submit the quiz
//               Navigator.of(context).pop();
//             },
//             child: const Text('End and Submit'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Continue the quiz
//               Navigator.of(context).pop();
//             },
//             child: const Text('Continue Quiz'),
//           ),
//         ],
//       ),
//     ).then((_) {
//       setState(() {
//         _isTimerStopped = true;
//       });
//     });
//   }

//   Widget _buildProgressSection() {
//     return Container(
//       width: 400,
//       height: 65,
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: AppColors.eLearningContColor1,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Text('02 of 15',
//                   style: TextStyle(color: Colors.white, fontSize: 16)),
//               SizedBox(width: 8),
//               Text('Completed',
//                   style: TextStyle(color: Colors.white, fontSize: 12)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(64),
//             child: const LinearProgressIndicator(
//               value: 2 / 15,
//               backgroundColor: AppColors.eLearningContColor2,
//               valueColor:
//                   AlwaysStoppedAnimation<Color>(AppColors.eLearningContColor3),
//               minHeight: 8,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   Widget _buildQuestionCard() {
//     final question = questions[currentQuestionIndex];
//     return Container(
//       width: 400,
//       height: 560,
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 56.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Topic: ${question.topic}',
//               style: const TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           if (question is ImageQuestion) Image.asset(question.imageUrl),
//           Text(question.questionText),
//           const SizedBox(height: 16),
//           _buildOptions(question),
//         ],
//       ),
//     );
//   }

//   Widget _buildOptions(QuizQuestion question) {
//     if (question is OptionsQuestion) {
//       return Column(
//         children: question.options
//             .map((option) => RadioListTile<String>(
//                   title: Text(option),
//                   value: option,
//                   groupValue: null,
//                   onChanged: (value) {
//                     // Implement selection logic
//                   },
//                 ))
//             .toList(),
//       );
//     } else if (question is TypedAnswerQuestion) {
//       return const TextField(
//         decoration: InputDecoration(
//           labelText: 'Enter answer',
//           border: OutlineInputBorder(),
//         ),
//       );
//     }
//     return const SizedBox.shrink();
//   }

//   Color _getOptionColor(int index) {
//     if (_selectedOption == index && _isAnswered) {
//       return _isCorrect
//           ? AppColors.eLearningBtnColor6
//           : AppColors.eLearningBtnColor7;
//     }
//     return Colors.transparent;
//   }

//   void _selectOption(int index) {
//     setState(() {
//       _selectedOption = index;
//       _isAnswered = true;
//       _isCorrect = index == 3;
//     });
//   }


//   Widget _buildNavigationButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: () {
//               // Handle previous
//             },
//             style: OutlinedButton.styleFrom(
//               side: const BorderSide(color: Colors.white),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             child:
//                 const Text('Previous', style: TextStyle(color: Colors.white)),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () {
//               // Handle next
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.eLearningBtnColor5,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             child: const Text('Next', style: TextStyle(color: Colors.white)),
//           ),
//         ),
//       ],
//     );
//   }

//   void _navigateToNextQuestion() {
//     setState(() {
//       _currentQuestionIndex++;
//     });
//   }

//   void _submitQuiz() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Good Job!'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               // Handle the submission
//               Navigator.of(context).pop();
//             },
//             icon: const Icon(Icons.more_vert),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';

class QuizAssessmentScreen extends StatefulWidget {
  final Question question;

  const QuizAssessmentScreen({Key? key, required this.question})
      : super(key: key);

  @override
  _QuizAssessmentScreenState createState() => _QuizAssessmentScreenState();
}

class _QuizAssessmentScreenState extends State<QuizAssessmentScreen> {
  bool _isTimerStopped = false;
  int _currentQuestionIndex = 0;
  int _totalQuestions = 3;
  bool isTimerStopped = false;
  String? _selectedOption;
  bool _isAnswered = false;
  bool _isCorrect = false;

  List<QuizQuestion> questions = [
    TextQuestion(
      topic: "Anti-corruption in the world",
      questionText: "What is the main reason for corruption in Nigeria?",
      options: [
        "Poverty",
        "Lack of education",
        "Weak institutions",
        "Cultural norms"
      ],
    ),
    ImageQuestion(
      topic: "Geography",
      questionText: "Which country does this flag belong to?",
      imageUrl: "assets/images/flag.png",
      options: ["France", "Italy", "Germany", "Spain"],
    ),
    TypedAnswerQuestion(
      topic: "History",
      questionText: "In which year did World War II end?",
      imageUrl: "assets/images/ww2.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        title: const Text('2nd Continuous Assessment',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
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
            SvgPicture.asset(
              'assets/icons/clock_icon.svg',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              '58:22',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: _isTimerStopped ? null : _showStopTimerDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Stop Timer'),
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
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isTimerStopped = true;
              });
            },
            child: const Text('End and Submit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Continue Quiz'),
          ),
        ],
      ),
    );
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
      height: 560,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 56.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Topic: ${question.topic}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (question is ImageQuestion) Image.asset(question.imageUrl),
          Text(question.questionText),
          const SizedBox(height: 16),
          _buildOptions(question),
        ],
      ),
    );
  }

  Widget _buildOptions(QuizQuestion question) {
    if (question is OptionsQuestion) {
      return Column(
        children: question.options.map((option) {
          return RadioListTile<String>(
            title: question is ImageQuestion
                ? Image.asset('assets/images/$option.png')
                : Text(option),
            value: option,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
                _isAnswered = true;
                // Assuming the last option is always correct for this example
                _isCorrect = value == question.options.last;
              });
            },
            tileColor: _getOptionColor(option),
          );
        }).toList(),
      );
    } else if (question is TypedAnswerQuestion) {
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
    bool isLastQuestion = _currentQuestionIndex == _totalQuestions - 1;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _currentQuestionIndex > 0 ? _navigateToPreviousQuestion : null,
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
            title: const Text('Quiz Completed'),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Handle menu options
                },
              ),
            ],
          ),
          body: Container(
            color: const Color(0xFFE8EDFF),
            child: const Center(
              child: Text(
                'Good Job!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

  QuizQuestion({required this.topic, required this.questionText});
}

class OptionsQuestion extends QuizQuestion {
  final List<String> options;

  OptionsQuestion(
      {required String topic,
      required String questionText,
      required this.options})
      : super(topic: topic, questionText: questionText);
}

class TextQuestion extends OptionsQuestion {
  TextQuestion(
      {required String topic,
      required String questionText,
      required List<String> options})
      : super(topic: topic, questionText: questionText, options: options);
}

class ImageQuestion extends OptionsQuestion {
  final String imageUrl;

  ImageQuestion(
      {required String topic,
      required String questionText,
      required this.imageUrl,
      required List<String> options})
      : super(topic: topic, questionText: questionText, options: options);
}

class TypedAnswerQuestion extends QuizQuestion {
  final String? imageUrl;

  TypedAnswerQuestion(
      {required String topic, required String questionText, this.imageUrl})
      : super(topic: topic, questionText: questionText);
}