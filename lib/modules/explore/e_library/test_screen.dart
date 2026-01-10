// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/timer_widget.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/explore/e_library/cbt_result_screen.dart';
import 'package:linkschool/modules/explore/e_library/backward_slash_clipper.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';

class TestScreen extends StatefulWidget {
  final String examTypeId;
  final String? subjectId;
  final String? subject;
  final int? year;
  final String calledFrom;
  final int? totalDurationInSeconds;
  final int? questionLimit;
  final Function(Map<int, int> userAnswers, int remainingTime)? onExamComplete;
  final bool isLastInMultiSubject;
  final int? currentExamIndex;
  final int? totalExams;
  final Map<String, Map<int, int>>? allAnswers;
  final Map<String, List<QuestionModel>>? allQuestions;

  const TestScreen({
    super.key,
    required this.examTypeId,
    this.subjectId,
    this.subject,
    this.year,
    this.calledFrom = 'details',
    this.totalDurationInSeconds,
    this.questionLimit,
    this.onExamComplete,
    this.isLastInMultiSubject = false,
    this.currentExamIndex,
    this.totalExams,
    this.allAnswers,
    this.allQuestions,
  });

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen>
    with SingleTickerProviderStateMixin {
  late double opacity;
  final TextEditingController _textController = TextEditingController();
  final _subscriptionService = CbtSubscriptionService();
  int? remainingSeconds;
  int _lastDisplayedQuestionIndex =
      -1; // Track which question's instruction/passage was shown
  bool _isCountdownActive = false;

  // Animation controller for bouncing arrow
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.totalDurationInSeconds;

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

    // Increment test count when test starts (only for single subject or first exam in multi-subject)
    if (widget.calledFrom != 'multi-subject' || widget.currentExamIndex == 0) {
      _subscriptionService.incrementTestCount();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show countdown dialog before fetching data (only for single subject or first exam in multi-subject)
      if (widget.calledFrom != 'multi-subject' ||
          widget.currentExamIndex == 0) {
        _showLoadingCountdown();
      } else {
        // For subsequent exams in multi-subject, fetch directly
        final provider = Provider.of<ExamProvider>(context, listen: false);
        provider.fetchExamData(
          widget.examTypeId,
          limit: widget.questionLimit,
        );
        print("Fetching exam data for examTypeId: ${widget.examTypeId}");
        print(
            "SubjectId: ${widget.subjectId}, Subject: ${widget.subject}, Year: ${widget.year}");
        print("Question Limit: ${widget.questionLimit ?? 'All'}");
        if (widget.totalDurationInSeconds != null) {
          print(
              "⏱️ Total Duration: ${widget.totalDurationInSeconds! ~/ 60} minutes");
        }
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _showLoadingCountdown() {
    setState(() {
      _isCountdownActive = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LoadingCountdownDialog(
        onComplete: () {
          if (!mounted) return;
          Navigator.of(context).pop();
          setState(() {
            _isCountdownActive = false;
          });

          // Dialog will only show when Read More is clicked
          // No auto-showing of instruction/passage dialog
        },
      ),
    );

    // Start fetching data immediately when countdown begins
    final provider = Provider.of<ExamProvider>(context, listen: false);
    provider.fetchExamData(
      widget.examTypeId,
      limit: widget.questionLimit,
    );
    print("Fetching exam data for examTypeId: ${widget.examTypeId}");
    print(
        "SubjectId: ${widget.subjectId}, Subject: ${widget.subject}, Year: ${widget.year}");
    print("Question Limit: ${widget.questionLimit ?? 'All'}");
    if (widget.totalDurationInSeconds != null) {
      print(
          "⏱️ Total Duration: ${widget.totalDurationInSeconds! ~/ 60} minutes");
    }
  }

  // Dialog only shows when Read More button is clicked - no auto-show

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        // Show instruction/passage modal when question changes (skip while countdown active)

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

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ExamProvider examProvider, bool isLandscape) {
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
                  widget.subject ??
                      examProvider.examInfo?.courseName ??
                      'CBT Test',
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
              initialSeconds:
                  remainingSeconds ?? widget.totalDurationInSeconds ?? 3600,
              onTimeUp: () =>
                  _submitQuiz(examProvider, isFullyCompleted: false),
              onTick: (remaining) {
                remainingSeconds = remaining;
              },
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
          // Instruction/Passage Preview Card
          if (question.instruction.isNotEmpty || question.passage.isNotEmpty)
            _buildInstructionPassagePreviewCard(question, isLandscape),
          const SizedBox(height: 40),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Html(
  data: question.content.isNotEmpty
      ? question.content[0].toUpperCase() +
          question.content.substring(1)
      : 'Question',
  style: {
    "body": Style(
      fontSize: FontSize(18),
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      lineHeight: LineHeight(1.6),
      fontWeight: FontWeight.w600,
      color: AppColors.text3Light,
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: _getImageWidget(src, height: 30), // Adjust height here
        );
      },
    ),
  ],
),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (question.questionImage != null &&
                          question.questionImage.isNotEmpty)
                        GestureDetector(
                          onTap: () =>
                              _showFullScreenImage(question.questionImage),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _getImageWidget(question.questionImage,
                                width: double.infinity, height: 220),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (question.instruction.isNotEmpty ||
                  question.passage.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      // If both instruction and passage exist, show them together.
                      final hasInstruction = question.instruction.isNotEmpty;
                      final hasPassage = question.passage.isNotEmpty;
                      String title = '';
                      String content = '';

                      if (hasInstruction && hasPassage) {
                        title = 'Instruction & Passage';
                        content =
                            '${question.instruction}\n\n${question.passage}';
                      } else if (hasInstruction) {
                        title = 'Instruction';
                        content = question.instruction;
                      } else if (hasPassage) {
                        title = 'Passage';
                        content = question.passage;
                      }

                      if (content.isNotEmpty)
                        _showInstructionOrPassageModal(title, content);
                    },
                    child: Row(
                      children: [
                        Text(
                          question.instruction.isNotEmpty
                              ? ' View Instruction'
                              : ' View Passage',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: AppColors.eLearningBtnColor1,
                            size: 24,
                          ),
                          onPressed: () {
                            final hasInstruction =
                                question.instruction.isNotEmpty;
                            final hasPassage = question.passage.isNotEmpty;
                            String title = '';
                            String content = '';

                            if (hasInstruction && hasPassage) {
                              title = 'Instruction & Passage';
                              content =
                                  '${question.instruction}\n\n${question.passage}';
                            } else if (hasInstruction) {
                              title = 'Instruction';
                              content = question.instruction;
                            } else if (hasPassage) {
                              title = 'Passage';
                              content = question.passage;
                            }

                            if (content.isNotEmpty)
                              _showInstructionOrPassageModal(title, content);
                          },
                          tooltip: (question.instruction.isNotEmpty &&
                                  question.passage.isNotEmpty)
                              ? 'View Instruction & Passage'
                              : (question.instruction.isNotEmpty
                                  ? 'View Instruction'
                                  : 'View Passage'),
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

  Widget _buildInstructionPassagePreviewCard(
      QuestionModel question, bool isLandscape) {
    final hasInstruction = question.instruction.isNotEmpty;
    final hasPassage = question.passage.isNotEmpty;

    String title = '';
    String content = '';

    if (hasInstruction && hasPassage) {
      title = 'Instruction & Passage';
      content = '${question.instruction}\n\n${question.passage}';
    } else if (hasInstruction) {
      title = 'Instruction';
      content = question.instruction;
    } else if (hasPassage) {
      title = 'Passage';
      content = question.passage;
    }

    if (content.isEmpty) return const SizedBox.shrink();

    // Define max characters for preview (adjust as needed)
    const int maxPreviewLength = 150;
    final bool isLongText = content.length > maxPreviewLength;
    final String previewText =
        isLongText ? '${content.substring(0, maxPreviewLength)}...' : content;

    return Container(
      width: isLandscape ? double.infinity : 400,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
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
          const SizedBox(height: 8),
          // Preview text with gradient fade overlay for long text
          Stack(
            children: [
              Html(
                data: previewText,
                style: {
                  "body": Style(
                    fontSize: FontSize(15),
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: LineHeight(1.5),
                    color: Colors.black87,
                    maxLines: 4,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                },
              ),
              // White gradient fade overlay at bottom (only if text is long)
              if (isLongText)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.7),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Read More (only if text is long)
          if (isLongText) ...[
            const SizedBox(height: 4),
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

  Widget _buildOptionsOrInputCard(
      ExamProvider provider, QuestionModel question, bool isLandscape) {
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
              borderSide: const BorderSide(
                  color: AppColors.eLearningBtnColor1, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(
      ExamProvider provider, QuestionModel question, bool isLandscape) {
    // If `question.options` is provided as structured maps, use that (supports option_files)
    final structuredOptions = question.options;
    final selectedAnswer = provider.userAnswers[provider.currentQuestionIndex];

    Widget buildItem(dynamic optionData, int index) {
      String optionText = '';
      String? optionImageUrl;

      if (optionData is Map) {
        optionText = (optionData['text'] ?? '').toString();
        // Use imageUrl directly from the processed options (already handled in model)
        optionImageUrl = optionData['imageUrl']?.toString();
      } else if (optionData is String) {
        optionText = optionData;
      }

      return _buildOptionTile(
        provider,
        optionText,
        index,
        selectedAnswer,
        optionImageUrl: optionImageUrl,
      );
    }

    if (structuredOptions != null && structuredOptions.isNotEmpty) {
      if (isLandscape) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: structuredOptions.length,
          itemBuilder: (context, index) =>
              buildItem(structuredOptions[index], index),
        );
      }

      return Column(
        children: structuredOptions
            .asMap()
            .entries
            .map((entry) => buildItem(entry.value, entry.key))
            .toList(),
      );
    }

    // Fallback to plain text options returned by getOptions()
    final options = question.getOptions();
    if (isLandscape) {
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
          return _buildOptionTile(
              provider, options[index], index, selectedAnswer);
        },
      );
    } else {
      return Column(
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return _buildOptionTile(provider, option, index, selectedAnswer);
        }).toList(),
      );
    }
  }

  Widget _buildOptionTile(
      ExamProvider provider, String option, int index, int? selectedAnswer,
      {String? optionImageUrl}) {
    final isSelected = selectedAnswer == index;

    Widget optionContent = Html(
      data: option,
      style: {
        "body": Style(
          fontSize: FontSize(16),
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          lineHeight: LineHeight(1.6),
          color: isSelected ? Colors.white : Colors.black87,
        ),
      },
    );

    // If there's an option image URL, show it alongside the text
    if (optionImageUrl != null && optionImageUrl.isNotEmpty) {
      optionContent = Row(
        children: [
          Expanded(child: optionContent),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showFullScreenImage(optionImageUrl),
            child: _getImageWidget(optionImageUrl, width: 80, height: 50),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey.shade300,
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
          onTap: () =>
              provider.selectAnswer(provider.currentQuestionIndex, index),
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
                      ? const Icon(Icons.check,
                          size: 16, color: AppColors.eLearningBtnColor1)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: optionContent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Extract first file url/string from option_files structure
  String? _extractFirstFileUrl(dynamic files) {
    // Use the model's image processing logic for consistency with assessment_screen
    try {
      if (files == null) return null;
      if (files is List && files.isNotEmpty) {
        final file = files.first;
        if (file is Map) {
          // Try to get file content first
          String? fileContent = file['file']?.toString();

          // If file is empty, use file_name instead
          if (fileContent == null || fileContent.isEmpty) {
            fileContent = file['file_name']?.toString();
          }

          if (fileContent != null && fileContent.isNotEmpty) {
            // Handle different image formats
            if (fileContent.startsWith('data:')) {
              return fileContent;
            } else if (_isBase64(fileContent)) {
              return 'data:image/jpeg;base64,$fileContent';
            } else {
              // It's a file path - return as is for network loading
              return fileContent;
            }
          }
        } else if (file is String) {
          return file;
        }
      }
      return null;
    } catch (e) {
      print('Error extracting file URL: $e');
      return null;
    }
  }

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
              child: _getImageWidget(imageUrl,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height),
            ),
          ),
        ),
      ),
    );
  }

  void _showInstructionOrPassageModal(String title, String content) {
    if (!mounted || content.isEmpty) return;

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
                            final provider = Provider.of<ExamProvider>(context,
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

                                // Section content (HTML)
                                Html(
                                  data: sectionContent,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(19),
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                      lineHeight: LineHeight(1.6),
                                      color: AppColors.text3Light,
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

  Widget _buildNavigationButtons(ExamProvider provider) {
    bool isLastQuestion =
        provider.currentQuestionIndex == provider.questions.length - 1;
    bool isLastSubject = widget.isLastInMultiSubject;
    bool hasQuestions = provider.questions.isNotEmpty;

    // If no questions, show skip button
    if (!hasQuestions) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (widget.onExamComplete != null) {
                  widget.onExamComplete!({}, remainingSeconds ?? 0);
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'Skip Test',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

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
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _submitQuiz(
              provider,
              isFullyCompleted: isLastQuestion && isLastSubject,
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
                ? () {
                    provider.nextQuestion();
                  }
                : (widget.onExamComplete != null && !isLastSubject)
                    ? () {
                        // Auto-proceed to next exam without dialog
                        _proceedToNextExam(provider);
                      }
                    : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: (!isLastQuestion ||
                          (widget.onExamComplete != null && !isLastSubject))
                      ? Colors.white
                      : const Color.fromARGB(255, 169, 168, 168)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              (isLastQuestion &&
                      widget.onExamComplete != null &&
                      !isLastSubject)
                  ? 'Next Subject'
                  : 'Next',
              style: TextStyle(
                  color: (!isLastQuestion ||
                          (widget.onExamComplete != null && !isLastSubject))
                      ? Colors.white
                      : const Color.fromARGB(255, 169, 168, 168)),
            ),
          ),
        ),
      ],
    );
  }

  void _proceedToNextExam(ExamProvider provider) {
    if (widget.onExamComplete != null) {
      widget.onExamComplete!(
        provider.userAnswers,
        remainingSeconds ?? 0,
      );
    }

    _showNextSubjectCountdown(provider);
  }

  void _showNextSubjectCountdown(ExamProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CountdownDialog(
        currentIndex: widget.currentExamIndex ?? 0,
        totalExams: widget.totalExams ?? 1,
        onComplete: () {
          Navigator.of(context).pop();
          // if (widget.onExamComplete != null) {
          //   widget.onExamComplete!(
          //     provider.userAnswers,
          //     remainingSeconds ?? 0,
          //   //   );
          //   }
        },
      ),
    );
  }

  void _submitQuiz(ExamProvider provider, {required bool isFullyCompleted}) {
    // Calculate stats for current subject
    final answeredCount = provider.userAnswers.length;
    final unansweredCount = provider.questions.length - answeredCount;

    // Calculate total stats if this is multi-subject test
    int totalAnswered = answeredCount;
    int totalQuestions = provider.questions.length;

    if (widget.isLastInMultiSubject &&
        widget.allAnswers != null &&
        widget.allQuestions != null) {
      totalAnswered = 0;
      totalQuestions = 0;
      // Count from all previous subjects
      for (var entry in widget.allAnswers!.entries) {
        final examAnswers = entry.value;
        final examQuestions = widget.allQuestions![entry.key] ?? [];
        totalAnswered += examAnswers.length;
        totalQuestions += examQuestions.length;
      }
      // Add current subject
      totalAnswered += answeredCount;
      totalQuestions += provider.questions.length;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Calculate responsive width like instruction dialog
        final dialogWidth = isLandscape
            ? screenWidth * 0.7 // 70% of screen width in landscape
            : screenWidth * 0.85; // 85% of screen width in portrait

        // Calculate max height (80% of screen)
        final maxHeight = screenHeight * 0.8;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 40 : 16,
            vertical: 24,
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxWidth: 500, // Maximum width for very wide screens
              maxHeight: maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(isLandscape ? 20 : 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // cancel button at top right
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Icon(
                                Icons.close,
                                size: isLandscape ? 24 : 28,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),

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

                          // Title - Updated to show current subject info
                          Text(
                            widget.isLastInMultiSubject
                                ? 'Submit All Tests?'
                                : widget.onExamComplete != null
                                    ? 'Submit Current Subject?'
                                    : 'Submit Exam?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isLandscape ? 18 : 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          SizedBox(height: isLandscape ? 4 : 8),

                          // Description - Updated to show subject progress
                          Text(
                            widget.isLastInMultiSubject
                                ? 'You are about to submit all ${widget.totalExams ?? 1} subject${(widget.totalExams ?? 1) > 1 ? 's' : ''}'
                                : widget.onExamComplete != null
                                    ? 'Subject ${(widget.currentExamIndex ?? 0) + 1} of ${widget.totalExams ?? 1}. Review before continuing.'
                                    : 'Please review your answers before submitting',
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Answered
                              Column(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.all(isLandscape ? 6 : 8),
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
                                    '$totalAnswered',
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

                              // Unanswered
                              Column(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.all(isLandscape ? 6 : 8),
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
                                    '${totalQuestions - totalAnswered}',
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
                          if (totalQuestions - totalAnswered > 0) ...[
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
                                      'You have ${totalQuestions - totalAnswered} unanswered question${(totalQuestions - totalAnswered) > 1 ? 's' : ''}. Are you sure you want to submit?',
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
                        ],
                      ),
                    ),
                  ),
                ),

                // Fixed "Got it" button at bottom
                Container(
                  padding: EdgeInsets.all(isLandscape ? 16 : 24),
                  decoration: BoxDecoration(
                      // border: Border(
                      //   top: BorderSide(color: Colors.grey.shade200),
                      // ),
                      ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: isLandscape ? 12 : 14),
                            side:
                                BorderSide(color: AppColors.eLearningBtnColor1),
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
                      SizedBox(width: isLandscape ? 12 : 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                            // After dialog closes, handle the navigation based on context
                            if (widget.onExamComplete != null &&
                                !widget.isLastInMultiSubject) {
                              // Multi-subject mode (not last): proceed to next subject
                              _proceedToNextExam(provider);
                            } else if (widget.onExamComplete != null &&
                                widget.isLastInMultiSubject) {
                              // Multi-subject mode (last subject): call callback for final submission
                              widget.onExamComplete!(
                                provider.userAnswers,
                                remainingSeconds ?? 0,
                              );
                            } else {
                              // Single subject mode: navigate to result screen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CbtResultScreen(
                                    questions: provider.questions,
                                    userAnswers: provider.userAnswers,
                                    subject: widget.subject ??
                                        provider.examInfo?.courseName ??
                                        'CBT Test',
                                    year: widget.year ?? DateTime.now().year,
                                    examType:
                                        provider.examInfo?.title ?? 'Test',
                                    examId: widget.examTypeId,
                                    calledFrom: widget.calledFrom,
                                    isFullyCompleted: isFullyCompleted,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.eLearningBtnColor1,
                            padding: EdgeInsets.symmetric(
                                vertical: isLandscape ? 12 : 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            widget.onExamComplete != null &&
                                    !widget.isLastInMultiSubject
                                ? 'Continue to Next'
                                : 'Submit Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isLandscape ? 12 : 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              'Starting Test',
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