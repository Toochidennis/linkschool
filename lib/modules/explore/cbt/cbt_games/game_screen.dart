// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'dart:convert';

import 'package:linkschool/modules/explore/cbt/back_navigation_interstitial_helper.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_Leaderboard.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/game_session_controller.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/gamify_ad_manager.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/model/explore/study/studies_questions_model.dart';
import 'package:linkschool/modules/services/explore/gamify_leaderboard_service.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class GameTestScreen extends StatefulWidget {
  final String subject;
  final int courseId;
  final int examTypeId;
  final int questionLimit;

  const GameTestScreen({
    super.key,
    required this.subject,
    required this.courseId,
    required this.examTypeId,
    required this.questionLimit,
  });

  @override
  State<GameTestScreen> createState() => _GameTestScreenState();
}

class _GameTestScreenState extends State<GameTestScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const int _startingLives = 5;
  static const int _questionsPerLevel = 15;

  final GamifyLeaderboardService _leaderboardService =
      GamifyLeaderboardService();
  final GlobalKey _gameStackKey = GlobalKey();
  final GlobalKey _livesKey = GlobalKey();
  final GlobalKey _scoreKey = GlobalKey();
  final Map<int, GlobalKey> _optionKeys = <int, GlobalKey>{};
  late final GameSessionController _sessionController;
  final Map<int, int> _userAnswers = {};
  int _score = 0;
  int _displayedScore = 0;
  int _streak = 0;
  int _highestStreak = 0;
  int _correctAnswers = 0;
  int _currentLevel = 1;
  int _lives = _startingLives;
  int _completedLevels = 0;
  bool _hasSavedScore = false;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  // Lifeline states
  bool _fiftyFiftyUsed = false;
  bool _askComputerUsed = false;
  bool _isExitingToDashboard = false;
  bool _allowRoutePop = false;
  final Map<int, Set<int>> _hiddenOptionsPerQuestion =
      {}; // For 50:50 lifeline - stores hidden options per question index
  int? _computerSuggestion; // For Ask Computer lifeline

  late AudioPlayer _correctSoundPlayer;
  late AudioPlayer _wrongSoundPlayer;
  late AudioPlayer _buttonSoundPlayer;

  final int _correctVibrationDuration = 200;
  final int _wrongVibrationDuration = 500;
  final List<int> _streakVibrationPattern = [100, 200, 100];

  // Points per question for gamification
  final int _pointsPerQuestion = 10;

  // Ad and lives system
  bool _canShowGamifyAds = false;

  void _initializeAudio() async {
    _correctSoundPlayer = AudioPlayer();
    _wrongSoundPlayer = AudioPlayer();
    _buttonSoundPlayer = AudioPlayer();

    // Preload sounds (optional - for better performance)
    try {
      await _correctSoundPlayer.setSource(AssetSource('sounds/correct.wav'));
      // await _wrongSoundPlayer.setSource(AssetSource('sounds/wrong.wav'));
      await _wrongSoundPlayer.setSource(AssetSource('sounds/wrong.wav'));
      await _buttonSoundPlayer.setSource(AssetSource('sounds/completed.mp3'));
    } catch (e) {
      // Intentionally ignored.
    }
  }

  bool _isAnswered = false;
  bool _showAnswerPopup = false;
  bool _isFeedbackAnimating = false;
  bool _isCountdownComplete = false;
  bool _shouldShowAppOpenOnResume = false;
  bool _showFlyingPoints = false;
  bool _showFlyingHeart = false;
  int _flyingPointsSeed = 0;
  int _flyingHeartSeed = 0;
  Offset? _flyingPointsStart;
  Offset? _flyingPointsEnd;
  Offset? _flyingHeartStart;
  Offset? _flyingHeartEnd;
  int _visibleOptionCount = 0;
  String? _activeQuestionPresentationKey;
  Timer? _optionsRevealTimer;
  Timer? _instructionPromptTimer;
  final Set<String> _autoShownInstructionKeys = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionController = GameSessionController(
      courseId: widget.courseId,
      examTypeId: widget.examTypeId,
      questionLimit: _questionsPerLevel,
    );
    _initializeAudio();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _prepareGameEntry();
    });
  }

  Future<void> _prepareGameEntry() async {
    if (!mounted) return;
    final canShowAds = await GamifyAdManager.instance.canShowRewarded(context);
    if (!mounted) return;
    setState(() {
      _canShowGamifyAds = canShowAds;
      _score = 0;
      _displayedScore = 0;
      _streak = 0;
      _highestStreak = 0;
      _correctAnswers = 0;
      _currentLevel = 1;
      _lives = _startingLives;
      _completedLevels = 0;
      _hasSavedScore = false;
      _fiftyFiftyUsed = false;
      _askComputerUsed = false;
    });
    await GamifyAdManager.instance.preloadAll(context);
    if (!mounted) return;
    _showLoadingCountdown();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) &&
        !GamifyAdManager.instance.isPresentingFullscreenAd) {
      _shouldShowAppOpenOnResume = true;
    } else if (state == AppLifecycleState.resumed &&
        _shouldShowAppOpenOnResume) {
      _shouldShowAppOpenOnResume = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await GamifyAdManager.instance.showAppOpenIfEligible(context: context);
      });
    }
  }

  void _showLoadingCountdown() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LoadingCountdownDialog(
        level: _currentLevel,
        onComplete: () {
          if (!mounted) return;
          Navigator.of(context).pop();
          setState(() {
            _isCountdownComplete = true;
          });
        },
      ),
    );

    // Start fetching questions immediately when countdown begins
    _initializeGameSession();
  }

  Future<void> _initializeGameSession() async {
    await _sessionController.initialize();
    if (!mounted) return;
    _resetQuestionUi();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _optionsRevealTimer?.cancel();
    _instructionPromptTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    _sessionController.dispose();
    _correctSoundPlayer.dispose();
    _wrongSoundPlayer.dispose();
    _buttonSoundPlayer.dispose();
    super.dispose();
  }

  void _resetQuestionUi() {
    _optionsRevealTimer?.cancel();
    _instructionPromptTimer?.cancel();
    _userAnswers.clear();
    _hiddenOptionsPerQuestion.clear();
    _computerSuggestion = null;
    _isAnswered = false;
    _showAnswerPopup = false;
    _visibleOptionCount = 0;
    _activeQuestionPresentationKey = null;
  }

  Future<void> _reloadCurrentLevel({
    required int startIndex,
  }) async {
    await _sessionController.reload(startIndex: startIndex);
    if (!mounted) return;
    setState(_resetQuestionUi);
    _progressController.forward(from: 0);
  }

  Future<void> _loadNextLevel() async {
    final nextLevel = _currentLevel + 1;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _NextTopicCountdownDialog(
        level: nextLevel,
        onComplete: () async {
          if (!mounted) return;
          Navigator.of(context).pop();
          await _reloadCurrentLevel(startIndex: 0);
          if (!mounted) return;
          setState(() {
            _currentLevel = nextLevel;
            _completedLevels = nextLevel - 1;
          });
        },
      ),
    );
  }

  int _currentProgressWithinLevel() {
    final base = _sessionController.currentQuestionIndex;
    return base + (_isAnswered ? 1 : 0);
  }

  int _totalAnsweredProgress() {
    return (_completedLevels * _questionsPerLevel) +
        _currentProgressWithinLevel();
  }

  String _playerName() {
    final user =
        Provider.of<CbtUserProvider>(context, listen: false).currentUser;
    return user?.displayName ?? 'Player';
  }

  Future<void> _saveScoreIfNeeded() async {
    if (_hasSavedScore) return;
    _hasSavedScore = true;

    await _leaderboardService.submitScoreIfHigher(
      username: _playerName(),
      examTypeId: widget.examTypeId,
      courseId: widget.courseId,
      courseName: widget.subject,
      score: _score,
    );
  }

  Future<void> _selectAnswer(int optionIndex, Question question) async {
    if (_isAnswered || _isFeedbackAnimating) return;

    _playButtonSound();
    _vibrateButton();

    final questionIndex = _sessionController.currentQuestionIndex;
    final isCorrect = optionIndex == question.correct.order;

    setState(() {
      _userAnswers[questionIndex] = optionIndex;
      _isAnswered = true;
      _isFeedbackAnimating = true;
      // Clear computer suggestion icon when user selects an option
      _computerSuggestion = null;

      // Check if answer is correct (compare with correct option order)
      if (isCorrect) {
        _streak++;
        _correctAnswers++; // Increment correct answers

        // Play correct sound and vibration
        _playCorrectSound();
        _vibrateCorrect();

        // Special vibration for high streaks
        if (_streak >= 3) {
          _vibrateStreak();
        }

        if (_streak > _highestStreak) {
          _highestStreak = _streak;
        }
      } else {
        _streak = 0;

        // Play wrong sound and vibration
        _playWrongSound();
        _vibrateWrong();
      }
    });

    if (isCorrect) {
      await _runCorrectAnswerFeedback(optionIndex);
    } else {
      await _runWrongAnswerFeedback();
    }

    if (!mounted) return;
    setState(() {
      _isFeedbackAnimating = false;
      _showAnswerPopup = true;
    });
  }

  void _closeAnswerPopup() async {
    setState(() {
      _showAnswerPopup = false;
    });

    // Wait a bit for animation
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Check if the answer was wrong (not in correct answers)
    final questionIndex = _sessionController.currentQuestionIndex;
    final question = _sessionController.questions[questionIndex];
    final selectedAnswer = _userAnswers[questionIndex];
    final isCorrect = selectedAnswer == question.correct.order;

    if (!isCorrect) {
      if (_lives > 0) {
        await _consumeLifeAndReloadLevel(questionIndex);
      } else {
        _showFailModal();
      }
    } else {
      await _moveToNextQuestion();
    }
  }

  Future<void> _moveToNextQuestion() async {
    final isLastQuestion = _sessionController.currentQuestionIndex >=
        _sessionController.questions.length - 1;

    if (isLastQuestion) {
      if (_lives <= 0) {
        _showNextLevelRewardGate();
      } else {
        await _loadNextLevel();
      }
      return;
    }

    // Try to move to next question
    final hasMore = await _sessionController.nextQuestion();

    if (!hasMore) {
      await _loadNextLevel();
    } else {
      setState(_resetQuestionUi);
      _progressController.forward(from: 0);
    }
  }

  void _playCorrectSound() async {
    try {
      await _correctSoundPlayer.stop(); // Stop any ongoing playback
      await _correctSoundPlayer.play(AssetSource('sounds/correct.wav'));
    } catch (e) {
      // Intentionally ignored.
    }
  }

  void _playWrongSound() async {
    try {
      await _wrongSoundPlayer.stop();
      // await _wrongSoundPlayer.play(AssetSource('sounds/wrong.wav'));
      await _wrongSoundPlayer.play(AssetSource('sounds/wrong.wav'));
    } catch (e) {
      // Intentionally ignored.
    }
  }

  void _playButtonSound() async {
    try {
      await _buttonSoundPlayer.stop();
      await _buttonSoundPlayer.play(AssetSource('sounds/completed.mp3'));
    } catch (e) {
      // Intentionally ignored.
    }
  }

  void _vibrateCorrect() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: _correctVibrationDuration);
    }
  }

  void _vibrateWrong() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: _wrongVibrationDuration);
    }
  }

  void _vibrateStreak() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: _streakVibrationPattern);
    }
  }

  void _vibrateButton() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50);
    }
  }

  GlobalKey _optionKeyFor(int index) {
    return _optionKeys.putIfAbsent(index, () => GlobalKey());
  }

  Offset? _centerInGameStack(GlobalKey key) {
    final targetContext = key.currentContext;
    final stackContext = _gameStackKey.currentContext;
    if (targetContext == null || stackContext == null) return null;

    final targetBox = targetContext.findRenderObject() as RenderBox?;
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (targetBox == null || stackBox == null) return null;

    final targetCenterGlobal =
        targetBox.localToGlobal(targetBox.size.center(Offset.zero));
    return stackBox.globalToLocal(targetCenterGlobal);
  }

  Future<void> _runCorrectAnswerFeedback(int optionIndex) async {
    final targetScore = _score + _pointsPerQuestion;
    await Future.wait([
      _animatePointsToScore(optionIndex),
      _animateScoreCountUp(targetScore),
    ]);

    if (!mounted) return;
    setState(() {
      _score = targetScore;
      _displayedScore = targetScore;
    });
  }

  Future<void> _runWrongAnswerFeedback() async {
    await _animateHeartLossFromLives();
  }

  Future<void> _animatePointsToScore(int optionIndex) async {
    final from = _centerInGameStack(_optionKeyFor(optionIndex));
    final to = _centerInGameStack(_scoreKey);
    if (from == null || to == null) return;

    setState(() {
      _flyingPointsStart = from;
      _flyingPointsEnd = to;
      _flyingPointsSeed++;
      _showFlyingPoints = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _showFlyingPoints = false;
    });
  }

  Future<void> _animateHeartLossFromLives() async {
    final from = _centerInGameStack(_livesKey);
    if (from == null) return;

    final to = Offset(from.dx + 110, from.dy - 70);
    setState(() {
      _flyingHeartStart = from;
      _flyingHeartEnd = to;
      _flyingHeartSeed++;
      _showFlyingHeart = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _showFlyingHeart = false;
    });
  }

  Future<void> _animateScoreCountUp(int targetScore) async {
    final from = _displayedScore;
    if (targetScore <= from) return;

    const steps = 16;
    const totalMs = 680;

    for (int i = 1; i <= steps; i++) {
      if (!mounted) return;
      final t = i / steps;
      final eased = Curves.easeOutCubic.transform(t);
      final nextValue = from + ((targetScore - from) * eased).round();
      setState(() {
        _displayedScore = nextValue.clamp(from, targetScore);
      });
      await Future.delayed(const Duration(milliseconds: totalMs ~/ steps));
    }

    if (!mounted) return;
    setState(() {
      _displayedScore = targetScore;
    });
  }

  Widget _buildFeedbackFxLayer() {
    return IgnorePointer(
      child: Stack(
        children: [
          if (_showFlyingPoints &&
              _flyingPointsStart != null &&
              _flyingPointsEnd != null)
            TweenAnimationBuilder<double>(
              key: ValueKey('points-$_flyingPointsSeed'),
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOutCubic,
              builder: (context, t, _) {
                final x = _flyingPointsStart!.dx +
                    (_flyingPointsEnd!.dx - _flyingPointsStart!.dx) * t;
                final yBase = _flyingPointsStart!.dy +
                    (_flyingPointsEnd!.dy - _flyingPointsStart!.dy) * t;
                final y = yBase - (math.sin(t * math.pi) * 34);
                final opacity =
                    (1 - (t - 0.85).clamp(0, 0.15) / 0.15).clamp(0.0, 1.0);

                return Positioned(
                  left: x - 28,
                  top: y - 14,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '+$_pointsPerQuestion',
                        style: AppTextStyles.normal700(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          if (_showFlyingHeart &&
              _flyingHeartStart != null &&
              _flyingHeartEnd != null)
            TweenAnimationBuilder<double>(
              key: ValueKey('heart-$_flyingHeartSeed'),
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                final x = _flyingHeartStart!.dx +
                    (_flyingHeartEnd!.dx - _flyingHeartStart!.dx) * t;
                final y = _flyingHeartStart!.dy +
                    (_flyingHeartEnd!.dy - _flyingHeartStart!.dy) * t;
                final scale = 1 - (0.2 * t);
                final opacity = (1 - t).clamp(0.0, 1.0);

                return Positioned(
                  left: x - 12,
                  top: y - 12,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _consumeLifeAndReloadLevel(int failedIndex) async {
    if (_lives <= 0) {
      _showFailModal();
      return;
    }

    final nextLives = _lives - 1;
    setState(() {
      _lives = nextLives;
    });

    if (nextLives <= 0) {
      _showFailModal();
      return;
    }

    await _reloadCurrentLevel(startIndex: failedIndex);
  }

  void _showFailModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        final dialogWidth =
            isLandscape ? screenWidth * 0.7 : screenWidth * 0.90;
        final maxHeight = screenHeight * 0.8;
        final canWatchRewardAd = _canShowGamifyAds;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 40 : 16, vertical: 24),
          backgroundColor: Colors.white,
          child: Stack(
            children: [
              Container(
                width: dialogWidth,
                constraints:
                    BoxConstraints(maxWidth: 500, maxHeight: maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.eLearningBtnColor1
                                  .withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.error_outline,
                                size: 48, color: AppColors.eLearningBtnColor1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Out of lives',
                            style: AppTextStyles.normal600(
                                fontSize: 20, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Watch a rewarded ad to continue from this question, or end this run here.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.normal400(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.red.shade200, width: 1),
                            ),
                            child: Text(
                              'Lives left: $_lives',
                              style: AppTextStyles.normal600(
                                fontSize: 12,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await _endRunToLeaderboard();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.stop_circle_outlined,
                                    color: Colors.grey.shade800,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'End Run',
                                    style: AppTextStyles.normal600(
                                        color: Colors.grey.shade800,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Watch ad button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: canWatchRewardAd
                                  ? () => _showRewardedAd(
                                        onRewardEarned: () async {
                                          final session = _sessionController;
                                          final failedIndex =
                                              session.currentQuestionIndex;
                                          Navigator.pop(context);
                                          await _reloadCurrentLevel(
                                            startIndex: failedIndex,
                                          );
                                        },
                                      )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.eLearningContColor3,
                                disabledBackgroundColor: Colors.grey.shade300,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      canWatchRewardAd
                                          ? Icons.play_circle_outline
                                          : Icons.hourglass_empty,
                                      color: canWatchRewardAd
                                          ? Colors.white
                                          : Colors.grey.shade500),
                                  const SizedBox(width: 8),
                                  Text(
                                      canWatchRewardAd
                                          ? 'Watch Ad'
                                          : 'Ad Unavailable',
                                      style: AppTextStyles.normal600(
                                          color: canWatchRewardAd
                                              ? Colors.white
                                              : Colors.grey.shade500,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                          if (canWatchRewardAd)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'You will continue from this same question after the ad.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.normal400(
                                    fontSize: 12, color: Colors.red.shade600),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Cancel button at top right
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _endRunToLeaderboard();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNextLevelRewardGate() {
    final nextLevel = _currentLevel + 1;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Unlock Level $nextLevel',
          style: AppTextStyles.normal600(fontSize: 20),
        ),
        content: Text(
          'You completed Level $_currentLevel with no lives left. Watch a rewarded ad to move to Level $nextLevel.',
          style: AppTextStyles.normal400(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _endRunToLeaderboard();
            },
            child: Text(
              'End Run',
              style: AppTextStyles.normal600(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _canShowGamifyAds
                ? () => _showRewardedAd(
                      onRewardEarned: () async {
                        Navigator.pop(context);
                        await _loadNextLevel();
                      },
                    )
                : null,
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }

  void _showRewardedAd({
    required Future<void> Function() onRewardEarned,
  }) {
    if (!_canShowGamifyAds) {
      return;
    }

    GamifyAdManager.instance
        .showRewardedIfEligible(context: context)
        .then((rewardEarned) async {
      if (!mounted || !rewardEarned) {
        return;
      }

      await onRewardEarned();
    });
  }

  // Lifeline: 50:50 - Remove 2 random wrong answers
  void _useFiftyFifty(Question question) {
    if (_fiftyFiftyUsed || _isAnswered) return;

    _vibrateButton();

    final questionIndex = _sessionController.currentQuestionIndex;
    final correctAnswer = question.correct.order;
    final wrongOptions = List.generate(question.options.length, (i) => i)
        .where((i) => i != correctAnswer)
        .toList();

    // Shuffle and take 2 random wrong answers to hide
    wrongOptions.shuffle();
    final toHide = wrongOptions.take(2).toSet();

    setState(() {
      _fiftyFiftyUsed = true;
      _hiddenOptionsPerQuestion[questionIndex] = toHide;
    });
  }

  // Lifeline: Ask Computer - Computer suggests the answer
  void _useAskComputer(Question question) {
    if (_askComputerUsed || _isAnswered) return;

    _vibrateButton();

    final correctAnswer = question.correct.order;

    setState(() {
      _askComputerUsed = true;
      _computerSuggestion = correctAnswer;
    });

    // Show dialog with computer suggestion
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.eLearningBtnColor1,
                AppColors.eLearningBtnColor1.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.computer, size: 64, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Computer Suggestion',
                style: AppTextStyles.normal600(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'I think the answer is Option ${String.fromCharCode(65 + correctAnswer)}',
                textAlign: TextAlign.center,
                style: AppTextStyles.normal400(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Got it',
                  style: AppTextStyles.normal600(
                    fontSize: 16,
                    color: AppColors.eLearningBtnColor1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Lifeline: Shuffle - Watch ad then shuffle to next question
  void _useShuffle(Question question) {
    _playButtonSound();
    _vibrateButton();

    if (!_canShowGamifyAds) {
      return;
    }

    _showShuffleRewardedAd();
  }

  void _showShuffleRewardedAd() {
    if (!_canShowGamifyAds) {
      return;
    }

    _showRewardedAd(
      onRewardEarned: () async {
        await _moveToNextQuestion();
      },
    );
  }

  Future<void> _endRunToLeaderboard() async {
    if (_score > 0 || _correctAnswers > 0) {
      await _saveScoreIfNeeded();
    }
    if (!mounted) return;

    await GamifyAdManager.instance.showInterstitialIfEligible(
      context: context,
    );
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(
          examTypeId: widget.examTypeId,
          subjects: <SubjectModel>[
            SubjectModel(id: widget.courseId.toString(), name: widget.subject),
          ],
          fromGameDashboard: true,
        ),
      ),
    );
  }

  Future<void> _finishQuiz() async {
    await _saveScoreIfNeeded();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ResultDialog(
        score: _score,
        answeredQuestions: _totalAnsweredProgress(),
        correctAnswers: _correctAnswers,
        highestStreak: _highestStreak,
        levelReached: _currentLevel,
        onDone: () async {
          Navigator.of(dialogContext).pop();
          await GamifyAdManager.instance.showInterstitialIfEligible(
            context: context,
          );
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LeaderboardScreen(
                examTypeId: widget.examTypeId,
                subjects: <SubjectModel>[
                  SubjectModel(
                      id: widget.courseId.toString(), name: widget.subject),
                ],
                fromGameDashboard: true,
              ),
            ),
          );
        },
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

    if (url.startsWith('/')) {
      return Image.file(
        File(url),
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
            width: width, height: height, color: Colors.grey.shade200),
      );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey.shade500,
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade500,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            'Image unavailable',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

  Future<void> _handleExitToDashboard() async {
    if (_isExitingToDashboard) return;

    if (mounted) {
      setState(() {
        _isExitingToDashboard = true;
      });
    } else {
      _isExitingToDashboard = true;
    }
    try {
      if (_score > 0 || _correctAnswers > 0) {
        await _finishQuiz();
      } else {
        if (mounted) {
          setState(() => _allowRoutePop = true);
        } else {
          _allowRoutePop = true;
        }
        await popThenShowInterstitial(
          popNavigation: () => Navigator.pop(context),
          showInterstitial: (targetContext) =>
              GamifyAdManager.instance.showInterstitialIfEligible(
            context: targetContext,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExitingToDashboard = false;
        });
      } else {
        _isExitingToDashboard = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sessionController,
      builder: (context, child) {
        final session = _sessionController;

        // Loading state
        if (session.loading) {
          return PopScope(
            canPop: _allowRoutePop,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop || _allowRoutePop) return;
              await _handleExitToDashboard();
            },
            child: Scaffold(
              backgroundColor: AppColors.eLearningBtnColor1,
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Loading questions...',
                        style: AppTextStyles.normal600(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Error state
        if (session.error != null) {
          return PopScope(
            canPop: _allowRoutePop,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop || _allowRoutePop) return;
              await _handleExitToDashboard();
            },
            child: Scaffold(
              backgroundColor: AppColors.eLearningBtnColor1,
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load questions',
                          style: AppTextStyles.normal600(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          session.error!,
                          style: AppTextStyles.normal400(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _initializeGameSession(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.eLearningBtnColor1,
                          ),
                          child: Text('Try Again'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _handleExitToDashboard,
                          child: Text(
                            'Go Back',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // No questions available
        if (session.questions.isEmpty) {
          return PopScope(
            canPop: _allowRoutePop,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop || _allowRoutePop) return;
              await _handleExitToDashboard();
            },
            child: Scaffold(
              backgroundColor: AppColors.eLearningBtnColor1,
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'No questions available',
                        style: AppTextStyles.normal600(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _handleExitToDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.eLearningBtnColor1,
                        ),
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Countdown not complete - show empty container
        if (!_isCountdownComplete) {
          return PopScope(
            canPop: _allowRoutePop,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop || _allowRoutePop) return;
              await _handleExitToDashboard();
            },
            child: Scaffold(
              backgroundColor: AppColors.eLearningBtnColor1,
              body: Container(),
            ),
          );
        }

        final questionIndex = session.currentQuestionIndex;
        final question = session.questions[questionIndex];
        final selectedAnswer = _userAnswers[questionIndex];
        final isCorrect = selectedAnswer == question.correct.order;
        _ensureQuestionPresentation(question: question);

        return PopScope(
          canPop: _allowRoutePop,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || _allowRoutePop) return;
            await _handleExitToDashboard();
          },
          child: Scaffold(
            body: Stack(
              key: _gameStackKey,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.eLearningBtnColor1,
                        AppColors.eLearningBtnColor1.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _buildGameHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildQuestionCard(question),
                                const SizedBox(height: 20),
                                _buildLifelinesSection(question),
                                _buildOptionsGrid(
                                  question,
                                  selectedAnswer,
                                  isCorrect,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildFeedbackFxLayer(),
                if (_showAnswerPopup && _isAnswered)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _AnswerPopup(
                        isCorrect: isCorrect,
                        points: _pointsPerQuestion,
                        onClose: _closeAnswerPopup,
                        questionText: question.questionText,
                        selectedAnswerText: selectedAnswer != null
                            ? question.options[selectedAnswer].text
                            : '',
                        correctAnswerText:
                            question.options[question.correct.order].text,
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

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed:
                    _isExitingToDashboard ? null : _handleExitToDashboard,
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.subject,
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.layers_rounded,
                  label: 'Level',
                  value: '$_currentLevel',
                  color: Colors.cyanAccent,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  key: _livesKey,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Lives',
                        style: AppTextStyles.normal400(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(width: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: Text(
                          '$_lives',
                          key: ValueKey(_lives),
                          style: AppTextStyles.normal600(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  cardKey: _scoreKey,
                  icon: Icons.star,
                  label: 'Score',
                  value: '$_displayedScore',
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _sessionController.questions.isEmpty
                  ? 0
                  : ((_sessionController.currentQuestionIndex + 1) /
                          _sessionController.totalQuestions)
                      .clamp(0, 1),
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    Key? cardKey,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      key: cardKey,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 2),
          Row(
            children: [
              Text(
                label,
                style: AppTextStyles.normal400(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(width: 4),
              Text(
                value,
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 4),
              Icon(icon, color: color, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasInstructionOrPassage(Question question) {
    return question.instruction.trim().isNotEmpty ||
        question.passage.trim().isNotEmpty;
  }

  String _instructionModalTitle(Question question) {
    final hasInstruction = question.instruction.trim().isNotEmpty;
    final hasPassage = question.passage.trim().isNotEmpty;

    if (hasInstruction && hasPassage) return 'Instruction & Passage';
    if (hasInstruction) return 'Instruction';
    return 'Passage';
  }

  String _instructionModalContent(Question question) {
    final hasInstruction = question.instruction.trim().isNotEmpty;
    final hasPassage = question.passage.trim().isNotEmpty;

    if (hasInstruction && hasPassage) {
      return '${question.instruction}\n\n${question.passage}';
    }
    if (hasInstruction) return question.instruction;
    return question.passage;
  }

  String _questionPresentationKey(
    Question question,
  ) {
    return '$_currentLevel-${_sessionController.currentQuestionIndex}-${question.questionId}';
  }

  void _ensureQuestionPresentation({
    required Question question,
  }) {
    final presentationKey = _questionPresentationKey(question);
    if (_activeQuestionPresentationKey == presentationKey) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startQuestionPresentation(
        question: question,
      );
    });
  }

  void _startQuestionPresentation({
    required Question question,
  }) {
    final presentationKey = _questionPresentationKey(question);
    if (_activeQuestionPresentationKey == presentationKey) {
      return;
    }

    _optionsRevealTimer?.cancel();
    _instructionPromptTimer?.cancel();

    setState(() {
      _activeQuestionPresentationKey = presentationKey;
      _visibleOptionCount = 0;
    });

    final totalOptions = question.options.length;
    if (totalOptions == 0) {
      _scheduleInstructionPrompt(question, presentationKey);
      return;
    }

    var revealedOptions = 0;
    _optionsRevealTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (!mounted || _activeQuestionPresentationKey != presentationKey) {
          timer.cancel();
          return;
        }

        revealedOptions += 1;
        setState(() {
          _visibleOptionCount = revealedOptions.clamp(0, totalOptions);
        });

        if (revealedOptions >= totalOptions) {
          timer.cancel();
          _scheduleInstructionPrompt(question, presentationKey);
        }
      },
    );
  }

  void _scheduleInstructionPrompt(Question question, String presentationKey) {
    if (!_hasInstructionOrPassage(question) ||
        _autoShownInstructionKeys.contains(presentationKey)) {
      return;
    }

    _instructionPromptTimer = Timer(
      const Duration(milliseconds: 220),
      () {
        if (!mounted ||
            _activeQuestionPresentationKey != presentationKey ||
            _showAnswerPopup) {
          return;
        }

        _autoShownInstructionKeys.add(presentationKey);
        _showInstructionOrPassageModal(
          _instructionModalTitle(question),
          _instructionModalContent(question),
        );
      },
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              'Question ${_sessionController.currentQuestionIndex + 1}',
                              style: AppTextStyles.normal700(
                                fontSize: 14,
                                color: AppColors.text4Light,
                              ),
                            ),
                          ),

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

  Widget _buildQuestionCard(Question question) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              if (_hasInstructionOrPassage(question)) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _showInstructionOrPassageModal(
                      _instructionModalTitle(question),
                      _instructionModalContent(question),
                    ),
                    icon: Icon(
                      question.instruction.trim().isNotEmpty &&
                              question.passage.trim().isNotEmpty
                          ? Icons.menu_book_rounded
                          : question.instruction.trim().isNotEmpty
                              ? Icons.info_outline
                              : Icons.article_outlined,
                      color: AppColors.eLearningBtnColor1,
                      size: 18,
                    ),
                    label: Text(
                      _instructionModalTitle(question),
                      style: AppTextStyles.normal600(
                        fontSize: 13,
                        color: AppColors.eLearningBtnColor1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
              ],
              Html(
                data: question.questionText,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(18),
                    color: AppColors.text4Light,
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
        Positioned(
          top: 0,
          left: 20,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.eLearningBtnColor1,
                  AppColors.eLearningBtnColor1.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.eLearningBtnColor1.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${_sessionController.currentQuestionIndex + 1}',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  '/${_sessionController.totalQuestions}',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsGrid(
      Question question, int? selectedAnswer, bool isCorrect) {
    final options = question.options;
    final correctAnswer = question.correct.order;
    final questionIndex = _sessionController.currentQuestionIndex;
    final hiddenOptions = _hiddenOptionsPerQuestion[questionIndex] ?? {};

    // Get display order - no shuffle for options, only entire question can be shuffled
    final displayOrder = List.generate(options.length, (i) => i);

    return Column(
      children: displayOrder.map((index) {
        final option = options[index];
        final isSelected = selectedAnswer == index;
        final isCorrectOption = index == correctAnswer;
        final showCorrect = _isAnswered && isCorrectOption;
        final showWrong = _isAnswered && isSelected && !isCorrect;
        final isHidden = hiddenOptions.contains(index);
        final isComputerSuggestion = _computerSuggestion == index;
        final isVisible = index < _visibleOptionCount || _isAnswered;

        // Keep empty space for removed options (even after answering)
        if (isHidden) {
          return SizedBox(
            height: 77, // Match the height of normal option (65 + 12 margin)
          );
        }

        Color backgroundColor = Colors.white;
        Color borderColor = Colors.grey.shade300;
        Color textColor = AppColors.text4Light;

        if (showCorrect) {
          backgroundColor = Colors.green.shade50;
          borderColor = Colors.green;
          textColor = Colors.green.shade900;
        } else if (showWrong) {
          backgroundColor = Colors.red.shade50;
          borderColor = Colors.red;
          textColor = Colors.red.shade900;
        } else if (isSelected) {
          backgroundColor = AppColors.eLearningBtnColor1.withValues(alpha: 0.1);
          borderColor = AppColors.eLearningBtnColor1;
        } else if (isComputerSuggestion) {
          backgroundColor = Colors.blue.shade50;
          borderColor = Colors.blue;
        }

        return AnimatedSlide(
          offset: isVisible ? Offset.zero : const Offset(0.12, 0),
          duration: Duration(milliseconds: 280 + (index * 40)),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: isVisible ? 1 : 0,
            duration: Duration(milliseconds: 240 + (index * 40)),
            curve: Curves.easeOut,
            child: IgnorePointer(
              ignoring: !isVisible,
              child: GestureDetector(
                onTap: () => _selectAnswer(index, question),
                child: KeyedSubtree(
                  key: _optionKeyFor(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.2),
                          blurRadius: isSelected ? 8 : 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: showCorrect
                                ? Colors.green
                                : showWrong
                                    ? Colors.red
                                    : isSelected
                                        ? AppColors.eLearningBtnColor1
                                        : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: showCorrect || showWrong || isSelected
                                  ? Colors.transparent
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: showCorrect
                                ? Icon(Icons.check,
                                    color: Colors.white, size: 20)
                                : showWrong
                                    ? Icon(Icons.close,
                                        color: Colors.white, size: 20)
                                    : isSelected
                                        ? Icon(Icons.check,
                                            color: Colors.white, size: 20)
                                        : Text(
                                            String.fromCharCode(65 + index),
                                            style: AppTextStyles.normal600(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Html(
                            data: option.text,
                            style: {
                              "body": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                fontSize: FontSize(16),
                                color: textColor,
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
                                  final attributes =
                                      extensionContext.attributes;
                                  final src = attributes['src'] ?? '';

                                  if (src.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

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
                        if (showCorrect)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+$_pointsPerQuestion ⭐',
                              style: AppTextStyles.normal600(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (isComputerSuggestion && !_isAnswered)
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.computer,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLifelinesSection(Question question) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLifelineButton(
            icon: Icons.exposure_neg_2, // -2 icon
            label: '50:50',
            isUsed: _fiftyFiftyUsed,
            isDisabled: _isAnswered,
            onTap: () => _useFiftyFifty(question),
            showAdBadge: false,
          ),
          _buildLifelineButton(
            icon: Icons.computer,
            label: 'Ask PC',
            isUsed: _askComputerUsed,
            isDisabled: _isAnswered,
            onTap: () => _useAskComputer(question),
            showAdBadge: false,
          ),
          _buildLifelineButton(
            icon: Icons.shuffle,
            label: 'Shuffle',
            isUsed: false, // Never mark as used - can shuffle anytime
            isDisabled: false, // Never disabled - can shuffle anytime
            onTap: () => _useShuffle(question),
            showAdBadge: _canShowGamifyAds,
          ),
        ],
      ),
    );
  }

  Widget _buildLifelineButton({
    required IconData icon,
    required String label,
    required bool isUsed,
    required bool isDisabled,
    required VoidCallback onTap,
    required bool showAdBadge,
  }) {
    final isActive = !isUsed && !isDisabled;

    return Expanded(
      child: GestureDetector(
        onTap: isActive
            ? onTap
            : (showAdBadge
                ? onTap
                : null), // Allow shuffle anytime, block used lifelines
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Container with Ad Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.eLearningBtnColor1
                                  .withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isActive
                        ? AppColors.eLearningBtnColor1
                        : Colors.grey.shade500,
                    size: 28,
                  ),
                ),
                // Ad Badge
                if (showAdBadge)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'AD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            // Label
            Text(
              label,
              style: AppTextStyles.normal600(
                fontSize: 12,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final int score;
  final int answeredQuestions;
  final int correctAnswers;
  final int highestStreak;
  final int levelReached;
  final Future<void> Function() onDone;

  const _ResultDialog({
    required this.score,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.highestStreak,
    required this.levelReached,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate accuracy based on correct answers out of answered questions
    final accuracy = answeredQuestions > 0
        ? (correctAnswers / answeredQuestions * 100).round()
        : 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.eLearningBtnColor1,
              AppColors.eLearningBtnColor1.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.amber,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Run Complete!',
              style: AppTextStyles.normal600(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You reached Level $levelReached',
              style: AppTextStyles.normal400(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Score', '$score ⭐', Colors.amber),
                      _buildStatItem(
                          'Answered', '$answeredQuestions', Colors.greenAccent),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          'Accuracy', '$accuracy%', Colors.lightBlueAccent),
                      _buildStatItem(
                          'Best Streak', '$highestStreak 🔥', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Done',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'Urbanist',
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
            fontFamily: 'Urbanist',
          ),
        ),
      ],
    );
  }
}

class _AnswerPopup extends StatefulWidget {
  final bool isCorrect;
  final int points;
  final VoidCallback onClose;
  final String questionText;
  final String selectedAnswerText;
  final String correctAnswerText;

  const _AnswerPopup({
    required this.isCorrect,
    required this.points,
    required this.onClose,
    required this.questionText,
    required this.selectedAnswerText,
    required this.correctAnswerText,
  });

  @override
  State<_AnswerPopup> createState() => _AnswerPopupState();
}

class _AnswerPopupState extends State<_AnswerPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  static const _correctColor = Color(0xFF16A34A);
  static const _wrongColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Color get _accentColor => widget.isCorrect ? _correctColor : _wrongColor;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Result row — icon + label + points badge
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _accentColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isCorrect ? 'Correct!' : 'Incorrect',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _accentColor,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          Text(
                            widget.isCorrect
                                ? 'Amazing! Keep the streak going 🔥'
                                : 'Don\'t give up! Try the next one 💪',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isCorrect)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '+${widget.points}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFD97706),
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Question',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Html(
                        data: widget.questionText,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(13),
                            color: const Color(0xFF1F2937),
                            lineHeight: LineHeight(1.4),
                          ),
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.isCorrect ? 'Selected answer' : 'Your answer',
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Html(
                        data: widget.selectedAnswerText,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(13),
                            color: widget.isCorrect
                                ? const Color(0xFF166534)
                                : const Color(0xFF991B1B),
                            lineHeight: LineHeight(1.4),
                            fontWeight: FontWeight.w600,
                          ),
                        },
                      ),
                      if (!widget.isCorrect) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Correct answer',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Html(
                          data: widget.correctAnswerText,
                          style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(13),
                              color: const Color(0xFF166534),
                              lineHeight: LineHeight(1.4),
                              fontWeight: FontWeight.w700,
                            ),
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Continue button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Urbanist',
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

class _GameCountdownDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _GameCountdownDialog({
    required this.onComplete,
  });

  @override
  State<_GameCountdownDialog> createState() => _GameCountdownDialogState();
}

class _GameCountdownDialogState extends State<_GameCountdownDialog>
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
              AppColors.eLearningBtnColor1.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Starting Game',
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
              'Get ready to play!',
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
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Text(
                          '$_countdown',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress indicator
            Text(
              'Get ready...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCountdownDialog extends StatefulWidget {
  final int level;
  final VoidCallback onComplete;

  const _LoadingCountdownDialog({
    required this.level,
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
              AppColors.eLearningBtnColor1.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.gamepad_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Starting Level',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Level ${widget.level}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
                    color: Colors.black.withValues(alpha: 0.2),
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
                color: Colors.white.withValues(alpha: 0.8),
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

class _NextTopicCountdownDialog extends StatefulWidget {
  final int level;
  final VoidCallback onComplete;

  const _NextTopicCountdownDialog({
    required this.level,
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
              AppColors.eLearningBtnColor1.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Next Level',
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
              'Level ${widget.level}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
                fontFamily: 'Urbanist',
              ),
            ),
            const SizedBox(height: 8),

            // Message
            const Text(
              'Loading a fresh question set...',
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
                    color: Colors.black.withValues(alpha: 0.2),
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
              'Get ready for more! 🚀',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
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
