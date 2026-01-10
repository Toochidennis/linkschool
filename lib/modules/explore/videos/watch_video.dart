import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../model/explore/videos/dashboard_video_model.dart';
import '../../model/explore/videos/video_model.dart';
import '../../model/explore/home/video_model.dart';
import '../../providers/explore/videos/video_provider.dart';
import '../../services/explore/watch_history_service.dart';

class VideoWatchScreen extends StatefulWidget {
  // For loading videos from course (subject card click)
  final String? courseId;
  final String? levelId;
  final String? courseName;

  // For playing specific video (recommended/recently watched click)
  final DashboardVideoModel? initialVideo;
  final List<DashboardVideoModel>? relatedVideos;

  const VideoWatchScreen({
    super.key,
    this.courseId,
    this.levelId,
    this.courseName,
    this.initialVideo,
    this.relatedVideos,
  });

  @override
  State<VideoWatchScreen> createState() => _VideoWatchScreenState();
}

class _VideoWatchScreenState extends State<VideoWatchScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isVideoInitialized = false;
  bool _showControls = true;
  int _selectedVideoIndex = 0;
  late TabController _tabController;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;
  bool _isFullscreen = false;
  bool _isYouTube = false;
  String? _errorMessage;

  // Dynamic video data
  List<dynamic> _courseVideos = []; // Can be DashboardVideoModel or VideoModel
  bool _isLoadingVideos = false;
  String _courseDescription = '';
  String _provider = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeScreen();
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

  Future<void> _initializeScreen() async {
    if (widget.courseId != null && widget.levelId != null) {
      // Load videos from course
      await _loadCourseVideos();
    } else if (widget.initialVideo != null) {
      // Play specific video with related videos
      _courseVideos = widget.relatedVideos ?? [widget.initialVideo!];
      _selectedVideoIndex =
          _courseVideos.indexWhere((v) => v.id == widget.initialVideo!.id);
      if (_selectedVideoIndex == -1) _selectedVideoIndex = 0;

      if (_courseVideos.isNotEmpty) {
        final firstVideo = _courseVideos[_selectedVideoIndex];
        if (firstVideo is DashboardVideoModel) {
          _courseDescription = firstVideo.description;
          _provider = firstVideo.authorName;
        }
        await _initializeVideo(
            _getVideoUrl(_courseVideos[_selectedVideoIndex]));
      }
    }
  }

  Future<void> _loadCourseVideos() async {
    setState(() => _isLoadingVideos = true);

    try {
      final provider = Provider.of<CourseVideoProvider>(context, listen: false);
      await provider.loadCourseVideos(
        courseId: widget.courseId!,
        levelId: widget.levelId!,
      );

      if (provider.courses.isNotEmpty) {
        // Flatten all videos from all courses and syllabi
        _courseVideos = provider.courses
            .expand((course) => course.syllabi)
            .expand((syllabus) => syllabus.videos)
            .toList();

        // Get course details from first video or course
        if (_courseVideos.isNotEmpty) {
          final firstVideo = _courseVideos[0];
          if (firstVideo is VideoModel) {
            _courseDescription = firstVideo.description;
            _provider = firstVideo.authorName;
          }
          await _initializeVideo(_getVideoUrl(_courseVideos[0]));
        }
      }
    } catch (e) {
      debugPrint('Error loading course videos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load videos: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingVideos = false);
    }
  }

  String _getVideoUrl(dynamic video) {
    if (video is DashboardVideoModel) {
      return video.videoUrl;
    } else if (video is VideoModel) {
      return video.videoUrl;
    }
    return '';
  }

  String _getVideoTitle(dynamic video) {
    if (video is DashboardVideoModel) {
      return video.title;
    } else if (video is VideoModel) {
      return video.title;
    }
    return 'Unknown';
  }

  String _getVideoDescription(dynamic video) {
    if (video is DashboardVideoModel) {
      return video.description;
    } else if (video is VideoModel) {
      return video.description;
    }
    return '';
  }

  String _getVideoThumbnail(dynamic video) {
    if (video is DashboardVideoModel) {
      return video.thumbnailUrl ?? '';
    } else if (video is VideoModel) {
      return video.thumbnailUrl;
    }
    return '';
  }

  String _getAuthorName(dynamic video) {
    if (video is DashboardVideoModel) {
      return video.authorName;
    } else if (video is VideoModel) {
      return video.authorName;
    }
    return 'Unknown';
  }

  Future<void> _initializeVideo(String url) async {
    // Dispose previous controllers
    await _videoController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();

    setState(() {
      _isVideoInitialized = false;
      _errorMessage = null;
    });

    try {
      debugPrint('Loading video URL: $url');

      // Check if it's a YouTube video
      if (isYouTubeUrl(url)) {
        await _initializeYouTubePlayer(url);
      } else {
        await _initializeDirectVideoPlayer(url);
      }

      // Add to watch history after successful initialization
      await _addToWatchHistory();
    } catch (e) {
      debugPrint('Error initializing video: $e');
      setState(() {
        _errorMessage = 'Failed to load video: $e';
      });
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
        autoPlay: true,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: false,
      ),
    );

    setState(() {
      _isYouTube = true;
      _isVideoInitialized = true;
    });
  }

  Future<void> _initializeDirectVideoPlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: _isLooping,
      aspectRatio: 16 / 9,
      placeholder: const Center(child: CircularProgressIndicator()),
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
      _isYouTube = false;
      _isVideoInitialized = true;
    });

    _hideControlsAfterDelay();
    _videoController!.addListener(() {
      if (_videoController!.value.position ==
          _videoController!.value.duration) {
        setState(() {
          _showControls = true;
        });
      }
    });
  }

  Future<void> _addToWatchHistory() async {
    try {
      if (_courseVideos.isNotEmpty) {
        final currentVideo = _courseVideos[_selectedVideoIndex];

        // Convert to Video model for watch history
        final Video historyVideo = Video(
          title: _getVideoTitle(currentVideo),
          url: _getVideoUrl(currentVideo),
          thumbnail: _getVideoThumbnail(currentVideo),
          description: _getVideoDescription(currentVideo),
        );

        await WatchHistoryService.addToWatchHistory(historyVideo);
      }
    } catch (e) {
      debugPrint('Error adding to watch history: $e');
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
          builder: (context) => VideoPlayerFullscreenScreen(
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
    setState(() {
      _selectedVideoIndex = index;
    });
    _initializeVideo(_getVideoUrl(_courseVideos[index]));
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

  Future<void> _handleBackButton() async {
    final currentOrientation = MediaQuery.of(context).orientation;

    if (currentOrientation == Orientation.landscape) {
      // In landscape: rotate to portrait, don't pop
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      // In portrait: pop the screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingVideos) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      );
    }

    if (_courseVideos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('No Videos Available'),
        ),
        body: Center(
          child: Text('No videos found for this course'),
        ),
      );
    }

    final currentVideo = _courseVideos[_selectedVideoIndex];

    return Scaffold(
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

  List<Widget> _buildSheetContent(dynamic currentVideo) {
    return [
      // Video Title and Description
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getVideoTitle(currentVideo),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getVideoDescription(currentVideo),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
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
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: const Color(0xFF6366F1),
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Lessons'),
          Tab(text: 'Overview'),
          Tab(text: 'Reviews'),
        ],
      ),

      // Tab Content
      SizedBox(
        height: 600,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildContentTab(),
            _buildOverviewTab(),
            _buildReviewsTab(),
          ],
        ),
      ),
    ];
  }

  Widget _buildVideoPlayer() {
    // Error display
    if (_errorMessage != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // YouTube Player
    if (_isYouTube && _youtubeController != null) {
      return YoutubePlayerBuilder(
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
            debugPrint('YouTube player is ready');
          },
        ),
        builder: (context, player) {
          return player;
        },
      );
    }

    // Chewie Player (Direct video)
    if (!_isYouTube && _chewieController != null && _isVideoInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieController!),
      );
    }

    // Loading placeholder
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
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
        final thumbnail = _getVideoThumbnail(video);

        return InkWell(
          onTap: () => _playVideo(index),
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
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      if (thumbnail.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            thumbnail,
                            width: 120,
                            height: 68,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  isSelected
                                      ? Icons.play_circle_filled
                                      : Icons.play_circle_outline,
                                  color: isSelected
                                      ? const Color(0xFF6366F1)
                                      : Colors.white,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Center(
                          child: Icon(
                            isSelected
                                ? Icons.play_circle_filled
                                : Icons.play_circle_outline,
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : Colors.white,
                            size: 32,
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
                        '${index + 1}. ${_getVideoTitle(video)}',
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
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Not completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Course',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _courseDescription.isEmpty
                ? 'No description available'
                : _courseDescription,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Instructor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _provider.isEmpty ? 'Unknown' : _provider,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Rating Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Reviews coming soon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Fullscreen Video Player Widget - YouTube-like behavior
class VideoPlayerFullscreenScreen extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onExit;
  final double playbackSpeed;
  final bool isLooping;
  final Function(double) onSpeedChange;
  final VoidCallback onLoopToggle;

  const VideoPlayerFullscreenScreen({
    super.key,
    required this.controller,
    required this.onExit,
    required this.playbackSpeed,
    required this.isLooping,
    required this.onSpeedChange,
    required this.onLoopToggle,
  });

  @override
  State<VideoPlayerFullscreenScreen> createState() =>
      _VideoPlayerFullscreenScreenState();
}

class _VideoPlayerFullscreenScreenState
    extends State<VideoPlayerFullscreenScreen> {
  late bool _showControls;
  late double _playbackSpeed;
  late bool _isLooping;

  @override
  void initState() {
    super.initState();
    _showControls = true;
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

  @override
  void dispose() {
    _resetAllOrientations();
    super.dispose();
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

  bool _isLandscape() {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = _isLandscape();

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
