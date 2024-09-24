import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';

class PreviewQuizAssessmentScreen extends StatelessWidget {
   late double opacity;
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildScoreCard(),
              const SizedBox(height: 16),
              _buildQuestionCard(
                questionNumber: 1,
                status: 'Correct',
                statusColor: Colors.green,
                question: 'What is the major reason for corruption in Nigeria?',
                userAnswer: 'Bad Governance',
                correctAnswer: 'Bad Governance',
                marks: 5,
              ),
              const SizedBox(height: 16),
              _buildQuestionCard(
                questionNumber: 2,
                status: 'Wrong',
                statusColor: Colors.red,
                question: 'Which year did Nigeria gain independence?',
                userAnswer: '1963',
                correctAnswer: '1960',
                marks: 5,
              ),
              const SizedBox(height: 16),
              _buildQuestionCard(
                questionNumber: 3,
                status: 'No answer',
                statusColor: Colors.orange,
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Score',
                  style: TextStyle(color: Colors.grey),
                ),
                Text('10 of 15 questions'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '175/200',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '56mins 40seconds',
                      style: TextStyle(color: Colors.grey),
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
                Text('Question $questionNumber'),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
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
              child: Text('${marks}marks'),
            ),
          ],
        ),
      ),
    );
  }
}
