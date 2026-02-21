import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/explore/explanation_model.dart';
import 'package:linkschool/modules/providers/explore/studies_question_provider.dart';
import 'package:linkschool/modules/model/explore/study/studies_questions_model.dart';
import 'package:linkschool/modules/explore/cbt/study_progress_dashboard.dart';
import 'package:linkschool/modules/explore/cbt/ai_chat_screen.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:linkschool/modules/common/ads/ad_manager.dart';

class CBTStudyScreen extends StatefulWidget {
  final String subject;
  final List<String> topics;
  final List<int> topicIds;
  final int courseId;
  final int examTypeId;

  const CBTStudyScreen({
    super.key,
    required this.subject,
    required this.topics,
    required this.topicIds,
    required this.courseId,
    required this.examTypeId,
  });

  @override
  State<CBTStudyScreen> createState() => _CBTStudyScreenState();
}

class _CBTStudyScreenState extends State<CBTStudyScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Cache for AI-generated explanations (keyed by question ID)
  final Map<int, String> _explanationCache = {};
  bool _isStudyComplete = false;
  bool _isInitialCountdownComplete = false;

  bool _isNavigatingAway = false;
  bool _shouldShowAdOnResume = false;

  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoaded = false;

  // Animation controller for bouncing arrow in Read More
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AdManager.instance.preload();

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

    // Show countdown immediately and load questions during countdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitialLoadingCountdown();
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _loadAppOpenAd();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      if (!_isNavigatingAway) {
        _shouldShowAdOnResume = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldShowAdOnResume) {
        _showAppOpenAd();
        _shouldShowAdOnResume = false;
      }
    }
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: EnvConfig.cbtAdsOpenApiKey,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          if (mounted) {
            setState(() {
              _isAppOpenAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (mounted) {
            setState(() {
              _isAppOpenAdLoaded = false;
            });
          }
        },
      ),
    );
  }

  void _showAppOpenAd() {
    if (_isAppOpenAdLoaded && _appOpenAd != null) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (AppOpenAd ad) {
          ad.dispose();
          _appOpenAd = null;
          _isAppOpenAdLoaded = false;
          _loadAppOpenAd();
        },
        onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
          ad.dispose();
          _appOpenAd = null;
          _isAppOpenAdLoaded = false;
          _loadAppOpenAd();
        },
      );

      _appOpenAd!.show();
    }
  }

  void _showInitialLoadingCountdown() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _InitialLoadingCountdownDialog(
        onComplete: () {
          if (!mounted) return;
          Navigator.of(context).pop();
          AdManager.instance
              .showIfEligible(
            context: context,
            trigger: AdTrigger.topicStart,
          )
              .then((_) {
            if (mounted) {
              setState(() {
                _isInitialCountdownComplete = true;
              });
            }
          });
        },
      ),
    );

    // Start fetching questions immediately when countdown begins
    _initializeStudySession();
  }

  Future<void> _initializeStudySession() async {
    final provider = Provider.of<QuestionsProvider>(context, listen: false);
    await provider.initializeStudySession(
      topicIds: widget.topicIds,
      courseId: widget.courseId,
      examTypeId: widget.examTypeId,
      topicNames: widget.topics,
    );
    print('📚 Loaded ${provider.allQuestions.length} questions');
  }

  void _onAnswer(int index, Question question) async {
    final isCorrect = index == question.correct.order;
    final selectedAnswer = question.options[index].text;
    final correctAnswer = question.correct.text;

    // Record the answer in the provider for statistics
    final provider = Provider.of<QuestionsProvider>(context, listen: false);
    provider.recordAnswer(
      questionId: question.questionId,
      isCorrect: isCorrect,
    );

    // Check if we already have explanation for this question (keyed by question ID)
    String? cachedExplanation = _explanationCache[question.questionId];

    // Use API explanation if available, otherwise will fall back to AI
    final apiExplanation =
        question.explanation.isNotEmpty ? question.explanation : null;

    if (!isCorrect) {
      await AdManager.instance.showIfEligible(
        context: context,
        trigger: AdTrigger.questionFailure,
      );
    }

    // Show modal with loading state or cached/API explanation
    await _showExplanationModal(
      isCorrect: isCorrect,
      selectedAnswer: selectedAnswer,
      correctAnswer: correctAnswer,
      questionText: question.questionText,
      cachedExplanation: cachedExplanation,
      apiExplanation: apiExplanation,
      questionId: question.questionId,
    );
  }

  Future<void> _showExplanationModal({
    required bool isCorrect,
    required String selectedAnswer,
    required String correctAnswer,
    required String questionText,
    String? cachedExplanation,
    String? apiExplanation,
    required int questionId,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: true,
      builder: (context) => ExplanationModal(
        isCorrect: isCorrect,
        selectedAnswer: selectedAnswer,
        correctAnswer: correctAnswer,
        question: questionText,
        cachedExplanation: cachedExplanation,
        apiExplanation: apiExplanation,
        onExplanationGenerated: (explanation) {
          // Cache the explanation by question ID
          _explanationCache[questionId] = explanation;
        },
        onContinue: () {
          Navigator.pop(context);
          _moveToNextQuestion();
        },
      ),
    );
  }

  Future<void> _moveToNextQuestion() async {
    final provider = Provider.of<QuestionsProvider>(context, listen: false);

    // Check if we're at the last question of current batch and there are more topics
    final isAtEndOfCurrentBatch =
        provider.currentQuestionIndex >= provider.allQuestions.length - 1;
    final hasMoreTopicsToLoad = provider.hasMoreTopics;

    if (isAtEndOfCurrentBatch && hasMoreTopicsToLoad) {
      // Show ad for topic completion, then countdown for next topic
      await AdManager.instance.showIfEligible(
        context: context,
        trigger: AdTrigger.topicCompletion,
      );
      _showNextTopicCountdown();
      return;
    }

    // Try to move to next question (this will auto-fetch more if needed)
    final hasMore = await provider.nextQuestion();

    if (!hasMore && provider.isLastQuestion && !provider.hasMoreTopics) {
      // Study session complete
      await AdManager.instance.showIfEligible(
        context: context,
        trigger: AdTrigger.topicCompletion,
      );
      setState(() {
        _isStudyComplete = true;
      });
      _showStudyCompleteDialog();
    }
  }

  void _showNextTopicCountdown() {
    final provider = Provider.of<QuestionsProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _NextTopicCountdownDialog(
        currentTopicIndex: provider.currentTopicIndex,
        totalTopics: provider.totalTopics,
        onComplete: () async {
          if (!mounted) return;
          Navigator.of(context).pop();

          await AdManager.instance.showIfEligible(
            context: context,
            trigger: AdTrigger.topicStart,
          );

          // Now fetch the next topic's questions
          final hasMore = await provider.nextQuestion();

          if (!hasMore && provider.isLastQuestion && !provider.hasMoreTopics) {
            setState(() {
              _isStudyComplete = true;
            });
            _showStudyCompleteDialog();
          }
        },
      ),
    );
  }

  void _showStudyCompleteDialog() {
    final provider = Provider.of<QuestionsProvider>(context, listen: false);

    // Generate session statistics
    final sessionStats = provider.generateSessionStats(widget.subject);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            Text(
              'Study Complete!',
              style: AppTextStyles.normal700(
                fontSize: 20,
                color: AppColors.text4Light,
              ),
            ),
          ],
        ),
        content: Text(
          'Great job! You have completed all questions for the selected topics.',
          style: AppTextStyles.normal400(
            fontSize: 16,
            color: AppColors.text7Light,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              await AdManager.instance.showIfEligible(
                context: context,
                trigger: AdTrigger.resultNavigation,
              );

              _isNavigatingAway = true;
              // Navigate to progress dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StudyProgressDashboard(
                    sessionStats: sessionStats,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eLearningBtnColor1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'View Progress',
              style: AppTextStyles.normal600(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
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

  /// Build instruction/passage preview card like test_screen
  Widget _buildInstructionPassagePreviewCard(Question question) {
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

    // Define max characters for preview
    const int maxPreviewLength = 150;
    final bool isLongText = content.length > maxPreviewLength;
    final String previewText =
        isLongText ? '${content.substring(0, maxPreviewLength)}...' : content;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  style: AppTextStyles.normal700(
                    fontSize: 14,
                    color: AppColors.eLearningBtnColor1,
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
                    fontSize: FontSize(14),
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: LineHeight(1.5),
                    color: AppColors.text4Light,
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
                        style: AppTextStyles.normal600(
                          fontSize: 13,
                          color: AppColors.eLearningBtnColor1,
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

  /// Show instruction or passage modal dialog
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
                            final provider = Provider.of<QuestionsProvider>(
                                context,
                                listen: false);
                            final qIndex = provider.currentQuestionIndex;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                'Question ${qIndex + 1}',
                                style: AppTextStyles.normal700(
                                  fontSize: 14,
                                  color: AppColors.text4Light,
                                ),
                              ),
                            );
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
                                  style: AppTextStyles.normal700(
                                    fontSize: 16,
                                    color: AppColors.eLearningBtnColor1,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Section content (HTML)
                                Html(
                                  data: sectionContent,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(16),
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
                          }),
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
                      child: Text(
                        'Got it',
                        style: AppTextStyles.normal600(
                          fontSize: 16,
                          color: Colors.white,
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

  /// Helper function to get image widget from URL or base64
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

  /// Helper function to check if string is base64 encoded
  bool _isBase64(String s) {
    return s.startsWith('data:image') ||
        (s.length > 100 && s.contains('base64'));
  }

  /// Show full screen image viewer
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

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionsProvider>(
      builder: (context, provider, child) {
        // Loading state
        if (provider.loading) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Container(
              color: AppColors.backgroundLight,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.eLearningBtnColor1,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading questions...',
                      style: AppTextStyles.normal500(
                        fontSize: 16,
                        color: AppColors.text7Light,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Error state
        if (provider.error != null) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Container(
              color: AppColors.backgroundLight,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load questions',
                        style: AppTextStyles.normal600(
                          fontSize: 18,
                          color: AppColors.text4Light,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.error ?? '',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.normal400(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _initializeStudySession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.eLearningBtnColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: AppTextStyles.normal600(
                            fontSize: 16,
                            color: Colors.white,
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

        // No questions available
        final question = provider.currentQuestion;
        if (question == null) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Container(
              color: AppColors.backgroundLight,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_outlined,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No questions available',
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: AppColors.text4Light,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try selecting different topics',
                      style: AppTextStyles.normal400(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Main question screen
        return Scaffold(
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              Container(
                color: AppColors.backgroundLight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (provider.currentQuestionIndex + 1) /
                                  (provider.totalQuestions > 0
                                      ? provider.totalQuestions
                                      : 1),
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.eLearningBtnColor1,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${provider.currentQuestionIndex + 1}/${provider.totalQuestions}',
                            style: AppTextStyles.normal600(
                              fontSize: 14,
                              color: AppColors.text7Light,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Topic indicator
                      if (question.topic.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                AppColors.eLearningBtnColor1.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            question.topic,
                            style: AppTextStyles.normal500(
                              fontSize: 12,
                              color: AppColors.eLearningBtnColor1,
                            ),
                          ),
                        ),
                      if (question.topic.isNotEmpty) const SizedBox(height: 16),

                      // Instruction/Passage Preview Card
                      if (question.instruction.isNotEmpty ||
                          question.passage.isNotEmpty)
                        _buildInstructionPassagePreviewCard(question),

                      // Question
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.eLearningBtnColor1,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${provider.currentQuestionIndex + 1}',
                                  style: AppTextStyles.normal600(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Html(
                                data: question.questionText,
                                style: {
                                  "body": Style(
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                    fontSize: FontSize(16),
                                    color: AppColors.text4Light,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  "img": Style(
                                    width: Width.auto(),
                                    padding:
                                        HtmlPaddings.only(left: 4, right: 4),
                                  ),
                                },
                                extensions: [
                                  TagExtension(
                                    tagsToExtend: {"img"},
                                    builder: (extensionContext) {
                                      final attributes =
                                          extensionContext.attributes;
                                      final src = attributes['src'] ?? '';

                                      if (src.isEmpty) {
                                        return const SizedBox.shrink();
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        child: _getImageWidget(src, height: 30),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Options
                      Expanded(
                        child: ListView.builder(
                          itemCount: question.options.length,
                          itemBuilder: (context, i) {
                            final option = question.options[i];
                            return GestureDetector(
                              onTap: () => _onAnswer(i, question),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.eLearningBtnColor1
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(65 +
                                              i), // A, B, C, D... (use index instead of order)
                                          style: AppTextStyles.normal600(
                                            fontSize: 14,
                                            color: AppColors.eLearningBtnColor1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Html(
                                        data: option.text,
                                        style: {
                                          "body": Style(
                                            margin: Margins.zero,
                                            padding: HtmlPaddings.zero,
                                            fontSize: FontSize(15),
                                            color: AppColors.text4Light,
                                          ),
                                          "img": Style(
                                            width: Width.auto(),
                                            padding: HtmlPaddings.only(
                                                left: 4, right: 4),
                                          ),
                                        },
                                        extensions: [
                                          TagExtension(
                                            tagsToExtend: {"img"},
                                            builder: (extensionContext) {
                                              final attributes =
                                                  extensionContext.attributes;
                                              final src =
                                                  attributes['src'] ?? '';

                                              if (src.isEmpty) {
                                                return const SizedBox.shrink();
                                              }

                                              return GestureDetector(
                                                onTap: () =>
                                                    _showFullScreenImage(src),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4,
                                                      vertical: 2),
                                                  child: _getImageWidget(src,
                                                      height: 30),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Loading more indicator
              if (provider.loadingMore)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white.withOpacity(0.9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.eLearningBtnColor1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading more questions...',
                          style: AppTextStyles.normal500(
                            fontSize: 14,
                            color: AppColors.text7Light,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          // Reset provider when leaving
          Provider.of<QuestionsProvider>(context, listen: false).reset();
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.subject} Study',
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: AppColors.text4Light,
            ),
          ),
          Text(
            widget.topics.join(', '),
            style: AppTextStyles.normal400(
              fontSize: 12,
              color: AppColors.text7Light,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// EXPLANATION MODAL WITH AI GENERATION (with API fallback)
class ExplanationModal extends StatefulWidget {
  final bool isCorrect;
  final String selectedAnswer;
  final String correctAnswer;
  final String question;
  final String? cachedExplanation;
  final String? apiExplanation; // Explanation from API endpoint
  final Function(String) onExplanationGenerated;
  final VoidCallback onContinue;

  const ExplanationModal({
    super.key,
    required this.isCorrect,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.question,
    this.cachedExplanation,
    this.apiExplanation,
    required this.onExplanationGenerated,
    required this.onContinue,
  });

  @override
  State<ExplanationModal> createState() => _ExplanationModalState();
}

class _ExplanationModalState extends State<ExplanationModal> {
  String? _explanation;
  bool _isLoading = false;
  String? _error;
  bool _isApiExplanation = false;

  /// Helper function to get image widget from URL or base64
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

  /// Helper function to check if string is base64 encoded
  bool _isBase64(String s) {
    return s.startsWith('data:image') ||
        (s.length > 100 && s.contains('base64'));
  }

  @override
  void initState() {
    super.initState();
    _initializeExplanation();
  }

  void _initializeExplanation() {
    // Priority: 1. Cached explanation, 2. API explanation, 3. AI generated
    if (widget.cachedExplanation != null &&
        widget.cachedExplanation!.isNotEmpty) {
      _explanation = widget.cachedExplanation;
      print('📖 Using cached explanation');
    } else if (widget.apiExplanation != null &&
        widget.apiExplanation!.isNotEmpty) {
      _explanation = widget.apiExplanation;
      _isApiExplanation = true;
      print('📖 Using API explanation');
      // Cache the API explanation for future use
      widget.onExplanationGenerated(widget.apiExplanation!);
    } else {
      // Fall back to AI-generated explanation
      print('🤖 No API explanation, fetching from AI...');
      _fetchExplanation();
    }
  }

  Future<void> _fetchExplanation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final explanation = await DeepSeekService.getExplanation(
        question: widget.question,
        selectedAnswer: widget.selectedAnswer,
        correctAnswer: widget.correctAnswer,
        isCorrect: widget.isCorrect,
      );

      if (mounted) {
        setState(() {
          _explanation = explanation;
          _isLoading = false;
        });
        widget.onExplanationGenerated(explanation);
        print('✅ AI explanation generated successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to generate explanation. Please try again.";
          _isLoading = false;
        });
        print('❌ AI explanation error: $e');
      }
    }
  }

  /// Convert HTML/span text to TextSpan list for explanations
  List<TextSpan> _parseExplanationHtml(String text) {
    if (!text.contains('<span') &&
        !text.contains('<b') &&
        !text.contains('<i') &&
        !text.contains('<strong')) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    final regExp = RegExp(
        r'<span[^>]*>([^<]*)</span>|<b>([^<]*)</b>|<strong>([^<]*)</strong>|<i>([^<]*)</i>|([^<]+)');
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      if (match.group(1) != null) {
        // <span> content - bold and colored
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue.shade700),
        ));
      } else if (match.group(2) != null || match.group(3) != null) {
        // <b> or <strong> content
        spans.add(TextSpan(
          text: match.group(2) ?? match.group(3),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(4) != null) {
        // <i> content
        spans.add(TextSpan(
          text: match.group(4),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(5) != null) {
        // Plain text
        spans.add(TextSpan(text: match.group(5)));
      }
    }

    return spans.isEmpty ? [TextSpan(text: text)] : spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Container(
                    child: Row(
                      children: [
                        Icon(
                          widget.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: widget.isCorrect ? Colors.green : Colors.red,
                          size: 48,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isCorrect ? 'Excellent!' : 'Incorrect',
                                style: AppTextStyles.normal700(
                                  fontSize: 24,
                                  color: widget.isCorrect
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              Text(
                                widget.isCorrect
                                    ? 'You got it right!'
                                    : 'Let\'s learn from this',
                                style: AppTextStyles.normal500(
                                  fontSize: 14,
                                  color: AppColors.text7Light,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),

                  const Divider(height: 1),

                  const SizedBox(height: 20),

                  // Question card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.eLearningBtnColor1.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.eLearningBtnColor1.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            Text(
                              'Question',
                              style: AppTextStyles.normal600(
                                fontSize: 14,
                                color: AppColors.eLearningBtnColor1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Html(
                          data: widget.question,
                          style: {
                            "body": Style(
                              fontSize: FontSize(15),
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              lineHeight: LineHeight(1.5),
                              color: AppColors.text4Light,
                            ),
                          },
                        ),
                      ],
                    ),
                  ),

                  // Content
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Answers section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  widget.isCorrect
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 20,
                                  color: widget.isCorrect
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Answer:',
                                  style: AppTextStyles.normal600(
                                    fontSize: 14,
                                    color: AppColors.text7Light,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Html(
                              data: widget.selectedAnswer,
                              style: {
                                "body": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  fontSize: FontSize(15),
                                  color: AppColors.text4Light,
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
                                    final attributes =
                                        extensionContext.attributes;
                                    final src = attributes['src'] ?? '';

                                    if (src.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      child: _getImageWidget(src, height: 30),
                                    );
                                  },
                                ),
                              ],
                            ),
                            if (!widget.isCorrect) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Correct Answer:',
                                    style: AppTextStyles.normal600(
                                      fontSize: 14,
                                      color: AppColors.text7Light,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Html(
                                data: widget.correctAnswer,
                                style: {
                                  "body": Style(
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                    fontSize: FontSize(15),
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  "img": Style(
                                    width: Width.auto(),
                                    padding:
                                        HtmlPaddings.only(left: 4, right: 4),
                                  ),
                                  
                                },


                                extensions: [
                                  TagExtension(
                                    tagsToExtend: {"img"},
                                    builder: (extensionContext) {
                                      final attributes =
                                          extensionContext.attributes;
                                      final src = attributes['src'] ?? '';

                                      if (src.isEmpty) {
                                        return const SizedBox.shrink();
                                      }

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
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Explanation section
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: Colors.orange, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Explanation',
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.text4Light,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Loading, error, or explanation
                      if (_isLoading)
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Generating explanation...',
                                style: AppTextStyles.normal400(
                                  fontSize: 14,
                                  color: AppColors.text7Light,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: AppTextStyles.normal400(
                                    fontSize: 14,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_explanation != null)
                        () {
                          final htmlData =
                              md.markdownToHtml(_explanation ?? "");

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Html(
                              data: htmlData,
                              style: {
                                "body": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  fontSize: FontSize(15),
                                  color: AppColors.text4Light,
                                ),
                              },
                            ),
                          );
                        }()
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Continue and Ask More buttons
          Container(
            padding: const EdgeInsets.all(23),
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
                // Ask More button
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to chat screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AIChatScreen(
                            question: widget.question,
                            initialExplanation: _explanation ?? '',
                            correctAnswer: widget.correctAnswer,
                            selectedAnswer: widget.selectedAnswer,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      side: BorderSide(
                        color: AppColors.eLearningBtnColor1,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Ask More',
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.eLearningBtnColor1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Continue button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: widget.onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eLearningBtnColor1,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: Colors.white,
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
  }
}

class _NextTopicCountdownDialog extends StatefulWidget {
  final int currentTopicIndex;
  final int totalTopics;
  final VoidCallback onComplete;

  const _NextTopicCountdownDialog({
    required this.currentTopicIndex,
    required this.totalTopics,
    required this.onComplete,
  });

  @override
  State<_NextTopicCountdownDialog> createState() =>
      _NextTopicCountdownDialogState();
}

class _NextTopicCountdownDialogState extends State<_NextTopicCountdownDialog>
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
                Icons.menu_book_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Next Topic',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 12),

            // Progress indicator
            Text(
              'Topic ${widget.currentTopicIndex + 1} of ${widget.totalTopics}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 8),

            // Message
            const Text(
              'Loading more questions...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
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

            // Get ready text
            Text(
              'Keep learning! 📚',
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

class _InitialLoadingCountdownDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _InitialLoadingCountdownDialog({
    required this.onComplete,
  });

  @override
  State<_InitialLoadingCountdownDialog> createState() =>
      _InitialLoadingCountdownDialogState();
}

class _InitialLoadingCountdownDialogState
    extends State<_InitialLoadingCountdownDialog>
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
                Icons.school_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Starting Study',
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

            // Get ready text
            Text(
              'Get ready to learn! 📖',
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
