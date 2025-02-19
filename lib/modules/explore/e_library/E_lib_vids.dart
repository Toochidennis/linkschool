import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:chewie/chewie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:video_player/video_player.dart';

class E_lib_vids extends StatefulWidget {
  const E_lib_vids({super.key, required this.video});
  final Video video;
  @override
  _E_lib_vidsState createState() => _E_lib_vidsState();
}
class _E_lib_vidsState extends State<E_lib_vids> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  final String par_1 =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Null leo enim, pretium vitae nisl sit amet, bibendum euismod velit. Fusce placerat sagittis mi, id aliquet felis vehicula ac. Suspendisse mi massa, suscipit in ex id, condimentum. ";

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }
  Future<void> initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.video.url));
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      placeholder: Center(child: CircularProgressIndicator()),
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.admissionclosed,
        handleColor: AppColors.admissionclosed,
        backgroundColor: AppColors.assessmentColor1,
        bufferedColor: AppColors.assessmentColor1.withOpacity(0.5),
      ),
    );
    setState(() {
    
    });
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
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video player
              _chewieController != null &&
                      _chewieController!
                          .videoPlayerController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Chewie(controller: _chewieController!),
                    )
                  : AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(child: Skeletonizer(child: 
                      Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.black,
                      )
                      )),
                    ),


              SizedBox(height: 10),

              // Title
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  widget.video.title,
                  style: AppTextStyles.normal600(
                    fontSize: 22.0,
                    color: AppColors.assessmentColor2,
                  ),
                ),
              ),

              // Time info
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.access_time, size: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        '${_videoPlayerController.value.duration.inMinutes}mins . Lessons',
                        style: AppTextStyles.normal400(
                            fontSize: 14, color: AppColors.assessmentColor2),
                      ),
                    )
                  ],
                ),
              ),

              // Description
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                height: 90,
                child: Text(
                  par_1,
                  style: AppTextStyles.normal400(
                      fontSize: 16, color: AppColors.assessmentColor2),
                  textAlign: TextAlign.justify,
                ),
              ),

              // Tab section
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      labelColor: AppColors.text2Light,
                      indicatorColor: AppColors.text3Light,
                      unselectedLabelColor: AppColors.assessmentColor2,
                      dividerColor: Colors.transparent,
                      tabs: [Tab(text: 'Lessons'), Tab(text: 'Related')],
                    ),
                    LimitedBox(
                      maxHeight: 450,
                      child: TabBarView(
                        children: [
                          ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              videoSection(),
                              SizedBox(height: 10),
                              videoSection(),
                              SizedBox(height: 10),
                              videoSection(),
                              SizedBox(height: 10),
                              videoSection(),
                              SizedBox(height: 10),
                            ],
                          ),
                          ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Container(
                                height: 100,
                                width: 350,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 0),
                                child: Text(
                                  par_1,
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
      ),
    );
  }
}

class videoSection extends StatelessWidget {
  const videoSection({
    super.key,
  });

  final String par_1 =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. id aliquet felis vehicula ac. Suspendisse mi massa, suscipit in ex id, condimentum. ";

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: AssetImage(
                  'assets/images/video_images/e-vids-thumb.png',
                ),
                height: 82,
                width: 88,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Bless the Lord oh my Soul',
                            style: AppTextStyles.normal500(
                                fontSize: 16, color: AppColors.backgroundDark),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => (print("Play Clicked")),
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '2014 . 2h 30m',
                      style: AppTextStyles.normal400(
                          fontSize: 12, color: AppColors.assessmentColor2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      par_1,
                      style: AppTextStyles.normal500(
                          fontSize: 12, color: AppColors.assessmentColor2),
                      maxLines: 8,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )
    ]);
  }
}
