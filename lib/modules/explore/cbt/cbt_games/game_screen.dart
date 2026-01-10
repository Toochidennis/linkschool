// ignore_for_file: deprecated_member_use
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:linkschool/modules/explore/cbt/cbt_games/game_Leaderboard.dart';
import 'package:linkschool/modules/providers/explore/studies_question_provider.dart';
import 'package:linkschool/modules/model/explore/study/studies_questions_model.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class GameTestScreen extends StatefulWidget {
  final String subject;
  final List<String> topics;
  final List<int> topicIds;
  final int courseId;
  final int examTypeId;

  const GameTestScreen({
    Key? key,
    required this.subject,
    required this.topics,
    required this.topicIds,
    required this.courseId,
    required this.examTypeId,
  }) : super(key: key);

  @override
  State<GameTestScreen> createState() => _GameTestScreenState();
}

class _GameTestScreenState extends State<GameTestScreen>
    with TickerProviderStateMixin {
  Map<int, int> _userAnswers = {};
  int _score = 0;
  int _streak = 0;
  int _highestStreak = 0;
  int _correctAnswers = 0; // Track correct answers for accuracy
  int _userCoins =
      50; // User's available coins (initialize with default or fetch from provider)
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Lifeline states
  bool _fiftyFiftyUsed = false;
  bool _askComputerUsed = false;
  bool _shuffleUsed = false;
  Map<int, Set<int>> _hiddenOptionsPerQuestion =
      {}; // For 50:50 lifeline - stores hidden options per question index
  int? _computerSuggestion; // For Ask Computer lifeline
  List<int>? _shuffledIndices; // For Shuffle lifeline

  late AudioPlayer _correctSoundPlayer;
  late AudioPlayer _wrongSoundPlayer;
  late AudioPlayer _buttonSoundPlayer;

  final int _correctVibrationDuration = 200;
  final int _wrongVibrationDuration = 500;
  final List<int> _streakVibrationPattern = [100, 200, 100];

  // Points per question for gamification
  final int _pointsPerQuestion = 10;

  // Ad and lives system
  RewardedAd? _rewardedAd;
  RewardedAd? _shuffleRewardedAd; // Separate ad for shuffle
  bool _isAdLoaded = false;
  bool _isShuffleAdLoaded = false;
  bool _isPendingFinish =
      false; // Track if quiz should finish after failed last question

  void _initializeAudio() async {
    _correctSoundPlayer = AudioPlayer();
    _wrongSoundPlayer = AudioPlayer();
    _buttonSoundPlayer = AudioPlayer();

    // Preload sounds (optional - for better performance)
    try {
      await _correctSoundPlayer.setSource(AssetSource('sounds/correct.wav'));
      await _wrongSoundPlayer.setSource(AssetSource('sounds/wrong.wav'));
      await _buttonSoundPlayer.setSource(AssetSource('sounds/completed.wav'));
    } catch (e) {
      print('Error loading sounds: $e');
    }
  }

  int _remainingTime = 600; // 10 minutes
  bool _isAnswered = false;
  bool _showAnswerPopup = false;
  bool _showExplanationModal = false;
  bool _isCountdownComplete = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Bounce animation for "Read More" arrow
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _initializeAudio();
    _loadRewardedAd();
    _loadShuffleRewardedAd();

    // Show countdown immediately and load questions during countdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoadingCountdown();
    });
  }

  void _showLoadingCountdown() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LoadingCountdownDialog(
        onComplete: () {
          if (!mounted) return;
          Navigator.of(context).pop();
          setState(() {
            _isCountdownComplete = true;
          });
          _startTimer(); // Start the timer after countdown
        },
      ),
    );

    // Start fetching questions immediately when countdown begins
    _initializeGameSession();
  }

  Future<void> _initializeGameSession() async {
    final provider = Provider.of<QuestionsProvider>(context, listen: false);
    await provider.initializeStudySession(
      topicIds: widget.topicIds,
      courseId: widget.courseId,
      examTypeId: widget.examTypeId,
    );

    print('📚 Loaded ${provider.allQuestions.length} questions');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _bounceController.dispose();
    _correctSoundPlayer.dispose();
    _wrongSoundPlayer.dispose();
    _buttonSoundPlayer.dispose();
    _rewardedAd?.dispose();
    _shuffleRewardedAd?.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
        _startTimer();
      } else if (_remainingTime == 0) {
        _finishQuiz();
      }
    });
  }

  void _selectAnswer(int optionIndex, Question question) {
    if (_isAnswered) return;

    _playButtonSound();
    _vibrateButton();

    final provider = Provider.of<QuestionsProvider>(context, listen: false);
    final questionIndex = provider.currentQuestionIndex;

    setState(() {
      _userAnswers[questionIndex] = optionIndex;
      _isAnswered = true;
      // Clear computer suggestion icon when user selects an option
      _computerSuggestion = null;

      // Check if answer is correct (compare with correct option order)
      if (optionIndex == question.correct.order) {
        _score += _pointsPerQuestion;
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
        _showAnswerPopup = true;
      } else {
        _streak = 0;

        // Play wrong sound and vibration
        _playWrongSound();
        _vibrateWrong();

        _showAnswerPopup = true;

        // Check if this is the last question
        final provider = Provider.of<QuestionsProvider>(context, listen: false);
        final isLastQuestion =
            provider.currentQuestionIndex >= provider.allQuestions.length - 1 &&
                !provider.hasMoreTopics;

        if (isLastQuestion) {
          // Set flag to prevent auto-finish and show revive dialog first
          _isPendingFinish = true;
        }
      }
    });

    // Note: User can now close popup manually
    // The popup will handle the advancement when closed
  }

  void _closeAnswerPopup() async {
    setState(() {
      _showAnswerPopup = false;
    });

    // Wait a bit for animation
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Check if the answer was wrong (not in correct answers)
    final provider = Provider.of<QuestionsProvider>(context, listen: false);
    final questionIndex = provider.currentQuestionIndex;
    final question = provider.allQuestions[questionIndex];
    final selectedAnswer = _userAnswers[questionIndex];
    final isCorrect = selectedAnswer == question.correct.order;

    if (!isCorrect) {
      // Show explanation modal first, then fail modal if needed
      setState(() {
        _showExplanationModal = true;
      });
    } else {
      // Show explanation modal for correct answer too
      setState(() {
        _showExplanationModal = true;
      });
    }
  }

  Future<void> _moveToNextQuestion() async {
    final provider = Provider.of<QuestionsProvider>(context, listen: false);

    // Check if we're at the last question of current batch and there are more topics
    final isAtEndOfCurrentBatch =
        provider.currentQuestionIndex >= provider.allQuestions.length - 1;
    final hasMoreTopicsToLoad = provider.hasMoreTopics;

    if (isAtEndOfCurrentBatch && hasMoreTopicsToLoad) {
      // Show countdown while loading next topic's questions
      _showNextTopicCountdown();
      return;
    }

    // Try to move to next question
    final hasMore = await provider.nextQuestion();

    if (!hasMore && provider.isLastQuestion && !provider.hasMoreTopics) {
      // Game complete - no more questions from any topic
      // Only finish if not pending (meaning user didn't fail on last question)
      if (!_isPendingFinish) {
        _finishQuiz();
      }
    } else {
      // Reset state for next question (but keep lifeline usage state)
      setState(() {
        _isAnswered = false;
        _showAnswerPopup = false;
        // Note: Lifelines (_fiftyFiftyUsed, _askComputerUsed, _shuffleUsed) are NOT reset
        // They remain used for the entire game session
        // Hidden options per question are preserved in _hiddenOptionsPerQuestion map
        _computerSuggestion = null;
        _shuffledIndices = null;
      });
      _progressController.forward(from: 0);
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

          // Now fetch the next topic's questions
          final hasMore = await provider.nextQuestion();

          if (!hasMore && provider.isLastQuestion && !provider.hasMoreTopics) {
            _finishQuiz();
          } else {
            setState(() {
              _isAnswered = false;
              _showAnswerPopup = false;
            });
            _progressController.forward(from: 0);
          }
        },
      ),
    );
  }

  void _playCorrectSound() async {
    try {
      await _correctSoundPlayer.stop(); // Stop any ongoing playback
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

  void _playButtonSound() async {
    try {
      await _buttonSoundPlayer.stop();
      await _buttonSoundPlayer.play(AssetSource('sounds/completed.wav'));
    } catch (e) {
      print('Error playing button sound: $e');
    }
  }

  void _vibrateCorrect() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: _correctVibrationDuration);
    }
  }

  void _vibrateWrong() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: _wrongVibrationDuration);
    }
  }

  void _vibrateStreak() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: _streakVibrationPattern);
    }
  }

  void _vibrateButton() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: EnvConfig.googleAdsApiKey,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          print('✅ Rewarded ad loaded successfully');

          // Set full screen content callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              // Load next ad for future use
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ Rewarded ad failed to load: $error');
          _isAdLoaded = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) _loadRewardedAd();
          });
        },
      ),
    );
  }

  void _loadShuffleRewardedAd() {
    RewardedAd.load(
      adUnitId: EnvConfig.googleAdsApiKey,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _shuffleRewardedAd = ad;
          _isShuffleAdLoaded = true;
          print('✅ Shuffle rewarded ad loaded successfully');

          // Set full screen content callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _shuffleRewardedAd = null;
              _isShuffleAdLoaded = false;
              // Load next ad for future use
              _loadShuffleRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Shuffle ad failed to show: $error');
              ad.dispose();
              _shuffleRewardedAd = null;
              _isShuffleAdLoaded = false;
              _loadShuffleRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ Shuffle rewarded ad failed to load: $error');
          _isShuffleAdLoaded = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) _loadShuffleRewardedAd();
          });
        },
      ),
    );
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
        final hasEnoughCoins = _userCoins >= 20;

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
                                  .withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.error_outline,
                                size: 48, color: AppColors.eLearningBtnColor1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Revive?',
                            style: AppTextStyles.normal600(
                                fontSize: 20, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You answered incorrectly. Choose an option to continue playing.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.normal400(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          // Display user's current coins
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.amber.shade200, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.monetization_on,
                                    color: Colors.amber.shade700, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  'Your coins: $_userCoins',
                                  style: AppTextStyles.normal600(
                                      fontSize: 12,
                                      color: Colors.amber.shade900),
                                ),
                              ],
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
                          // Revive with 20 coins button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: hasEnoughCoins
                                  ? () {
                                      _reviveWithCoins();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade600,
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
                                    Icons.monetization_on,
                                    color: hasEnoughCoins
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Revive with 20 Coins',
                                    style: AppTextStyles.normal600(
                                        color: hasEnoughCoins
                                            ? Colors.white
                                            : Colors.grey.shade500,
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
                              onPressed: _isAdLoaded
                                  ? () {
                                      _showRewardedAd();
                                    }
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
                                      _isAdLoaded
                                          ? Icons.play_circle_outline
                                          : Icons.hourglass_empty,
                                      color: _isAdLoaded
                                          ? Colors.white
                                          : Colors.grey.shade500),
                                  const SizedBox(width: 8),
                                  Text(
                                      _isAdLoaded
                                          ? 'Watch Ad'
                                          : 'Loading Ad...',
                                      style: AppTextStyles.normal600(
                                          color: _isAdLoaded
                                              ? Colors.white
                                              : Colors.grey.shade500,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                          if (!hasEnoughCoins)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Not enough coins. Watch an ad to continue!',
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
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    if (_isPendingFinish) {
                      _isPendingFinish = false;
                      _finishQuiz();
                    } else {
                      Navigator.pop(context); // exit game
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _reviveWithCoins() {
    if (_userCoins < 20) {
      print('❌ Not enough coins to revive');
      return;
    }

    setState(() {
      _userCoins -= 20; // Deduct 20 coins
    });

    // Clear pending finish flag since user is continuing
    _isPendingFinish = false;

    // Close the fail modal
    Navigator.pop(context);

    // Show success message (without sound since this is a revive action)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Revived! 20 coins deducted. Continue playing! 🎮',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Continue to next question after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _moveToNextQuestion();
      }
    });
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('❌ Rewarded ad is not ready yet');
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('✅ User earned reward: ${reward.amount} ${reward.type}');

        // Clear pending finish flag since user is continuing
        _isPendingFinish = false;

        // Close the fail modal
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Great! You can continue playing! 🎮',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Continue to next question after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _moveToNextQuestion();
          }
        });
      },
    );
  }

  Future<void> _nextQuestion() async {
    _playButtonSound();
    _vibrateButton();

    await _moveToNextQuestion();
  }

  void _previousQuestion() {
    _playButtonSound();
    _vibrateButton();

    final provider = Provider.of<QuestionsProvider>(context, listen: false);
    provider.previousQuestion();

    setState(() {
      _isAnswered = _userAnswers.containsKey(provider.currentQuestionIndex);
      // Clear visual effects when going back (lifeline usage flags remain)
      // Hidden options per question are preserved in _hiddenOptionsPerQuestion map
      _computerSuggestion = null;
      _shuffledIndices = null;
    });
  }

  // Lifeline: 50:50 - Remove 2 random wrong answers
  void _useFiftyFifty(Question question) {
    if (_fiftyFiftyUsed || _isAnswered) return;

    _playButtonSound();
    _vibrateButton();

    final provider = Provider.of<QuestionsProvider>(context, listen: false);
    final questionIndex = provider.currentQuestionIndex;
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

    _playButtonSound();
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
                AppColors.eLearningBtnColor1.withOpacity(0.8),
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

    // User can shuffle anytime - show ad immediately
    _showShuffleRewardedAd();
  }

  void _showShuffleAdDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.eLearningBtnColor1,
                AppColors.eLearningBtnColor1.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shuffle, size: 64, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Shuffle Question',
                style: AppTextStyles.normal600(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Watch a short ad to skip to the next question',
                textAlign: TextAlign.center,
                style: AppTextStyles.normal400(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.normal600(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isShuffleAdLoaded
                          ? () {
                              Navigator.pop(context);
                              _showShuffleRewardedAd();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _isShuffleAdLoaded ? 'Watch Ad' : 'Loading...',
                        style: AppTextStyles.normal600(
                          fontSize: 16,
                          color: _isShuffleAdLoaded
                              ? AppColors.eLearningBtnColor1
                              : Colors.grey.shade500,
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
    );
  }

  void _showShuffleRewardedAd() {
    if (_shuffleRewardedAd == null) {
      print('❌ Shuffle rewarded ad is not ready yet');
      return;
    }

    _shuffleRewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('✅ User earned shuffle reward: ${reward.amount} ${reward.type}');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Moving to next question! 🔀',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Move to next question after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _moveToNextQuestion();
          }
        });
      },
    );
  }

  void _finishQuiz() {
    final provider = Provider.of<QuestionsProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ResultDialog(
        score: _score,
        totalQuestions: provider.allQuestions.length,
        answeredQuestions: _userAnswers.length,
        correctAnswers: _correctAnswers,
        highestStreak: _highestStreak,
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

  void _closeExplanationModal() async {
    setState(() {
      _showExplanationModal = false;
    });

    // Wait a bit for animation
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Check if the answer was wrong
    final provider = Provider.of<QuestionsProvider>(context, listen: false);
    final questionIndex = provider.currentQuestionIndex;
    final question = provider.allQuestions[questionIndex];
    final selectedAnswer = _userAnswers[questionIndex];
    final isCorrect = selectedAnswer == question.correct.order;

    if (!isCorrect) {
      // Show revive modal for wrong answer
      _showFailModal();
    } else {
      // Auto-advance for correct answer
      await _moveToNextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionsProvider>(
      builder: (context, provider, child) {
        // Loading state
        if (provider.loading) {
          return Scaffold(
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
          );
        }

        // Error state
        if (provider.error != null) {
          return Scaffold(
            backgroundColor: AppColors.eLearningBtnColor1,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.white),
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
                        provider.error!,
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
                        onPressed: () => Navigator.pop(context),
                        child: Text('Go Back',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // No questions available
        if (provider.allQuestions.isEmpty) {
          return Scaffold(
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
                      onPressed: () => Navigator.pop(context),
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
          );
        }

        // Countdown not complete - show empty container
        if (!_isCountdownComplete) {
          return Scaffold(
            backgroundColor: AppColors.eLearningBtnColor1,
            body: Container(),
          );
        }

        // Sync local index with provider
        final questionIndex = provider.currentQuestionIndex;
        final question = provider.allQuestions[questionIndex];
        final selectedAnswer = _userAnswers[questionIndex];
        final isCorrect = selectedAnswer == question.correct.order;

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.eLearningBtnColor1,
                      AppColors.eLearningBtnColor1.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Game Header
                      _buildGameHeader(provider),

                      // Main Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Instruction/Passage Preview
                              _buildInstructionPassagePreviewCard(question),

                              // Question Card
                              _buildQuestionCard(question),
                              const SizedBox(height: 20),

                              // Lifelines Section
                              _buildLifelinesSection(question),

                              // Options
                              _buildOptionsGrid(
                                  question, selectedAnswer, isCorrect),
                            ],
                          ),
                        ),
                      ),

                      // Navigation Buttons
                      // _buildNavigationBar(),
                    ],
                  ),
                ),
              ),

              // Answer Popup Overlay
              if (_showAnswerPopup && _isAnswered)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: _AnswerPopup(
                      isCorrect: isCorrect,
                      points: _pointsPerQuestion,
                      onClose: _closeAnswerPopup,
                      correctAnswerText:
                          question.options[question.correct.order].text,
                    ),
                  ),
                ),

              // Explanation Modal Overlay
              if (_showExplanationModal)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: _ExplanationModal(
                      explanation: question.explanation,
                      onContinue: _closeExplanationModal,
                      onClose: _closeExplanationModal,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameHeader(QuestionsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                onPressed: () {
                  // Reset provider when leaving
                  provider.reset();
                  Navigator.pop(context);
                },
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
                  icon: Icons.star,
                  label: 'Score',
                  value: '$_score',
                  color: Colors.amber,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '$_streak',
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  label: 'Best',
                  value: '$_highestStreak',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (provider.currentQuestionIndex + 1) /
                  provider.allQuestions.length,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
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
                  color: Colors.white.withOpacity(0.8),
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

  /// Build instruction/passage preview card
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
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
                  AppColors.eLearningBtnColor1.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.eLearningBtnColor1.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_pointsPerQuestion',
                  style: AppTextStyles.normal600(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '⭐',
                  style: TextStyle(fontSize: 14),
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
    final provider = Provider.of<QuestionsProvider>(context, listen: false);
    final questionIndex = provider.currentQuestionIndex;
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
          backgroundColor = AppColors.eLearningBtnColor1.withOpacity(0.1);
          borderColor = AppColors.eLearningBtnColor1;
        } else if (isComputerSuggestion) {
          backgroundColor = Colors.blue.shade50;
          borderColor = Colors.blue;
        }

        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () => _selectAnswer(index, question),
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
                    color: borderColor.withOpacity(0.2),
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
                          ? Icon(Icons.check, color: Colors.white, size: 20)
                          : showWrong
                              ? Icon(Icons.close, color: Colors.white, size: 20)
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
                  if (showCorrect)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            showAdBadge: true, // Show ad badge on shuffle
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
                              color:
                                  AppColors.eLearningBtnColor1.withOpacity(0.2),
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
                            color: Colors.red.withOpacity(0.4),
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
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    final provider = Provider.of<QuestionsProvider>(context, listen: false);
    final currentIndex = provider.currentQuestionIndex;
    final totalQuestions = provider.allQuestions.length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: currentIndex > 0 ? _previousQuestion : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: currentIndex > 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Previous',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: currentIndex > 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _finishQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Finish Quiz',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: currentIndex < totalQuestions - 1 && !_isAnswered
                  ? _nextQuestion
                  : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: currentIndex < totalQuestions - 1 && !_isAnswered
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Skip',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: currentIndex < totalQuestions - 1 && !_isAnswered
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final int highestStreak;

  const _ResultDialog({
    required this.score,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.highestStreak,
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
              AppColors.eLearningBtnColor1.withOpacity(0.8),
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
                color: Colors.white.withOpacity(0.2),
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
              'Quiz Complete!',
              style: AppTextStyles.normal600(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Great job! Here\'s your result',
              style: AppTextStyles.normal400(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Score', '$score ⭐', Colors.amber),
                      _buildStatItem(
                          'Answered',
                          '$answeredQuestions/$totalQuestions',
                          Colors.greenAccent),
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
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LeaderboardScreen()));
              },
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
            color: Colors.white.withOpacity(0.8),
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
  final String correctAnswerText;

  const _AnswerPopup({
    required this.isCorrect,
    required this.points,
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
      tween: IntTween(begin: 0, end: widget.points),
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
              if (!widget.isCorrect) SizedBox(height: 12),
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

    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * math.pi;
      final distance = progress * 150;
      final x = centerX + math.cos(angle) * distance;
      final y = centerY + math.sin(angle) * distance;
      final opacity = 1.0 - progress;

      paint.color = Colors.amber.withOpacity(opacity * 0.8);
      canvas.drawCircle(
        Offset(x, y),
        6 * (1 - progress),
        paint,
      );
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
      ..color = Colors.amber.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final radius = 60 + (progress * 100);
      final x = size.width / 2 + math.cos(angle) * radius;
      final y = size.height / 2 + math.sin(angle) * radius;
      final scale = 1.0 - progress;

      if (scale > 0) {
        _drawStar(canvas, Offset(x, y), 8 * scale, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - (math.pi / 2);
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
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
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
                color: Colors.white.withOpacity(0.8),
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
                Icons.gamepad_rounded,
                size: 48,
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
                Icons.auto_awesome,
                size: 48,
                color: Colors.amber,
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
              'Get ready for more! 🚀',
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

class _ExplanationModal extends StatelessWidget {
  final String explanation;
  final VoidCallback onContinue;
  final VoidCallback onClose;

  const _ExplanationModal({
    required this.explanation,
    required this.onContinue,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                          final qIndex = (provider.allQuestions.isNotEmpty)
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

                        // Section title
                        const Text(
                          'Explanation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.eLearningBtnColor1,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Explanation content (HTML)
                        explanation.isEmpty
                            ? Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No explanation available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                          fontFamily: 'Urbanist',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Html(
                                data: explanation,
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
                      ],
                    ),
                  ),
                ),
              ),

              // Fixed "Continue" button at bottom
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
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eLearningBtnColor1,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue',
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
    );
  }
}
