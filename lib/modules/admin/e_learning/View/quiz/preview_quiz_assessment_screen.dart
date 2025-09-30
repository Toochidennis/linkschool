// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/assessment_screen.dart' ;
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/quiz_model.dart'hide QuizQuestion;

class PreviewQuizAssessmentScreen extends StatelessWidget {
   late double opacity;
   final List<QuizQuestion> question;
   final List<dynamic> correctAnswers;
  final List<dynamic> userAnswer;
  final String? mark;
 final  Duration? duration;
  PreviewQuizAssessmentScreen({
    super.key,
    required this.question,
    required this.correctAnswers,
    required this.userAnswer,  this.mark,
     this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
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
        title: const Text('Quiz Summary'),
        centerTitle: true,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2nd Continuous Assessment Test.......',
                style: AppTextStyles.normal600(fontSize: 18, color: AppColors.eLearningContColor2),
              ),
              const SizedBox(height: 16),
              _buildScoreCard(),
              const SizedBox(height: 16),
              // Dynamic question list
              ...List.generate(question.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildDynamicQuestionCard(index),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Method to get user answer safely
  String _getUserAnswer(int index) {
    if (index < userAnswer.length && userAnswer[index] != null) {
      return userAnswer[index].toString().trim();
    }
    return '';
  }

String _getCorrectAnswer(int index) {
  if (index < correctAnswers.length && correctAnswers[index] != null) {
    final answer = correctAnswers[index] as Map<String, dynamic>;
    return answer['imageUrl']?.toString().trim() ?? answer['text']?.toString().trim() ?? '';
  }
  return '';
}


  // Method to determine question status
  String _getQuestionStatus(int index) {
    String userAns = _getUserAnswer(index);
    String correctAns = _getCorrectAnswer(index);
    
    if (userAns.isEmpty) {
      return 'No answer';
    }
    
    // Case-insensitive comparison
    if (userAns.toLowerCase() == correctAns.toLowerCase()) {
      return 'Correct';
    }
    
    return 'Wrong';
  }

  // Method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Correct':
        return AppColors.attCheckColor2;
      case 'Wrong':
        return AppColors.eLearningRedBtnColor;
      case 'No answer':
      default:
        return AppColors.text5Light;
    }
  }

  // Calculate total score
  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < question.length; i++) {
      if (_getQuestionStatus(i) == 'Correct') {
       // score += question[i].questionGrade ?? 5; // Default to 5 if grade is null
     score += question[i].questionGrade;
      }
    }
    return score;
  }

  // Calculate total possible score
  int _calculateTotalScore() {
    int total = 0;
    for (var q in question) {
      //total += q.questionGrade ?? 5; // Default to 5 if grade is null
    total += q.questionGrade;
    }
    return total;
  }

  // Count correct answers
  int _countCorrectAnswers() {
    int correct = 0;
    for (int i = 0; i < question.length; i++) {
      if (_getQuestionStatus(i) == 'Correct') {
        correct++;
      }
    }
    return correct;
  }

 Widget _buildScoreCard() {
  int correctAnswers = _countCorrectAnswers();
  int totalQuestions = question.length;
  int totalScore = _calculateTotalScore();
  int score = mark != null ? int.tryParse(mark!) ?? 0 : _calculateScore(); // Use mark if available

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Score',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '$correctAnswers of $totalQuestions questions',
                style: AppTextStyles.normal500(fontSize: 12, color: AppColors.backgroundDark),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$score/$totalScore',
                style: AppTextStyles.normal700(fontSize: 18, color: AppColors.eLearningContColor2),
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    duration != null
                        ? _formatTime(duration!.inSeconds)
                        : 'N/A',
                    style: AppTextStyles.normal600(fontSize: 12, color: AppColors.backgroundDark),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
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

  Widget _buildDynamicQuestionCard(int index) {
    String status = _getQuestionStatus(index);
    Color statusColor = _getStatusColor(status);
    String userAns = _getUserAnswer(index);
    String correctAns = _getCorrectAnswer(index);
int marks = question[index].questionGrade;
   
    

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${index + 1}', 
                  style: AppTextStyles.normal600(fontSize: 18, color: AppColors.eLearningContColor2)
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      if (status != 'No answer') ...[
                        const SizedBox(width: 4),
                        Icon(
                          status == 'Correct' ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question[index].questionText ?? 'Question text not available',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            
            // Display options for multiple choice questions
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your answer:'),
                if(userAns.endsWith('.jpg'))
                GestureDetector(
                  child: Image.network(
                           "https://linkskool.net/$userAns",
                            height: 50,
                            width: 50,
                            fit: BoxFit.contain,
                          ),
                )

              else  Flexible(
                  child: Text(
                    userAns.isEmpty ? 'No answer' : userAns,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: status == 'Correct' ? Colors.green : 
                             status == 'Wrong' ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                const Text('Correct Answer:'),
                if (correctAns.endsWith(".jpg"))
               Image.network(
                   "https://linkskool.net/$correctAns",
                 height: 50,
                 width: 50,
                 fit: BoxFit.contain,
               )
      else

                Flexible(
                  child: Text(
                    correctAns,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$marks marks',
                style: AppTextStyles.normal600(fontSize: 16, color: _getMarksColor(status)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to determine the dynamic color for marks
  Color _getMarksColor(String status) {
    switch (status) {
      case 'Correct':
        return Colors.green;
      case 'Wrong':
        return Colors.red;
      case 'No answer':
      default:
        return Colors.red;
    }
  }

  Widget _buildQuestionCard({
    required int questionNumber,
    required String status,
    required Color statusColor,
    required String question,
    required String userAnswer,
    required String correctAnswer,
    required int marks,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question $questionNumber', style: AppTextStyles.normal600(fontSize: 18, color: AppColors.eLearningContColor2)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      if (status != 'No answer') ...[
                        const SizedBox(width: 4),
                        Icon(
                          status == 'Correct' ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your answer:'),
                Text(userAnswer.isEmpty ? 'No answer' : userAnswer),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Correct Answer:'),
                Text(correctAnswer),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              // Use the dynamic color for the marks
              child: Text(
                '$marks marks',
                style: AppTextStyles.normal600(fontSize: 16, color: _getMarksColor(status)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}