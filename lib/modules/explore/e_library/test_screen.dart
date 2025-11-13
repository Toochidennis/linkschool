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
  final String calledFrom; // Track where screen is called from
  
  const TestScreen({
    super.key, 
    required this.examTypeId,
    this.subjectId,
    this.subject,
    this.year,
    this.calledFrom = 'details', // Default to details screen
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: TimerWidget(
                    initialSeconds: 3600, // Default to 1 hour
                    onTimeUp: () => _submitQuiz(examProvider, isFullyCompleted: false),
                  ),
                ),
              ),
            ],
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
                  padding: const EdgeInsets.symmetric( horizontal: 16.0),
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
    // Timer is now in AppBar, navigation buttons handle submission
    return const SizedBox.shrink();
  }

  Widget _buildProgressSection(ExamProvider provider) {
    // Count the number of answered questions (userAnswers is a Map<int, int>)
    int answeredQuestions = provider.userAnswers.length;
    final total = provider.questions.length;

    return Container(
      width: 400,
      
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.eLearningContColor1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Progress bar background
          ClipRRect(
            borderRadius: BorderRadius.circular(64),
            child: LinearProgressIndicator(
              value: total > 0 ? answeredQuestions / total : 0,
              backgroundColor: AppColors.eLearningContColor2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.eLearningContColor3,
              ),
              minHeight: 18,
            ),
          ),
          // Text overlay inside progress bar
          Center(
            child: Positioned(
              
              child: Text(
                '$answeredQuestions of $total Completed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
      child: Column(
        children: [
          // Question Card
          Container(
            width: 400,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.eLearningBtnColor1,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Question ${provider.currentQuestionIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.content.isNotEmpty
                      ? question.content[0].toUpperCase() +
                          question.content.substring(1)
                      : "Question",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Options/Input Card
          _buildOptionsOrInputCard(provider, question),
        ],
      ),
    );
  }

  Widget _buildOptionsOrInputCard(ExamProvider provider, QuestionModel question) {
    final options = question.getOptions();
    
    return Container(
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
      child: options.isEmpty 
          ? _buildTextInput(provider)
          : _buildOptions(provider, question),
    );
  }

  Widget _buildTextInput(ExamProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Answer:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text4Light,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.eLearningBtnColor1, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) {
            // Store text answer - you may need to update provider to handle text answers
            // For now, we'll just update the text in the controller
          },
        ),
      ],
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
        // Previous Button
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
            child: const Text('Previous', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        
        // Submit Button (Center)
        Expanded(
          child: ElevatedButton(
            onPressed: () => _submitQuiz(
              provider, 
              isFullyCompleted: isLastQuestion, // Completed if on last question, incomplete otherwise
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eLearningContColor3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Next Button
        Expanded(
          child: ElevatedButton(
            onPressed: !isLastQuestion 
                ? () => provider.nextQuestion()
                : null,
            style: OutlinedButton.styleFrom(
              side:  BorderSide(color:!isLastQuestion ? Colors.white : const Color.fromARGB(255, 169, 168, 168)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child:  Text(
              'Next',
              style: TextStyle(color:!isLastQuestion ? Color.fromARGB(255, 34, 2, 215) : const Color.fromARGB(255, 169, 168, 168)),
            ),
          ),
        ),
      ],
    );
  }

  void _submitQuiz(ExamProvider provider, {required bool isFullyCompleted}) {
    // Show a dialog to confirm submission
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test'),
        content: Text(
          isFullyCompleted
              ? 'You have reached the last question. Are you sure you want to submit?'
              : 'You are submitting early. Not all questions have been seen. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              
              // Navigate to result screen
              print(" questions: ${provider.questions}, userAnswers: ${provider.userAnswers}, isFullyCompleted: $isFullyCompleted");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CbtResultScreen(
                    questions: provider.questions,
                    userAnswers: provider.userAnswers,
                    subject: widget.subject ?? provider.examInfo?.courseName ?? 'CBT Test',
                    year: widget.year ?? DateTime.now().year,
                    examType: provider.examInfo?.title ?? 'Test',
                    examId: widget.examTypeId,
                    calledFrom: widget.calledFrom, // Pass the source
                    isFullyCompleted: isFullyCompleted, // Pass completion status
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