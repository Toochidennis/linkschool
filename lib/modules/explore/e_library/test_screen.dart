// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/timer_widget.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/explore/e_library/cbt_result_screen.dart';
import 'package:linkschool/modules/explore/e_library/backward_slash_clipper.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class TestScreen extends StatefulWidget {
  final String examTypeId;
  final String? subjectId;
  final String? subject;
  final int? year;
  final String calledFrom;
  
  const TestScreen({
    super.key, 
    required this.examTypeId,
    this.subjectId,
    this.subject,
    this.year,
    this.calledFrom = 'details',
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.eLearningBtnColor1,
          appBar: _buildAppBar(context, examProvider, isLandscape),
          body: examProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : examProvider.questions.isEmpty
                  ? const Center(
                      child: Text(
                        'No Questions Available',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : _buildBody(examProvider, isLandscape),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ExamProvider examProvider, bool isLandscape) {
    return AppBar(
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
      title: isLandscape
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              widget.subject ?? examProvider.examInfo?.courseName ?? 'CBT Test',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: "urbanist",
              ),
            ),
                Expanded(
                  child: Center(child: _buildCompactProgressBar(examProvider)),
                ),
              ],
            )
          : Text(
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
              initialSeconds: 3600,
              onTimeUp: () => _submitQuiz(examProvider, isFullyCompleted: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactProgressBar(ExamProvider provider) {
    int answeredQuestions = provider.userAnswers.length;
    final total = provider.questions.length;

    return Container(
      width: 260, 
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.eLearningContColor1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(64),
            child: LinearProgressIndicator(
              value: total > 0 ? answeredQuestions / total : 0,
              backgroundColor: AppColors.eLearningContColor2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.eLearningContColor3,
              ),
              minHeight: 14,
            ),
          ),
          Center(
            child: Text(
              '$answeredQuestions/$total',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ExamProvider examProvider, bool isLandscape) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          if (!isLandscape) ...[
            const SizedBox(height: 16),
            _buildProgressSection(examProvider),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: isLandscape
                ? _buildLandscapeLayout(examProvider)
                : _buildPortraitLayout(examProvider),
          ),
          const SizedBox(height: 16),
          _buildNavigationButtons(examProvider),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(ExamProvider provider) {
    return _buildQuestionCard(provider, false);
  }

  Widget _buildLandscapeLayout(ExamProvider provider) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildQuestionCard(provider, true),
        ),
      ],
    );
  }

  Widget _buildProgressSection(ExamProvider provider) {
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
          Center(
            child: Text(
              '$answeredQuestions of $total Completed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ExamProvider provider, bool isLandscape) {
    final question = provider.currentQuestion;
    
    if (question == null) {
      return SingleChildScrollView(
        child: Container(
          width: isLandscape ? double.infinity : 400,
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
          const SizedBox(height: 20),
          Stack(
                     clipBehavior: Clip.none,
            children: [
               Positioned(
                top: -26,
                left: 0,
                child: ClipPath(
                  clipper: isLandscape 
                      ? BackwardSlashClipper(borderRadius: 19.8)
                      : BackwardSlashClipper(borderRadius: 8),
                  child: Container(
                    height: 40,
                    width: 130,
                    decoration: const BoxDecoration(
                      color: AppColors.eLearningContColor1,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 5.0),
                      child: Text(
                        'Question ${provider.currentQuestionIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  width: isLandscape ? double.infinity : 400,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
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
              ),
             
            ],
          ),
          const SizedBox(height: 16),
          _buildOptionsOrInputCard(provider, question, isLandscape),
        ],
      ),
    );
  }

  Widget _buildOptionsOrInputCard(ExamProvider provider, QuestionModel question, bool isLandscape) {
    final options = question.getOptions();
    
    return Container(
      width: isLandscape ? double.infinity : 400,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
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
          : _buildOptions(provider, question, isLandscape),
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
        ),
      ],
    );
  }

  Widget _buildOptions(ExamProvider provider, QuestionModel question, bool isLandscape) {
    final options = question.getOptions();
    final selectedAnswer = provider.userAnswers[provider.currentQuestionIndex];

    if (isLandscape) {
      // Grid layout for landscape: 2 columns
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          return _buildOptionTile(provider, options[index], index, selectedAnswer);
        },
      );
    } else {
      // List layout for portrait
      return Column(
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return _buildOptionTile(provider, option, index, selectedAnswer);
        }).toList(),
      );
    }
  }

  Widget _buildOptionTile(ExamProvider provider, String option, int index, int? selectedAnswer) {
    final isSelected = selectedAnswer == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected ? Colors.green  : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () => provider.selectAnswer(provider.currentQuestionIndex, index),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: AppColors.eLearningBtnColor1)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            child: const Text('Previous', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _submitQuiz(
              provider, 
              isFullyCompleted: isLastQuestion,
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
        Expanded(
          child: OutlinedButton(
            onPressed: !isLastQuestion 
                ? () => provider.nextQuestion()
                : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: !isLastQuestion 
                    ? Colors.white 
                    : const Color.fromARGB(255, 169, 168, 168)
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Next',
              style: TextStyle(
                color: !isLastQuestion 
                    ? Colors.white 
                    : const Color.fromARGB(255, 169, 168, 168)
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitQuiz(ExamProvider provider, {required bool isFullyCompleted}) {
    final answeredCount = provider.userAnswers.length;
    final unansweredCount = provider.questions.length - answeredCount;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = isLandscape 
            ? screenWidth * 0.7 // 60% of screen width in landscape
            : screenWidth * 0.85; // 85% of screen width in portrait
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 600 : 400,
                maxHeight: MediaQuery.of(context).size.height * 100,
              ),
              child: Container(
                width: dialogWidth,
                padding: EdgeInsets.all(isLandscape ? 20 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning Icon
                    Container(
                      padding: EdgeInsets.all(isLandscape ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: Colors.orange.shade700,
                        size: isLandscape ? 28 : 40,
                      ),
                    ),
                    SizedBox(height: isLandscape ? 12 : 20),
                    
                    // Title
                    Text(
                      'Submit Exam?',
                      style: TextStyle(
                        fontSize: isLandscape ? 18 : 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    SizedBox(height: isLandscape ? 4 : 8),
                    
                    // Description
                    Text(
                      'Please review your answers before submitting',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLandscape ? 12 : 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    SizedBox(height: isLandscape ? 10 : 24),
                    
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Answered
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isLandscape ? 6 : 8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                                size: isLandscape ? 20 : 24,
                              ),
                            ),
                            SizedBox(height: isLandscape ? 6 : 8),
                            Text(
                              '$answeredCount',
                              style: TextStyle(
                                fontSize: isLandscape ? 20 : 24,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            Text(
                              'Answered',
                              style: TextStyle(
                                fontSize: isLandscape ? 10 : 12,
                                color: Colors.grey,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(width: isLandscape ? 40 : 60),
                        
                        // Unanswered
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isLandscape ? 6 : 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.cancel,
                                color: Colors.red.shade700,
                                size: isLandscape ? 20 : 24,
                              ),
                            ),
                            SizedBox(height: isLandscape ? 6 : 8),
                            Text(
                              '$unansweredCount',
                              style: TextStyle(
                                fontSize: isLandscape ? 20 : 24,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            Text(
                              'Unanswered',
                              style: TextStyle(
                                fontSize: isLandscape ? 10 : 12,
                                color: Colors.grey,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Warning message if unanswered
                    if (unansweredCount > 0) ...[
                      SizedBox(height: isLandscape ? 16 : 20),
                      Container(
                        padding: EdgeInsets.all(isLandscape ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                              size: isLandscape ? 18 : 20,
                            ),

                            SizedBox(width: isLandscape ? 8 : 12),
                           
                            Expanded(
                              child: Text(
                                'You have $unansweredCount unanswered question${unansweredCount > 1 ? 's' : ''}. Are you sure you want to submit?',
                                style: TextStyle(
                                  fontSize: isLandscape ? 11 : 12,
                                  color: Colors.orange.shade900,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    SizedBox(height: isLandscape ? 16 : 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 14),
                              side: BorderSide(color: AppColors.eLearningBtnColor1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Review Answers',
                              style: TextStyle(
                                color: AppColors.eLearningBtnColor1,
                                fontSize: isLandscape ? 12 : 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.eLearningBtnColor1,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                
                                print("questions: ${provider.questions}, userAnswers: ${provider.userAnswers}, isFullyCompleted: $isFullyCompleted");
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
                                      calledFrom: widget.calledFrom,
                                      isFullyCompleted: isFullyCompleted,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Submit Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isLandscape ? 12 : 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


// // ignore_for_file: deprecated_member_use
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/admin/e_learning/View/question/timer_widget.dart';
// import 'package:linkschool/modules/model/explore/home/exam_model.dart';
// import 'package:linkschool/modules/providers/explore/exam_provider.dart';
// import 'package:linkschool/modules/explore/e_library/cbt_result_screen.dart';
// import 'package:linkschool/modules/explore/e_library/backward_slash_clipper.dart';
// import 'package:provider/provider.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

// class TestScreen extends StatefulWidget {
//   final String examTypeId;
//   final String? subjectId;
//   final String? subject;
//   final int? year;
//   final String calledFrom; // Track where screen is called from
  
//   const TestScreen({
//     super.key, 
//     required this.examTypeId,
//     this.subjectId,
//     this.subject,
//     this.year,
//     this.calledFrom = 'details', // Default to details screen
//   });

//   @override
//   _TestScreenState createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   late double opacity;

//   final TextEditingController _textController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Fetch exam data when screen initializes
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<ExamProvider>(context, listen: false);
//       provider.fetchExamData(widget.examTypeId);
//       print("Fetching exam data for examTypeId: ${widget.examTypeId}");
//       print("SubjectId: ${widget.subjectId}, Subject: ${widget.subject}, Year: ${widget.year}");
//     });
//   }

//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
    
//     return Consumer<ExamProvider>(
//       builder: (context, examProvider, child) {
//         return Scaffold(
//           backgroundColor: AppColors.eLearningBtnColor1,
//           appBar: AppBar(
//             backgroundColor: AppColors.eLearningBtnColor1,
//             leading: IconButton(
//               onPressed: () => Navigator.of(context).pop(),
//               icon: Image.asset(
//                 'assets/icons/arrow_back.png',
//                 color: AppColors.backgroundLight,
//                 width: 34.0,
//                 height: 34.0,
//               ),
//             ),
//             title: Text(
//               widget.subject ?? examProvider.examInfo?.courseName ?? 'CBT Test',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: "urbanist",
//               ),
//             ),
//             elevation: 0,
//             actions: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: Center(
//                   child: TimerWidget(
//                     initialSeconds: 3600, // Default to 1 hour
//                     onTimeUp: () => _submitQuiz(examProvider, isFullyCompleted: false),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           body: examProvider.isLoading
//               ? const Center(
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                   ),
//                 ) :
          
//           examProvider.questions.isEmpty
//               ? const Center(
//                   child:Text(
//                     'No Questions Available',
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                 )  
//               : Padding(
//                   padding: const EdgeInsets.symmetric( horizontal: 16.0),
//                   child: Column(
//                     children: [
//                       _buildTimerRow(examProvider),
//                       const SizedBox(height: 16),
//                       _buildProgressSection(examProvider),
//                       const SizedBox(height: 16),
//                       Expanded(child: _buildQuestionCard(examProvider)),
//                       const SizedBox(height: 16),
//                       _buildNavigationButtons(examProvider),
//                     ],
//                   ),
//                 ),
//         );
//       },
//     );
//   }

//   Widget _buildTimerRow(ExamProvider provider) {
//     // Timer is now in AppBar, navigation buttons handle submission
//     return const SizedBox.shrink();
//   }

//   Widget _buildProgressSection(ExamProvider provider) {
//     // Count the number of answered questions (userAnswers is a Map<int, int>)
//     int answeredQuestions = provider.userAnswers.length;
//     final total = provider.questions.length;

//     return Container(
//       width: 400,
      
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: AppColors.eLearningContColor1,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Stack(
//         children: [
//           // Progress bar background
//           ClipRRect(
//             borderRadius: BorderRadius.circular(64),
//             child: LinearProgressIndicator(
//               value: total > 0 ? answeredQuestions / total : 0,
//               backgroundColor: AppColors.eLearningContColor2,
//               valueColor: const AlwaysStoppedAnimation<Color>(
//                 AppColors.eLearningContColor3,
//               ),
//               minHeight: 18,
//             ),
//           ),
//           // Text overlay inside progress bar
//           Center(
//             child: Positioned(
              
//               child: Text(
//                 '$answeredQuestions of $total Completed',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuestionCard(ExamProvider provider) {
//     final question = provider.currentQuestion;
    
//     if (question == null) {
//       return SingleChildScrollView(
//         child: Container(
//           width: 400,
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 alignment: Alignment.center,
//                 height: 300,
//                 child: SvgPicture.asset(
//                   'assets/images/e-learning/Student stress-amico.svg',
//                   width: 200,
//                   height: 200,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'No Questions Available',
//                 style: AppTextStyles.normal700(
//                   fontSize: 22,
//                   color: AppColors.text3Light,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           // Question Card with Stack
//            SizedBox(
//                   height:20,
//                   ),
//           Container(
//             width: 400,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Stack(
//               clipBehavior: Clip.none, // Allow the badge to overflow if needed
//               children: [
//                 // Main content
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 40), // Space for the curved badge
//                       Text(
//                         question.content.isNotEmpty
//                             ? question.content[0].toUpperCase() +
//                                 question.content.substring(1)
//                             : "Question",
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                           height: 1.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 // Top-left curved badge with backward slash shape
//                 Positioned(
//                   top: -26,
//                   left: 0,
//                   child: ClipPath(
//                     clipper: BackwardSlashClipper(),
//                     child: Container(
//                       height: 27,
//                       width: 110,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(8),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 12.0, top: 5.0),
//                         child: Text(
//                           'Question ${provider.currentQuestionIndex + 1}',
//                           style: const TextStyle(
//                             color: AppColors.eLearningBtnColor1,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
          
//           // Options/Input Card
//           _buildOptionsOrInputCard(provider, question),
//         ],
//       ),
//     );
//   }

//   Widget _buildOptionsOrInputCard(ExamProvider provider, QuestionModel question) {
//     final options = question.getOptions();
    
//     return Container(
//       width: 400,
//       padding: const EdgeInsets.symmetric( vertical: 16.0),
//       decoration: BoxDecoration(
//        // color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: options.isEmpty 
//           ? _buildTextInput(provider)
//           : _buildOptions(provider, question),
//     );
//   }

//   Widget _buildTextInput(ExamProvider provider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Your Answer:',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: AppColors.text4Light,
//           ),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _textController,
//           maxLines: 4,
//           decoration: InputDecoration(
//             hintText: 'Type your answer here...',
//             hintStyle: TextStyle(color: Colors.grey.shade400),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: AppColors.eLearningBtnColor1, width: 2),
//             ),
//             filled: true,
//             fillColor: Colors.grey.shade50,
//             contentPadding: const EdgeInsets.all(16),
//           ),
//           onChanged: (value) {
//             // Store text answer - you may need to update provider to handle text answers
//             // For now, we'll just update the text in the controller
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildOptions(ExamProvider provider, QuestionModel question) {
//   final options = question.getOptions();
//   final selectedAnswer = provider.userAnswers[provider.currentQuestionIndex];

//   return Column(
//     children: options.asMap().entries.map((entry) {
//       final index = entry.key;
//       final option = entry.value;
//       final isSelected = selectedAnswer == index;

//       return Container(
//         margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue.withOpacity(0.5) : Colors.white,
//           borderRadius: BorderRadius.circular(8.0),
//           border: Border.all(
//             color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey.shade300,
//             width: 1.5,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(8.0),
//             onTap: () => provider.selectAnswer(provider.currentQuestionIndex, index),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: isSelected ? Colors.white : Colors.grey,
//                         width: 2,
//                       ),
//                       color: isSelected ? Colors.white : Colors.transparent,
//                     ),
//                     child: isSelected
//                         ? const Icon(Icons.check, size: 16, color: AppColors.eLearningBtnColor1)
//                         : null,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       option,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: isSelected ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }).toList(),
//   );
// }

//   Color _getOptionColor(int index, int? selectedAnswer) {
//     if (selectedAnswer == index) {
//       return const Color.fromARGB(255, 230, 236, 255);
//     }
//     return Colors.transparent;
//   }

//   Widget _buildNavigationButtons(ExamProvider provider) {
//     bool isLastQuestion = provider.currentQuestionIndex == provider.questions.length - 1;
    
//     return Row(
//       children: [
//         // Previous Button
//         Expanded(
//           child: OutlinedButton(
//             onPressed: provider.currentQuestionIndex > 0
//                 ? () => provider.previousQuestion()
//                 : null,
//             style: OutlinedButton.styleFrom(
//               side: const BorderSide(color: Colors.white),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             child: const Text('Previous', style: TextStyle(color: Colors.white)),
//           ),
//         ),
//         const SizedBox(width: 12),
        
//         // Submit Button (Center)
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () => _submitQuiz(
//               provider, 
//               isFullyCompleted: isLastQuestion, // Completed if on last question, incomplete otherwise
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.eLearningContColor3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             child: const Text(
//               'Submit',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
        
//         // Next Button
//         Expanded(
//           child: OutlinedButton(
//             onPressed: !isLastQuestion 
//                 ? () => provider.nextQuestion()
//                 : null,
//             style: OutlinedButton.styleFrom(
//               side:  BorderSide(color:!isLastQuestion ? Colors.white : const Color.fromARGB(255, 169, 168, 168)),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             child:  Text(
//               'Next',
//               style: TextStyle(color:!isLastQuestion ? Colors.white : const Color.fromARGB(255, 169, 168, 168)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _submitQuiz(ExamProvider provider, {required bool isFullyCompleted}) {
//     // Show a dialog to confirm submission
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Submit Test'),
//         content: Text(
//           isFullyCompleted
//               ? 'You have reached the last question. Are you sure you want to submit?'
//               : 'You are submitting early. Not all questions have been seen. Continue?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
              
//               // Navigate to result screen
//               print(" questions: ${provider.questions}, userAnswers: ${provider.userAnswers}, isFullyCompleted: $isFullyCompleted");
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => CbtResultScreen(
//                     questions: provider.questions,
//                     userAnswers: provider.userAnswers,
//                     subject: widget.subject ?? provider.examInfo?.courseName ?? 'CBT Test',
//                     year: widget.year ?? DateTime.now().year,
//                     examType: provider.examInfo?.title ?? 'Test',
//                     examId: widget.examTypeId,
//                     calledFrom: widget.calledFrom, // Pass the source
//                     isFullyCompleted: isFullyCompleted, // Pass completion status
//                   ),
//                 ),
//               );
//             },
//             child: const Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }
// }