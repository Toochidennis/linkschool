// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class CbtResultScreen extends StatelessWidget {
  late double opacity;
  final List<QuestionModel> questions;
  final Map<int, int> userAnswers;
  final String subject;
  final int year;
  final String examType;

  CbtResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.subject,
    required this.year,
    required this.examType,
  });

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Pop twice to go back to CBT dashboard
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: const Text('Test Summary'),
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
                '$examType - $subject ($year)',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.eLearningContColor2,
                ),
              ),
              const SizedBox(height: 16),
              _buildScoreCard(),
              const SizedBox(height: 16),
              // Dynamic question list
              ...List.generate(questions.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildQuestionCard(index),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    final score = _calculateScore();
    final totalQuestions = questions.length;
    final percentage = totalQuestions > 0 ? (score / totalQuestions * 100).toStringAsFixed(1) : '0.0';
    final correctAnswers = _getCorrectAnswersCount();
    final wrongAnswers = _getWrongAnswersCount();
    final unanswered = totalQuestions - (correctAnswers + wrongAnswers);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.eLearningBtnColor1,
            AppColors.eLearningBtnColor5,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Score',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percentage%',
                  style: AppTextStyles.normal700(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreItem('Correct', correctAnswers, AppColors.attCheckColor2),
              _buildScoreItem('Wrong', wrongAnswers, AppColors.eLearningRedBtnColor),
              _buildScoreItem('Unanswered', unanswered, AppColors.text5Light),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalQuestions > 0 ? correctAnswers / totalQuestions : 0,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            count.toString(),
            style: AppTextStyles.normal700(
              fontSize: 20,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.normal500(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = questions[index];
    final userAnswerIndex = userAnswers[index];
    final correctAnswerIndex = question.getCorrectAnswerIndex();
    final options = question.getOptions();
    
    String status;
    Color statusColor;
    
    if (userAnswerIndex == null) {
      status = 'Unanswered';
      statusColor = AppColors.text5Light;
    } else if (userAnswerIndex == correctAnswerIndex) {
      status = 'Correct';
      statusColor = AppColors.attCheckColor2;
    } else {
      status = 'Wrong';
      statusColor = AppColors.eLearningRedBtnColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header with status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.eLearningBtnColor1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: AppTextStyles.normal600(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      status == 'Correct'
                          ? Icons.check_circle
                          : status == 'Wrong'
                              ? Icons.cancel
                              : Icons.help_outline,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: AppTextStyles.normal600(
                        fontSize: 14,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Question text
          Text(
            question.content,
            style: AppTextStyles.normal500(
              fontSize: 16,
              color: AppColors.text3Light,
            ),
          ),
          const SizedBox(height: 16),
          // Options
          if (options.isNotEmpty)
            ...List.generate(options.length, (optionIndex) {
              final isUserAnswer = userAnswerIndex == optionIndex;
              final isCorrectAnswer = correctAnswerIndex == optionIndex;
              
              Color? optionColor;
              IconData? optionIcon;
              
              if (isCorrectAnswer) {
                optionColor = AppColors.attCheckColor2;
                optionIcon = Icons.check_circle;
              } else if (isUserAnswer && !isCorrectAnswer) {
                optionColor = AppColors.eLearningRedBtnColor;
                optionIcon = Icons.cancel;
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: optionColor?.withOpacity(0.1) ?? Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: optionColor ?? Colors.grey.shade300,
                    width: isUserAnswer || isCorrectAnswer ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: optionColor ?? Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: optionIcon != null
                            ? Icon(optionIcon, color: Colors.white, size: 16)
                            : Text(
                                String.fromCharCode(65 + optionIndex), // A, B, C, D
                                style: AppTextStyles.normal600(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        options[optionIndex],
                        style: AppTextStyles.normal500(
                          fontSize: 14,
                          color: AppColors.text3Light,
                        ),
                      ),
                    ),
                    if (isUserAnswer && !isCorrectAnswer)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Your answer',
                          style: AppTextStyles.normal500(
                            fontSize: 12,
                            color: AppColors.eLearningRedBtnColor,
                          ),
                        ),
                      ),
                    if (isCorrectAnswer)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Correct answer',
                          style: AppTextStyles.normal500(
                            fontSize: 12,
                            color: AppColors.attCheckColor2,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      final userAnswerIndex = userAnswers[i];
      final correctAnswerIndex = questions[i].getCorrectAnswerIndex();
      
      if (userAnswerIndex != null && userAnswerIndex == correctAnswerIndex) {
        score++;
      }
    }
    return score;
  }

  int _getCorrectAnswersCount() {
    return _calculateScore();
  }

  int _getWrongAnswersCount() {
    int wrongCount = 0;
    for (int i = 0; i < questions.length; i++) {
      final userAnswerIndex = userAnswers[i];
      final correctAnswerIndex = questions[i].getCorrectAnswerIndex();
      
      if (userAnswerIndex != null && userAnswerIndex != correctAnswerIndex) {
        wrongCount++;
      }
    }
    return wrongCount;
  }
}
