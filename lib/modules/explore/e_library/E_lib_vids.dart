import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/model/explore/home/video_model.dart';
// import 'package:linkschool/modules/model/explore/home/subject_model.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/explore/subject_provider.dart';
import 'package:video_player/video_player.dart';

import '../../model/explore/home/subject_model2.dart';

class E_lib_vids extends StatefulWidget {
  const E_lib_vids({super.key, required this.video});
  final Video video;

  @override
  _E_lib_vidsState createState() => _E_lib_vidsState();
}

class _E_lib_vidsState extends State<E_lib_vids> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

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

  Future<void> initializePlayer() async {
    try {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.video.url));
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
        placeholder: const Center(child: CircularProgressIndicator()),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.admissionclosed,
          handleColor: AppColors.admissionclosed,
          backgroundColor: AppColors.assessmentColor1,
          bufferedColor: AppColors.assessmentColor1.withOpacity(0.5),
        ),
      );
      if (mounted) setState(() {});
    } catch (e) {
      print('Error initializing video player: $e');
      // Handle error appropriately
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
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
          final allVideos = subjectProvider.subjects
              .expand((subject) => subject.categories)
              .expand((category) => category.videos)
              .toList();

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
                    length: 2,
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
                            Tab(text: 'Lessons'),
                            Tab(text: 'Related'),
                          ],
                        ),
                        LimitedBox(
                          maxHeight: 450,
                          child: TabBarView(
                            children: [
                              Skeletonizer(
                                enabled: _isLoading,
                                child: _buildLessonsList(allVideos),
                              ),
                              ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  Container(
                                    height: 100,
                                    width: 350,
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

  // Widget builder methods
  Widget _buildVideoPlayer() {
    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieController!),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Center(
        child: Skeletonizer(
          child: Container(
            height: 300,
            width: double.infinity,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoMetadata() {
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
                  '${_videoPlayerController.value.duration.inMinutes}mins . Lessons',
                  style: AppTextStyles.normal400(
                    fontSize: 14,
                    color: AppColors.assessmentColor2,
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 90,
          child: Text(
            description,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => E_lib_vids(video: videos[index]),
              ),
            );
          },
          child: _buildVideoCard(videos[index]),
        );
      },
    );
  }

  Widget _buildVideoCard(Video video) {
    return Container(
      height: 121,
      padding:
          const EdgeInsets.only(left: 16.0, top: 16.0, right: 8.0, bottom: 18),
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
                ),
              ),
              Positioned(
                child: Container(
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
              )
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
                    Text(
                      "345",
                      style: AppTextStyles.normal500(
                        fontSize: 12.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    const Icon(Icons.file_download_outlined, size: 16.0),
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
