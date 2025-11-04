import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class TestScreen extends StatefulWidget {
  final String examTypeId;
  const TestScreen({super.key, required this.examTypeId});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  @override
  void initState() {
    super.initState();
    // Fetch exam data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExamProvider>(context, listen: false);
      provider.fetchExamData(widget.examTypeId);
      print("Fetching exam data...");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
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
            title: Text(
              examProvider.examInfo?.courseName ?? 'Loading...',
              style: const TextStyle(color: Colors.white),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Fixed sections at the top
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Timer Section
                      Row(
                        children: [
                          Image(
                              image:
                                  AssetImage('assets/icons/alarm_clock.png')),
                          const SizedBox(width: 8),
                          Text(
                            '58:22',
                            style: AppTextStyles.normal700(
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Progress Section
                      _buildProgressSection(examProvider),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Question Card
                          _buildQuestionCard(examProvider),

                          // Navigation Buttons
                          const SizedBox(height: 16),
                          _buildNavigationButtons(examProvider),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(ExamProvider provider) {
    final total = provider.questions.length;
    final current = provider.currentQuestionIndex + 1;

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
              Text(
                '$current of $total',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Completed',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(64),
            child: LinearProgressIndicator(
              value: total > 0 ? current / total : 0,
              backgroundColor: AppColors.eLearningContColor2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.eLearningContColor3,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ExamProvider provider) {
    final question = provider.currentQuestion;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Question Content Section (not scrollable)
          Text(
            question?.content ?? 'Loading question...',
            style: AppTextStyles.normal700(
              fontSize: 22,
              color: AppColors.text3Light,
            ),
          ),
          const SizedBox(height: 16),

          // Options Section (not scrollable)
          if (question != null)
            Column(
              children: _buildOptions(provider, question),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(ExamProvider provider, QuestionModel question) {
    final options = question.getOptions();
    final selectedAnswer = provider.userAnswers[provider.currentQuestionIndex];

    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: () =>
              provider.selectAnswer(provider.currentQuestionIndex, index),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8.0,
            ),
            decoration: BoxDecoration(
              color: _getOptionColor(index, selectedAnswer),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedAnswer == index
                    ? AppColors.attCheckColor2
                    : Colors.grey,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Radio<int>(
                  value: index,
                  groupValue: selectedAnswer,
                  onChanged: (value) => provider.selectAnswer(
                      provider.currentQuestionIndex, value!),
                  activeColor: AppColors.attCheckColor2,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      option,
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.text3Light,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Color _getOptionColor(int index, int? selectedAnswer) {
    if (selectedAnswer == index) {
      return AppColors.eLearningBtnColor6;
    }
    return Colors.transparent;
  }

  Widget _buildNavigationButtons(ExamProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: provider.currentQuestionIndex > 0
                ? () => provider.previousQuestion()
                : null,
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
            onPressed:
                provider.currentQuestionIndex < provider.questions.length - 1
                    ? () => provider.nextQuestion()
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eLearningBtnColor5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Next', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
