import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../model/explore/videos/dashboard_video_model.dart';
import '../../model/explore/videos/video_model.dart';
import '../../providers/explore/videos/video_provider.dart';

class VideoWatchScreen extends StatefulWidget {
  // For loading videos from course (subject card click)
  final String? courseId;
  final String? levelId;
  final String? courseName;

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
  bool _isVideoInitialized = false;
  bool _showControls = true;
  int _selectedVideoIndex = 0;
  late TabController _tabController;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;

  List<dynamic> _videos = []; // Can be DashboardVideoModel or VideoModel
  bool _isLoadingVideos = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    if (widget.courseId != null && widget.levelId != null) {
      // Load videos from course
      await _loadCourseVideos();
    } else if (widget.initialVideo != null) {
      // Play specific video with related videos
      _videos = widget.relatedVideos ?? [widget.initialVideo!];
      _selectedVideoIndex =
          _videos.indexWhere((v) => v.id == widget.initialVideo!.id);
      if (_selectedVideoIndex == -1) _selectedVideoIndex = 0;
      await _initializeVideo(_videos[_selectedVideoIndex].videoUrl);
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
        _videos = provider.courses
            .expand((course) => course.syllabi)
            .expand((syllabus) => syllabus.videos)
            .toList();

        if (_videos.isNotEmpty) {
          await _initializeVideo(_videos[0].videoUrl);
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

  Future<void> _initializeVideo(String url) async {
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
      _videoController!.play();
      _hideControlsAfterDelay();
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load video: $e')),
        );
      }
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

  void _playVideo(int index) {
    setState(() {
      _selectedVideoIndex = index;
    });
    final video = _videos[index];
    final videoUrl = video is DashboardVideoModel
        ? video.videoUrl
        : (video as VideoModel).videoUrl;
    _initializeVideo(videoUrl);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
    final currentVideo =
        _videos.isNotEmpty ? _videos[_selectedVideoIndex] : null;
    final videoTitle = currentVideo is DashboardVideoModel
        ? currentVideo.title
        : (currentVideo as VideoModel?)?.title ?? 'Loading...';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Video Player
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _isLoadingVideos
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _buildVideoPlayer(),
                ),
                // Bottom Sheet with video list
                Expanded(
                  child: DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: 0.6,
                    minChildSize: 0.3,
                    maxChildSize: 0.9,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Handle bar
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // Video title and info
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    videoTitle,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (currentVideo is DashboardVideoModel) ...[
                                    Text(
                                      currentVideo.courseName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'By ${currentVideo.authorName}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Tabs
                            TabBar(
                              controller: _tabController,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.blue,
                              tabs: const [
                                Tab(text: 'Videos'),
                                Tab(text: 'Description'),
                              ],
                            ),
                            // Tab content
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildVideosList(scrollController),
                                  _buildDescriptionTab(scrollController),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Back button
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_videoController!),
          if (_showControls) ...[
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
            // Play/Pause button
            IconButton(
              icon: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 64,
                color: Colors.white,
              ),
              onPressed: _togglePlayPause,
            ),
            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      _videoController!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.blue,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatDuration(_videoController!.value.position),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          _formatDuration(_videoController!.value.duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideosList(ScrollController scrollController) {
    if (_isLoadingVideos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_videos.isEmpty) {
      return const Center(
        child: Text('No videos available'),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        final isSelected = index == _selectedVideoIndex;

        String title, thumbnail, author;
        if (video is DashboardVideoModel) {
          title = video.title;
          thumbnail = video.thumbnailUrl ?? '';
          author = video.authorName;
        } else {
          final v = video as VideoModel;
          title = v.title;
          thumbnail = v.thumbnailUrl;
          author = v.authorName;
        }

        return InkWell(
          onTap: () => _playVideo(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: thumbnail.isNotEmpty
                      ? Image.network(
                          thumbnail,
                          width: 120,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 68,
                              color: Colors.grey[300],
                              child: const Icon(Icons.play_circle_outline),
                            );
                          },
                        )
                      : Container(
                          width: 120,
                          height: 68,
                          color: Colors.grey[300],
                          child: const Icon(Icons.play_circle_outline),
                        ),
                ),
                const SizedBox(width: 12),
                // Video info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        author,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.play_arrow,
                    color: Colors.blue,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionTab(ScrollController scrollController) {
    final currentVideo =
        _videos.isNotEmpty ? _videos[_selectedVideoIndex] : null;

    if (currentVideo == null) {
      return const Center(child: Text('No video selected'));
    }

    String description = '';
    if (currentVideo is DashboardVideoModel) {
      description = currentVideo.description;
    } else {
      description = (currentVideo as VideoModel).description;
    }

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About this video',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description.isEmpty ? 'No description available' : description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
