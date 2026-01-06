import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseTitle;
  final String courseDescription;
  final String provider;

  const CourseDetailScreen({
    super.key,
    required this.courseTitle,
    required this.courseDescription,
    required this.provider,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _showControls = true;
  int _selectedVideoIndex = 0;
  late TabController _tabController;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;
  bool _isFullscreen = false;
  bool _isSheetFullyExpanded = false;
  bool _isContentScrolling = false;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // Sample video data - using sample video URLs
  final List<Map<String, dynamic>> _courseVideos = [
    {
      'title': 'Introduction to the Course',
      'duration': '12:45',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'isIntro': true,
      'description':
          'Welcome to the course! In this introduction, we\'ll cover what you\'ll learn, the prerequisites, and how to get the most out of this course.',
    },
    {
      'title': 'Getting Started - Setup',
      'duration': '8:30',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'isIntro': false,
      'description': 'Learn how to set up your development environment.',
    },
    {
      'title': 'Understanding the Basics',
      'duration': '15:20',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'isIntro': false,
      'description': 'Master the fundamental concepts you need to know.',
    },
    {
      'title': 'Advanced Concepts',
      'duration': '22:15',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'isIntro': false,
      'description': 'Dive deeper into advanced techniques and best practices.',
    },
    {
      'title': 'Practical Examples',
      'duration': '18:40',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      'isIntro': false,
      'description': 'Apply what you\'ve learned with hands-on examples.',
    },
    {
      'title': 'Common Pitfalls to Avoid',
      'duration': '10:25',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      'isIntro': false,
      'description': 'Learn about common mistakes and how to avoid them.',
    },
    {
      'title': 'Building Your First Project',
      'duration': '25:30',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      'isIntro': false,
      'description': 'Put everything together in a complete project.',
    },
    {
      'title': 'Final Project and Next Steps',
      'duration': '16:50',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      'isIntro': false,
      'description': 'Complete the final project and discover where to go next.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeVideo(_courseVideos[0]['url'] as String);
  }

  Future<void> _initializeVideo(String url) async {
    // Dispose previous controller
    await _videoController?.dispose();

    setState(() {
      _isVideoInitialized = false;
    });

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      setState(() {
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
    } catch (e) {
      debugPrint('Error initializing video: $e');
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
            }).toList(),
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
    setState(() {
      _selectedVideoIndex = index;
    });
    _initializeVideo(_courseVideos[index]['url'] as String);
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
    _tabController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = _courseVideos[_selectedVideoIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player - Fixed at top
          SafeArea(
            bottom: false,
            child: _buildVideoPlayer(),
          ),

          // Draggable Content Sheet (YouTube-style)
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.73, // Expands by ~70px (8% more)
            snap: true,
            snapSizes: const [0.65, 0.73],
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  // Lock when reaching expanded state
                  if (notification.extent >= 0.72) {
                    if (!_isSheetFullyExpanded) {
                      setState(() {
                        _isSheetFullyExpanded = true;
                      });
                    }
                  } else {
                    if (_isSheetFullyExpanded) {
                      setState(() {
                        _isSheetFullyExpanded = false;
                      });
                    }
                  }
                  return true;
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag Handle
                      GestureDetector(
                        onVerticalDragUpdate: (details) {
                          // Allow dragging down to collapse when fully expanded
                          if (_isSheetFullyExpanded && details.delta.dy > 0) {
                            setState(() {
                              _isSheetFullyExpanded = false;
                            });
                            _sheetController.animateTo(
                              0.65,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: Colors.transparent,
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (!_isSheetFullyExpanded) {
                              // When user tries to scroll content, expand the sheet first
                              if (scrollNotification is ScrollStartNotification) {
                                _sheetController.animateTo(
                                  0.73,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                );
                                return true;
                              }
                            } else {
                              // When expanded, monitor scroll position
                              if (scrollNotification is ScrollUpdateNotification) {
                                final scrollPosition = scrollNotification.metrics.pixels;
                                
                                // Collapse when scrolling up to top (title section)
                                if (scrollPosition <= 0 && scrollNotification.scrollDelta! < 0) {
                                  setState(() {
                                    _isSheetFullyExpanded = false;
                                  });
                                  _sheetController.animateTo(
                                    0.65,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                  );
                                  return true;
                                }
                                
                                // Also collapse when user scrolls back up and reaches near the top
                                if (scrollPosition < 50 && scrollNotification.scrollDelta! < 0) {
                                  setState(() {
                                    _isSheetFullyExpanded = false;
                                  });
                                  _sheetController.animateTo(
                                    0.65,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                  );
                                  return true;
                                }
                              }
                            }
                            return false;
                          },
                          child: _isSheetFullyExpanded
                              ? ListView(
                                  padding: EdgeInsets.zero,
                                  children: _buildSheetContent(currentVideo),
                                )
                              : ListView(
                                  controller: scrollController,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: _buildSheetContent(currentVideo),
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
              currentVideo['title'] as String,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.provider[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.provider,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${_courseVideos.length} lectures • ${_calculateTotalDuration()}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border),
                  color: const Color(0xFF6366F1),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                  color: const Color(0xFF6366F1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentVideo['description'] as String,
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
          Tab(text: 'Lesson'),
          Tab(text: 'Overview'),
          Tab(text: 'Reviews'),
        ],
      ),

      // Tab Content
      SizedBox(
        height: 800,
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
    return Container(
      width: double.infinity,
      height: 240,
      color: Colors.black,
      child: Stack(
        children: [
          // Video
          if (_isVideoInitialized && _videoController != null)
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            ),

          // Controls Overlay
          if (_isVideoInitialized)
            GestureDetector(
              onTap: _toggleControls,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black38,
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
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
                                    Icon(Icons.repeat, color: Colors.white, size: 14),
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
                            iconSize: 40,
                          ),
                          const SizedBox(width: 20),
                          // Play/Pause
                          IconButton(
                            onPressed: _togglePlayPause,
                            icon: Icon(
                              _videoController!.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              size: 64,
                            ),
                            color: Colors.white,
                          ),
                          const SizedBox(width: 20),
                          // Forward 10s
                          IconButton(
                            onPressed: _seekForward,
                            icon: const Icon(Icons.forward_10),
                            color: Colors.white,
                            iconSize: 40,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            VideoProgressIndicator(
                              _videoController!,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: Color(0xFF6366F1),
                                bufferedColor: Colors.grey,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _formatDuration(
                                          _videoController!.value.position),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      ' / ${_formatDuration(_videoController!.value.duration)}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
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
                                        _isLooping ? Icons.repeat_on : Icons.repeat,
                                        color: _isLooping
                                            ? const Color(0xFF6366F1)
                                            : Colors.white,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    // Speed button
                                    InkWell(
                                      onTap: _showSpeedOptions,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${_playbackSpeed}x',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Fullscreen button
                                    IconButton(
                                      onPressed: _toggleFullscreen,
                                      icon: const Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                      Center(
                        child: Icon(
                          isSelected ? Icons.play_circle_filled : Icons.play_circle_outline,
                          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
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
            widget.courseDescription,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'What You\'ll Learn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            'Master the fundamentals from scratch',
            'Build real-world projects',
            'Understand advanced concepts',
            'Best practices and common pitfalls',
            'Hands-on coding exercises',
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
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
          child: Row(
            children: [
              Column(
                children: [
                  const Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFA500),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star,
                        color: Color(0xFFFFA500),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1,234 ratings',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 12,
                            child: Text(
                              '$star',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (6 - star) * 0.18,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFA500)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Individual Reviews
        ...List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF6366F1),
                      child: Text(
                        'U${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User ${index + 1}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '2 weeks ago',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (starIndex) => Icon(
                          starIndex < 4 ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFA500),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Great course! The instructor explains everything clearly and the examples are very practical. Highly recommended for anyone wanting to learn.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }),
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

  @override
  void initState() {
    super.initState();
    _playbackSpeed = widget.playbackSpeed;
    _isLooping = widget.isLooping;
    _hideControlsAfterDelay();
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
            }).toList(),
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
                              onPressed: () {
                                widget.onExit();
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close),
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
                                    Icon(Icons.repeat, color: Colors.white, size: 14),
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
                                        _isLooping ? Icons.repeat_on : Icons.repeat,
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
                                          borderRadius: BorderRadius.circular(6),
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
                                      onPressed: () {
                                        widget.onExit();
                                        Navigator.pop(context);
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