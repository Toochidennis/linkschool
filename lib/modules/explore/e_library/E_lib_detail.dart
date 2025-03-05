import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/e_library/E_lib_vids.dart';
import 'package:linkschool/modules/explore/videos/see_all_screen.dart';
// import 'package:linkschool/modules/explore/videos/see_all_screen.dart';

import 'package:provider/provider.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';
import '../../model/explore/home/video_model.dart';
import '../../providers/explore/subject_provider.dart';

import 'package:skeletonizer/skeletonizer.dart';
import '../e_library/e_lib_subject_detail.dart';

class VideoDisplay extends StatefulWidget {
  const VideoDisplay({super.key});

  @override
  State<VideoDisplay> createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  @override
  void initState() {
    super.initState();
    Provider.of<SubjectProvider>(context, listen: false).fetchSubjects();
  }

  Color _getSubjectColor(String subjectName) {
    switch (subjectName.toLowerCase()) {
      case 'english language':
        return AppColors.videoColor1;

      case 'mathematics':
        return AppColors.videoColor2;
      case 'physics':
        return AppColors.videoColor3;
      case 'chemistry':
        return AppColors.videoColor4;
      case 'biology':
        return AppColors.videoColor5;

      default:
        return AppColors.videoColor3;
    }
  }

  List<String> subjectIcons = [
    'english',
    'maths',
    'physics',
    'chemistry',
    'biology',
  ];

  List<String> subjectName = [
    'English',
    'maths',
    'physics',
    'chemistry',
    'biology',
  ];
_navigateToSeeall() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeeallScreen(),
        ));
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
        if (subjectProvider.isLoading) {
          return Scaffold(
            body: Skeletonizer(
              child: Container(
                decoration: Constants.customBoxDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Constants.headingWithSeeAll600(
                              title: 'Watch history',
                              titleSize: 14.0,
                              titleColor: AppColors.primaryLight,

                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 200.0,
                              child: ListView.builder(
                                itemCount: 7,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Skeletonizer(
                                    child: Container(
                                      width: 100,
                                      color: Colors.amber,
                                      height: 100,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                              child: Constants.heading600(
                            title: 'Categories',
                            titleSize: 16.0,
                            titleColor: AppColors.primaryLight,
                          )),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: 10.0)),
                          SliverToBoxAdapter(
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              double screenHeight =
                                  MediaQuery.of(context).size.height;
                              double screenWidth =
                                  MediaQuery.of(context).size.width;
                              double height = screenHeight * 0.34;
                              double aspectRatio =
                                  (screenWidth / 4) / (height / 2);

                              return Container(
                                height: height,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3.2,
                                  vertical: 1.90,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.videoCardColor,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.videoCardBorderColor,
                                    ),
                                    top: BorderSide(
                                      color: AppColors.videoCardBorderColor,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: aspectRatio,
                                  ),
                                  itemCount: 8,
                                  itemBuilder: (context, index) {
                                    return _buildCategoriesCard(
                                      subjectName: 'Loading...',
                                      subjectIcon: 'english',
                                      backgroundColor: AppColors.videoColor1,
                                    );
                                  },
                                ),
                              );
                            }),
                          ),
                          const SliverToBoxAdapter(
                              child: SizedBox(height: 19.0)),
                          SliverToBoxAdapter(
                            child: Constants.heading600(
                              title: 'Recommended for you',
                              titleSize: 16.0,
                              titleColor: AppColors.primaryLight,
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _recommendedForYouCard(Video(
                                  title: 'Loading...',
                                  url: '',
                                  thumbnail: '',
                                  author: '',
                                ));
                              },
                              childCount: 6,
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
        } else {
          final categories = subjectProvider.subjects
              .map((subject) => _buildCategoriesCard(
                    subjectName:
                        subjectName[subjectProvider.subjects.indexOf(subject)],
                    subjectIcon:
                        subjectIcons[subjectProvider.subjects.indexOf(subject)],
                    backgroundColor: _getSubjectColor(subject.name),
                  ))
              .toList();

          final allVideos = subjectProvider.subjects
              .expand((subject) => subject.categories)
              .expand((category) => category.videos)
              .toList();

          final recommendationVideos = allVideos.length > 4
              ? allVideos.getRange(0, 6).toList()
              : allVideos;

          return Scaffold(
            body: Container(
              decoration: Constants.customBoxDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Constants.headingWithSeeAll600(
                            title: 'Watch history',
                            titleSize: 18.0,
                            titleColor: AppColors.primaryLight,
                            SeeAllPressed: _navigateToSeeall
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 150.0,
                            child: ListView.builder(
                              itemCount: allVideos.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => E_lib_vids(
                                                video: allVideos[index])),
                                      );
                                    },
                                    child: _buildWatchHistoryCard(
                                        allVideos[index]));
                              },
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                            child: Constants.heading600(
                          title: 'Categories',
                          titleSize: 18.0,
                          titleColor: AppColors.primaryLight,
                        )),
                        const SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                        SliverToBoxAdapter(
                          child: LayoutBuilder(builder: (context, constraints) {
                            double screenHeight =
                                MediaQuery.of(context).size.height;
                            double screenWidth =
                                MediaQuery.of(context).size.width;
                            double height = screenHeight * 0.34;
                            double aspectRatio =
                                (screenWidth / 4) / (height / 2);

                            return Container(
                              height: height,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3.2,
                                vertical: 1.90,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.videoCardColor,
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.videoCardBorderColor,
                                  ),
                                  top: BorderSide(
                                    color: AppColors.videoCardBorderColor,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  childAspectRatio: aspectRatio,
                                ),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ELibSubjectDetail(
                                                    subject: subjectProvider
                                                        .subjects[index])),
                                      );
                                    },
                                    child: categories[index],
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 19.0)),
                        SliverToBoxAdapter(
                          child: Constants.heading600(
                            title: 'Recommended for you',
                            titleSize: 18.0,
                            titleColor: AppColors.primaryLight,
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                          
                            (context, index) {
                              if (index < recommendationVideos.length) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => E_lib_vids(
                                          video: recommendationVideos[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: _recommendedForYouCard(
                                      recommendationVideos[index]),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            childCount: recommendationVideos.length,
                          ),
                        
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: 100,),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildWatchHistoryCard(Video video) {
    return Container(
      height: 146,
      width: 150,
      margin: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Image.network(
            video.thumbnail,
            fit: BoxFit.cover,
            height: 92,
            width: 150,
          ),
          const SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              video.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.normal600(
                fontSize: 16.0,
                color: AppColors.backgroundDark,
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          
        ],
      ),
    );
  }

  Widget _buildCategoriesCard({
    required String subjectName,
    required String subjectIcon,
    required Color backgroundColor,
    // Video? video,
    // Category? category,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            Container(
              height: 60,
              width: 60,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Image.asset(
                'assets/icons/$subjectIcon.png',
                color: Colors.white,
                width: 24.0,
                height: 24.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                subjectName,
                style: AppTextStyles.normal500(
                    fontSize: 14.0, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _recommendedForYouCard(Video video) {
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
                  style: AppTextStyles.normal500(
                    fontSize: 16.0,
                    color: AppColors.videoColor9,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  video.runtimeType.toString(),
                  style: AppTextStyles.normal500(
                    fontSize: 10.0,
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
                        fontSize: 10.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    const Icon(Icons.file_download_outlined, size: 16.0),
                    Text(
                      '12k',
                      style: AppTextStyles.normal500(
                        fontSize: 10,
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