import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quiz_summary_screen.dart';
import '../../providers/explore/lesson_quiz_provider.dart';
import '../../model/explore/lesson_quiz/lesson_quiz_model.dart';
import '../../providers/explore/assignment_submission_provider.dart';

class QuizScreen extends StatefulWidget {
  final String courseTitle;
  final String lessonTitle;
  final int lessonId;
  final String cohortId;
  final String profileId;
  final String userName;
  final String userEmail;
  final String userPhone;

  const QuizScreen({
    super.key,
    required this.courseTitle,
    required this.lessonTitle,
    required this.lessonId,
    required this.cohortId,
    required this.profileId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isSubmittingScore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LessonQuizProvider>(context, listen: false);
      provider.loadQuizzes(widget.lessonId);
    });
  }

  void _selectAnswer(BuildContext context, int optionIndex) {
    final provider = Provider.of<LessonQuizProvider>(context, listen: false);
    provider.selectAnswer(optionIndex);
  }

  void _previousQuestion(BuildContext context) {
    final provider = Provider.of<LessonQuizProvider>(context, listen: false);
    provider.previousQuestion();
  }

  void _nextQuestion(BuildContext context) {
    final provider = Provider.of<LessonQuizProvider>(context, listen: false);
    provider.nextQuestion();
  }

  Future<void> _postQuizScore(int score) async {
    if (_isSubmittingScore) return;
    _isSubmittingScore = true;

    final provider = AssignmentSubmissionProvider();
    try {
      await provider.submitAssignment(
        name:widget.userName,
        email: widget.userEmail,
        phone: widget.userPhone,
        quizScore: score.toString(),
        lessonId: widget.lessonId.toString(),
        cohortId: widget.cohortId,
        profileId: widget.profileId,
      
      );

      print('✅ ===== data to submit quiz score: =====');
      print('Name: ${widget.userName}');
      print('Email: ${widget.userEmail}');
      print('Phone: ${widget.userPhone}');
      print('Quiz Score: $score');
      print('Lesson ID: ${widget.lessonId}');
      print('Cohort ID: ${widget.cohortId}');
      print('Profile ID: ${widget.profileId}');

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit quiz score: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isSubmittingScore = false;
    }
  }

  Future<void> _submitQuiz(BuildContext context) async {
    final provider = Provider.of<LessonQuizProvider>(context, listen: false);
    final score = ((provider.calculateScore() / provider.totalQuestions) * 100).round();

    // Post quiz score to assignment endpoint (no assignment files)
    await _postQuizScore(score);

    // Navigate to summary screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSummaryScreen(
          totalScore: score,
          totalQuestions: provider.totalQuestions,
          questions: provider.quizzes.map((quiz) => {
            'question': quiz.questionText,
            'options': quiz.options.map((opt) => opt.text).toList(),
            'correctAnswer': quiz.correct.order,
          }).toList(),
          userAnswers: provider.selectedAnswers,
          courseTitle: widget.courseTitle,
          lessonTitle: widget.lessonTitle,
          onRetake: () {
            Navigator.pop(context); // Close summary
            provider.resetQuiz();
          },
          onClose: () {
            Navigator.pop(context); // Close summary
            Navigator.pop(context, score); // Close quiz screen and return score
          },
        ),
      ),
    ).then((_) {
      // When returning from summary, close the quiz screen and return score
      Navigator.pop(context, score);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonQuizProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.courseTitle),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.courseTitle),
            ),
            body: Center(
              child: Container(
                height: 100,
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        if (provider.quizzes.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.courseTitle),
            ),
            body: const Center(
              child: Text('No quizzes available'),
            ),
          );
        }

        final currentQuestion = provider.currentQuestion!;
        final selectedAnswer = provider.selectedAnswers[provider.currentQuestionIndex];
        final isLastQuestion = provider.isLastQuestion;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Exit Quiz?'),
                    content:
                        const Text('Your progress will be lost if you exit now.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Close quiz screen
                        },
                        child: const Text(
                          'Exit',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            title: Text(
              widget.courseTitle,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              // Progress bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${provider.currentQuestionIndex + 1} of ${provider.totalQuestions}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${((provider.currentQuestionIndex + 1) / provider.totalQuestions * 100).round()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (provider.currentQuestionIndex + 1) / provider.totalQuestions,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),

              // Question and options
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question
                      Text(
                        currentQuestion.questionText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Options
                      ...List.generate(
                        currentQuestion.options.length,
                        (index) {
                          final isSelected = selectedAnswer == index;
                          return GestureDetector(
                            onTap: () => _selectAnswer(context, index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6366F1).withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6366F1)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFF6366F1)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF6366F1)
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      currentQuestion.options[index].text,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Previous button
                    if (provider.currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _previousQuestion(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6366F1),
                            side: const BorderSide(
                              color: Color(0xFF6366F1),
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    if (provider.currentQuestionIndex > 0) const SizedBox(width: 12),

                    // Next/Submit button
                    Expanded(
                      flex: provider.currentQuestionIndex == 0 ? 1 : 1,
                      child: ElevatedButton(
                        onPressed: selectedAnswer != null
                            ? (isLastQuestion ? () => _submitQuiz(context) : () => _nextQuestion(context))
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLastQuestion ? 'Submit' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
