// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/timer_widget.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/explore/e_library/cbt_result_screen.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class TestScreen extends StatefulWidget {
  final String examTypeId;
  final String? subjectId;
  final String? subject;
  final int? year;
  
  const TestScreen({
    super.key, 
    required this.examTypeId,
    this.subjectId,
    this.subject,
    this.year,
  });

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late double opacity;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch exam data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExamProvider>(context, listen: false);
      provider.fetchExamData(widget.examTypeId);
      print("Fetching exam data for examTypeId: ${widget.examTypeId}");
      print("SubjectId: ${widget.subjectId}, Subject: ${widget.subject}, Year: ${widget.year}");
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    
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
              widget.subject ?? examProvider.examInfo?.courseName ?? 'CBT Test',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: "urbanist",
              ),
            ),
            elevation: 0,
          ),
          body: examProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ) :
          
          examProvider.questions.isEmpty
              ? const Center(
                  child:Text(
                    'No Questions Available',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )  
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTimerRow(examProvider),
                      const SizedBox(height: 16),
                      _buildProgressSection(examProvider),
                      const SizedBox(height: 16),
                      Expanded(child: _buildQuestionCard(examProvider)),
                      const SizedBox(height: 16),
                      _buildNavigationButtons(examProvider),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTimerRow(ExamProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            TimerWidget(
              initialSeconds: 3600, // Default to 1 hour
              onTimeUp: () => _submitQuiz(provider),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection(ExamProvider provider) {
    // Count the number of answered questions (userAnswers is a Map<int, int>)
    int answeredQuestions = provider.userAnswers.length;
    final total = provider.questions.length;

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
                '$answeredQuestions of $total',
                style: const TextStyle(color: Colors.white, fontSize: 16),
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
              value: total > 0 ? answeredQuestions / total : 0,
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
    
    if (question == null) {
      return SingleChildScrollView(
        child: Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 300,
                child: SvgPicture.asset(
                  'assets/images/e-learning/Student stress-amico.svg',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'No Questions Available',
                style: AppTextStyles.normal700(
                  fontSize: 22,
                  color: AppColors.text3Light,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
            Text(
              question.content.isNotEmpty
                  ? question.content[0].toUpperCase() +
                      question.content.substring(1)
                  : "Question",
              style: const TextStyle(fontSize: 23),
            ),
            const SizedBox(height: 16),
            _buildOptions(provider, question),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(ExamProvider provider, QuestionModel question) {
    final options = question.getOptions();
    final selectedAnswer = provider.userAnswers[provider.currentQuestionIndex];

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: _getOptionColor(index, selectedAnswer),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedAnswer == index
                  ? Colors.blue
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: RadioListTile<int>(
            title: Text(option),
            value: index,
            groupValue: selectedAnswer,
            onChanged: (value) {
              provider.selectAnswer(provider.currentQuestionIndex, value!);
            },
            activeColor: Colors.blue,
            tileColor: Colors.transparent,
          ),
        );
      }).toList(),
    );
  }

  Color _getOptionColor(int index, int? selectedAnswer) {
    if (selectedAnswer == index) {
      return const Color.fromARGB(255, 230, 236, 255);
    }
    return Colors.transparent;
  }

  Widget _buildNavigationButtons(ExamProvider provider) {
    bool isLastQuestion = provider.currentQuestionIndex == provider.questions.length - 1;
    
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
            onPressed: isLastQuestion 
                ? () => _submitQuiz(provider)
                : () => provider.nextQuestion(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eLearningBtnColor5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              isLastQuestion ? 'Submit' : 'Next',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _submitQuiz(ExamProvider provider) {
    // Show a dialog to confirm submission
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test'),
        content: const Text('Are you sure you want to submit your answers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              
              // Navigate to result screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CbtResultScreen(
                    questions: provider.questions,
                    userAnswers: provider.userAnswers,
                    subject: widget.subject ?? provider.examInfo?.courseName ?? 'CBT Test',
                    year: widget.year ?? DateTime.now().year,
                    examType: provider.examInfo?.title ?? 'Test',
                  ),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}