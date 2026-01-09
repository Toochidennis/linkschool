import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/model/explore/home/video_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/explore/subject_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class E_lib_vids extends StatefulWidget {
  const E_lib_vids({super.key, required this.video});
  final Video video;

  @override
  _E_lib_vidsState createState() => _E_lib_vidsState();
}

class _E_lib_vidsState extends State<E_lib_vids> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isLoading = true;
  bool _isYouTube = false;
  String? _errorMessage;

  final String description =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Null leo enim, pretium vitae nisl sit amet, bibendum euismod velit. Fusce placerat sagittis mi, id aliquet felis vehicula ac. Suspendisse mi massa, suscipit in ex id, condimentum. ";

  @override
  void initState() {
    super.initState();
    initializePlayer();
    _startLoading();
  }

  Future<void> _startLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
    }
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

  Future<void> initializePlayer() async {
    try {
      final videoUrl = widget.video.url;
      print('Loading video URL: $videoUrl');

      // Check if it's a YouTube video
      if (isYouTubeUrl(videoUrl)) {
        await _initializeYouTubePlayer(videoUrl);
      } else {
        await _initializeDirectVideoPlayer(videoUrl);
      }
    } catch (e) {
      print('Error initializing video player: $e');
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
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: false,
      ),
    );

    setState(() {
      _isYouTube = true;
    });
  }

  Future<void> _initializeDirectVideoPlayer(String url) async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
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
        playedColor: AppColors.admissionclosed,
        handleColor: AppColors.admissionclosed,
        backgroundColor: AppColors.assessmentColor1,
        bufferedColor: AppColors.assessmentColor1.withOpacity(0.5),
      ),
    );

    setState(() {
      _isYouTube = false;
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.assessmentColor3),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SubjectProvider>(
        builder: (context, subjectProvider, child) {
          // final allVideos = subjectProvider.subjects
          //     .expand((subject) => subject.categories)
          //     .expand((category) => category.videos)
          //     .toList();
          final allVideos =[];

          return Container(
            decoration: Constants.customBoxDecoration(context),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoPlayer(),
                  const SizedBox(height: 10),
                  _buildVideoMetadata(),
                  DefaultTabController(
                    length: 1,
                    child: Column(
                      children: [
                        TabBar(
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          labelColor: AppColors.text2Light,
                          indicatorColor: AppColors.text2Light,
                          unselectedLabelColor: AppColors.assessmentColor2,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            // Tab(text: 'Lessons'),
                            Tab(text: 'Related'),
                          ],
                        ),
                        LimitedBox(
                          maxHeight: 450,
                          child: TabBarView(
                            children: [
                              Skeletonizer(
                                enabled: _isLoading,
                                child: Container(),
                               // child: _buildLessonsList(allVideos),
                              ),
                              ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  Container(
                                    height: 100,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0,
                                    ),
                                    child: Text(
                                      description,
                                      style: AppTextStyles.normal400(
                                        fontSize: 14,
                                        color: AppColors.assessmentColor2,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
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
      ),
    );
  }

  Widget _buildVideoPlayer() {
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
          progressIndicatorColor: AppColors.admissionclosed,
          progressColors: ProgressBarColors(
            playedColor: AppColors.admissionclosed,
            handleColor: AppColors.admissionclosed,
            backgroundColor: AppColors.assessmentColor1,
            bufferedColor: AppColors.assessmentColor1.withOpacity(0.5),
          ),
          onReady: () {
            print('YouTube player is ready');
          },
        ),
        builder: (context, player) {
          return player;
        },
      );
    }

    // Direct Video Player (Chewie)
    if (!_isYouTube &&
        _chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieController!),
      );
    }

    // Loading placeholder
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Center(
        child: Skeletonizer(
          child: Container(
            height: 300,
            width: double.infinity,
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoMetadata() {
    String duration = 'Video';

    // Get duration from appropriate controller
    if (!_isYouTube && _videoPlayerController?.value.isInitialized == true) {
      final mins = _videoPlayerController!.value.duration.inMinutes;
      duration = '${mins}mins';
    } else if (_isYouTube && _youtubeController != null) {
      // YouTube controller provides duration in metadata
      final metaData = _youtubeController!.metadata;
      if (metaData.duration.inSeconds > 0) {
        duration = '${metaData.duration.inMinutes}mins';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            widget.video.title,
            style: AppTextStyles.normal500(
              fontSize: 22.0,
              color: AppColors.assessmentColor2,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.access_time, size: 14),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  '$duration · Lessons',
                  style: AppTextStyles.normal400(
                    fontSize: 14,
                    color: AppColors.assessmentColor2,
                  ),
                ),
              ),
              if (_isYouTube) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'YouTube',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 90,
          child: Text(
            widget.video.description ?? "",
            style: AppTextStyles.normal400(
              fontSize: 16,
              color: AppColors.assessmentColor2,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonsList(List<Video> videos) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, _, __) =>
                    E_lib_vids(video: videos[index]),
                transitionDuration: Duration.zero,
              ),
            );
          },
          child: _buildVideoCard(videos[index]),
        );
      },
    );
  }

  Future<void> _switchVideo(Video newVideo) async {
    // Dispose old controllers
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();

    // Reset state
    setState(() {
      _errorMessage = null;
      _isYouTube = false;
      _videoPlayerController = null;
      _chewieController = null;
      _youtubeController = null;
    });

    await initializePlayer();
  }

  Widget _buildVideoCard(Video video) {
    final isYouTube = isYouTubeUrl(video.url);

    return Container(
      height: 150,
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        right: 16.0,
        bottom: 18,
      ),
      decoration: const BoxDecoration(
        color: AppColors.videoCardColor,
        border: Border(
          bottom: BorderSide(color: AppColors.newsBorderColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  video.thumbnail,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 108,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: 108,
                      color: Colors.grey[300],
                      child: const Icon(Icons.videocam, size: 32),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              ),
              if (isYouTube)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'YT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal400(
                    fontSize: 16.0,
                    color: AppColors.videoColor9,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '1hr 34mins',
                  style: AppTextStyles.normal500(
                    fontSize: 12.0,
                    color: AppColors.videoColor9,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/views.png',
                      width: 16,
                      height: 16.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      "345",
                      style: AppTextStyles.normal500(
                        fontSize: 12.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    const Icon(Icons.file_download_outlined, size: 16.0),
                    const SizedBox(width: 4.0),
                    Text(
                      '12k',
                      style: AppTextStyles.normal500(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
