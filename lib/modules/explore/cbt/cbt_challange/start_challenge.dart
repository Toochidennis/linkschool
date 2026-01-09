// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_modal.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challenge_leader.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_provider.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_questions.dart';
import 'package:linkschool/modules/providers/explore/challenge/challenge_leader_provider.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';

import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';

class StartChallenge extends StatefulWidget {
  final ChallengeModel? challenge;
  final int? challengeId;
  final List<String>? examIds;
  final List<String>? subjectNames;
  final List<String>? years;
  final int? totalDurationInSeconds;
  final int? questionLimit;
  final bool isPreview;
  const StartChallenge({
    Key? key,
    this.challenge,
    this.examIds,
    this.subjectNames,
    this.years,
    this.totalDurationInSeconds = 3600,
    this.questionLimit,
    this.challengeId,
    this.isPreview = false,
  }) : super(key: key);

  @override
  State<StartChallenge> createState() => _StartChallengeState();
}

class _StartChallengeState extends State<StartChallenge>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  int _lastDisplayedQuestionIndex = -1;

  Timer? _timer;
  int? _remainingSeconds;

  // Multi-subject handling
  int currentExamIndex = 0;
  Map<String, Map<int, int>> allAnswers = {};
  Map<String, List<QuestionModel>> allQuestions = {};
  Map<String, String> subjectNames = {};
  Map<String, String> subjectYears = {};

  // Answer popup handling
  bool _showAnswerPopup = false;
  bool _isCurrentAnswerCorrect = false;
  String _correctAnswerText = '';
  late AudioPlayer _correctSoundPlayer;
  late AudioPlayer _wrongSoundPlayer;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Initialize bounce animation for Read More arrow
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );
    _bounceController.repeat(reverse: true);

    _correctSoundPlayer = AudioPlayer();
    _wrongSoundPlayer = AudioPlayer();

    _remainingSeconds = widget.totalDurationInSeconds;
    _startTimer();

    // Initialize subject mappings for multi-subject
    if (widget.examIds != null &&
        widget.subjectNames != null &&
        widget.years != null) {
      for (int i = 0; i < widget.examIds!.length; i++) {
        subjectNames[widget.examIds![i]] = widget.subjectNames![i];
        subjectYears[widget.examIds![i]] = widget.years![i];
      }
    }

    if (widget.examIds == null || widget.examIds!.isEmpty) {
      print('❌ ERROR: No exam IDs provided!');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No subjects available for this challenge'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoadingCountdown();
    });
    _slideController.forward();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds == null || _remainingSeconds! <= 0) {
        t.cancel();
        if (mounted) _submitQuiz();
      } else {
        setState(() => _remainingSeconds = _remainingSeconds! - 1);
      }
    });
  }

  Future<void> _loadQuestions() async {
    if (widget.examIds == null ||
        widget.examIds!.isEmpty ||
        currentExamIndex >= widget.examIds!.length) {
      return;
    }

    final currentExamId = widget.examIds![currentExamIndex];

    try {
      if (widget.isPreview) {
        // PREVIEW MODE → Use ChallengeProvider + ExamProvider (random questions)
        final challengeProvider = context.read<ChallengeProvider>();

        // Use examType from first subject or fallback
        final examType = widget.subjectNames?[currentExamIndex] ?? 'default';

        await challengeProvider.previewChallengeExam(
          examType,
          limit: widget.questionLimit,
        );

        // Manually set questions into ChallengeQuestionProvider (to reuse UI)
        // final questionProvider = context.read<ChallengeQuestionProvider>();
        // questionProvider.setQuestionsManually(challengeProvider.previewQuestions);
      } else {
        // REAL MODE → Use normal challenge questions endpoint
        final provider = context.read<ChallengeQuestionProvider>();
        final realChallengeId = widget.challengeId ?? 0;

        await provider.fetchChallengeQuestions(
          examId: int.parse(currentExamId),
          challengeId: realChallengeId,
          limit: widget.questionLimit,
        );
      }

      if (mounted) {
        setState(() {});
        // Only pop countdown if it's still showing
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // close countdown
        }
      }
    } catch (e) {
      print("Load error: $e");
      if (mounted) {
        setState(() {});
        if (Navigator.canPop(context)) Navigator.of(context).pop();
      }
    }
  }

  void _showLoadingCountdown() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LoadingCountdownDialog(
        onComplete: () {
          // This runs exactly when 3 → 2 → 1 → 0 finishes
          Navigator.of(context).pop(); // close the countdown dialog
          // ← NOW show instruction/passage
        },
      ),
    );

    _loadQuestions(); // start loading questions in background
  }

  void _showNextSubjectCountdown() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CountdownDialog(
        currentIndex: currentExamIndex,
        totalExams: widget.examIds!.length,
        onComplete: () {},
      ),
    );
    _loadQuestions();
  }

  void _loadNextExam() {
    if (currentExamIndex < widget.examIds!.length - 1) {
      setState(() {
        currentExamIndex++;
      });
      print('\n📚 Loading Next Exam:');
      print('   Subject: ${widget.subjectNames![currentExamIndex]}');
      print('   Exam ID: ${widget.examIds![currentExamIndex]}');
      print('   Progress: ${currentExamIndex + 1}/${widget.examIds!.length}');
      print('   Remaining Time: ${_remainingSeconds! ~/ 60} minutes');
      print('─' * 50);

      _showNextSubjectCountdown();
    } else {
      // All exams completed - show comprehensive results
      _showFinalResults();
    }
  }

  void _selectAnswer(int optionIndex) {
    final provider = context.read<ChallengeQuestionProvider>();
    final currentIdx = provider.currentQuestionIndex;

    // Prevent double tap
    if (provider.userAnswers.containsKey(currentIdx)) return;

    provider.selectAnswer(currentIdx, optionIndex);
    _scaleController.forward(from: 0);

    // Check if answer is correct - FIX: Parse the order as int
    final correctAnswerOrderStr =
        provider.questions[currentIdx].correctAnswer?['order'];
    int? correctAnswerOrder;

    // Handle both String and int types
    if (correctAnswerOrderStr is String) {
      correctAnswerOrder = int.tryParse(correctAnswerOrderStr);
    } else if (correctAnswerOrderStr is int) {
      correctAnswerOrder = correctAnswerOrderStr;
    }

    // Compare with +1 offset since optionIndex is 0-based but order is 1-based
    final isCorrect =
        correctAnswerOrder != null && (optionIndex + 1) == correctAnswerOrder;

    // Get correct answer text for display
    String correctAnswerText = '';
    if (correctAnswerOrder != null) {
      final correctOptionIndex = correctAnswerOrder - 1; // Convert to 0-based
      final options = provider.questions[currentIdx].getOptions();
      if (correctOptionIndex >= 0 && correctOptionIndex < options.length) {
        correctAnswerText = options[correctOptionIndex];
      }
    }

    print(
        'Answer Selected: ${isCorrect ? "Correct" : "Wrong"} (Selected index: $optionIndex, Order: ${optionIndex + 1}, Correct Order: $correctAnswerOrder)');

    setState(() {
      _isCurrentAnswerCorrect = isCorrect;
      _correctAnswerText = correctAnswerText;
      _showAnswerPopup = true;
    });

    // Play sound
    if (isCorrect) {
      _playCorrectSound();
    } else {
      _playWrongSound();
    }
  }

  void _playCorrectSound() async {
    try {
      await _correctSoundPlayer.stop();
      await _correctSoundPlayer.play(AssetSource('sounds/correct.wav'));
    } catch (e) {
      print('Error playing correct sound: $e');
    }
  }

  void _playWrongSound() async {
    try {
      await _wrongSoundPlayer.stop();
      await _wrongSoundPlayer.play(AssetSource('sounds/wrong.wav'));
    } catch (e) {
      print('Error playing wrong sound: $e');
    }
  }

  void _closeAnswerPopup() {
    setState(() {
      _showAnswerPopup = false;
    });

    final provider = context.read<ChallengeQuestionProvider>();
    final currentIdx = provider.currentQuestionIndex;

    // Auto-advance after popup is closed
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      if (currentIdx < provider.questions.length - 1) {
        _slideController.reset();
        provider.nextQuestion();
        _slideController.forward();
      } else {
        // Last question of current exam completed
        _completeCurrentExam(provider);
      }
    });
  }

  void _completeCurrentExam(ChallengeQuestionProvider provider) {
    // Save answers and questions for current exam
    final currentExamId = widget.examIds![currentExamIndex];
    allAnswers[currentExamId] = Map<int, int>.from(provider.userAnswers);
    allQuestions[currentExamId] = List<QuestionModel>.from(provider.questions);

    print('\n✅ Exam Completed:');
    print('   Subject: ${widget.subjectNames![currentExamIndex]}');
    print('   Questions: ${provider.questions.length}');
    print('   Questions Answered: ${provider.userAnswers.length}');
    print('   Remaining Time: ${_remainingSeconds! ~/ 60} minutes');
    print('   Saved Questions: ${allQuestions[currentExamId]?.length ?? 0}');
    print('   Saved Answers: ${allAnswers[currentExamId]?.length ?? 0}');
    print('─' * 50);

    // Reset provider for next exam
    provider.reset();

    // Load next exam or show results
    _loadNextExam();
  }

  void _submitQuiz() {
    _timer?.cancel();

    // Calculate total score across all exams
    int totalScore = 0;
    int totalQuestions = 0;
    int totalAnswered = 0;
    int totalCorrect = 0;

    for (var entry in allAnswers.entries) {
      final examId = entry.key;
      final answers = entry.value;
      final questions = allQuestions[examId] ?? [];

      totalQuestions += questions.length;
      totalAnswered += answers.length;

      for (int i = 0; i < questions.length; i++) {
        if (answers.containsKey(i)) {
          // Extract the order from the correctAnswer object
          final correctAnswerOrder = questions[i].correctAnswer?['order'];

          if (answers[i] == correctAnswerOrder) {
            totalScore += 10;
            totalCorrect++;
          }
        }
      }
    }

    // Calculate time taken
    final timeTaken =
        (widget.totalDurationInSeconds ?? 0) - (_remainingSeconds ?? 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        score: totalScore,
        totalQuestions: totalQuestions,
        answeredQuestions: totalAnswered,
        correctAnswers: totalCorrect,
        challengeId: widget.challengeId,
        timeTaken: timeTaken,
      ),
    );
  }

  void _showFinalResults() {
    print('\n🎉 All Exams Completed!');
    print('   Total Subjects Completed: ${widget.examIds!.length}');
    print('   Total Answers Recorded: ${allAnswers.length}');

    int totalQuestions = 0;
    int totalAnswered = 0;
    for (var entry in allAnswers.entries) {
      final examId = entry.key;
      final answers = entry.value;
      final questions = allQuestions[examId] ?? [];
      totalQuestions += questions.length;
      totalAnswered += answers.length;
      final index = widget.examIds!.indexOf(examId);
      if (index >= 0) {
        print(
            '   ${widget.subjectNames![index]}: ${answers.length}/${questions.length} answered');
      }
    }
    print('   Total: $totalAnswered/$totalQuestions answered');
    print('─' * 50);

    _submitQuiz();
  }

  int _calculateScore(ChallengeQuestionProvider p) {
    int score = 0;
    for (int i = 0; i < p.questions.length; i++) {
      if (p.userAnswers[i] == p.questions[i].correctAnswer) score += 10;
    }
    return score;
  }

  int _calculateCorrectAnswers(ChallengeQuestionProvider p) {
    int correct = 0;
    for (int i = 0; i < p.questions.length; i++) {
      if (p.userAnswers[i] == p.questions[i].correctAnswer) correct++;
    }
    return correct;
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Convert HTML/span text to TextSpan list for RichText
  List<TextSpan> _parseHtmlToTextSpans(String text) {
    if (!text.contains('<span') &&
        !text.contains('<b') &&
        !text.contains('<i')) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    final regExp = RegExp(
        r'<span[^>]*>([^<]*)</span>|<b>([^<]*)</b>|<i>([^<]*)</i>|([^<]+)');
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      if (match.group(1) != null) {
        // <span> content - bold and colored
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue.shade700),
        ));
      } else if (match.group(2) != null) {
        // <b> content
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(3) != null) {
        // <i> content
        spans.add(TextSpan(
          text: match.group(3),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(4) != null) {
        // Plain text
        spans.add(TextSpan(text: match.group(4)));
      }
    }

    return spans.isEmpty ? [TextSpan(text: text)] : spans;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    _correctSoundPlayer.dispose();
    _wrongSoundPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeQuestionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return _buildLoading();
        if (provider.questions.isEmpty) return _buildError();

        final question = provider.currentQuestion;
        final selected = provider.userAnswers[provider.currentQuestionIndex];

        // Calculate total progress across all exams
        int totalQuestionsAnswered = 0;
        int totalQuestions = 0;

        // Add completed exams
        for (var entry in allAnswers.entries) {
          final answers = entry.value;
          final questions = allQuestions[entry.key] ?? [];
          totalQuestionsAnswered += answers.length;
          totalQuestions += questions.length;
        }

        // Add current exam progress
        totalQuestionsAnswered += provider.currentQuestionIndex + 1;
        totalQuestions += provider.questions.length;

        final progress =
            totalQuestions > 0 ? totalQuestionsAnswered / totalQuestions : 0;

        // Dialog only shows when Read More button is clicked - no auto-show

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(provider, progress.toDouble()),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            // Instruction/Passage Preview Card
                            if (question != null &&
                                ((question.instruction?.isNotEmpty ?? false) ||
                                    (question.passage?.isNotEmpty ?? false)))
                              _buildInstructionPassagePreviewCard(question),
                            if (question != null)
                              SlideTransition(
                                position: Tween<Offset>(
                                        begin: Offset(1.0, 0), end: Offset.zero)
                                    .animate(CurvedAnimation(
                                        parent: _slideController,
                                        curve: Curves.easeOutCubic)),
                                child: FadeTransition(
                                  opacity: _slideController,
                                  child: _buildQuestionCard(question),
                                ),
                              ),
                            SizedBox(height: 30),
                            if (question != null)
                              _buildOptions(question, selected),
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Answer Popup Overlay
              if (_showAnswerPopup)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: _AnswerPopup(
                      isCorrect: _isCurrentAnswerCorrect,
                      onClose: _closeAnswerPopup,
                      correctAnswerText: _correctAnswerText,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.eLearningBtnColor1),
              SizedBox(height: 20),
              Text("Loading Challenge...",
                  style: AppTextStyles.normal600(fontSize: 16)),
            ],
          ),
        ),
      );

  Widget _buildError() => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 70, color: Colors.red),
              SizedBox(height: 16),
              Text("Failed to load questions",
                  style: AppTextStyles.normal600(fontSize: 18)),
              ElevatedButton(onPressed: _loadQuestions, child: Text("Retry")),
            ],
          ),
        ),
      );

  Widget _buildHeader(ChallengeQuestionProvider p, double progress) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            colors: [Colors.blue.shade50, Colors.white]),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new, size: 20),
                style: IconButton.styleFrom(backgroundColor: Colors.white),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.challenge?.title ?? "CBT Challenge",
                        style: AppTextStyles.normal600(fontSize: 20)),
                    if (widget.subjectNames?.isNotEmpty == true)
                      Text(
                          widget.subjectNames!.length > 1
                              ? "${widget.subjectNames![currentExamIndex]} (${currentExamIndex + 1}/${widget.subjectNames!.length})"
                              : widget.subjectNames![currentExamIndex],
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.red.shade500, Colors.orange.shade600]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(_formatTime(_remainingSeconds ?? 0),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "Question ${p.currentQuestionIndex + 1} of ${p.questions.length}",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text("${(progress * 100).toInt()}% Complete"),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(6)),
        ],
      ),
    );
  }

  Widget _buildInstructionPassagePreviewCard(QuestionModel question) {
    final hasInstruction = question.instruction?.isNotEmpty ?? false;
    final hasPassage = question.passage?.isNotEmpty ?? false;

    String title = '';
    String content = '';

    if (hasInstruction && hasPassage) {
      title = 'Instruction & Passage';
      content = '${question.instruction}\n\n${question.passage}';
    } else if (hasInstruction) {
      title = 'Instruction';
      content = question.instruction ?? '';
    } else if (hasPassage) {
      title = 'Passage';
      content = question.passage ?? '';
    }

    if (content.isEmpty) return const SizedBox.shrink();

    // Define max characters for preview (adjust as needed)
    const int maxPreviewLength = 150;
    final bool isLongText = content.length > maxPreviewLength;
    final String previewText =
        isLongText ? '${content.substring(0, maxPreviewLength)}...' : content;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Header row with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.eLearningBtnColor1.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasInstruction && hasPassage
                      ? Icons.menu_book_rounded
                      : (hasInstruction
                          ? Icons.info_outline
                          : Icons.article_outlined),
                  color: AppColors.eLearningBtnColor1,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.eLearningBtnColor1,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Preview text with HTML rendering
          Html(
            data: previewText,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(14),
                color: Colors.black87,
                lineHeight: LineHeight(1.5),
              ),
            },
          ),
          // Read More with bouncing arrow animation (only if text is long)
          if (isLongText) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => _showInstructionOrPassageModal(title, content),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Read More',
                        style: TextStyle(
                          color: AppColors.eLearningBtnColor1,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_bounceAnimation.value, 0),
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.eLearningBtnColor1,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel q) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.amber.shade400,
                        Colors.orange.shade600
                      ]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("10 pts",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                  Spacer(),
                  Icon(Icons.lightbulb_outline, color: Colors.amber, size: 26),
                ],
              ),
              SizedBox(height: 16),

              // If there's a question image (either base64/data url or network path), show it
              if (q.questionImage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GestureDetector(
                    onTap: () => _showFullScreenImage(q.questionImage),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _getImageWidget(q.questionImage, height: 180),
                    ),
                  ),
                ),

              Html(
                data: q.content.isNotEmpty
                    ? q.content[0].toUpperCase() + q.content.substring(1)
                    : "Question",
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(19),
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  "img": Style(
                    width: Width.auto(),
                    padding: HtmlPaddings.only(left: 4, right: 4),
                  ),
                },
                extensions: [
                  TagExtension(
                    tagsToExtend: {"img"},
                    builder: (extensionContext) {
                      final attributes = extensionContext.attributes;
                      final src = attributes['src'] ?? '';

                      if (src.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: _getImageWidget(src, height: 30),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Positioned instruction/passage icon at top-right
        if ((q.instruction?.isNotEmpty ?? false) ||
            (q.passage?.isNotEmpty ?? false))
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: AppColors.eLearningBtnColor1,
                size: 24,
              ),
              onPressed: () {
                // Determine which content to show
                String title = '';
                String content = '';

                if (q.instruction?.isNotEmpty ?? false) {
                  title = 'Instruction';
                  content = q.instruction ?? '';
                } else if (q.passage?.isNotEmpty ?? false) {
                  title = 'Passage';
                  content = q.passage ?? '';
                }

                // Show the modal immediately
                if (content.isNotEmpty) {
                  _showInstructionOrPassageModal(title, content);
                }
              },
              tooltip: (q.instruction?.isNotEmpty ?? false)
                  ? 'View Instruction'
                  : 'View Passage',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black26,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptions(QuestionModel question, int? selectedAnswer) {
    // Support structured options (with optional imageUrl) and fallback to plain text options
    final structuredOptions = question.options;
    final options = question.getOptions();

    List<Widget> optionWidgets = [];

    for (int index = 0;
        index <
            (structuredOptions != null && structuredOptions.isNotEmpty
                ? structuredOptions.length
                : options.length);
        index++) {
      final isSelected = selectedAnswer == index;
      String optionText = '';
      String? optionImageUrl;

      if (structuredOptions != null &&
          structuredOptions.isNotEmpty &&
          index < structuredOptions.length) {
        final opt = structuredOptions[index];
        optionText = opt['text']?.toString() ?? '';
        optionImageUrl = opt['imageUrl']?.toString();
      } else if (index < options.length) {
        optionText = options[index];
        optionImageUrl =
            question.getOptionWithImage(index)?['imageUrl']?.toString();
      }

      final child = GestureDetector(
        onTap: () => _selectAnswer(index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [
                    AppColors.eLearningBtnColor1,
                    AppColors.eLearningBtnColor1.withOpacity(0.8)
                  ])
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                width: 1.5),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppColors.eLearningBtnColor1.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 6)
                  ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    isSelected ? Colors.white : Colors.grey.shade100,
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.eLearningBtnColor1
                          : Colors.grey.shade700),
                ),
              ),
              SizedBox(width: 12),
              if (optionImageUrl != null && optionImageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () => _showFullScreenImage(optionImageUrl!),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _getImageWidget(optionImageUrl,
                            width: 72, height: 56)),
                  ),
                ),
              Expanded(
                child: Html(
                  data: optionText,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(16.2),
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    "img": Style(
                      width: Width.auto(),
                      padding: HtmlPaddings.only(left: 4, right: 4),
                    ),
                  },
                  extensions: [
                    TagExtension(
                      tagsToExtend: {"img"},
                      builder: (extensionContext) {
                        final attributes = extensionContext.attributes;
                        final src = attributes['src'] ?? '';

                        if (src.isEmpty) return const SizedBox.shrink();

                        return GestureDetector(
                          onTap: () => _showFullScreenImage(src),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: _getImageWidget(src, height: 30),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (isSelected)
                ScaleTransition(
                  scale: CurvedAnimation(
                      parent: _scaleController, curve: Curves.elasticOut),
                  child:
                      Icon(Icons.check_circle, color: Colors.white, size: 28),
                ),
            ],
          ),
        ),
      );

      optionWidgets.add(TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 360 + index * 80),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) => Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: Opacity(opacity: value, child: child)),
        child: child,
      ));
    }

    return Column(children: optionWidgets);
  }

  // Show an image (handles data: base64 or network paths)
  Widget _getImageWidget(String url, {double? width, double? height}) {
    if (_isBase64(url)) {
      try {
        final bytes = base64.decode(url.split(',').last);
        return Image.memory(bytes,
            width: width, height: height, fit: BoxFit.cover);
      } catch (e) {
        return Container(
            width: width, height: height, color: Colors.grey.shade200);
      }
    }

    // Prepend base URL if it's a relative path
    String imageUrl = url;
    if (!url.startsWith('http') && !url.startsWith('data:')) {
      imageUrl = 'https://linkskool.net/$url';
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Container(width: width, height: height, color: Colors.grey.shade200),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
            width: width,
            height: height,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
      },
    );
  }

  bool _isBase64(String s) {
    return s.startsWith('data:image') ||
        (s.length > 100 && s.contains('base64'));
  }

  void _showFullScreenImage(String imageUrl) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black87,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Tap to zoom, pinch to zoom in/out',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: _getImageWidget(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  void _showInstructionOrPassageModal(String title, String content) {
    if (!mounted || content.trim().isEmpty) return;

    // Parse if both instruction and passage are combined (separated by \n\n)
    bool hasBothSections = title == 'Instruction & Passage';
    List<String> sections = [];
    List<String> sectionTitles = [];

    if (hasBothSections && content.contains('\n\n')) {
      final parts = content.split('\n\n');
      if (parts.length >= 2) {
        sections = [parts[0], parts.sublist(1).join('\n\n')];
        sectionTitles = ['Instruction', 'Passage'];
      } else {
        sections = [content];
        sectionTitles = [title];
      }
    } else {
      sections = [content];
      sectionTitles = [title];
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show question number at top
                          Builder(builder: (context) {
                            final provider =
                                Provider.of<ChallengeQuestionProvider>(context,
                                    listen: false);
                            final qIndex = (provider.questions.isNotEmpty)
                                ? provider.currentQuestionIndex
                                : -1;
                            if (qIndex >= 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  'Question ${qIndex + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),

                          // Render sections
                          ...sections.asMap().entries.map((entry) {
                            final index = entry.key;
                            final sectionContent = entry.value.trim();
                            final sectionTitle = sectionTitles[index];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section title
                                Text(
                                  sectionTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.eLearningBtnColor1,
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Section content with HTML rendering
                                Html(
                                  data: sectionContent,
                                  style: {
                                    "body": Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                      fontSize: FontSize(14),
                                      color: AppColors.text3Light,
                                      lineHeight: LineHeight(1.6),
                                    ),
                                  },
                                ),

                                // Add spacing between sections
                                if (index < sections.length - 1)
                                  const SizedBox(height: 24),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Fixed "Got it" button at bottom
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.eLearningBtnColor1,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Got it',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Urbanist',
                        ),
                      ),
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
}

class _ResultDialog extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final int? challengeId;
  final int timeTaken;

  const _ResultDialog({
    required this.score,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    this.challengeId,
    required this.timeTaken,
  });

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(Duration(milliseconds: 400), () {
      _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage =
        (widget.correctAnswers / widget.totalQuestions * 100).round();
    final isPerfect = percentage == 100;
    final isGood = percentage >= 70;
    final isAverage = percentage >= 50;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                isPerfect
                    ? Colors.amber.shade50
                    : isGood
                        ? Colors.green.shade50
                        : Colors.blue.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: Offset(0, 15),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Confetti overlay
              if (isPerfect) _buildConfettiOverlay(),

              // Main content
              Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),

                    // Animated trophy/icon
                    _buildAnimatedIcon(isPerfect, isGood),

                    SizedBox(height: 14),

                    // Title with gradient text
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: isPerfect
                            ? [Colors.amber.shade600, Colors.orange.shade600]
                            : isGood
                                ? [Colors.green.shade600, Colors.teal.shade600]
                                : [
                                    Colors.blue.shade600,
                                    Colors.indigo.shade600
                                  ],
                      ).createShader(bounds),
                      child: Text(
                        isPerfect
                            ? 'Perfect Score!'
                            : isGood
                                ? 'Excellent Work!'
                                : isAverage
                                    ? 'Good Effort!'
                                    : 'Keep Trying!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Urbanist',
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      isPerfect
                          ? '🎉 Flawless performance!'
                          : isGood
                              ? '⭐ Outstanding achievement!'
                              : isAverage
                                  ? '👍 You\'re making progress!'
                                  : '💪 Practice makes perfect!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.normal500(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: 12),

                    // Score circle with animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildScoreCircle(percentage, isPerfect, isGood),
                    ),

                    SizedBox(height: 20),

                    // Stats cards
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildStatsGrid(percentage),
                    ),

                    SizedBox(height: 32),

                    // Action buttons
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildActionButtons(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfettiOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _confettiController,
        builder: (context, child) {
          return CustomPaint(
            painter: ConfettiPainter(_confettiController.value),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedIcon(bool isPerfect, bool isGood) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.rotate(
            angle: (1 - value) * 0.5,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPerfect
                      ? [Colors.amber.shade400, Colors.orange.shade500]
                      : isGood
                          ? [Colors.green.shade400, Colors.teal.shade500]
                          : [Colors.blue.shade400, Colors.indigo.shade500],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isPerfect
                            ? Colors.amber
                            : isGood
                                ? Colors.green
                                : Colors.blue)
                        .withOpacity(0.5),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isPerfect
                    ? Icons.emoji_events_rounded
                    : isGood
                        ? Icons.stars_rounded
                        : Icons.emoji_events_outlined,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCircle(int percentage, bool isPerfect, bool isGood) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            isPerfect
                ? Colors.amber.shade50
                : isGood
                    ? Colors.green.shade50
                    : Colors.blue.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress indicator
          SizedBox(
            width: 160,
            height: 160,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: percentage / 100),
              duration: Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPerfect
                        ? Colors.amber.shade500
                        : isGood
                            ? Colors.green.shade500
                            : Colors.blue.shade500,
                  ),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),

          // Score text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: widget.score),
                duration: Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: isPerfect
                          ? Colors.amber.shade700
                          : isGood
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                      fontFamily: 'Urbanist',
                      height: 1,
                    ),
                  );
                },
              ),
              SizedBox(height: 4),
              Text(
                'points',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int percentage) {
    return Container(
      // padding: EdgeInsets.all(8),

      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.check_circle_rounded,
              '${widget.correctAnswers}/${widget.totalQuestions}',
              'Correct',
              Colors.green.shade500,
            ),
          ),
          Container(
            height: 50,
            width: 1.5,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStatItem(
              Icons.analytics_rounded,
              '$percentage%',
              'Accuracy',
              Colors.amber.shade600,
            ),
          ),
          Container(
            height: 50,
            width: 1.5,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStatItem(
              Icons.quiz_rounded,
              '${widget.answeredQuestions}',
              'Answered',
              Colors.blue.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
            fontFamily: 'Urbanist',
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.normal500(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    final userProvider = Provider.of<CbtUserProvider>(context);
    final user = userProvider.currentUser;

    return Column(
      children: [
        // Primary button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade500, Colors.indigo.shade600],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade400.withOpacity(0.4),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: leaderboardProvider.submitting
                  ? null
                  : () async {
                      // Submit result if challengeId is available
                      if (widget.challengeId != null && user != null) {
                        // Show loading indicator with centered container
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => WillPopScope(
                            onWillPop: () async => false,
                            child: Material(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 40),
                                  padding: EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.blue.shade600,
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      Text(
                                        'Submitting results...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Please wait',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );

                        final success =
                            await leaderboardProvider.submitChallengeResult(
                          challengeId: widget.challengeId!,
                          userId: user.id ?? 0,
                          username: user.name,
                          score: widget.score,
                          correctAnswers: widget.correctAnswers,
                          totalQuestions: widget.totalQuestions,
                          timeTaken: widget.timeTaken,
                        );

                        // Close loading dialog
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }

                        if (success) {
                          // Navigate to leaderboard on success
                          if (context.mounted) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChallengeLeader(
                                  fromChallenge: true,
                                  fromChallengeCompletion: true,
                                  challengeId: widget.challengeId,
                                ),
                              ),
                            );
                            // No need to handle result - just let user view leaderboard and come back
                          }
                        } else {
                          // Show error
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to submit results. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: leaderboardProvider.submitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.leaderboard_rounded,
                              color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'View Leaderboard',
                            style: AppTextStyles.normal700(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),

        SizedBox(height: 12),

        // Secondary button
      ],
    );
  }
}

class _CountdownDialog extends StatefulWidget {
  final int currentIndex;
  final int totalExams;
  final VoidCallback onComplete;

  const _CountdownDialog({
    required this.currentIndex,
    required this.totalExams,
    required this.onComplete,
  });

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (_countdown > 1) {
          setState(() {
            _countdown--;
          });
          _controller.reset();
          _controller.forward();
          _startCountdown();
        } else {
          widget.onComplete();
          // Navigator.of(context).pop(); // Remove auto-pop
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextSubjectNumber = widget.currentIndex + 2;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
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
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Great Progress!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              'Moving to Subject $nextSubjectNumber of ${widget.totalExams}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 32),

            // Countdown container (static)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: AppColors.eLearningBtnColor1,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress indicator
            Text(
              'Get ready...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'Urbanist',
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCountdownDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _LoadingCountdownDialog({
    required this.onComplete,
  });

  @override
  State<_LoadingCountdownDialog> createState() =>
      _LoadingCountdownDialogState();
}

class _LoadingCountdownDialogState extends State<_LoadingCountdownDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (_countdown > 1) {
          setState(() {
            _countdown--;
          });
          _controller.reset();
          _controller.forward();
          _startCountdown();
        } else {
          widget.onComplete();
          // Navigator.of(context).pop(); // Remove auto-pop
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
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
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Starting Challenge',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 12),

            // Message
            const Text(
              'Loading questions...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 32),

            // Countdown container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: AppColors.eLearningBtnColor1,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress indicator
            Text(
              'Get ready...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'Urbanist',
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for confetti effect
class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final colors = [
      Colors.amber,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.green,
    ];

    for (int i = 0; i < 30; i++) {
      final x = (i * 37) % size.width;
      final y = (progress * size.height * 1.5) - (i * 15 % 100);

      if (y > -20 && y < size.height + 20) {
        paint.color = colors[i % colors.length].withOpacity(0.7);
        canvas.drawCircle(
          Offset(x, y),
          3 + (i % 3),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

// Answer Popup Widget with Close Button
class _AnswerPopup extends StatefulWidget {
  final bool isCorrect;
  final VoidCallback onClose;
  final String correctAnswerText;

  const _AnswerPopup({
    required this.isCorrect,
    required this.onClose,
    required this.correctAnswerText,
  });

  @override
  State<_AnswerPopup> createState() => _AnswerPopupState();
}

class _AnswerPopupState extends State<_AnswerPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Main scale animation with bounce
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    // Slide up animation
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    );

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    // Pulse animation for icon
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    // Rotate animation for wrong answers
    _rotateController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    // Particle burst animation
    _particleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));

    // Start animations in sequence
    _scaleController.forward();
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) _slideController.forward();
    });

    if (widget.isCorrect) {
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          _confettiController.forward();
          _particleController.forward();
        }
      });
      Future.delayed(Duration(milliseconds: 400), () {
        if (mounted) {
          _pulseController.repeat(reverse: true);
        }
      });
    } else {
      // Shake animation for wrong answers
      Future.delayed(Duration(milliseconds: 400), () {
        if (mounted) {
          _rotateController.repeat(reverse: true);
          Future.delayed(Duration(milliseconds: 600), () {
            if (mounted) _rotateController.stop();
          });
        }
      });
    }

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleController,
        _slideController,
        _rotateController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * MediaQuery.of(context).size.width,
              _slideAnimation.value.dy * MediaQuery.of(context).size.height,
            ),
            child: Transform.rotate(
              angle: widget.isCorrect ? 0 : _rotateAnimation.value,
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                margin: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isCorrect
                        ? [
                            Colors.green.shade50,
                            Colors.white,
                            Colors.green.shade50,
                          ]
                        : [
                            Colors.red.shade50,
                            Colors.white,
                            Colors.red.shade50,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: widget.isCorrect
                        ? Colors.green.shade300
                        : Colors.red.shade300,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isCorrect ? Colors.green : Colors.red)
                          .withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Confetti overlay for correct answers
                    if (widget.isCorrect) _buildConfettiOverlay(),

                    // Particle burst overlay
                    if (widget.isCorrect) _buildParticleBurstOverlay(),

                    // Main content
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated Icon
                          _buildAnimatedIcon(),
                          SizedBox(height: 24),

                          // Title with shimmer effect
                          _buildAnimatedTitle(),
                          SizedBox(height: 12),

                          // Points display for correct answers
                          if (widget.isCorrect) _buildPointsCounter(),

                          // Subtitle
                          SizedBox(height: 12),
                          _buildSubtitle(),
                        ],
                      ),
                    ),

                    // Floating stars for correct answers
                    if (widget.isCorrect) _buildFloatingStars(),

                    // Close button at top right - MUST BE LAST to be on top
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color: widget.isCorrect
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            size: 24,
                          ),
                        ),
                      ),
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

  Widget _buildConfettiOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _confettiController,
        builder: (context, child) {
          return CustomPaint(
            painter: _ConfettiPainter(_confettiController.value),
          );
        },
      ),
    );
  }

  Widget _buildParticleBurstOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticleBurstPainter(_particleController.value),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isCorrect ? _pulseAnimation.value : 1.0,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.rotate(
                  angle: (1 - value) * (widget.isCorrect ? 2 : -2),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isCorrect
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.red.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isCorrect ? Colors.green : Colors.red)
                              .withOpacity(0.5),
                          blurRadius: 25,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: widget.isCorrect
                      ? [Colors.green.shade700, Colors.green.shade900]
                      : [Colors.red.shade700, Colors.red.shade900],
                ).createShader(bounds);
              },
              child: Text(
                widget.isCorrect ? 'Correct!' : 'Wrong! 😔',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsCounter() {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: 10),
      duration: Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade300, Colors.orange.shade400],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.5),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+$value',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                ),
              ),
              SizedBox(width: 8),
              Text(
                '⭐',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isCorrect
                    ? 'Amazing! Keep the streak going! 🔥'
                    : 'Don\'t give up! Try the next one! 💪',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!widget.isCorrect && widget.correctAnswerText.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Correct Answer:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        widget.correctAnswerText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade900,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingStars() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: _FloatingStarsPainter(_particleController.value),
          );
        },
      ),
    );
  }
}

// Enhanced confetti painter with more particles
class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final colors = [
      Colors.amber,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.teal,
    ];

    for (int i = 0; i < 50; i++) {
      final x = (i * 23 + math.sin(i * 0.5) * 50) % size.width;
      final y = (progress * size.height * 1.8) - (i * 25 % 150);
      final rotation = (progress * 4 * math.pi + i * 0.5);

      if (y > -30 && y < size.height + 30) {
        paint.color = colors[i % colors.length].withOpacity(0.8);

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotation);

        // Draw different shapes
        if (i % 3 == 0) {
          // Rectangle
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: 8, height: 4),
            paint,
          );
        } else if (i % 3 == 1) {
          // Circle
          canvas.drawCircle(Offset.zero, 4, paint);
        } else {
          // Triangle
          final path = Path();
          path.moveTo(0, -4);
          path.lineTo(-3, 4);
          path.lineTo(3, 4);
          path.close();
          canvas.drawPath(path, paint);
        }

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

// Particle burst painter
class _ParticleBurstPainter extends CustomPainter {
  final double progress;

  _ParticleBurstPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final colors = [
      Colors.amber,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.teal,
    ];

    // Create burst particles radiating from center
    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * math.pi;
      final distance = progress * 150;
      final x = centerX + math.cos(angle) * distance;
      final y = centerY + math.sin(angle) * distance;

      paint.color = colors[i % colors.length].withOpacity(1 - progress);

      final size = 6 * (1 - progress);
      canvas.drawCircle(Offset(x, y), size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticleBurstPainter oldDelegate) => true;
}

// Floating stars painter
class _FloatingStarsPainter extends CustomPainter {
  final double progress;

  _FloatingStarsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.amber.withOpacity(0.8 * (1 - progress));

    // Draw floating stars around the popup
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + progress * math.pi;
      final radius = 120 + math.sin(progress * math.pi) * 20;
      final x = size.width / 2 + math.cos(angle) * radius;
      final y = size.height / 2 + math.sin(angle) * radius;

      _drawStar(canvas, Offset(x, y), 8 + math.sin(progress * math.pi * 2) * 2,
          paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FloatingStarsPainter oldDelegate) => true;
}
