import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'quiz_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/explore/quiz_result_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reading_lesson_screen.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

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
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isVideoInitialized = false;
  bool _isYoutubeVideo = false;
  bool _showControls = true;
  int _selectedVideoIndex = 0;
  late TabController _tabController;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;
  bool _isFullscreen = false;
  bool _isDescriptionExpanded = false;

  // Quiz state variables
  int _quizScore = 0;
  bool _quizTaken = false;
  String? _pendingUsername;
  String? _pendingAssignmentFileName;
  String? _pendingAssignmentFileBase64;

  final List<Map<String, dynamic>> _courseVideos = [
    {
      'title': 'Introduction to the Course',
      'duration': '12:45',
      'type': 'video',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'isIntro': true,
      'isCompleted': false,
      'description':
          'Welcome to the course! In this introduction, we\'ll cover what you\'ll learn, the prerequisites, and how to get the most out of this course.',
    },
    {
      'title': 'Getting Started - Setup',
      'duration': '8:30',
      'type': 'video',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'isIntro': false,
      'isCompleted': false,
      'description': 'Learn how to set up your development environment.',
    },
    {
      'title': 'Reading: Fundamentals of Structure',
      'duration': '10 min read',
      'type': 'reading',
      'isIntro': false,
      'isCompleted': false,
      'description': 'Explore the building blocks of compelling content.',
      'content':
          '''Fundamentals of Structure\n\nA strong structure is the backbone of any compelling story. Understanding the fundamental elements is essential for creating engaging content.\n\nThe Three-Part Framework\n\nMost content follows a three-part framework:\n\nPart 1: Setup\nThis is where you introduce your topic and context. The setup establishes the foundation before the main content begins.\n\nPart 2: Development\nThe longest section, where the main ideas are explored. This is where understanding happens and concepts evolve.\n\nPart 3: Resolution\nThe final part brings everything together. All concepts are reinforced and key takeaways are emphasized.\n\nApplying These Principles\n\nAs you work through this course, remember that these are guidelines to help you learn effectively. Practice identifying these elements in what you study.''',
    },
    {
      'title': 'Understanding the Basics',
      'duration': '15:20',
      'type': 'video',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'isIntro': false,
      'isCompleted': false,
      'description': 'Master the fundamental concepts you need to know.',
    },
    {
      'title': 'Advanced Concepts',
      'duration': '22:15',
      'type': 'video',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'isIntro': false,
      'isCompleted': false,
      'description': 'Dive deeper into advanced techniques and best practices.',
    },
    {
      'title': 'Reading: Best Practices Guide',
      'duration': '8 min read',
      'type': 'reading',
      'isIntro': false,
      'isCompleted': false,
      'description': 'Understand key principles of effective learning.',
      'content':
          '''Best Practices Guide\n\nEffective learning requires understanding several fundamental principles that guide your progress.\n\nKey Learning Principles\n\nSeveral fundamental principles guide effective learning:\n\nActive Engagement\nEngage actively with the material. Don't just passively consume content - think critically and ask questions.\n\nConsistent Practice\nRegular practice reinforces learning. Short, consistent study sessions are more effective than cramming.\n\nReflection\nTake time to reflect on what you've learned. Consider how new concepts connect to what you already know.\n\nApplication\nApply what you learn in practical scenarios. Real-world application deepens understanding.\n\nPractical Implementation\n\nApply these principles by:\n1. Setting clear learning objectives\n2. Taking regular breaks\n3. Seeking feedback from others\n4. Reviewing and revising regularly\n5. Teaching others what you've learned\n\nRemember, effective learning balances understanding with application. Always prioritize comprehension over memorization.''',
    },
    {
      'title': 'Practical Examples',
      'duration': '18:40',
      'type': 'video',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      'isIntro': false,
      'isCompleted': false,
      'description': 'Apply what you\'ve learned with hands-on examples.',
    },
    {
      'title': 'Common Pitfalls to Avoid',
      'duration': '10:25',
      'type': 'video',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      'isIntro': false,
      'isCompleted': false,
      'description': 'Learn about common mistakes and how to avoid them.',
    },
    {
      'title': 'Building Your First Project',
      'duration': '25:30',
      'type': 'video',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      'isIntro': false,
      'isCompleted': false,
      'description': 'Put everything together in a complete project.',
    },
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
    _tabController = TabController(length: 3, vsync: this);
    _loadCompletionStatus();
    _loadPendingAssignmentData();
    // Use provided video URL or fallback to hardcoded videos
    final initialVideoUrl = widget.videoUrl?.isNotEmpty == true
        ? widget.videoUrl!
        : _courseVideos[0]['url'] as String;
    _initializeVideo(initialVideoUrl);
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

    final quizScore = await QuizResultService.getQuizScore(
      courseTitle: widget.courseTitle,
      lessonTitle: videoTitle,
    );

    setState(() {
      _quizScore = quizScore;
      _quizTaken = quizScore > 0;
    });
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

  void _prepareAndPrintPayload({
    required int score,
    required String? assignmentFileName,
    required String? assignmentBase64,
    required String username,
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
      "email": "",
      "phone": "",
      'name': username,
      'course_title': widget.courseTitle,
      'lesson_title': _courseVideos[_selectedVideoIndex]['title'],
      'timestamp': DateTime.now().toIso8601String(),
    };

    final jsonPayload = jsonEncode(payload);
    debugPrint('=== ASSIGNMENT SUBMISSION PAYLOAD ===');
    debugPrint(jsonPayload);
    debugPrint('====================================');

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
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  /// Check if URL is a YouTube video
  bool isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  /// Determine the zoom class status based on date and recorded URL
  /// Priority: Check recorded_url first, then zoom_url
  Map<String, dynamic> _getZoomStatus() {
    final hasRecordedUrl =
        widget.recordedUrl != null && widget.recordedUrl!.isNotEmpty;
    final hasZoomUrl = widget.zoomUrl != null && widget.zoomUrl!.isNotEmpty;

    // If neither URL exists, return unavailable
    if (!hasRecordedUrl && !hasZoomUrl) {
      return {
        'status': 'unavailable',
        'message': 'No Zoom class scheduled',
        'buttonText': '',
        'url': null,
      };
    }

    // PRIORITY 1: If recorded URL exists, always show it first
    if (hasRecordedUrl) {
      return {
        'status': 'recorded',
        'message': 'Watch the recorded video.',
        'buttonText': 'Watch Record video',
        'url': widget.recordedUrl,
      };
    }

    // PRIORITY 2: Check zoom URL with date logic
    if (hasZoomUrl) {
      // If no date provided, assume class is available
      if (widget.classDate == null || widget.classDate!.isEmpty) {
        return {
          'status': 'available',
          'message': 'Join the  class',
          'buttonText': 'Join class',
          'url': widget.zoomUrl,
        };
      }

      try {
        final classDateTime = DateTime.parse(widget.classDate!);
        final now = DateTime.now();

        // Assuming class duration is 2 hours (you can make this configurable)
        final classEndTime = classDateTime.add(const Duration(hours: 3));

        // Class hasn't started yet
        if (now.isBefore(classDateTime)) {
          final formatter = DateFormat('EEEE, MMMM d \'at\' h:mm a');
          final dateStr = formatter.format(classDateTime);
          return {
            'status': 'scheduled',
            'message': 'Class starts on $dateStr',
            'buttonText': 'Scheduled',
            'url': null,
            'classDate': classDateTime,
          };
        }

        // Class is ongoing
        if (now.isAfter(classDateTime) && now.isBefore(classEndTime)) {
          return {
            'status': 'ongoing',
            'message': 'Class is ongoing. Join now!',
            'buttonText': 'Join class',
            'url': widget.zoomUrl,
          };
        }

        // Class has ended but no recorded video
        return {
          'status': 'pending',
          'message': 'Class has ended. Recorded video pending.',
          'buttonText': 'Pending',
          'url': null,
        };
      } catch (e) {
        debugPrint('Error parsing class date: $e');
        return {
          'status': 'available',
          'message': 'Join the class',
          'buttonText': 'Join class',
          'url': widget.zoomUrl,
        };
      }
    }

    // Fallback (should never reach here)
    return {
      'status': 'unavailable',
      'message': 'No content available',
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
    // Dispose previous controllers
    await _videoController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();

    setState(() {
      _isVideoInitialized = false;
      _isYoutubeVideo = false;
    });

    try {
      print('Loading video URL: $url');

      // Check if it's a YouTube video
      if (isYouTubeUrl(url)) {
        await _initializeYouTubePlayer(url);
      } else {
        await _initializeDirectVideoPlayer(url);
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load video: $e')),
        );
      }
    }
  }

  Future<void> _initializeYouTubePlayer(String url) async {
    final videoId = extractYouTubeId(url);

    if (videoId == null) {
      throw Exception('Invalid YouTube URL');
    }

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: false,
      ),
    );

    setState(() {
      _isYoutubeVideo = true;
      _isVideoInitialized = true;
    });
  }

  Future<void> _initializeDirectVideoPlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      placeholder: const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading video',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.white70, fontSize: 12),
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
    _videoController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showSubmitAssignmentModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    String? selectedFileName;
    String? selectedFilePath;
    String? selectedFileBase64;

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
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Submit Assignment',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Please enter your full name and upload your assignment:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Your Full Name',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6366F1),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // PDF Upload Button
                          InkWell(
                            onTap: () async {
                              try {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf'],
                                );

                                if (result != null) {
                                  final filePath = result.files.single.path;
                                  if (filePath != null) {
                                    // Read file and convert to base64
                                    final file = File(filePath);
                                    final bytes = await file.readAsBytes();
                                    final base64String = base64Encode(bytes);

                                    setModalState(() {
                                      selectedFileName =
                                          result.files.single.name;
                                      selectedFilePath = filePath;
                                      selectedFileBase64 = base64String;
                                    });
                                  }
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error picking file: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selectedFileName != null
                                    ? const Color(0xFF6366F1).withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selectedFileName != null
                                      ? const Color(0xFF6366F1)
                                      : Colors.grey.shade300,
                                  width: selectedFileName != null ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selectedFileName != null
                                        ? Icons.picture_as_pdf
                                        : Icons.upload_file,
                                    color: selectedFileName != null
                                        ? const Color(0xFF6366F1)
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedFileName ??
                                          'Upload PDF Assignment',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: selectedFileName != null
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: selectedFileName != null
                                            ? const Color(0xFF6366F1)
                                            : Colors.grey.shade600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (selectedFileName != null)
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 20),
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
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'After clicking "Send Email", your email app will open with the details. ',
                                ),
                                if (selectedFileName == null)
                                  const TextSpan(
                                    text:
                                        'Please remember to attach your assignment file.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
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
                                        color: Colors.grey.shade400,
                                        width: 1.5),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
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
                                  onPressed: () async {
                                    final name = nameController.text.trim();
                                    if (name.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Please enter your name'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // Check if quiz has been taken
                                    if (!_quizTaken) {
                                      // Save pending data
                                      await _savePendingAssignmentData(name,
                                          selectedFileName, selectedFileBase64);

                                      Navigator.pop(context);

                                      // Show dialog to take quiz
                                      final shouldTakeQuiz =
                                          await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            title: const Row(
                                              children: [
                                                Icon(
                                                  Icons.quiz,
                                                  color: Color(0xFFFFA500),
                                                  size: 28,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Take Quiz First',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: const Text(
                                              'You need to take the quiz before submitting your assignment. Your assignment details have been saved.',
                                              style: TextStyle(
                                                fontSize: 15,
                                                height: 1.5,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: Text(
                                                  'Later',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFFFFA500),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Take Quiz Now',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (shouldTakeQuiz == true) {
                                        // Navigate to quiz screen
                                        final currentVideo =
                                            _courseVideos[_selectedVideoIndex];
                                        final videoTitle =
                                            currentVideo['title'] as String;

                                        final result =
                                            await Navigator.push<int>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => QuizScreen(
                                              courseTitle: widget.courseTitle,
                                              lessonTitle: videoTitle,
                                            ),
                                          ),
                                        );

                                        // Reload quiz data
                                        await _loadQuizData();

                                        // If quiz was completed and we have score
                                        if (result != null && _quizTaken) {
                                          // Prepare and print payload
                                          _prepareAndPrintPayload(
                                            score: result,
                                            assignmentFileName:
                                                selectedFileName,
                                            assignmentBase64:
                                                selectedFileBase64,
                                            username: name,
                                          );

                                          // Clear pending data
                                          await _clearPendingAssignmentData();

                                          // Open email app
                                          _openEmailApp(name);
                                        }
                                      }
                                      return;
                                    }

                                    // Quiz already taken, proceed normally
                                    Navigator.pop(context);

                                    // Prepare and print payload
                                    _prepareAndPrintPayload(
                                      score: _quizScore,
                                      assignmentFileName: selectedFileName,
                                      assignmentBase64: selectedFileBase64,
                                      username: name,
                                    );

                                    // Clear pending data if any
                                    await _clearPendingAssignmentData();

                                    _openEmailApp(name);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0066FF),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Send Email',
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

  Future<void> _previewAssignment(String assignmentUrl) async {
    // Navigate to a PDF preview screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AssignmentPreviewScreen(
          assignmentUrl: assignmentUrl,
          assignmentTitle: 'Assignment',
        ),
      ),
    );
  }

  Future<void> _downloadMaterial(String materialUrl) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
        return;
      }

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Downloading materials...'),
              ],
            ),
          ),
        );
      }

      final response = await http.get(Uri.parse(materialUrl));
      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();
        final downloadsDir = Directory('${dir!.path}/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final fileName =
            'Material_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes, flush: true);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded to: ${file.path}'),
              duration: const Duration(seconds: 3),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
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
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadAssignment(String assignmentUrl) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
        return;
      }

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Downloading assignment...'),
              ],
            ),
          ),
        );
      }

      final response = await http.get(Uri.parse(assignmentUrl));
      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();
        final downloadsDir = Directory('${dir!.path}/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final fileName =
            'Assignment_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes, flush: true);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded to: ${file.path}'),
              duration: const Duration(seconds: 3),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
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
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = _courseVideos[_selectedVideoIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoPlayer(),
            const SizedBox(height: 10),
            ..._buildSheetContent(currentVideo),
          ],
        ),
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
              widget.courseTitle,
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
          Tab(text: 'Assignments'),
          Tab(text: 'Quiz'),
        ],
      ),

      // Tab Content
      SizedBox(
        height: 600,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildAssignmentsTab(currentVideo),
            _buildReviewsTab(),
          ],
        ),
      ),
    ];
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        height: 240,
        color: Colors.black,
        child: Stack(children: [
          // Video - Handle both YouTube and regular videos
          if (_isVideoInitialized)
            _isYoutubeVideo && _youtubeController != null
                ? YoutubePlayerBuilder(
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
                        print('YouTube player is ready');
                      },
                    ),
                    builder: (context, player) {
                      return player;
                    },
                  )
                : _chewieController != null &&
                        _chewieController!
                            .videoPlayerController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Chewie(controller: _chewieController!),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                        ),
                      )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            ),
        ]),
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
              widget.courseDescription,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              widget.courseDescription,
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
      if (widget.materialUrl != null && widget.materialUrl!.isNotEmpty) ...[
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
                  onPressed: () => _downloadMaterial(widget.materialUrl!),
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

      // Join/Watch Button with Zoom-style banner - Show if zoom URL or recorded URL exists
      if ((widget.zoomUrl != null && widget.zoomUrl!.isNotEmpty) ||
          (widget.recordedUrl != null && widget.recordedUrl!.isNotEmpty)) ...[
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
            bool isButtonEnabled;

            switch (status) {
              case 'scheduled':
                backgroundColor = Colors.grey.shade300;
                iconColor = Colors.grey.shade600;
                isButtonEnabled = false;
                break;
              case 'ongoing':
                backgroundColor = const Color(0xFF2D8CFF);
                iconColor = Colors.white;
                isButtonEnabled = true;
                break;
              case 'recorded':
                backgroundColor = const Color(0xFF10B981);
                iconColor = Colors.white;
                isButtonEnabled = true;
                break;
              case 'pending':
                backgroundColor = Colors.grey;
                iconColor = Colors.white;
                isButtonEnabled = false;
                break;
              case 'unavailable':
              default:
                backgroundColor = Colors.grey.shade300;
                iconColor = Colors.grey.shade600;
                isButtonEnabled = false;
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
                  // Header with Zoom logo
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
                          status == 'recorded'
                              ? Icons.play_circle_outline
                              : Icons.video_camera_front,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        status == 'recorded' ? 'Recording' : 'class',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: backgroundColor,
                          letterSpacing: -0.5,
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
                      child: ElevatedButton(
                        onPressed: isButtonEnabled && url != null
                            ? () => _launchUrl(url)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor,
                          foregroundColor: iconColor,
                          disabledBackgroundColor: backgroundColor,
                          disabledForegroundColor: iconColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Lesson Assignment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Download the file below and complete the assignment as instructed.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Current Video/Lesson Info Card

        const SizedBox(height: 24),

        // Download Assignment Card
        if (widget.assignmentUrl != null && widget.assignmentUrl!.isNotEmpty)
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
                // Assignment description
                Text(
                  widget.assignmentDescription ??
                      'Download the file below and complete the assignment as instructed.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Buttons Row
                Row(
                  children: [
                    // Preview Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _previewAssignment(widget.assignmentUrl!),
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
                            _downloadAssignment(widget.assignmentUrl!),
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

        // Submit Assignment Card - Only show if assignmentUrl exists
        if (widget.assignmentUrl != null &&
            widget.assignmentUrl!.isNotEmpty) ...[
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
                    const Text(
                      'Submit',
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
                const Text(
                  'Once you\'ve completed the assignment, submit your work here for review.',
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
                    onPressed: () {
                      // Check if quiz has been taken before allowing submission
                      if (!_quizTaken) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Quiz Required'),
                            content: const Text(
                                'You need to take the quiz first before submitting your assignment. Please go to the Quiz tab and complete the quiz.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Switch to Quiz tab (index 2)
                                  _tabController.animateTo(2);
                                },
                                child: const Text('Go to Quiz'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      _showSubmitAssignmentModal(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.3)),
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
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Take Quiz Card (Zoom style)
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
              Text(
                'Find out how much you learnt by taking a Test',
                style: const TextStyle(
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
                    final currentVideo = _courseVideos[_selectedVideoIndex];
                    final videoTitle = currentVideo['title'] as String;

                    final result = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          courseTitle: widget.courseTitle,
                          lessonTitle: videoTitle,
                        ),
                      ),
                    );

                    // Reload quiz data when returning from quiz
                    await _loadQuizData();

                    // If we have pending assignment data and quiz was completed
                    if (result != null &&
                        _pendingUsername != null &&
                        _quizTaken) {
                      _prepareAndPrintPayload(
                        score: result,
                        assignmentFileName: _pendingAssignmentFileName,
                        assignmentBase64: _pendingAssignmentFileBase64,
                        username: _pendingUsername!,
                      );

                      // Clear pending data
                      await _clearPendingAssignmentData();

                      // Open email app
                      _openEmailApp(_pendingUsername!);
                    }
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
                      // Progress circle
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: _quizScore / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFA500),
                          ),
                        ),
                      ),
                      // Score text
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_quizScore/100',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFA500),
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
              const SizedBox(height: 20),
              // Take Quiz button (below progress)
            ],
          ),
        ),
      ],
    );
  }

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
  bool _isLandscape = true;

  @override
  void initState() {
    super.initState();
    _playbackSpeed = widget.playbackSpeed;
    _isLooping = widget.isLooping;
    _setLandscapeOrientation();
    _hideControlsAfterDelay();
  }

  Future<void> _setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
    setState(() {
      _isLandscape = true;
    });
  }

  Future<void> _setPortraitOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    setState(() {
      _isLandscape = false;
    });
  }

  Future<void> _resetOrientation() async {
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

  Future<void> _handleBackButton() async {
    // Reset orientation and exit fullscreen
    await _resetOrientation();
    widget.onExit();
    if (mounted) {
      Navigator.pop(context);
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
  void dispose() {
    _resetOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video Player
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),

            // Controls Overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black38,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _handleBackButton,
                              icon: const Icon(Icons.arrow_back),
                              color: Colors.white,
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

                      // Play/Pause Button with Rewind/Forward
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Rewind 10s
                          IconButton(
                            onPressed: _seekBackward,
                            icon: const Icon(Icons.replay_10),
                            color: Colors.white,
                            iconSize: 48,
                          ),
                          const SizedBox(width: 32),
                          // Play/Pause
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
                          // Forward 10s
                          IconButton(
                            onPressed: _seekForward,
                            icon: const Icon(Icons.forward_10),
                            color: Colors.white,
                            iconSize: 48,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Progress Bar and Controls
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    // Loop button
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
                                    // Speed button
                                    InkWell(
                                      onTap: _showSpeedOptions,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
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
                                    // Exit Fullscreen button
                                    IconButton(
                                      onPressed: () async {
                                        await _resetOrientation();
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

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.assignmentUrl));
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

  Future<void> _downloadToDevice() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
        return;
      }

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

      final response = await http.get(Uri.parse(widget.assignmentUrl));
      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();
        final downloadsDir = Directory('${dir!.path}/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final fileName =
            '${widget.assignmentTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes, flush: true);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded to: ${file.path}'),
              duration: const Duration(seconds: 3),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
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
