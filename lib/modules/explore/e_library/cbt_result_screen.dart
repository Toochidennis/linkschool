import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/model/explore/cbt_history_model.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/cbt_history_service.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/e_library/widgets/google_signup_dialog.dart';
import 'package:linkschool/modules/explore/e_library/widgets/subscription_enforcement_dialog.dart';
import 'package:provider/provider.dart';

class CbtResultScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final Map<int, int> userAnswers;
  final String subject;
  final int year;
  final String examType;
  final String? examId;
  final String calledFrom; // Track where screen was called from
  final bool isFullyCompleted; // Track if all questions were answered
  final List<Map<String, dynamic>>? allSubjectsData; // For multi-subject results

  const CbtResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.subject,
    required this.year,
    required this.examType,
    this.examId,
    this.calledFrom = 'details', // Default to details screen
    this.isFullyCompleted = false, // Default to false
    this.allSubjectsData,
  });

  @override
  State<CbtResultScreen> createState() => _CbtResultScreenState();
}

class _CbtResultScreenState extends State<CbtResultScreen> {
  late double opacity;
  final CbtHistoryService _historyService = CbtHistoryService();
  final _authService = FirebaseAuthService();
  final _subscriptionService = CbtSubscriptionService();
  bool _isSaved = false;
  bool _userSignedIn = false;
  late PageController _pageController;
  int _currentSubjectIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Check if user is signed in on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserSigninStatus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Check if user is already signed in
  Future<void> _checkUserSigninStatus() async {
    final isSignedIn = await _authService.isUserSignedUp();
    
    if (!isSignedIn && mounted) {
      // Show persistent Google sign-in dialog
      _showGoogleSigninDialog();
    } else if (isSignedIn && mounted) {
      setState(() {
        _userSignedIn = true;
      });
      // Save test result only after user is signed in
      _saveTestResult();
      // Check subscription status before showing score popup
      await _checkSubscriptionStatus();
    }
  }
  
  /// Check subscription status and show appropriate dialog
  Future<void> _checkSubscriptionStatus() async {
    final cbtUserProvider = Provider.of<CbtUserProvider>(context, listen: false);
    final testCount = await _subscriptionService.getTestCount();
    final hasPaid = cbtUserProvider.hasPaid;
    final remainingTests = await _subscriptionService.getRemainingFreeTests();

    print('\n📊 Subscription Status Check:');
    print('   Test Count: $testCount');
    print('   Has Paid (provider): $hasPaid');
    print('   Remaining Free Tests: $remainingTests');

    if (!mounted) return;

    if (hasPaid) {
      // User has paid, sync subscription service and show normal score popup
      await cbtUserProvider.syncSubscriptionService();
      _showScorePopup();
    } else if (testCount == 2) {
      // On 2nd test - show soft prompt to subscribe
      print('   ⚠️ Showing soft subscription prompt (2nd test)');
      _showScorePopup();
      // Show subscription prompt after score popup is dismissed
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showSubscriptionPrompt(isHardBlock: false, remainingTests: remainingTests);
        }
      });
    } else if (testCount >= 3) {
      // On 3rd test or more - MUST pay (hard block)
      print('   🔒 Enforcing payment (3rd+ test)');
      _showSubscriptionPrompt(isHardBlock: true, remainingTests: 0);
    } else {
      // 1st test - show normal score popup
      _showScorePopup();
    }
  }
  
  /// Show subscription enforcement dialog
  void _showSubscriptionPrompt({required bool isHardBlock, required int remainingTests}) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: !isHardBlock,
      builder: (context) => SubscriptionEnforcementDialog(
        isHardBlock: isHardBlock,
        remainingTests: remainingTests,
        amount: 400,
        onSubscribed: () {
          print('✅ User subscribed successfully');
          if (mounted) {
            setState(() {
              // Refresh the UI
            });
          }
        },
      ),
    );
  }

  /// Show persistent Google Sign-in dialog
  void _showGoogleSigninDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      barrierColor: Colors.black54,
      builder: (context) => GoogleSignupDialog(
        onSignupSuccess: () {
          print('✅ User signed in successfully');
          setState(() {
            _userSignedIn = true;
          });
          // Save test result after successful signup
          _saveTestResult();
          // Check subscription status
          _checkSubscriptionStatus();
        },
        onSkip: () {
          print('🔙 User skipped signin - going back to dashboard');
          // Navigate back to CBT Dashboard
          Navigator.of(context).popUntil(
            (route) => route.settings.name == '/cbt_dashboard' || route.isFirst,
          );
        },
      ),
    );
  }

  // Save test result to shared preferences
  Future<void> _saveTestResult() async {
    if (_isSaved || !_userSignedIn) return; // Prevent duplicate saves and ensure user is signed in
    
    try {
      // Check if this is a multi-subject test
      if (widget.allSubjectsData != null && widget.allSubjectsData!.isNotEmpty) {
        // Save ALL subjects in multi-subject test
        print('\n🔄 Saving Multi-Subject Test Results:');
        for (int i = 0; i < widget.allSubjectsData!.length; i++) {
          final subjectData = widget.allSubjectsData![i];
          final questions = subjectData['questions'] as List<QuestionModel>;
          final userAnswers = subjectData['userAnswers'] as Map<int, int>;
          final subject = subjectData['subject'] as String;
          final year = subjectData['year'] as int;
          final examId = subjectData['examId'] as String;
          
          final score = _calculateScore(questions, userAnswers);
          final totalQuestions = questions.length;
          
          final historyModel = CbtHistoryModel(
            subject: subject,
            year: year,
            examId: examId,
            examType: widget.examType,
            score: score,
            totalQuestions: totalQuestions,
            timestamp: DateTime.now(),
            isFullyCompleted: userAnswers.length == questions.length,
          );
          
          await _historyService.saveTestResult(historyModel);
          print('   ✅ Subject ${i + 1}/${widget.allSubjectsData!.length}: $subject - ${historyModel.percentage.toStringAsFixed(1)}%');
        }
        print('✅ All subjects saved successfully!\n');
      } else {
        // Save single subject test
        final score = _calculateScore(widget.questions, widget.userAnswers);
        final totalQuestions = widget.questions.length;
        
        final historyModel = CbtHistoryModel(
          subject: widget.subject,
          year: widget.year,
          examId: widget.examId ?? '',
          examType: widget.examType,
          score: score,
          totalQuestions: totalQuestions,
          timestamp: DateTime.now(),
          isFullyCompleted: widget.userAnswers.length == widget.questions.length,
        );
        
        await _historyService.saveTestResult(historyModel);
        print('✅ Test result saved: ${historyModel.subject} - ${historyModel.percentage.toStringAsFixed(1)}% (Completed: ${historyModel.isFullyCompleted})');
      }
      
      setState(() {
        _isSaved = true;
      });
    } catch (e) {
      print('❌ Error saving test result: $e');
    }
  }

  void _showScorePopup() {
    // Calculate total stats across all subjects or single subject
    int totalScore = 0;
    int totalQuestions = 0;
    int totalCorrect = 0;
    int totalWrong = 0;
    int totalUnanswered = 0;

    if (widget.allSubjectsData != null && widget.allSubjectsData!.isNotEmpty) {
      // Multi-subject test
      for (var subjectData in widget.allSubjectsData!) {
        final questions = subjectData['questions'] as List<QuestionModel>;
        final userAnswers = subjectData['userAnswers'] as Map<int, int>;
        
        totalScore += _calculateScore(questions, userAnswers);
        totalQuestions += questions.length;
        totalCorrect += _getCorrectAnswersCount(questions, userAnswers);
        totalWrong += _getWrongAnswersCount(questions, userAnswers);
        totalUnanswered += questions.length - (userAnswers.length);
      }
    } else {
      // Single subject test
      totalScore = _calculateScore(widget.questions, widget.userAnswers);
      totalQuestions = widget.questions.length;
      totalCorrect = _getCorrectAnswersCount(widget.questions, widget.userAnswers);
      totalWrong = _getWrongAnswersCount(widget.questions, widget.userAnswers);
      totalUnanswered = totalQuestions - (totalCorrect + totalWrong);
    }

    final percentage = totalQuestions > 0 
        ? (totalScore / totalQuestions * 100).toStringAsFixed(1) 
        : '0.0';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ScorePopupDialog(
        totalScore: totalScore,
        totalQuestions: totalQuestions,
        percentage: percentage,
        correctAnswers: totalCorrect,
        wrongAnswers: totalWrong,
        unanswered: totalUnanswered,
        isMultiSubject: widget.allSubjectsData != null && widget.allSubjectsData!.isNotEmpty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    
    final bool isMultiSubject = widget.allSubjectsData != null && widget.allSubjectsData!.isNotEmpty;
    
    return WillPopScope(
      // Prevent back navigation if user hasn't signed in
      onWillPop: () async {
        if (!_userSignedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in first to save your scores'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        
        // Refresh the CBT provider statistics before going back
        context.read<CBTProvider>().refreshStats();
        
        // Handle navigation based on where we came from
        if (widget.calledFrom == 'dashboard' || widget.calledFrom == 'multi-subject') {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _userSignedIn
              ? IconButton(
                  onPressed: () {
                    context.read<CBTProvider>().refreshStats();
                    
                    if (widget.calledFrom == 'dashboard' || widget.calledFrom == 'multi-subject') {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Image.asset(
                    'assets/icons/arrow_back.png',
                    color: AppColors.primaryLight,
                    width: 34.0,
                    height: 34.0,
                  ),
                )
              : null, // Hide back button until signed in
          title: Text(isMultiSubject ? 'Multi-Subject Results' : 'Test Summary'),
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
        body: !_userSignedIn
            ? const SizedBox() // Empty body while waiting for signin
            : Container(
              decoration: Constants.customBoxDecoration(context),
              child: isMultiSubject ? _buildMultiSubjectView() : _buildSingleSubjectView(),
            ),
      ),
    );
  }

  Widget _buildSingleSubjectView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.examType,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 74, 72, 72),
            ),
          ),
          Text(
            ' ${widget.subject}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 115, 114, 114),
            ),
          ),
          Text(
            widget.year.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildScoreCard(widget.questions, widget.userAnswers),
          const SizedBox(height: 16),
          // Dynamic question list
          ...List.generate(widget.questions.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildQuestionCard(index, widget.questions, widget.userAnswers),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMultiSubjectView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Swipeable score cards
          SizedBox(
            height: 380,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.allSubjectsData!.length,
              onPageChanged: (index) {
                setState(() {
                  _currentSubjectIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final subjectData = widget.allSubjectsData![index];
                final questions = subjectData['questions'] as List<QuestionModel>;
                final userAnswers = subjectData['userAnswers'] as Map<int, int>;
                final subject = subjectData['subject'] as String;
                final year = subjectData['year'] as int;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.normal600(
                                    fontSize: 18,
                                    color: AppColors.text3Light,
                                  ),
                                ),
                                Text(
                                  'Year: $year',
                                  style: AppTextStyles.normal500(
                                    fontSize: 14,
                                    color: AppColors.text7Light,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Page indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.eLearningBtnColor1,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${index + 1} / ${widget.allSubjectsData!.length}',
                              style: AppTextStyles.normal600(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildScoreCard(questions, userAnswers),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Swipe indicator
          if (widget.allSubjectsData!.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.swipe, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Swipe to see other subjects',
                    style: AppTextStyles.normal500(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Question details for current subject
          _buildQuestionsListForSubject(_currentSubjectIndex),
        ],
      ),
    );
  }

  Widget _buildQuestionsListForSubject(int subjectIndex) {
    final subjectData = widget.allSubjectsData![subjectIndex];
    final questions = subjectData['questions'] as List<QuestionModel>;
    final userAnswers = subjectData['userAnswers'] as Map<int, int>;

    return Column(
      children: List.generate(
        questions.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildQuestionCard(index, questions, userAnswers),
        ),
      ),
    );
  }

  Widget _buildScoreCard(List<QuestionModel> questions, Map<int, int> userAnswers) {
    final score = _calculateScore(questions, userAnswers);
    final totalQuestions = questions.length;
    final percentage = totalQuestions > 0 ? (score / totalQuestions * 100).toStringAsFixed(1) : '0.0';
    final correctAnswers = _getCorrectAnswersCount(questions, userAnswers);
    final wrongAnswers = _getWrongAnswersCount(questions, userAnswers);
    final unanswered = totalQuestions - (correctAnswers + wrongAnswers);

    return Container(
      padding: const EdgeInsets.all(16),
     
      decoration: BoxDecoration(
        color: AppColors.eLearningBtnColor1,
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
           
            ],
          ),

         Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 90.0,
                  width: 90.0,
                  child: CircularProgressIndicator(
                    backgroundColor:  AppColors.eLearningContColor1,
                    color: Colors.white,
                    value: percentage != 'NaN' ? (score / totalQuestions) : 0,
                    strokeWidth: 16,
                  ),
                ),
                Text(
                  '$percentage %',
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreItem('Correct', correctAnswers, AppColors.attCheckColor2),
              _buildScoreItem('Wrong', wrongAnswers, AppColors.eLearningRedBtnColor),
              _buildScoreItem('Unanswered', unanswered, AppColors.text5Light),
            ],
          ),
          const SizedBox(height: 8),
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
          padding: const EdgeInsets.all(10),
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
        //const SizedBox(height: ),
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

  Widget _buildQuestionCard(int index, List<QuestionModel> questions, Map<int, int> userAnswers) {
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

  int _calculateScore(List<QuestionModel> questions, Map<int, int> userAnswers) {
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

  int _getCorrectAnswersCount(List<QuestionModel> questions, Map<int, int> userAnswers) {
    return _calculateScore(questions, userAnswers);
  }

  int _getWrongAnswersCount(List<QuestionModel> questions, Map<int, int> userAnswers) {
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

class _ScorePopupDialog extends StatefulWidget {
  final int totalScore;
  final int totalQuestions;
  final String percentage;
  final int correctAnswers;
  final int wrongAnswers;
  final int unanswered;
  final bool isMultiSubject;

  const _ScorePopupDialog({
    required this.totalScore,
    required this.totalQuestions,
    required this.percentage,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unanswered,
    required this.isMultiSubject,
  });

  @override
  State<_ScorePopupDialog> createState() => _ScorePopupDialogState();
}

class _ScorePopupDialogState extends State<_ScorePopupDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scoreValue = widget.totalQuestions > 0 
        ? widget.totalScore / widget.totalQuestions 
        : 0.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.eLearningBtnColor1,
                AppColors.eLearningBtnColor1.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                widget.isMultiSubject ? 'Test Completed!' : 'Well Done!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                widget.isMultiSubject 
                    ? 'Here\'s your overall performance'
                    : 'Here\'s how you performed',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 24),
              
              // Circular progress with percentage
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          color: Colors.white,
                          value: scoreValue * _progressAnimation.value,
                          strokeWidth: 12,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            widget.percentage,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          Text(
                            '%',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    'Correct',
                    widget.correctAnswers,
                    Icons.check_circle,
                    Colors.green.shade400,
                  ),
                  _buildStatItem(
                    'Wrong',
                    widget.wrongAnswers,
                    Icons.cancel,
                    Colors.red.shade400,
                  ),
                  _buildStatItem(
                    'Skipped',
                    widget.unanswered,
                    Icons.help_outline,
                    Colors.orange.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Progress bar
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: scoreValue * _progressAnimation.value,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.totalScore} / ${widget.totalQuestions} Questions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.eLearningBtnColor1,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
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
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Urbanist',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontFamily: 'Urbanist',
          ),
        ),
      ],
    );
  }
}
