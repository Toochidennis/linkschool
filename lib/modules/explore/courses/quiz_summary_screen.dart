import 'package:flutter/material.dart';
import '../../services/explore/quiz_result_service.dart';

class QuizSummaryScreen extends StatefulWidget {
  final int totalScore;
  final int totalQuestions;
  final List<Map<String, dynamic>> questions;
  final Map<int, int> userAnswers;
  final VoidCallback onRetake;
  final VoidCallback onClose;
  final String courseTitle;
  final String lessonTitle;

  const QuizSummaryScreen({
    Key? key,
    required this.totalScore,
    required this.totalQuestions,
    required this.questions,
    required this.userAnswers,
    required this.onRetake,
    required this.onClose,
    required this.courseTitle,
    required this.lessonTitle,
  }) : super(key: key);

  @override
  State<QuizSummaryScreen> createState() => _QuizSummaryScreenState();
}

class _QuizSummaryScreenState extends State<QuizSummaryScreen> {
  bool _hasBeenSaved = false;

  @override
  void initState() {
    super.initState();
    // Save quiz result immediately when screen loads
    _saveQuizResult();
  }

  Future<void> _saveQuizResult() async {
    if (_hasBeenSaved) return;

    _hasBeenSaved = true;
    final correctAnswers = _calculateCorrectAnswers();

    await QuizResultService.saveQuizResult(
      courseTitle: widget.courseTitle,
      lessonTitle: widget.lessonTitle,
      totalScore: widget.totalScore,
      totalQuestions: widget.totalQuestions,
      correctAnswers: correctAnswers,
      userAnswers: widget.userAnswers,
      questions: widget.questions,
    );

    print(
        '📊 Quiz auto-saved: ${widget.courseTitle} - ${widget.lessonTitle} = ${widget.totalScore}%');
  }

  int _calculateCorrectAnswers() {
    int correct = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (widget.userAnswers[i] == widget.questions[i]['correctAnswer']) {
        correct++;
      }
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    final correctAnswers = _calculateCorrectAnswers();
    final percentage = ((correctAnswers / widget.totalQuestions) * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Quiz Summary',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Total Points Section - Modern Design
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF64B6FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(height: 24),
                  // Well Done text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Well Done!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'You scored $percentage% on this quiz',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  // Animated circular progress
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.transparent,
                            ),
                          ),
                        ),
                        // Progress circle
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: percentage / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4ADE80),
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Score text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.totalScore}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            const Text(
                              'points',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Stats row
                ],
              ),
            ),

            // Questions list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                final question = widget.questions[index];
                final userAnswer = widget.userAnswers[index];
                final correctAnswer = question['correctAnswer'] as int;
                final isCorrect = userAnswer == correctAnswer;
                final options = question['options'] as List;

                // Determine border color based on correctness
                final borderColor = isCorrect
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF5350);

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: borderColor,
                        width: 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question header
                        Text(
                          'Question ${index + 1}/${widget.totalQuestions}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Question text
                        Text(
                          question['question'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Options
                        ...List.generate(options.length, (optionIndex) {
                          final isUserAnswer = userAnswer == optionIndex;
                          final isCorrectAnswer = correctAnswer == optionIndex;

                          Color? backgroundColor;
                          Color borderColor = Colors.grey.shade300;

                          if (isCorrectAnswer) {
                            // Correct answer - light green background
                            backgroundColor = const Color(0xFFE8F5E9);
                            borderColor = Colors.transparent;
                          } else if (isUserAnswer && !isCorrect) {
                            // Wrong user answer - light red background
                            backgroundColor = const Color(0xFFFFEBEE);
                            borderColor = Colors.transparent;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(6),
                              border: backgroundColor == null
                                  ? Border.all(color: borderColor, width: 1)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // Radio button
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCorrectAnswer
                                        ? const Color(0xFF4CAF50)
                                        : isUserAnswer && !isCorrect
                                            ? const Color(0xFFEF5350)
                                            : Colors.transparent,
                                    border: Border.all(
                                      color: isCorrectAnswer
                                          ? const Color(0xFF4CAF50)
                                          : isUserAnswer && !isCorrect
                                              ? const Color(0xFFEF5350)
                                              : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: (isCorrectAnswer || isUserAnswer)
                                      ? Center(
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                // Option text
                                Expanded(
                                  child: Text(
                                    options[optionIndex] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isCorrectAnswer
                                          ? const Color(0xFF2E7D32)
                                          : isUserAnswer && !isCorrect
                                              ? const Color(0xFFC62828)
                                              : Colors.grey.shade700,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Bottom buttons
          ],
        ),
      ),
    );
  }
}

// Custom painter for the green arc
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7FFF7F)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create a curved arc shape
    path.moveTo(size.width * 0.3, 0);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.3,
      size.width * 0.3,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.8,
      size.width * 0.4,
      size.height,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
