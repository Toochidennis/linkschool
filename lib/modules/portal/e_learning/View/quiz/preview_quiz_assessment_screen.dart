// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class PreviewQuizAssessmentScreen extends StatelessWidget {
   late double opacity;

  PreviewQuizAssessmentScreen({super.key});
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
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.primaryLight),
              onSelected: (String result) {
                // Handle menu item selection
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2nd Continuous Assessment Test',
                style: AppTextStyles.normal600(fontSize: 18, color: AppColors.eLearningContColor2),
              ),
              const SizedBox(height: 16),
              _buildScoreCard(),
              const SizedBox(height: 16),
              _buildQuestionCard(
                questionNumber: 1,
                status: 'Correct',
                statusColor: AppColors.attCheckColor2,
                question: 'What is the major reason for corruption in Nigeria?',
                userAnswer: 'Bad Governance',
                correctAnswer: 'Bad Governance',
                marks: 5,
              ),
              const SizedBox(height: 16),
              _buildQuestionCard(
                questionNumber: 2,
                status: 'Wrong',
                statusColor: AppColors.eLearningRedBtnColor,
                question: 'Which year did Nigeria gain independence?',
                userAnswer: '1963',
                correctAnswer: '1960',
                marks: 5,
              ),
              const SizedBox(height: 16),
              _buildQuestionCard(
                questionNumber: 3,
                status: 'No answer',
                statusColor: AppColors.text5Light,
                question: 'Who was the first president of Nigeria?',
                userAnswer: '',
                correctAnswer: 'Nnamdi Azikiwe',
                marks: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
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
                Text('10 of 15 questions', style: AppTextStyles.normal500(fontSize: 12, color: AppColors.backgroundDark)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '175/200',
                  style: AppTextStyles.normal700(fontSize: 18, color: AppColors.eLearningContColor2),
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '56mins 40seconds',
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
                '${marks} marks',
                style: AppTextStyles.normal600(fontSize: 16, color: _getMarksColor(status)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

