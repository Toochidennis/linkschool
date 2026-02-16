import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/explore/courses/create_user_profile_screen.dart';
import 'package:linkschool/modules/providers/explore/courses/course_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/model/explore/courses/lesson_detail_model.dart';
import '../../providers/explore/lesson_detail_provider.dart';
import 'package:video_player/video_player.dart';
import 'quiz_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/explore/quiz_result_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reading_lesson_screen.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform, Directory, File;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:convert';
import '../../providers/explore/assignment_submission_provider.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../model/cbt_user_model.dart';
import '../../providers/cbt_user_provider.dart';
import 'package:linkschool/modules/model/explore/courses/lesson_model.dart';

// Top-level function for compute isolate - encodes bytes to base64
String _encodeToBase64(Uint8List bytes) {
  return base64Encode(bytes);
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashLength = 6,
    this.gapLength = 6,
    this.radius = 12,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        dashedPath.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next + gapLength;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.radius != radius;
  }
}

class CourseDetailScreen extends StatefulWidget {
  final String courseTitle;
  final String courseName;
  final String courseDescription;
  final String provider;
  final String? videoUrl;
  final String? assignmentUrl;
  final String? assignmentDescription;
  final String? materialUrl;
  final String? zoomUrl;
  final String? recordedUrl;
  final String? classDate;
  final int? profileId;
  final int? lessonId;
  final String cohortId;
  final List<LessonModel>? lessons;
  final int? lessonIndex;
  final void Function(int lessonId)? onLessonCompleted;


  const CourseDetailScreen({
    super.key,
    required this.courseTitle,
    required this.courseName,
    required this.courseDescription,
    required this.provider,
    this.videoUrl,
    this.assignmentUrl,
    this.assignmentDescription,
    this.materialUrl,
    this.zoomUrl,
    this.recordedUrl,
    this.classDate,
    required this.cohortId,
    this.profileId,
    this.lessonId,
    this.lessons,
    this.lessonIndex,
    this.onLessonCompleted,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin,WidgetsBindingObserver  {
      static const platform = MethodChannel('com.linkskool.app/downloads');
  late final LessonDetailProvider _lessonDetailProvider;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isVideoInitialized = false;
  bool _isYoutubeVideo = false;
  bool _showControls = true;
  String? _videoError;
  int _selectedVideoIndex = 0;
  late TabController _tabController;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;
  bool _isFullscreen = false;
  bool _isDescriptionExpanded = false;
  String? emailError;
  String? pdfError;
  late final Stream<int> _countdownStream;
  // Quiz state variables
  int _quizScore = 0;
  bool _quizTaken = false;
  String? _pendingUsername;
  String? _pendingAssignmentFileName;
  String? _pendingAssignmentFileBase64;
  // Lesson data fields
  String? courseTitle;
  String? courseDescription;
  String? videoUrl;
  String? assignmentUrl;
  String? assignmentDescription;
  String? materialUrl;
  String? certificateUrl;
  Submission? _submission;
  String? zoomUrl;
  String? recordedUrl;
  String? classDate;
  String? assignmentDueDate;
  String? liveSessionStartTime;
  String? liveSessionEndTime;
  bool _dataLoaded = false;
  bool _hasVideo = false;
  bool _requestSent = false;
  CbtUserProfile? _activeProfile;
  bool _loadedActiveProfile = false;
  bool _lessonHasQuiz = false;
  bool _lessonHasAssignment = false;
  bool _isFinalLesson = false;
  bool _isMinor = false;
  bool _isNavigatingAway = false;
bool _shouldShowAdOnResume = false;
  String? _lastMetaSignature;

  AppOpenAd? _appOpenAd;
bool _isAppOpenAdLoaded = false;

DateTime? _lastPauseTime;

String? _assignmentSubmissionType; // Store the submission type
final TextEditingController _linkController = TextEditingController();
final TextEditingController _textController = TextEditingController();
  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  String get _displayTitle =>
      courseTitle?.isNotEmpty == true ? courseTitle! : widget.courseTitle;
  String get _displayDescription => courseDescription?.isNotEmpty == true
      ? courseDescription!
      : widget.courseDescription;
  String? get _effectiveVideoUrl =>
      videoUrl?.isNotEmpty == true ? videoUrl : widget.videoUrl;
  String? get _effectiveMaterialUrl =>
      materialUrl?.isNotEmpty == true ? materialUrl : widget.materialUrl;
  bool get _shouldShowCertificate =>
      _isFinalLesson && certificateUrl?.isNotEmpty == true;
// Check if user has submitted assignment
bool get _hasSubmittedAssignment {
  final submission = _submission;
  if (submission == null) return false;

  final assignment = submission.assignment;
  final hasAssignment = assignment != null &&
      (assignment is String
          ? assignment.trim().isNotEmpty
          : assignment is List
              ? assignment.isNotEmpty
              : assignment is Map
                  ? assignment.isNotEmpty
                  : true);
  final hasLink = submission.linkUrl?.trim().isNotEmpty == true;
  final hasText = submission.textContent?.trim().isNotEmpty == true;

  return hasAssignment || hasLink || hasText;
}

// Get the submitted assignment URL
String? get _submittedAssignmentUrl {
  final submission = _submission;
  if (submission == null) return null;
  final assignmentFile = submission.assignmentFile;
  if (assignmentFile == null) return null;
  final value = assignmentFile.toString().trim();
  return value.isEmpty ? null : value;
}
  String? get _effectiveSessionStart =>
      liveSessionStartTime?.isNotEmpty == true ? liveSessionStartTime : null;
  String? get _effectiveSessionEnd =>
      liveSessionEndTime?.isNotEmpty == true ? liveSessionEndTime : null;
  String? get _effectiveAssignmentUrl =>
      assignmentUrl?.isNotEmpty == true ? assignmentUrl : widget.assignmentUrl;
  String? get _effectiveAssignmentDescription =>

      assignmentDescription?.isNotEmpty == true
          ? assignmentDescription
          : widget.assignmentDescription;

  String? get _effectiveZoomUrl =>
      zoomUrl?.isNotEmpty == true ? zoomUrl : widget.zoomUrl;
  String? get _effectiveRecordedUrl =>
      recordedUrl?.isNotEmpty == true ? recordedUrl : widget.recordedUrl;
  String? get _effectiveClassDate =>
      classDate?.isNotEmpty == true ? classDate : widget.classDate;
  String _formattedAssignmentDeadline() {
    final raw = assignmentDueDate;
    if (raw == null || raw.trim().isEmpty) {
      return 'Not set';
    }
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) {
      return raw;
    }
    return DateFormat('E, dd MMM yyyy (hh:mm a)').format(parsed);
  }

  DateTime? _assignmentDeadlineDate() {
    final raw = assignmentDueDate;
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw.trim());
  }

  bool _isAssignmentPastDue() {
    final deadline = _assignmentDeadlineDate();
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline);
  }

  String _assignmentCountdownText() {
    final deadline = _assignmentDeadlineDate();
    if (deadline == null) return 'No deadline set';

    final now = DateTime.now();
    if (now.isAfter(deadline)) return 'Deadline passed';

    final diff = deadline.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m ${seconds}s ';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${minutes}m ${seconds}s ';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ${seconds}s ';
    }
    return '${seconds}s ';
  }

  Widget _buildCountdownItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF0F172A)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
       bool _isInitializing = false;
       bool _hasAppliedLessonData = false;

       RewardedAd? _rewardedAd;
bool _isRewardedAdLoaded = false;
  bool _quizUnlocked = false;
  String? _quizRetryMessage;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }


 

  // Assignment submission state
  bool _isAssignmentSubmitted = false;
  String? _lastInitializedUrl;
  final bool _isSubmittingAssignment = false;

  final List<Map<String, dynamic>> _courseVideos = [
   
    {
      'title': 'Final Project and Next Steps',
      'duration': '16:50',
      'type': 'video',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      'isIntro': false,
      'isCompleted': false,
      'description':
          'Complete the final project and discover where to go next.',
    },
  ];

  @override
void initState() {
  super.initState();
  _lessonDetailProvider = LessonDetailProvider();
  _tabController = TabController(length: 3, vsync: this);
  _countdownStream = Stream<int>.periodic(
    const Duration(seconds: 1),
    (i) => i,
  ).asBroadcastStream();
  _loadSubmissionStatus();
  _loadActiveProfile();

  WidgetsBinding.instance.addObserver(this);


  
  // Only seed widget data, don't initialize video yet
  if (widget.courseTitle.isNotEmpty ||
      widget.courseDescription.isNotEmpty ||
      widget.videoUrl?.isNotEmpty == true) {
    _seedContentFromWidget();
  }
  
  if (_courseVideos.isNotEmpty) {
    _loadCompletionStatus();
    _loadPendingAssignmentData();
    _loadQuizData();
  }
  
  // Check if we have video URL from widget
  final initialVideoUrl = _effectiveVideoUrl;
  if (initialVideoUrl != null && initialVideoUrl.isNotEmpty) {
    _hasVideo = true;
  }
  
  // DON'T initialize video here - wait for lesson data
  print('initState completed, waiting for lesson data...');
  
  // Initialize interstitial ad
  _loadInterstitialAd();
   Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      _loadAppOpenAd();
    }
  });
}


@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  
  if (state == AppLifecycleState.paused) {
    // Only mark for ad if not navigating away
    if (!_isNavigatingAway) {
      _lastPauseTime = DateTime.now();
      _shouldShowAdOnResume = true;
      print('App paused (real background) at: $_lastPauseTime');
    } else {
      print('App paused due to navigation, skipping ad flag');
    }
  } else if (state == AppLifecycleState.resumed) {
    // Only show ad if it was a real background event
    if (_shouldShowAdOnResume) {
      print('App resumed from real background, attempting to show App Open Ad');
      _showAppOpenAd();
      _shouldShowAdOnResume = false;
    } else {
      print('App resumed from navigation, skipping ad');
    }
    
    // Reset navigation flag
    _isNavigatingAway = false;
  }
}

  void _seedContentFromWidget() {
    final initialUrl = widget.videoUrl ?? '';
    _courseVideos
      ..clear()
      ..add({
        'title': widget.courseTitle,
        'description': widget.courseDescription,
        'url': initialUrl,
        'type': initialUrl.isNotEmpty ? 'video' : 'reading',
        'duration': '',
        'content': widget.courseDescription,
        'isCompleted': false,
      });
  }


  // calculate age range for ads 
  

  int? _computeAgeFromBirthDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    DateTime? dob;
    try {
      dob = DateTime.tryParse(trimmed);
    } catch (_) {
      dob = null;
    }
    if (dob == null) {
      final formats = [
        DateFormat('yyyy-MM-dd'),
        DateFormat('dd/MM/yyyy'),
        DateFormat('MM/dd/yyyy'),
      ];
      for (final f in formats) {
        try {
          dob = f.parseStrict(trimmed);
          break;
        } catch (_) {}
      }
    }
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    final hadBirthdayThisYear =
        (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hadBirthdayThisYear) age -= 1;
    print('Computed age: $age from birth date: $raw');
    return age < 0 ? null : age;
  }

  void _applyAgeGate(String? birthDate) {
    final age = _computeAgeFromBirthDate(birthDate);
    final isMinor = age != null && age < 13;
    print('Applying age gate. Birth date: $birthDate, Computed age: $age, Is minor: $isMinor');
    if (_isMinor == isMinor) return;
    setState(() {
      _isMinor = isMinor;
      // if (_isMinor) {
      //   _interstitialAd?.dispose();
      //   _interstitialAd = null;
      //   _isInterstitialAdLoaded = false;
      // }
    });
  }

  void _loadAppOpenAd() {
  // Don't load if user is a minor
  // if (_isMinor == true) return;
  
  final AdRequest request;
  if (_isMinor == true) {
    request = AdRequest(nonPersonalizedAds: true);
    print('AppOpenAd: Loading with nonPersonalizedAds for minor');
  } else {
    request = AdRequest();
  }

  AppOpenAd.load(
    adUnitId: EnvConfig.programAdsOpenApiKey,
    request: request,
  
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (AppOpenAd ad) {
        _appOpenAd = ad;
        if (mounted) {
          setState(() {
            _isAppOpenAdLoaded = true;
          });
        }
        print('App Open Ad loaded successfully');
      },
      onAdFailedToLoad: (LoadAdError error) {
        print('App Open Ad failed to load: $error');
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
  // Check if enough time has passed since last ad
  // if (_lastAppOpenAdTime != null) {
  //   final timeSinceLastAd = DateTime.now().difference(_lastAppOpenAdTime!);
  //   if (timeSinceLastAd < _minTimeBetweenAds) {
  //     print('App Open Ad: Cooling period active, ${_minTimeBetweenAds.inHours - timeSinceLastAd.inHours} hours remaining');
  //     return;
  //   }
  // }

  

  if (_isAppOpenAdLoaded && _appOpenAd != null) {
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        print('App Open Ad showed');
      },
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        print('App Open Ad dismissed');
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdLoaded = false;
    
        // Reload for next time
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        print('App Open Ad failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        // Reload for next time
        _loadAppOpenAd();
      },
    );
    
    _appOpenAd!.show();
  } else {
    print('App Open Ad not ready to show');
  }
}

void _loadRewardedAd() {
  final AdRequest request;
  if (_isMinor == true) {
    request = AdRequest(nonPersonalizedAds: true);
    print('RewardedAd: Loading with nonPersonalizedAds for minor');
  } else {
    request = AdRequest();
  }

  RewardedAd.load(
    adUnitId: EnvConfig.programRewardsAdsKey,
    request: request,
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (RewardedAd ad) {
        _rewardedAd = ad;
        if (mounted) {
          setState(() {
            _isRewardedAdLoaded = true;
          });
        }
        print('Rewarded Ad loaded successfully');
      },
      onAdFailedToLoad: (LoadAdError error) {
        print('Rewarded Ad failed to load: $error');
        if (mounted) {
          setState(() {
            _isRewardedAdLoaded = false;
          });
        }
      },
    ),
  );
}

void _showRewardedAdAndUnlockQuiz() {
  if (_isRewardedAdLoaded && _rewardedAd != null) {
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        print('Rewarded ad showed');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        // Reload for next time
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        // Reload for next time
        _loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
        // Unlock the quiz
        setState(() {
          _quizUnlocked = true;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz unlocked! You can now retake the quiz.'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 3),
          ),
        );
        
        // Navigate to quiz after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          _navigateToQuiz();
        });
      },
    );
  } else {
    // Ad not loaded, show error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ad not ready yet. Please try again.'),
        backgroundColor: Colors.orange,
      ),
    );
    // Try to load the ad
    _loadRewardedAd();
  }
}

void _showUnlockQuizDialog() {
  int retrySeconds = 0;
  String? retryMessage;
  Timer? retryTimer;

  void startRetryCountdown(StateSetter setDialogState) {
    retryTimer?.cancel();
    retrySeconds = 10;
    retryMessage = 'Ad not ready yet. Please retry in $retrySeconds seconds.';
    setDialogState(() {});

    retryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (retrySeconds <= 1) {
        timer.cancel();
        retrySeconds = 0;
        retryMessage = null;
        setDialogState(() {});
        return;
      }
      retrySeconds -= 1;
      retryMessage = 'Ad not ready yet. Please retry in $retrySeconds seconds.';
      setDialogState(() {});
    });
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.99,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black87),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        tooltip: 'Close',
                      ),
                    ),
                    // Lock Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA500).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 40,
                        color: Color(0xFFFFA500),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Title
                    const Text(
                      'Quiz Locked',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Message
                    const Text(
                      'This Feature is locked,please watch a short ad to unlock this feature ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Info box
                    if (retryMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFB74D).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFFF9800),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              retryMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),],
                    
                      // const SizedBox(height: 12),
                      // Text(
                      //   retryMessage!,
                      //   textAlign: TextAlign.center,
                      //   style: const TextStyle(
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.w600,
                      //     color: Color(0xFFEF5350),
                      //   ),
                      // ),
                    
                    const SizedBox(height: 24),
                    
                    // Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: retrySeconds > 0
                            ? null
                            : () {
                                if (!_isRewardedAdLoaded || _rewardedAd == null) {
                                  setState(() {
                                    _quizRetryMessage =
                                        'Ad not ready yet. Please retry taking the quiz.';
                                  });
                                  startRetryCountdown(setDialogState);
                                  _loadRewardedAd();
                                  return;
                                }

                                setState(() {
                                  _quizRetryMessage = null;
                                });
                                Navigator.pop(context);
                                _showRewardedAdAndUnlockQuiz();
                              },
                        icon: const Icon(Icons.play_circle_outline, size: 20),
                        label: Text(
                          retrySeconds > 0 ? 'Retry in ${retrySeconds}s' : 'Watch Ad',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  ).then((_) {
    retryTimer?.cancel();
  });
}

Future<void> _navigateToQuiz() async {
  // Mark that we're navigating away
  setState(() {
    _isNavigatingAway = true;
  });
  
  final cbtUserProvider = Provider.of<CbtUserProvider>(context, listen: false);
  final user = cbtUserProvider.currentUser;
  final activeProfile = _activeProfile ??
      user?.profiles.firstWhere(
        (p) => true,
        orElse: () => CbtUserProfile(
          id: 0,
          firstName: 'User',
          lastName: '',
          avatar: null,
        ),
      );
  final userName = activeProfile != null ? _profileName(activeProfile) : 'User';
  final userEmail = user?.email ?? '';
  final userPhone = user?.phone ?? '';
  final profileId = activeProfile?.id?.toString() ??
      widget.profileId?.toString() ??
      '0';
  final currentVideo = _courseVideos[_selectedVideoIndex];
  final videoTitle = currentVideo['title'] as String;

  final result = await Navigator.push<int>(
    context,
    MaterialPageRoute(
      builder: (context) => QuizScreen(
        courseTitle: widget.courseTitle,
        lessonTitle: videoTitle,
        lessonId: widget.lessonId!,
        cohortId: widget.cohortId,
        profileId: profileId,
        userName: userName,
        userEmail: userEmail,
        userPhone: userPhone,
      ),
    ),
  );

  // Reset navigation flag when returning
  setState(() {
    _isNavigatingAway = false;
  });

  // Reload quiz data when returning from quiz
  await _loadQuizData();

  // Reset unlock status
  setState(() {
    _quizUnlocked = false;
  });
}

  

  void _loadInterstitialAd() {
    
    // if user is minor add non-personalized ads
    final AdRequest request;
     if (_isMinor == true) {
    request = AdRequest(nonPersonalizedAds: true);
     print('AdRequest created with nonPersonalizedAds: ${_isMinor}');

  } else {

    request = AdRequest();
   
  }
  
  
 
  
 
   
    InterstitialAd.load(
      adUnitId: EnvConfig.programInterstitialAdsApiKey,
      request:request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          if (mounted) {
            setState(() {
              _isInterstitialAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (mounted) {
            setState(() {
              _isInterstitialAdLoaded = false;
            });
          }
        },
      ),
    );
  }

  void _showInterstitialAdAndNavigateBack() {
    // if (_isMinor) {
    //   Navigator.pop(context);
    //   return;
    // }
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          // Navigate back after ad is dismissed
          if (mounted) {
            Navigator.pop(context);
          }
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          // Navigate back if ad fails to show
          if (mounted) {
            Navigator.pop(context);
          }
        },
      );
      _interstitialAd!.show();
      // Reload for next back action
      _loadInterstitialAd();
    } else {
      // If ad is not loaded, just navigate back
      Navigator.pop(context);
    }
  }

  bool get _hasLessonNavigation =>
      widget.lessons != null && widget.lessonIndex != null;

  void _navigateToLesson(int targetIndex) {
  if (!_hasLessonNavigation) return;
  final lessons = widget.lessons!;
  if (targetIndex < 0 || targetIndex >= lessons.length) return;
  final lesson = lessons[targetIndex];
  
  // Mark that we're navigating away
  setState(() {
    _isNavigatingAway = true;
  });
  
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => CourseDetailScreen(
        courseTitle: lesson.title,
        courseName: widget.courseName,
        courseDescription: lesson.description,
        provider: widget.provider,
        videoUrl: lesson.videoUrl,
        assignmentUrl: null,
        assignmentDescription: null,
        materialUrl: null,
        zoomUrl: null,
        recordedUrl: null,
        classDate: null,
        cohortId: widget.cohortId,
        profileId: widget.profileId,
        lessonId: lesson.id,
        lessons: lessons,
        lessonIndex: targetIndex,
        onLessonCompleted: widget.onLessonCompleted,
      ),
    ),
  );
}

  void _completeLesson() {
    final lessonId = widget.lessonId;
    if (lessonId != null) {
      widget.onLessonCompleted?.call(lessonId);
    }
    if (_hasLessonNavigation &&
        widget.lessonIndex! < (widget.lessons!.length - 1)) {
      _navigateToLesson(widget.lessonIndex! + 1);
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson marked as complete')),
      );
    }
  }

  Widget _buildLessonNavigationBar() {
    final hasNav = _hasLessonNavigation;
    final currentIndex = widget.lessonIndex ?? 0;
    final hasPrev = hasNav && currentIndex > 0;
    final hasNext = hasNav && currentIndex < (widget.lessons!.length - 1);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: hasPrev ? () => _navigateToLesson(currentIndex - 1) : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _completeLesson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA500),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(hasNext ? 'Complete & Next' : 'Complete'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: hasNext ? () => _navigateToLesson(currentIndex + 1) : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyLessonData(Lesson lesson, {Submission? submission}) {
  final resolvedVideoUrl =
      lesson.videoUrl.isNotEmpty ? lesson.videoUrl : lesson.recordedVideoUrl;
  
  print('=== APPLYING LESSON DATA ===');
  print('Video URL: $resolvedVideoUrl');
  print('Already applied: $_hasAppliedLessonData');
  print('Last initialized URL: $_lastInitializedUrl');
  
  // Prevent applying the same lesson data twice
  if (_hasAppliedLessonData && _lastInitializedUrl == resolvedVideoUrl) {
    print('Same lesson already applied, skipping...');
    return;
  }
  
  setState(() {
    _dataLoaded = true;
    _hasAppliedLessonData = true;
    courseTitle = lesson.title;
    courseDescription = lesson.description;
    videoUrl = resolvedVideoUrl;
    assignmentUrl = lesson.assignmentUrl;
    assignmentDescription = lesson.assignmentInstructions;
    materialUrl = lesson.materialUrl;
    certificateUrl = lesson.certificateUrl;
    assignmentDueDate = lesson.assignmentDueDate;
    _submission = submission;
    _assignmentSubmissionType = lesson.assignmentSubmissionType; // ADD THIS LINE
    zoomUrl = lesson.liveSessionInfo?.url?.isNotEmpty == true
        ? lesson.liveSessionInfo!.url
        : widget.zoomUrl;
    recordedUrl = lesson.recordedVideoUrl;
    classDate = lesson.lessonDate;
    liveSessionStartTime = lesson.liveSessionInfo?.startTime;
    liveSessionEndTime = lesson.liveSessionInfo?.endTime;
    _hasVideo = resolvedVideoUrl.isNotEmpty;
    _lessonHasQuiz = lesson.hasQuiz;
    _lessonHasAssignment = (lesson.assignmentUrl?.isNotEmpty ?? false);
    _isFinalLesson = lesson.isFinalLesson;
    _courseVideos
      ..clear()
      ..add({
        'title': lesson.title,
        'description': lesson.description,
        'url': resolvedVideoUrl,
        'type': _hasVideo ? 'video' : 'reading',
        'duration': '',
        'content': lesson.description,
        'isCompleted': false,
      });
    _selectedVideoIndex = 0;
    _lastMetaSignature = _buildLessonMetaSignature(lesson, submission);
    
    // Pre-fill controllers if submission exists
    if (submission != null) {
      if (submission.linkUrl != null) {
        _linkController.text = submission.linkUrl!;
      }
      if (submission.textContent != null) {
        _textController.text = submission.textContent!;
      }
    }
  });

  // NOW initialize video after lesson data is applied
  if (_hasVideo && resolvedVideoUrl.isNotEmpty) {
    print('Lesson data applied, now initializing video...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitializing) {
        _initializeVideo(resolvedVideoUrl);
      }
    });
  }
  
  _loadCompletionStatus();
  _loadPendingAssignmentData();
  _loadQuizData();
}


  Future<void> _loadCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < _courseVideos.length; i++) {
        final key =
            '${widget.courseTitle}_${_courseVideos[i]['title']}_completed';
        _courseVideos[i]['isCompleted'] = prefs.getBool(key) ?? false;
      }
    });
  }

  Future<void> _saveCompletionStatus(int index, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        '${widget.courseTitle}_${_courseVideos[index]['title']}_completed';
    await prefs.setBool(key, isCompleted);
    setState(() {
      _courseVideos[index]['isCompleted'] = isCompleted;
    });
  }

  void _goToPreviousVideo() {
    if (_selectedVideoIndex > 0) {
      _navigateToContent(_selectedVideoIndex - 1);
    }
  }

  void _goToNextVideo() {
    if (_selectedVideoIndex < _courseVideos.length - 1) {
      _navigateToContent(_selectedVideoIndex + 1);
    }
  }

  Future<void> _navigateToContent(int index) async {
    final content = _courseVideos[index];
    final contentType = content['type'] as String;

    if (contentType == 'reading') {
      // Navigate to reading screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadingLessonScreen(
            lessonTitle: content['title'] as String,
            lessonContent: content['content'] as String,
            courseTitle: widget.courseTitle,
            duration: content['duration'] as String,
            currentIndex: index,
            courseContent: _courseVideos,
          ),
        ),
      );
      // Reload completion status after returning from reading
      await _loadCompletionStatus();
    } else {
      // Play video
      _playVideo(index);
    }
  }

  void _toggleCompletion() {
    final currentStatus =
        _courseVideos[_selectedVideoIndex]['isCompleted'] as bool;
    _saveCompletionStatus(_selectedVideoIndex, !currentStatus);
  }

  Future<void> _loadQuizData() async {
    final currentVideo = _courseVideos[_selectedVideoIndex];
    final videoTitle = currentVideo['title'] as String;

    final quizTaken = await QuizResultService.hasQuizBeenTaken(
      courseTitle: widget.courseTitle,
      lessonTitle: videoTitle,
    );

    final quizScore = await QuizResultService.getQuizScore(
      courseTitle: widget.courseTitle,
      lessonTitle: videoTitle,
    );

    setState(() {
      _quizScore = quizScore;
      _quizTaken = quizTaken;
    });
  }

  Future<void> _loadSubmissionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${widget.courseTitle}_assignment_submitted';
      final isSubmitted = prefs.getBool(key) ?? false;

      setState(() {
        _isAssignmentSubmitted = isSubmitted;
      });
    } catch (e) {
      print('Error loading submission status: $e');
    }
  }

  Future<void> _saveSubmissionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${widget.courseTitle}_assignment_submitted';
      await prefs.setBool(key, true);

      setState(() {
        _isAssignmentSubmitted = true;
      });
    } catch (e) {
      print('Error saving submission status: $e');
    }
  }

  Future<void> _loadPendingAssignmentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVideo = _courseVideos[_selectedVideoIndex];
      final videoTitle = currentVideo['title'] as String;
      final key = '${widget.courseTitle}_${videoTitle}_pending';

      setState(() {
        _pendingUsername = prefs.getString('${key}_username');
        _pendingAssignmentFileName = prefs.getString('${key}_assignment_name');
        _pendingAssignmentFileBase64 =
            prefs.getString('${key}_assignment_base64');
      });
    } catch (e) {
      debugPrint('Error loading pending assignment data: $e');
    }
  }

  Future<void> _savePendingAssignmentData(String username,
      String? assignmentFileName, String? assignmentBase64) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVideo = _courseVideos[_selectedVideoIndex];
      final videoTitle = currentVideo['title'] as String;
      final key = '${widget.courseTitle}_${videoTitle}_pending';

      await prefs.setString('${key}_username', username);
      if (assignmentFileName != null) {
        await prefs.setString('${key}_assignment_name', assignmentFileName);
      }
      if (assignmentBase64 != null) {
        await prefs.setString('${key}_assignment_base64', assignmentBase64);
      }

      setState(() {
        _pendingUsername = username;
        _pendingAssignmentFileName = assignmentFileName;
        _pendingAssignmentFileBase64 = assignmentBase64;
      });
    } catch (e) {
      debugPrint('Error saving pending assignment data: $e');
    }
  }

  Future<void> _clearPendingAssignmentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVideo = _courseVideos[_selectedVideoIndex];
      final videoTitle = currentVideo['title'] as String;
      final key = '${widget.courseTitle}_${videoTitle}_pending';

      await prefs.remove('${key}_username');
      await prefs.remove('${key}_assignment_name');
      await prefs.remove('${key}_assignment_base64');

      setState(() {
        _pendingUsername = null;
        _pendingAssignmentFileName = null;
        _pendingAssignmentFileBase64 = null;
      });
    } catch (e) {
      debugPrint('Error clearing pending assignment data: $e');
    }
  }

  Future<void> _saveActiveProfileId(int? id, {String? birthDate}) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setInt('active_profile_id', id);
      if (birthDate != null) {
        await prefs.setString('active_profile_dob', birthDate);
      } else {
        await prefs.remove('active_profile_dob');
      }
    } else {
      await prefs.remove('active_profile_id');
      await prefs.remove('active_profile_dob');
      // Clear provider persisted values as well
      if (mounted) {
        Provider.of<ExploreCourseProvider>(context, listen: false).clearPersistedProfile();
      }
    }
  }

  Future<int?> _loadActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('active_profile_id');
  }

  Future<void> _loadActiveProfile() async {
    if (_loadedActiveProfile) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProfileId = prefs.getInt('active_profile_id');
      if (savedProfileId != null) {
        final cbtUserProvider = Provider.of<CbtUserProvider>(context, listen: false);
        final profiles = cbtUserProvider.currentUser?.profiles ?? [];
        if (profiles.isNotEmpty) {
          final profile = profiles.firstWhere(
            (p) => p.id == savedProfileId,
            orElse: () => profiles.first,
          );
          setState(() {
            _activeProfile = profile;
          });
          _applyAgeGate(profile.birthDate);
        }
      }
      if (_activeProfile == null) {
        final dob = prefs.getString('active_profile_dob');
        _applyAgeGate(dob);
      }
      setState(() => _loadedActiveProfile = true);
    } catch (e) {
      print('Error loading active profile: $e');
    }
  }

  String _buildLessonMetaSignature(Lesson lesson, Submission? submission) {
    return [
      lesson.title,
      lesson.description ?? '',
      lesson.assignmentUrl ?? '',
      lesson.assignmentInstructions,
      lesson.assignmentDueDate ?? '',
      lesson.assignmentSubmissionType ?? '',
      lesson.materialUrl,
      lesson.certificateUrl ?? '',
      lesson.lessonDate,
      lesson.recordedVideoUrl,
      lesson.liveSessionInfo?.url ?? '',
      lesson.liveSessionInfo?.startTime ?? '',
      lesson.liveSessionInfo?.endTime ?? '',
      lesson.hasQuiz.toString(),
      lesson.isFinalLesson.toString(),
      submission?.submittedAt ?? '',
      submission?.assignment?.toString() ?? '',
      submission?.linkUrl ?? '',
      submission?.textContent ?? '',
      submission?.assignedScore?.toString() ?? '',
    ].join('|');
  }

  void _applyLessonMeta(Lesson lesson, {Submission? submission}) {
    if (!mounted) return;
    setState(() {
      courseTitle = lesson.title;
      courseDescription = lesson.description;
      assignmentUrl = lesson.assignmentUrl;
      assignmentDescription = lesson.assignmentInstructions;
      materialUrl = lesson.materialUrl;
      certificateUrl = lesson.certificateUrl;
      assignmentDueDate = lesson.assignmentDueDate;
      _assignmentSubmissionType = lesson.assignmentSubmissionType;
      zoomUrl = lesson.liveSessionInfo?.url?.isNotEmpty == true
          ? lesson.liveSessionInfo!.url
          : widget.zoomUrl;
      recordedUrl = lesson.recordedVideoUrl;
      classDate = lesson.lessonDate;
      liveSessionStartTime = lesson.liveSessionInfo?.startTime;
      liveSessionEndTime = lesson.liveSessionInfo?.endTime;
      _lessonHasQuiz = lesson.hasQuiz;
      _lessonHasAssignment = (lesson.assignmentUrl?.isNotEmpty ?? false);
      _isFinalLesson = lesson.isFinalLesson;
      _submission = submission;
      _lastMetaSignature = _buildLessonMetaSignature(lesson, submission);
    });
  }

  Future<void> _silentRefreshLessonDetail() async {
    if (widget.lessonId == null || widget.profileId == null) return;
    final success = await _lessonDetailProvider.fetchLessonDetail(
      lessonId: widget.lessonId!,
      profileId: widget.profileId!,
    );
    if (!success) return;
    final lesson = _lessonDetailProvider.lessonDetailData?.lesson;
    final submission = _lessonDetailProvider.lessonDetailData?.submission;
    if (lesson != null && mounted) {
      _applyLessonMeta(lesson, submission: submission);
    }
  }

  String _profileName(CbtUserProfile profile) {
    final first = profile.firstName?.trim() ?? '';
    final last = profile.lastName?.trim() ?? '';
    final name = "$first $last".trim();
    if (name.isNotEmpty) return name;
    if (profile.id != null) return "Profile ${profile.id}";
   
    return 'Profile';
  }

  String _profileInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Widget _avatarWidget({String? imageUrl, required String name, double radius = 20}) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    final initials = _profileInitials(name);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.black,
          fontSize: radius * 0.6,
        ),
      ),
    );
  }

  void _showAccountSwitcherDialog(BuildContext context, dynamic user, {Function(CbtUserProfile)? onProfileSelected}) {
    final profiles = (user?.profiles as List<CbtUserProfile>?) ?? <CbtUserProfile>[];
    final activeProfileId = _activeProfile?.id;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Switch Profile',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                if (profiles.isNotEmpty)
                  Column(
                    children: profiles.map((profile) {
                      final name = _profileName(profile);
                      final subtitle = user.email.toString();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildAccountItem(
                          name: name,
                          email: subtitle,
                          imageUrl: profile.avatar,
                          isActive: activeProfileId == profile.id,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _activeProfile = profile;
                            });
                            _saveActiveProfileId(profile.id, birthDate: profile.birthDate);
                            _applyAgeGate(profile.birthDate);
                            onProfileSelected?.call(profile);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                // Add New Profile Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Navigate to create profile screen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateUserProfileScreen(
                            userId: user.id.toString(),

                          ),
                        ),
                      );
                      // If profile was created successfully, refresh user data
                      if (result == true && mounted) {
                        // Refresh user list if needed and select the newly created profile
                        final updatedUser = Provider.of<CbtUserProvider>(context, listen: false).currentUser;
                        final profiles = (updatedUser?.profiles ?? []);
                        setState(() {
                          if (profiles.isNotEmpty) {
                            _activeProfile = profiles.last;
                            _saveActiveProfileId(_activeProfile?.id, birthDate: _activeProfile?.birthDate);
                            _applyAgeGate(_activeProfile?.birthDate);
                            onProfileSelected?.call(_activeProfile!);
                          } else {
                            _activeProfile = null;
                            _saveActiveProfileId(null);
                            _applyAgeGate(null);
                          }
                        });
                      }
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add New Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.black87,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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

  Widget _buildAccountItem({
    required String name,
    required String email,
    String? imageUrl,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey.shade100 : Colors.transparent,
          border: isActive ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Row(
          children: [
            _avatarWidget(imageUrl: imageUrl, name: name, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _prepareAndPrintPayload({
    required int score,
    required String? assignmentFileName,
    required String? assignmentBase64,
    required String username,
    required TextEditingController emailController,
    required TextEditingController phoneController,
  }) {
    final payload = {
      'quiz_score': score.toString(),
      'assignment': assignmentFileName != null && assignmentBase64 != null
          ? {
              'file_name': assignmentFileName,
              'file': assignmentBase64,
              "type": assignmentFileName.split('.').last,
              "old_file_name": "",
            }
          : 'No file uploaded',
      "email": emailController.text,
      "phone": phoneController.text,
      'name': username,
      'course_title': _displayTitle,
      'lesson_title': _courseVideos[_selectedVideoIndex]['title'],
      'timestamp': DateTime.now().toIso8601String(),
    };

    final jsonPayload = jsonEncode(payload);

    // Show success message to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assignment submitted successfully!\nScore: $score%'),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Extract YouTube video ID from various YouTube URL formats
  String? extractYouTubeId(String url) {
    final sanitized = url.replaceAll(r'\/', '/').trim();
    final converted = YoutubePlayer.convertUrlToId(sanitized);
    if (converted != null && converted.isNotEmpty) {
      return converted;
    }

    final uri = Uri.tryParse(sanitized);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    }

    if (uri.host.contains('youtube.com') || uri.host.contains('m.youtube.com')) {
      final vParam = uri.queryParameters['v'];
      if (vParam != null && vParam.isNotEmpty) return vParam;
      final segments = uri.pathSegments;
      final idx = segments.indexWhere(
        (s) => s == 'shorts' || s == 'embed' || s == 'live' || s == 'v',
      );
      if (idx != -1 && segments.length > idx + 1) {
        return segments[idx + 1];
      }
    }

    return null;
  }

  /// Check if URL is a YouTube video
/// Check if URL is a YouTube video
bool isYouTubeUrl(String url) {
  if (url.isEmpty) return false;
  
  final sanitized = url.replaceAll(r'\/', '/').trim().toLowerCase();
  
  // Check for YouTube domain patterns
  if (sanitized.contains('youtube.com') || 
      sanitized.contains('youtu.be') ||
      sanitized.contains('m.youtube.com') ||
      sanitized.contains('youtube.com/shorts/') ||
      sanitized.contains('youtube.com/live/') ||
      sanitized.contains('youtube.com/embed/')) {
    return true;
  }
  
  // Check if it's just a YouTube ID (11 characters)
  if (sanitized.length == 11 && 
      RegExp(r'^[a-za-z0-9_-]{11}$').hasMatch(sanitized)) {
    return true;
  }
  
  return false;
}

  /// Determine the live session status based on start/end time and recorded URL.
  /// Priority: Check live session first, then fallback to recorded URL.
Map<String, dynamic> _getZoomStatus() {
  final hasRecordedUrl =
      _effectiveRecordedUrl != null && _effectiveRecordedUrl!.isNotEmpty;
  final hasLiveUrl =
      _effectiveZoomUrl != null && _effectiveZoomUrl!.isNotEmpty;

  // If neither URL exists, return unavailable
  if (!hasRecordedUrl && !hasLiveUrl) {
    return {
      'status': 'unavailable',
      'message': 'No live class or recording available for this lesson.',
      'buttonText': '',
      'url': null,
    };
  }

  // PRIORITY 1: Check zoom URL with date logic FIRST
  if (hasLiveUrl) {
    // If no time provided, assume session is available
    if (_effectiveSessionStart == null || _effectiveSessionStart!.isEmpty) {
      return {
        'status': 'available',
        'message': 'Live session link is available.',
        'buttonText': 'Join Live Class',
        'url': _effectiveZoomUrl,
      };
    }

    try {
      final classDateTime = DateTime.parse(_effectiveSessionStart!);
      final now = DateTime.now();

      final DateTime classEndTime;
      if (_effectiveSessionEnd != null && _effectiveSessionEnd!.isNotEmpty) {
        classEndTime = DateTime.parse(_effectiveSessionEnd!);
      } else {
        // Assuming class duration is 3 hours (fallback)
        classEndTime = classDateTime.add(const Duration(hours: 3));
      }

      // Session hasn't started yet
      if (now.isBefore(classDateTime)) {
        final formatter = DateFormat('EEEE, MMMM d \'at\' h:mm a');
        final dateStr = formatter.format(classDateTime);
        
        // Calculate time until class starts
        final difference = classDateTime.difference(now);
        String timeUntil = '';
        if (difference.inDays > 0) {
          timeUntil = ' (in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'})';
        } else if (difference.inHours > 0) {
          timeUntil = ' (in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'})';
        } else if (difference.inMinutes > 0) {
          timeUntil = ' (in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'})';
        }
        
        return {
          'status': 'scheduled',
          'message': 'Live session scheduled for $dateStr$timeUntil',
          'buttonText': 'Scheduled',
          'url': null,
          'classDate': classDateTime,
        };
      }

      // Session is ongoing
      if (now.isAfter(classDateTime) && now.isBefore(classEndTime)) {
        return {
          'status': 'ongoing',
          'message': 'Live session is in progress! Join now to participate.',
          'buttonText': 'Join Live Class',
          'url': _effectiveZoomUrl,
        };
      }

      // Session has ended - check if recorded video is available
      if (hasRecordedUrl) {
        return {
          'status': 'recorded',
          'message':
              'Live session has ended. Watch the recorded session at your convenience.',
          'buttonText': 'Watch Recorded Class',
          'url': _effectiveRecordedUrl,
        };
      }

      // Session has ended but no recorded video yet
      return {
        'status': 'pending',
        'message':
            'Live session has ended. The recorded session will be available soon. Check back later.',
        'buttonText': 'Recording Pending',
        'url': null,
      };
    } catch (e) {
      debugPrint('Error parsing class date: $e');
      // If time parsing fails but we have a live URL, make it available
      return {
        'status': 'available',
        'message': 'Live session link is available.',
        'buttonText': 'Join Live Class',
        'url': _effectiveZoomUrl,
      };
    }
  }

  // PRIORITY 2: If only recorded URL exists (no live URL), show it
  if (hasRecordedUrl) {
    return {
      'status': 'recorded',
      'message': 'This lesson is available as a recorded class. Watch it anytime.',
      'buttonText': 'Watch Recorded Class',
      'url': _effectiveRecordedUrl,
    };
  }

  // Fallback (should never reach here)
  return {
    'status': 'unavailable',
    'message': 'No content available for this lesson at the moment.',
    'buttonText': '',
    'url': null,
  };
}

  /// Launch URL in browser
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

Future<void> _initializeVideo(String url) async {
  // Guard 1: Prevent multiple simultaneous initializations
  if (_isInitializing) {
    print('Already initializing video, skipping...');
    return;
  }
  
  // Guard 2: Don't re-initialize the same video
  if (_lastInitializedUrl == url && _isVideoInitialized) {
    print('Video already initialized with same URL, skipping...');
    return;
  }
  
  _isInitializing = true;
  
  print('=== DEBUG VIDEO INITIALIZATION ===');
  print('URL: $url');
  print('isYouTubeUrl check: ${isYouTubeUrl(url)}');
  print('extractYouTubeId result: ${extractYouTubeId(url)}');
  
  try {
    // Store old controllers
    final oldYoutubeController = _youtubeController;
    final oldVideoController = _videoController;
    final oldChewieController = _chewieController;
    
    // Clear references FIRST
    if (mounted) {
      setState(() {
        _youtubeController = null;
        _videoController = null;
        _chewieController = null;
        _isVideoInitialized = false;
        _isYoutubeVideo = false;
        _videoError = null;
      });
    }
    
    // Wait for frame to render
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Now dispose old controllers safely
    if (oldYoutubeController != null) {
      try {
        oldYoutubeController.dispose();
        print('Disposed old YouTube controller');
      } catch (e) {
        print('Error disposing YouTube controller: $e');
      }
    }
    if (oldChewieController != null) {
      try {
        oldChewieController.dispose();
        print('Disposed old Chewie controller');
      } catch (e) {
        print('Error disposing Chewie controller: $e');
      }
    }
    if (oldVideoController != null) {
      try {
        await oldVideoController.dispose();
        print('Disposed old video controller');
      } catch (e) {
        print('Error disposing video controller: $e');
      }
    }

    // Wait for disposal to complete
    await Future.delayed(const Duration(milliseconds: 200));

    final sanitized = url.replaceAll(r'\/', '/').trim();
    print('Sanitized URL: $sanitized');
    
    // Check if it's a YouTube video
    if (isYouTubeUrl(sanitized)) {
      print('Detected as YouTube URL');
      await _initializeYouTubePlayer(sanitized);
    } else {
      print('Detected as regular video URL');
      await _initializeDirectVideoPlayer(sanitized);
    }
    
    // Mark URL as initialized
    _lastInitializedUrl = url;
    print('Video initialization completed successfully');
    
  } catch (e) {
    print('Error initializing video: $e');
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
        _isYoutubeVideo = false;
        _videoError = 'Failed to load video: ${e.toString()}';
      });
    }
  } finally {
    _isInitializing = false;
  }
}

Future<void> _initializeYouTubePlayer(String url) async {
  try {
    final videoId = extractYouTubeId(url);
    print('Extracted YouTube ID: $videoId');

    if (videoId == null || videoId.isEmpty) {
      throw Exception('Could not extract YouTube video ID from: $url');
    }

    if (videoId.length != 11) {
      throw Exception('Invalid YouTube video ID length: $videoId');
    }

    // Create new controller
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: false,
      ),
    );

    // Add error listener
    controller.addListener(() {
      if (controller.value.hasError == true) {
        print('YouTube player error: ${controller.value.metaData}');
        if (mounted) {
          setState(() {
            _videoError = 'YouTube error: ${controller.value.metaData}';
          });
        }
      }
    });

    // Set everything in one setState
    if (mounted) {
      setState(() {
        _youtubeController = controller;
        _isYoutubeVideo = true;
        _isVideoInitialized = true;
        _videoError = null;
      });
    }
    
    print('YouTube player initialized successfully');
    
  } catch (e) {
    print('Error initializing YouTube player: $e');
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
        _isYoutubeVideo = false;
        _videoError = 'Failed to initialize YouTube player: $e';
      });
    }
    throw Exception('Failed to initialize YouTube player: $e');
  }
}

Future<void> _initializeDirectVideoPlayer(String url) async {
  try {
    print('Initializing direct video player for URL: $url');
    
    if (url.contains('youtube') || url.contains('youtu.be')) {
      throw Exception('This appears to be a YouTube URL. Please check your YouTube detection logic.');
    }
    
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();
    await _videoController!.pause();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error loading video',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFF6366F1),
        handleColor: const Color(0xFF6366F1),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey.withOpacity(0.5),
      ),
    );

    setState(() {
      _isYoutubeVideo = false;
      _isVideoInitialized = true;
    });
    
    print('Direct video player initialized successfully');
    
  } catch (e) {
    print('Error initializing direct video player: $e');
    throw Exception('Failed to initialize video: $e');
  }
}


  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted &&
          _videoController != null &&
          _videoController!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _showControls = true;
      } else {
        _videoController!.play();
        _hideControlsAfterDelay();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls &&
        _videoController != null &&
        _videoController!.value.isPlaying) {
      _hideControlsAfterDelay();
    }
  }

  void _seekForward() {
    if (_videoController != null) {
      final currentPosition = _videoController!.value.position;
      final targetPosition = currentPosition + const Duration(seconds: 10);
      final maxDuration = _videoController!.value.duration;
      _videoController!.seekTo(
        targetPosition > maxDuration ? maxDuration : targetPosition,
      );
    }
  }

  void _seekBackward() {
    if (_videoController != null) {
      final currentPosition = _videoController!.value.position;
      final targetPosition = currentPosition - const Duration(seconds: 10);
      _videoController!.seekTo(
        targetPosition < Duration.zero ? Duration.zero : targetPosition,
      );
    }
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _videoController?.setPlaybackSpeed(speed);
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
    });
    _videoController?.setLooping(_isLooping);
  }

  void _showSpeedOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Playback Speed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...[0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
              return ListTile(
                leading: Radio<double>(
                  value: speed,
                  groupValue: _playbackSpeed,
                  activeColor: const Color(0xFF6366F1),
                  onChanged: (value) {
                    _changePlaybackSpeed(value!);
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  speed == 1.0 ? 'Normal' : '${speed}x',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: _playbackSpeed == speed
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: _playbackSpeed == speed
                        ? const Color(0xFF6366F1)
                        : Colors.black87,
                  ),
                ),
                onTap: () {
                  _changePlaybackSpeed(speed);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _FullscreenVideoPlayer(
            controller: _videoController!,
            onExit: () {
              setState(() {
                _isFullscreen = false;
              });
            },
            playbackSpeed: _playbackSpeed,
            isLooping: _isLooping,
            onSpeedChange: _changePlaybackSpeed,
            onLoopToggle: _toggleLoop,
          ),
        ),
      ).then((_) {
        setState(() {
          _isFullscreen = false;
        });
      });
    }
  }

  void _playVideo(int index) {
    final content = _courseVideos[index];
    final contentType = content['type'] as String;

    if (contentType == 'video') {
      setState(() {
        _selectedVideoIndex = index;
      });
      _initializeVideo(_courseVideos[index]['url'] as String);
      // Reload quiz data for the new video
      _loadQuizData();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

 @override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  
  // Dispose app open ad
  _appOpenAd?.dispose();
  _videoController?.dispose();
  _chewieController?.dispose();
  _youtubeController?.dispose();
  _interstitialAd?.dispose();
  _tabController.dispose();
  
  // Dispose text controllers
  _linkController.dispose();
  _textController.dispose();
  _lessonDetailProvider.dispose();

  // Ensure system UI is restored when leaving this screen
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  super.dispose();
}

Future<void> _handleBackButton() async {
  final currentOrientation = MediaQuery.of(context).orientation;

  if (currentOrientation == Orientation.landscape) {
    // In landscape: rotate to portrait, don't pop
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  } else {
    // In portrait: mark navigation and show interstitial ad then pop the screen
    setState(() {
      _isNavigatingAway = true;
    });
    _showInterstitialAdAndNavigateBack();
  }
}

 void _showSubmitAssignmentModal(BuildContext context) {
  // Get active profile
  final cbtUserProvider = Provider.of<CbtUserProvider>(context, listen: false);
  final user = cbtUserProvider.currentUser;
  CbtUserProfile? modalActiveProfile = _activeProfile ?? 
      user?.profiles.firstWhere((p) => true, 
        orElse: () => CbtUserProfile(id: 0, firstName: 'User', lastName: '', avatar: null));
  
  String? selectedFileName;
  String? selectedFilePath;
  String? selectedFileBase64;
  bool _isPickingFile = false;
  
  // Get the submission type
  final submissionType = _assignmentSubmissionType ?? 'upload';
  final isPastDue = _isAssignmentPastDue();

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: animation1,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: FadeTransition(
          opacity: animation1,
          child: Center(
            child: Container(
              width: 500,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Submit Assignment',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Submitting as:',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _showAccountSwitcherDialog(context, user, 
                                    onProfileSelected: (profile) {
                                      setModalState(() {
                                        modalActiveProfile = profile;
                                      });
                                    });
                                },
                                icon: const Icon(Icons.swap_horiz, size: 18),
                                label: const Text('Change Profile'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF6366F1),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Active Profile Display
                          _buildProfileItem(
                            name: _profileName(modalActiveProfile!),
                            email: user?.email ?? '',
                            phone: user?.phone ?? '',
                            imageUrl: modalActiveProfile!.avatar,
                            isSelected: true,
                            onTap: () {},
                          ),
                          const SizedBox(height: 16),
                          
                          // Dynamic submission fields based on type
                          if (submissionType == 'upload') ...[
                            Builder(
                              builder: (context) {
                                Future<void> pickFile() async {
                                  if (_isPickingFile) return;
                                  if (mounted) {
                                    setState(() {
                                      _isPickingFile = true;
                                      _isNavigatingAway = true;
                                    });
                                  }
                                  try {
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['pdf'],
                                    );
                                    if (result != null) {
                                      final filePath = result.files.single.path;
                                      final fileName = result.files.single.name;
                                      final ext =
                                          fileName.split('.').last.toLowerCase();
                                      if (filePath != null) {
                                        if (ext != 'pdf') {
                                          setModalState(() {
                                            selectedFileName = null;
                                            pdfError = 'Only PDF files are allowed.';
                                          });
                                          return;
                                        }
                                        // Check file size (limit to 1MB)
                                        final file = File(filePath);
                                        final fileSize = await file.length();
                                        if (fileSize > 1024 * 1024) {
                                          setModalState(() {
                                            selectedFileName = null;
                                            pdfError = 'PDF file must not exceed 1MB.';
                                          });
                                          return;
                                        }
                                        // Show loading indicator while encoding
                                        setModalState(() {
                                          selectedFileName = 'Encoding file...';
                                          pdfError = null;
                                        });
                                        // Read file bytes
                                        final bytes = await file.readAsBytes();
                                        // Encode to base64
                                        final base64String =
                                            await compute(_encodeToBase64, bytes);
                                        setModalState(() {
                                          selectedFileName = fileName;
                                          selectedFilePath = filePath;
                                          selectedFileBase64 = base64String;
                                          pdfError = null;
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    setModalState(() {
                                      selectedFileName = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error picking file: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isPickingFile = false;
                                        _isNavigatingAway = false;
                                      });
                                    }
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    CustomPaint(
                                      painter: _DashedRRectPainter(
                                        color: Colors.grey.shade400,
                                        strokeWidth: 1,
                                        dashLength: 6,
                                        gapLength: 6,
                                        radius: 12,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 24,
                                          horizontal: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 36,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Drag & Drop your file here',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                onPressed: _isPickingFile ? null : pickFile,
                                                icon: const Icon(Icons.folder_open, size: 18),
                                                label: Center(
                                                  child: const Text('Browse File',style: TextStyle(
                                                    color: Colors.white
                                                  ),),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor:const Color(0xFF6366F1) ,
                                                  foregroundColor:const Color(0xFF6366F1) ,
                                                  side: const BorderSide(
                                                    color: Color(0xFF6366F1),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '1 file only � PDF � max 1MB',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (selectedFileName != null) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.picture_as_pdf,
                                              color: Color(0xFF6366F1),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                selectedFileName!,
                                                style: const TextStyle(fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              icon:
                                                  const Icon(Icons.close, size: 18),
                                              onPressed: () {
                                                setModalState(() {
                                                  selectedFileName = null;
                                                  selectedFilePath = null;
                                                  selectedFileBase64 = null;
                                                });
                                              },
                                              color: Colors.grey.shade600,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    if (pdfError != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          pdfError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ] else if (submissionType == 'link' || submissionType == 'url') ...[
                            // URL/Link input field
                            TextField(
                              controller: _linkController,
                              decoration: InputDecoration(
                                labelText: 'Assignment Link/URL',
                                hintText: 'Enter the link to your assignment',
                                prefixIcon: const Icon(Icons.link),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6366F1),
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.url,
                            ),
                          ] else if (submissionType == 'text') ...[
                            // Text input field
                            TextField(
                              controller: _textController,
                              decoration: InputDecoration(
                                labelText: 'Assignment Text',
                                hintText: 'Type your assignment here',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6366F1),
                                    width: 2,
                                  ),
                                ),
                              ),
                              maxLines: 8,
                              keyboardType: TextInputType.multiline,
                            ),
                          ],
                          
                          const SizedBox(height: 8),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text: submissionType == 'upload'
                                      ? 'Upload your assignment as a PDF file (max 1MB).'
                                      : submissionType == 'link' || submissionType == 'url'
                                          ? 'Provide a link to your assignment (e.g., Google Drive, Dropbox).'
                                          : 'Type your assignment directly in the text field above.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey.shade700,
                                    side: BorderSide(
                                        color: Colors.grey.shade400, width: 1.5),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isPastDue
                                      ? null
                                      : () async {
                                    // Get selected profile data
                                    final name = _profileName(modalActiveProfile!);
                                    final phone = user?.phone ?? '';
                                    final email = user?.email;
                                    
                                    // Validate based on submission type
                                    if (submissionType == 'upload') {
                                      if (selectedFileName == null ||
                                          selectedFileBase64 == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please upload your assignment file'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                    } else if (submissionType == 'link' || 
                                               submissionType == 'url') {
                                      if (_linkController.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please enter the assignment link'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                      // Basic URL validation
                                      if (!_linkController.text.trim().startsWith('http')) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please enter a valid URL (starting with http:// or https://)'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                    } else if (submissionType == 'text') {
                                      if (_textController.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please enter your assignment text'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                    }

                                    // Close the modal first
                                    Navigator.of(context).pop();

                                    // Store the navigator context before showing dialog
                                    final navigatorContext =
                                        Navigator.of(context).context;

                                    // Show loading dialog
                                    showDialog(
                                      context: navigatorContext,
                                      barrierDismissible: false,
                                      builder: (BuildContext dialogContext) {
                                        return PopScope(
                                          canPop: false,
                                          child: Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(24.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                const CircularProgressIndicator(
                                                  color: Colors.blueAccent,
                                                ),
                                                  const SizedBox(height: 24),
                                                  const Text(
                                                    'Submitting Assignment...',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Please wait while we submit your work',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );

                                    // Submit assignment using provider
                                    try {
                                      final provider =
                                          AssignmentSubmissionProvider();

                                      // Use 0 as score if quiz not taken
                                      final quizScoreToSubmit =
                                          _quizTaken ? _quizScore : 0;

                                      // Prepare submission data based on type
                                      Map<String, dynamic> submissionData = {
                                        'name': name,
                                        'email': email ?? '',
                                        'phone': phone ?? '',
                                        'quiz_score': quizScoreToSubmit.toString(),
                                        'lesson_id': widget.lessonId.toString(),
                                        'cohort_id': widget.cohortId,
                                        'profile_id': widget.profileId.toString(),
                                        'submission_type': submissionType,
                                      };

                                      if (submissionType == 'upload') {
                                        submissionData['assignments'] = [
                                          {
                                            'file_name': selectedFileName!,
                                            'type': 'pdf',
                                            'file': selectedFileBase64!,
                                          }
                                        ];
                                      } else if (submissionType == 'link' || 
                                                 submissionType == 'url') {
                                        submissionData['link_url'] = 
                                            _linkController.text.trim();
                                      } else if (submissionType == 'text') {
                                        submissionData['text_content'] = 
                                            _textController.text.trim();
                                      }

                                      // Debug: print final payload per submission type
                                      try {
                                        final payloadJson = jsonEncode(submissionData);
                                        print('Assignment submission payload: $payloadJson');
                                      } catch (e) {
                                        print('Failed to encode submission payload: $e');
                                      }

                                      final success = await provider.submitAssignment(
                                        name: submissionData['name'],
                                        email: submissionData['email'],
                                        phone: submissionData['phone'],
                                        quizScore: submissionData['quiz_score'],
                                        lessonId: submissionData['lesson_id'],
                                        cohortId: submissionData['cohort_id'],
                                        profileId: submissionData['profile_id'],
                                        submissionType: submissionData['submission_type'],
                                        assignments: submissionData['assignments'],
                                        linkUrl: submissionData['link_url'],
                                        textContent: submissionData['text_content'],
                                      );

                                      // Close loading dialog
                                      if (navigatorContext.mounted) {
                                        Navigator.of(navigatorContext,
                                                rootNavigator: true)
                                            .pop();
                                      }

                                      if (success) {
                                        // Save submission status
                                        await _saveSubmissionStatus();
                                        await _clearPendingAssignmentData();
                                        
                                        // Clear controllers
                                        _linkController.clear();
                                        _textController.clear();

                                        unawaited(_silentRefreshLessonDetail());

                                        // Show success message
                                        if (navigatorContext.mounted) {
                                          showDialog(
                                            context: navigatorContext,
                                            builder: (BuildContext successContext) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                title: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 28,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Success!',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                  'Your assignment has been submitted successfully and is pending review.',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    height: 1.5,
                                                  ),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(successContext)
                                                          .pop();
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(0xFF6366F1),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'OK',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        // Show error message
                                        if (navigatorContext.mounted) {
                                          ScaffoldMessenger.of(navigatorContext)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                provider.errorMessage ??
                                                    'Failed to submit assignment',
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(seconds: 5),
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      // Close loading dialog
                                      if (navigatorContext.mounted) {
                                        Navigator.of(navigatorContext,
                                                rootNavigator: true)
                                            .pop();
                                      }

                                      // Show error message
                                      if (navigatorContext.mounted) {
                                        ScaffoldMessenger.of(navigatorContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 5),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isPastDue
                                        ? Colors.grey.shade400
                                        : const Color(0xFF6366F1),
                                    disabledBackgroundColor:
                                        Colors.grey.shade400,
                                    disabledForegroundColor: Colors.white,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildProfileItem({
    required String name,
    required String email,
    required String phone,
    String? imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            // Name and Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? const Color(0xFF6366F1) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Selection Indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6366F1),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEmailApp(String userName) async {
    final courseTitle = widget.courseTitle;
    final subject = Uri.encodeComponent(
        'Assignment Submission for $courseTitle - Lesson 1');
    final body = Uri.encodeComponent(
        'Hi,\n\nMy name is $userName, and I am submitting my assignment.\n\nPlease find the file attached.\n\nThank you.');
    final emailAddress = 'communication@digitaldreamsng.com';

    final Uri emailUri =
        Uri.parse('mailto:$emailAddress?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getFileNameFromUrl(String url) {
  try {
    // Remove query parameters if any
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    if (pathSegments.isNotEmpty) {
      // Get the last segment (filename)
      String filename = pathSegments.last;
      
      // Decode URL encoding (e.g., %20 -> space)
      filename = Uri.decodeComponent(filename);
      
      // If no extension, add .pdf
      if (!filename.toLowerCase().endsWith('.pdf')) {
        filename = '$filename.pdf';
      }
      
      return filename;
    }
  } catch (e) {
    print('Error extracting filename: $e');
  }
  
  // Fallback to timestamp-based name
  return 'Linkskool_File_${DateTime.now().millisecondsSinceEpoch}.pdf';
}


// In _previewAssignment
Future<void> _previewAssignment(String assignmentUrl) async {
  setState(() {
    _isNavigatingAway = true;
  });
  
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _AssignmentPreviewScreen(
        assignmentUrl: assignmentUrl,
        assignmentTitle: 'Assignment',
      ),
    ),
  );
  
  setState(() {
    _isNavigatingAway = false;
  });
}

  // Helper function to get public Downloads directory
  Future<Directory?> _getDownloadsDirectory() async {
  if (Platform.isAndroid) {
    // For Android, use app-specific external storage (no permission needed)
    // This is accessible via Files app and won't be deleted when app is uninstalled
    final dir = await getExternalStorageDirectory();
    if (dir != null) {
      // Use a public-like directory within app space
      final downloadDir = Directory('${dir.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    }
  } else if (Platform.isIOS) {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/Downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }
  return null;
}

Future<String?> _saveToPublicDownloads(Uint8List bytes, String fileName) async {
  if (!Platform.isAndroid) {
    return null;
  }
  
  try {
    // Call native Android code to save to public Downloads
    final String? result = await platform.invokeMethod(
      'saveToDownloads',
      {
        'fileName': fileName,
        'bytes': bytes,
      },
    );
    return result;
  } catch (e) {
    print('Error saving to Downloads: $e');
    return null;
  }
}



Future<String?> _saveToDownloadsUsingMediaStore(
  Uint8List bytes,
  String fileName,
) async {
  if (!Platform.isAndroid) return null;
  
  try {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    
    // Only use MediaStore for Android 10+
    if (sdkInt >= 29) {
      // Call native Android code to save file using MediaStore
      final String? filePath = await platform.invokeMethod(
        'saveToDownloads',
        {
          'fileName': fileName,
          'bytes': bytes,
        },
      );
      return filePath;
    }
  } catch (e) {
    print('MediaStore save failed: $e');
  }
  return null;
}
Future<void> _openFileWithChooser(String filePath) async {
  if (!Platform.isAndroid) return;
  
  try {
    await platform.invokeMethod('openFile', {'filePath': filePath});
  } catch (e) {
    print('Error opening file: $e');
  }
}

// Download Material - simplified version
Future<void> _downloadMaterial(String materialUrl) async {
  try {
    // Show loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Downloading...'),
            ],
          ),
        ),
      );
    }

    // Download file
    final response = await http.get(Uri.parse("https://linkskool.net/$materialUrl"));
    
    if (response.statusCode == 200) {
      final fileName = _getFileNameFromUrl(materialUrl);
      
      // Save to Downloads
      final savedPath = await _saveToPublicDownloads(
        response.bodyBytes,
        fileName,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        
        if (savedPath != null) {
          // Open with system chooser immediately
          await _openFileWithChooser(savedPath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download material'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    print('Download error: $e');
    if (mounted) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Download Certificate - simplified version
Future<void> _downloadCertificate(String certificateUrl) async {
  try {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Downloading...'),
            ],
          ),
        ),
      );
    }

    final response =
        await http.get(Uri.parse("https://linkskool.net/$certificateUrl"));

    if (response.statusCode == 200) {
      final fileName = _getFileNameFromUrl(certificateUrl);

      final savedPath = await _saveToPublicDownloads(
        response.bodyBytes,
        fileName,
      );

      if (mounted) {
        Navigator.pop(context);
        if (savedPath != null) {
          await _openFileWithChooser(savedPath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download certificate'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    print('Download error: $e');
    if (mounted) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Download Assignment - simplified version
Future<void> _downloadAssignment(String assignmentUrl) async {
  try {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Downloading...'),
            ],
          ),
        ),
      );
    }

    final response = await http.get(Uri.parse("https://linkskool.net/$assignmentUrl"));
    
    if (response.statusCode == 200) {
 final fileName = _getFileNameFromUrl(assignmentUrl);
      
      final savedPath = await _saveToPublicDownloads(
        response.bodyBytes,
        fileName,
      );

      if (mounted) {
        Navigator.pop(context);
        
        if (savedPath != null) {
          // Open with system chooser immediately
          await _openFileWithChooser(savedPath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download assignment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    print('Download error: $e');
    if (mounted) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}



  @override
  @override
Widget build(BuildContext context) {
  return ChangeNotifierProvider<LessonDetailProvider>.value(
    value: _lessonDetailProvider,
    child: Consumer<LessonDetailProvider>(
      builder: (context, provider, child) {
        final hasLessonRequest =
            widget.profileId != null && widget.lessonId != null;
        print("lesson: ${widget.lessonId}");
        print("profile: ${widget.profileId}");

        if (!_requestSent && hasLessonRequest && !provider.isLoading) {
          _requestSent = true;
          provider.fetchLessonDetail(
            lessonId: widget.lessonId!,
            profileId: widget.profileId!,
          );
        }

        final lesson = provider.lessonDetailData?.lesson;
        final submission = provider.lessonDetailData?.submission;

        if (lesson != null && !_dataLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _applyLessonData(lesson, submission: submission);
            }
          });
        }
        if (lesson != null && _dataLoaded) {
          final signature = _buildLessonMetaSignature(lesson, submission);
          if (signature != _lastMetaSignature) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _applyLessonMeta(lesson, submission: submission);
              }
            });
          }
        }
        if (submission != null && submission != _submission) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _submission = submission;
              });
            }
          });
        }

        if (provider.isLoading && hasLessonRequest && !_dataLoaded) {
          return Scaffold(
            appBar: AppBar(title: Text('Loading...')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.errorMessage != null && hasLessonRequest && !_dataLoaded) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Error: ${provider.errorMessage}')),
          );
        }

        if (lesson == null && hasLessonRequest && !_dataLoaded) {
          return Scaffold(
            appBar: AppBar(title: Text('No Data')),
            body: Center(child: Text('No lesson data available')),
          );
        }

        final currentVideo = _courseVideos.isNotEmpty
            ? _courseVideos[_selectedVideoIndex]
            : {
                'title': _displayTitle,
                'description': _displayDescription,
                'url': _effectiveVideoUrl ?? '',
              };

        return WillPopScope(
          onWillPop: () async {
            await _handleBackButton();
            return false;
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _handleBackButton,
              ),
            ),
            backgroundColor: Colors.white,
            body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVideoPlayer(),
                      const SizedBox(height: 10),
                      // Video Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF6366F1),
                      isScrollable: false,
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: const Color(0xFF6366F1),
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Quiz'),
                        Tab(text: 'Assignments'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildReviewsTab(),
                _buildAssignmentsTab(currentVideo),
              ],
            ),
            ),
          ),
        );
      },
    ),
  );
}


  List<Widget> _buildSheetContent(Map<String, dynamic> currentVideo) {
    return [
      // Video Title and Description
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _displayTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),

      const Divider(height: 1),

      // Tabs Section
      TabBar(
        controller: _tabController,
        
        labelColor: const Color(0xFF6366F1),
        isScrollable: false,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: const Color(0xFF6366F1),
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Quiz'),
          Tab(text: 'Assignments'),
        ],
      ),

      // Tab Content
      SizedBox(
        height: 600,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildReviewsTab(),
            _buildAssignmentsTab(currentVideo),
          ],
        ),
      ),
    ];
  }
Widget _buildVideoPlayer() {
  if (_videoError != null) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Video Error',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _videoError!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final url = _effectiveVideoUrl;
                if (url != null && url.isNotEmpty) {
                  setState(() {
                    _lastInitializedUrl = null; // Reset to allow re-init
                  });
                  _initializeVideo(url);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  if (!_hasVideo) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text(
          'No video available',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // YouTube player
  if (_isYoutubeVideo && _youtubeController != null) {
    print('Rendering YouTube player with ID: ${_youtubeController!.initialVideoId}');
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: YoutubePlayerBuilder(
        key: ValueKey(_youtubeController!.initialVideoId),
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFF6366F1),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFF6366F1),
            handleColor: Color(0xFF6366F1),
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey,
          ),
          onReady: () {
            print('YouTube player ready and visible');
          },
        ),
        builder: (context, player) {
          return player;
        },
      ),
    );
  }

  // Direct video player
  if (!_isYoutubeVideo && _chewieController != null && _isVideoInitialized) {
    print('Rendering Chewie player');
    return AspectRatio(
      aspectRatio: 16 / 9,
      key: ValueKey(_videoController.hashCode),
      child: Chewie(controller: _chewieController!),
    );
  }

  // Loading state - show while waiting for lesson data or video initialization
  print('Showing loading state. hasAppliedData: $_hasAppliedLessonData, isInitializing: $_isInitializing, initialized: $_isVideoInitialized');
  return AspectRatio(
    aspectRatio: 16 / 9,
    child: Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 16),
            Text(
              _hasAppliedLessonData ? 'Loading video...' : 'Loading lesson data...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildContentTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _courseVideos.length,
      itemBuilder: (context, index) {
        final video = _courseVideos[index];
        final isSelected = index == _selectedVideoIndex;
        final isReading = video['type'] == 'reading';

        return InkWell(
          onTap: () => _navigateToContent(index),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 120,
                  height: 68,
                  decoration: BoxDecoration(
                    color: isReading ? const Color(0xFFF3F4F6) : Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: isReading
                        ? Border.all(color: Colors.grey.shade300)
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          isReading
                              ? Icons.article_outlined
                              : (isSelected
                                  ? Icons.play_circle_filled
                                  : Icons.play_circle_outline),
                          color: isReading
                              ? const Color(0xFF6366F1)
                              : (isSelected
                                  ? const Color(0xFF6366F1)
                                  : Colors.white),
                          size: 32,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video['duration'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${video['title']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (video['isIntro'] as bool) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA500),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'INTRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            video['isCompleted'] as bool
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            size: 14,
                            color: video['isCompleted'] as bool
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            video['isCompleted'] as bool
                                ? 'Completed'
                                : 'Not completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: video['isCompleted'] as bool
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
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

  Widget _buildOverviewTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text(
        'About This Course',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 20),
      Stack(
        children: [
          AnimatedCrossFade(
            firstChild: Text(
              _displayDescription,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              _displayDescription,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            crossFadeState: _isDescriptionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          if (!_isDescriptionExpanded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () {
          setState(() {
            _isDescriptionExpanded = !_isDescriptionExpanded;
          });
        },
        child: Text(
          _isDescriptionExpanded ? 'See less' : 'See more',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6366F1),
          ),
        ),
      ),
      const SizedBox(height: 24),

      // Course Materials Card - Only show if materialUrl exists
      if (_effectiveMaterialUrl != null && _effectiveMaterialUrl!.isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Course Materials',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Message
              const Text(
                'Download all course materials including slides, resources, and supplementary documents.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _downloadMaterial(_effectiveMaterialUrl!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Download Materials',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],

      // Certificate Card - Only show if final lesson and certificate URL exists
      if (_shouldShowCertificate) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Certificate',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF59E0B),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Download your certificate of completion for this course.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _downloadCertificate(certificateUrl!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Download Certificate',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],

      // Join/Watch Button with Zoom-style banner - Show if zoom URL or recorded URL exists
      // Join/Watch Button with class status banner
if ((_effectiveZoomUrl != null && _effectiveZoomUrl!.isNotEmpty) ||
    (_effectiveRecordedUrl != null && _effectiveRecordedUrl!.isNotEmpty)) ...[
  Builder(
    builder: (context) {
      final zoomStatus = _getZoomStatus();
      final status = zoomStatus['status'] as String;
      final message = zoomStatus['message'] as String;
      final buttonText = zoomStatus['buttonText'] as String;
      final url = zoomStatus['url'] as String?;

      // Determine button style and behavior based on status
      Color backgroundColor;
      Color iconColor;
      IconData iconData;
      bool isButtonEnabled;
      String cardTitle;

      switch (status) {
        case 'scheduled':
          backgroundColor = Colors.grey.shade300;
          iconColor = Colors.grey.shade600;
          iconData = Icons.schedule;
          isButtonEnabled = false;
          cardTitle = 'Upcoming Live Class';
          break;
        case 'ongoing':
          backgroundColor = const Color(0xFF2D8CFF);
          iconColor = Colors.white;
          iconData = Icons.videocam;
          isButtonEnabled = true;
          cardTitle = 'Live Class Now';
          break;
        case 'recorded':
          backgroundColor = const Color(0xFF10B981);
          iconColor = Colors.white;
          iconData = Icons.play_circle_outline;
          isButtonEnabled = true;
          cardTitle = 'Recorded Class';
          break;
        case 'pending':
          backgroundColor = Colors.blueGrey;
          iconColor = Colors.white;
          iconData = Icons.hourglass_empty;

          isButtonEnabled = false;
          cardTitle = 'Recorded video';
          break;
        case 'available':
          backgroundColor = const Color(0xFF2D8CFF);
          iconColor = Colors.white;
          iconData = Icons.videocam;
          isButtonEnabled = true;
          cardTitle = 'Live Class';
          break;
        case 'unavailable':
        default:
          backgroundColor = Colors.grey.shade300;
          iconColor = Colors.grey.shade600;
          iconData = Icons.not_interested;
          isButtonEnabled = false;
          cardTitle = 'No Class Available';
          break;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cardTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: backgroundColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                // Live indicator for ongoing classes
                if (status == 'ongoing')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            if (buttonText.isNotEmpty) ...[
              const SizedBox(height: 16),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isButtonEnabled && url != null
                      ? () => _launchUrl(url)
                      : null,
                  icon: Icon(
                    iconData,
                    size: 20,
                  ),
                  label: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: iconColor,
                    disabledBackgroundColor: backgroundColor,
                    disabledForegroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: isButtonEnabled ? 2 : 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  ),
  const SizedBox(height: 16),
],
    ]);
  }

  Widget _buildAssignmentsTab(Map<String, dynamic> currentVideo) {
    final remark = _submission?.remark?.trim();
    final comment = _submission?.comment?.trim();
    final hasRemark = remark != null && remark.isNotEmpty;
    final hasComment = comment != null && comment.isNotEmpty;
    final hasFeedback = hasRemark || hasComment;
    final assignedScore = _submission?.assignedScore;
    final isPastDue = _isAssignmentPastDue();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (hasFeedback) ...[
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                if (assignedScore != null) ...[
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 12,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF1D4ED8).withOpacity(0.15),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: assignedScore / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${assignedScore}/100',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                              const Text(
                                'Score',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (hasRemark) ...[
                  const Text(
                    'Remark:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    remark!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (hasComment) ...[
                  const Text(
                    'Instructor Feedback:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comment!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      
       
        if (!hasFeedback) ...[
            const Text(
          'Lesson Assignment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFFFFB74D).withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assignment Guidelines',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete the assignment and submit before the deadline. Make sure to follow all instructions provided in the downloaded file.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Deadline: ${_formattedAssignmentDeadline()}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      StreamBuilder<int>(
                        stream: _countdownStream,
                        builder: (context, snapshot) {
                          final deadline = _assignmentDeadlineDate();
                          if (deadline == null) {
                            return Text(
                              'No deadline set',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade900,
                              ),
                            );
                          }

                          final now = DateTime.now();
                          final isPastDue = now.isAfter(deadline);
                          final diff = isPastDue
                              ? Duration.zero
                              : deadline.difference(now);
                          final days = diff.inDays;
                          final hours = diff.inHours % 24;
                          final minutes = diff.inMinutes % 60;
                          final seconds = diff.inSeconds % 60;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF2E5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFFD4A1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildCountdownItem(
                                      'DAYS',
                                      days.toString().padLeft(2, '0'),
                                    ),
                                    _buildCountdownItem(
                                      'HOURS',
                                      hours.toString().padLeft(2, '0'),
                                    ),
                                    _buildCountdownItem(
                                      'MINUTES',
                                      minutes.toString().padLeft(2, '0'),
                                    ),
                                    _buildCountdownItem(
                                      'SECONDS',
                                      seconds.toString().padLeft(2, '0'),
                                    ),
                                  ],
                                ),
                              ),
                              if (isPastDue) ...[
                                const SizedBox(height: 6),
                                Center(
                                  child: const Text(
                                    'Deadline passed',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        // Current Video/Lesson Info Card

        const SizedBox(height: 24),

        if ((_effectiveAssignmentDescription ?? '').trim().isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
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
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.list_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Assignment Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Html(
                  data: _effectiveAssignmentDescription,
                  style: {
                    "body": Style(
                      fontSize: FontSize(18),
                      color: Colors.black87,
                      lineHeight: LineHeight(1.4),
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "p": Style(
                      margin: Margins(bottom: Margin(8)),
                    ),
                    "ul": Style(
                      margin: Margins(bottom: Margin(8)),
                      padding: HtmlPaddings(left: HtmlPadding(20)),
                    ),
                    "ol": Style(
                      margin: Margins(bottom: Margin(8)),
                      padding: HtmlPaddings(left: HtmlPadding(20)),
                    ),
                    "li": Style(
                      margin: Margins(bottom: Margin(2)),
                      padding: HtmlPaddings.zero,
                    ),
                  },
                ),
              ],
            ),
          ),

        if ((_effectiveAssignmentDescription ?? '').trim().isNotEmpty)
          const SizedBox(height: 10),

        // Download Assignment Card
        // Download Assignment Card
if (_effectiveAssignmentUrl != null && _effectiveAssignmentUrl!.isNotEmpty)
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.assignment,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Assignment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2196F3),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Use the buttons below to preview or download the assignment file.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
       
        const SizedBox(height: 16),

        // Buttons Row
        Row(
          children: [
            // Preview Button - FIXED: Preview the lesson assignment, not submitted
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Use lesson assignment URL, not submitted assignment
                  if (_effectiveAssignmentUrl == null || 
                      _effectiveAssignmentUrl!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No assignment file available'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  _previewAssignment(_effectiveAssignmentUrl!); // CHANGED THIS LINE
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Preview'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2196F3),
                  side: const BorderSide(color: Color(0xFF2196F3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Download Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _downloadAssignment(_effectiveAssignmentUrl!),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),

        const SizedBox(height: 16),
       

        // Submit Assignment Card - Only show if assignmentUrl exists
        if (_effectiveAssignmentUrl != null &&
            _effectiveAssignmentUrl!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.upload_file,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                     Text(
                      _hasSubmittedAssignment ? 'Submitted Assignment' : 'Submit Assignment',
                      
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6366F1),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  _hasSubmittedAssignment
                      ? 'You have already submitted this assignment. Preview it or resubmit with an updated file.'
                      : 'Once you\'ve completed the assignment, submit your work here for review.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Buttons
                _hasSubmittedAssignment
    ? Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                final submittedFileUrl = _submittedAssignmentUrl;
                if (submittedFileUrl != null && submittedFileUrl.isNotEmpty) {
                  _previewAssignment(submittedFileUrl);
                  return;
                }
                final linkUrl = _submission?.linkUrl?.trim();
                if (linkUrl != null && linkUrl.isNotEmpty) {
                  _launchUrl(linkUrl);
                  return;
                }
                final textContent = _submission?.textContent?.trim();
                if (textContent != null && textContent.isNotEmpty) {
                  _showTextSubmissionDialog(textContent);
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No submitted assignment found'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('Preview'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
                side: const BorderSide(color: Color(0xFF6366F1)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isPastDue
                  ? null
                  : () {
                      _showSubmitAssignmentModal(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPastDue
                    ? Colors.grey.shade400
                    : const Color(0xFF6366F1),
                disabledBackgroundColor: Colors.grey.shade400,
                disabledForegroundColor: Colors.white,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Resubmit',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isPastDue
                              ? null
                              : () {
                                  _showSubmitAssignmentModal(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPastDue
                                ? Colors.grey.shade400
                                : const Color(0xFF6366F1),
                            disabledBackgroundColor: Colors.grey.shade400,
                            disabledForegroundColor: Colors.white,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Submit Assignment',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Additional Info
        
      ],
    );
  }

  Widget _buildReviewsTab() {
  // Check if score is below threshold
  final bool isBelowThreshold = _quizTaken && _quizScore < 50;

  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // Low Score Warning - Only show if score is below 50
      if (isBelowThreshold) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEF5350).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF5350),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Score Below Threshold',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF5350),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Your current score of '),
                    TextSpan(
                      text: '$_quizScore%',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(
                      text:
                          ' does not meet the program\'s minimum threshold of ',
                    ),
                    const TextSpan(
                      text: '50%',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(
                      text:
                          '. Please retake the quiz to improve your score.',
                    ),
                  ],
                ),
              ),
             
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Check if quiz needs to be unlocked (score < 50 and not unlocked yet)
                    if (isBelowThreshold && !_quizUnlocked) {
                      _showUnlockQuizDialog();
                      return;
                    }

                    // Otherwise, navigate to quiz directly
                    _navigateToQuiz();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child:  Text( 
                    _quizRetryMessage != null ? 'Retake Quiz' :
                    'Retake Quiz',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],

      // Take Quiz Card (hide when below threshold)
      if (!isBelowThreshold)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA500),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.quiz,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Lesson Quiz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFA500),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Message
              const Text(
                'Find out how much you learnt by taking a Test',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Check if quiz needs to be unlocked (score < 50 and not unlocked yet)
                    if (isBelowThreshold && !_quizUnlocked) {
                      _showUnlockQuizDialog();
                      return;
                    }

                    // Otherwise, navigate to quiz directly
                    _navigateToQuiz();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _quizTaken ? 'Retake Quiz' : 'Take Quiz',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

      const SizedBox(height: 24),

      // Lesson Assessment Progress
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lesson Assessment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Circular Progress
            Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFFFFA500).withOpacity(0.15),
                        ),
                      ),
                    ),
                    // Progress circle with color based on score
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: _quizScore / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _quizScore >= 50
                              ? const Color(0xFF4CAF50) // Green for passing
                              : const Color(0xFFEF5350), // Red for failing
                        ),
                      ),
                    ),
                    // Score text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_quizScore/100',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: _quizScore >= 50
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEF5350),
                          ),
                        ),
                        if (_quizTaken)
                          Text(
                            '$_quizScore%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// preview assignment 




  String _calculateTotalDuration() {
    int totalMinutes = 0;
    for (var video in _courseVideos) {
      final duration = video['duration'] as String;
      final parts = duration.split(':');
      totalMinutes += int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  void _showTextSubmissionDialog(String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submitted Text'),
          content: SingleChildScrollView(
            child: Text(text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

// Fullscreen Video Player Widget
class _FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onExit;
  final double playbackSpeed;
  final bool isLooping;
  final Function(double) onSpeedChange;
  final VoidCallback onLoopToggle;

  const _FullscreenVideoPlayer({
    required this.controller,
    required this.onExit,
    required this.playbackSpeed,
    required this.isLooping,
    required this.onSpeedChange,
    required this.onLoopToggle,
  });

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  bool _showControls = true;
  late double _playbackSpeed;
  late bool _isLooping;

  @override
  void initState() {
    super.initState();
    _playbackSpeed = widget.playbackSpeed;
    _isLooping = widget.isLooping;

    // Lock to landscape on fullscreen entry
    _lockLandscape();
    _hideControlsAfterDelay();
  }

  Future<void> _lockLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  Future<void> _resetToPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _resetAllOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Handle back button - rotate to portrait first, then exit
  Future<void> _handleBackButton() async {
    final currentOrientation = MediaQuery.of(context).orientation;

    if (currentOrientation == Orientation.landscape) {
      // In landscape: rotate to portrait
      await _resetToPortrait();
      setState(() {
        _showControls = true;
      });
    } else {
      // In portrait: exit fullscreen
      await _resetAllOrientations();
      widget.onExit();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls && widget.controller.value.isPlaying) {
      _hideControlsAfterDelay();
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
        _showControls = true;
      } else {
        widget.controller.play();
        _hideControlsAfterDelay();
      }
    });
  }

  void _seekForward() {
    final currentPosition = widget.controller.value.position;
    final targetPosition = currentPosition + const Duration(seconds: 10);
    final maxDuration = widget.controller.value.duration;
    widget.controller.seekTo(
      targetPosition > maxDuration ? maxDuration : targetPosition,
    );
  }

  void _seekBackward() {
    final currentPosition = widget.controller.value.position;
    final targetPosition = currentPosition - const Duration(seconds: 10);
    widget.controller.seekTo(
      targetPosition < Duration.zero ? Duration.zero : targetPosition,
    );
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    widget.controller.setPlaybackSpeed(speed);
    widget.onSpeedChange(speed);
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
    });
    widget.controller.setLooping(_isLooping);
    widget.onLoopToggle();
  }

  void _showSpeedOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Playback Speed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...[0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
              return ListTile(
                leading: Radio<double>(
                  value: speed,
                  groupValue: _playbackSpeed,
                  activeColor: const Color(0xFF6366F1),
                  onChanged: (value) {
                    _changePlaybackSpeed(value!);
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  speed == 1.0 ? 'Normal' : '${speed}x',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: _playbackSpeed == speed
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: _playbackSpeed == speed
                        ? const Color(0xFF6366F1)
                        : Colors.black87,
                  ),
                ),
                onTap: () {
                  _changePlaybackSpeed(speed);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return WillPopScope(
      onWillPop: () async {
        await _handleBackButton();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              // Full screen video player
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: widget.controller.value.size.width,
                    height: widget.controller.value.size.height,
                    child: VideoPlayer(widget.controller),
                  ),
                ),
              ),
              // Controls overlay
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black38,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Top bar - back button and indicators
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _handleBackButton,
                                icon: Icon(
                                  isLandscape
                                      ? Icons.expand_more
                                      : Icons.arrow_back,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const Spacer(),
                              // Loop indicator
                              if (_isLooping)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.repeat,
                                          color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Loop',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_isLooping) const SizedBox(width: 8),
                              // Speed indicator
                              if (_playbackSpeed != 1.0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFA500),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_playbackSpeed}x',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Center controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _seekBackward,
                              icon: const Icon(Icons.replay_10),
                              color: Colors.white,
                              iconSize: 48,
                            ),
                            const SizedBox(width: 32),
                            IconButton(
                              onPressed: _togglePlayPause,
                              icon: Icon(
                                widget.controller.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 72,
                              ),
                              color: Colors.white,
                            ),
                            const SizedBox(width: 32),
                            IconButton(
                              onPressed: _seekForward,
                              icon: const Icon(Icons.forward_10),
                              color: Colors.white,
                              iconSize: 48,
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Bottom controls
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              VideoProgressIndicator(
                                widget.controller,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Color(0xFF6366F1),
                                  bufferedColor: Colors.grey,
                                  backgroundColor: Colors.white24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _formatDuration(
                                            widget.controller.value.position),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        ' / ${_formatDuration(widget.controller.value.duration)}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _toggleLoop,
                                        icon: Icon(
                                          _isLooping
                                              ? Icons.repeat_on
                                              : Icons.repeat,
                                          color: _isLooping
                                              ? const Color(0xFF6366F1)
                                              : Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: _showSpeedOptions,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${_playbackSpeed}x',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () async {
                                          await _resetAllOrientations();
                                          widget.onExit();
                                          if (mounted) {
                                            Navigator.pop(context);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.fullscreen_exit,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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

// Assignment Preview Screen Widget
class _AssignmentPreviewScreen extends StatefulWidget {
  final String assignmentUrl;
  final String assignmentTitle;

  const _AssignmentPreviewScreen({
    required this.assignmentUrl,
    required this.assignmentTitle,
  });

  @override
  State<_AssignmentPreviewScreen> createState() =>
      _AssignmentPreviewScreenState();
}

class _AssignmentPreviewScreenState extends State<_AssignmentPreviewScreen> {
  String? _localPdfPath;
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  // Helper function to get public Downloads directory
  Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // For Android, use the public Downloads folder
      final downloadsPath = '/storage/emulated/0/Download';
      final downloadsDir = Directory(downloadsPath);
      
      // Check if the directory exists, if not try alternative paths
      if (await downloadsDir.exists()) {
        return downloadsDir;
      }
      
      // Try alternative path (some devices use different paths)
      final altPath = '/sdcard/Download';
      final altDir = Directory(altPath);
      if (await altDir.exists()) {
        return altDir;
      }
      
      // If neither exists, create the standard one
      try {
        await downloadsDir.create(recursive: true);
        return downloadsDir;
      } catch (e) {
        // Fallback to external storage directory
        final dir = await getExternalStorageDirectory();
        return Directory('${dir!.path}/Download');
      }
    } else if (Platform.isIOS) {
      // For iOS, use the app's documents directory
      final dir = await getApplicationDocumentsDirectory();
      return Directory('${dir.path}/Downloads');
    }
    return null;
  }

  Future<String?> _saveToPublicDownloads(Uint8List bytes, String fileName) async {
  if (!Platform.isAndroid) return null;
  
  try {
    const platform = MethodChannel('com.linkskool.app/downloads');
    final String? result = await platform.invokeMethod(
      'saveToDownloads',
      {
        'fileName': fileName,
        'bytes': bytes,
      },
    );
    return result;
  } catch (e) {
    print('Error saving to Downloads: $e');
    return null;
  }
}

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse("https://linkskool.net/${widget.assignmentUrl}"));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/assignment_preview.pdf');
        await file.writeAsBytes(response.bodyBytes, flush: true);

        if (mounted) {
          setState(() {
            _localPdfPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load assignment')),
          );
        }
      }
    } catch (e) {
      debugPrint('PDF download error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading assignment: $e')),
        );
      }
    }
  }

  String _getFileNameFromUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    if (pathSegments.isNotEmpty) {
      String filename = pathSegments.last;
      filename = Uri.decodeComponent(filename);
      
      if (!filename.toLowerCase().endsWith('.pdf')) {
        filename = '$filename.pdf';
      }
      
      return filename;
    }
  } catch (e) {
    print('Error extracting filename: $e');
  }
  
  return 'Linkskool_File_${DateTime.now().millisecondsSinceEpoch}.pdf';
}

Future<void> _downloadToDevice() async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Downloading...'),
          ],
        ),
      ),
    );

    final response = await http.get(Uri.parse("https://linkskool.net/${widget.assignmentUrl}"));
    
    if (response.statusCode == 200) {
       final fileName = _getFileNameFromUrl(widget.assignmentUrl);
      
      final savedPath = await _saveToPublicDownloads(
        response.bodyBytes,
        fileName,
      );

      if (mounted) {
        Navigator.pop(context);
        
        if (savedPath != null) {
          // Open with system chooser immediately
          await _openFileWithChooser(savedPath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


Future<void> _openFileWithChooser(String filePath) async {
  if (!Platform.isAndroid) return;
  
  try {
    const platform = MethodChannel('com.linkskool.app/downloads');
    await platform.invokeMethod('openFile', {'filePath': filePath});
  } catch (e) {
    print('Error opening file: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.assignmentTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF2196F3)),
            onPressed: _downloadToDevice,
            tooltip: 'Download',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2196F3)),
                  SizedBox(height: 16),
                  Text('Loading assignment...'),
                ],
              ),
            )
          : _localPdfPath != null
              ? Column(
                  children: [
                    // PDF page indicator
                    if (_totalPages > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.grey.shade100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _currentPage > 0
                                  ? () => setState(() => _currentPage--)
                                  : null,
                            ),
                            Text(
                              'Page ${_currentPage + 1} of $_totalPages',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _currentPage < _totalPages - 1
                                  ? () => setState(() => _currentPage++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    // PDF viewer
                    Expanded(
                      child: PDFView(
                        filePath: _localPdfPath!,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        autoSpacing: true,
                        pageFling: true,
                        pageSnap: true,
                        defaultPage: _currentPage,
                        fitPolicy: FitPolicy.BOTH,
                        onRender: (pages) {
                          setState(() => _totalPages = pages ?? 0);
                        },
                        onPageChanged: (page, total) {
                          setState(() => _currentPage = page ?? 0);
                        },
                        onError: (error) {
                          debugPrint('PDF Error: $error');
                        },
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Text('Failed to load assignment'),
                ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}











