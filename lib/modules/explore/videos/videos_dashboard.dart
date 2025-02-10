import 'package:flutter/material.dart';
import 'package:linkschool/modules/E_library/e_lib_vids.dart';

import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/search_bar.dart';
import '../../common/text_styles.dart';

class VideosDashboard extends StatefulWidget {
  const VideosDashboard({super.key});

  @override
  State<VideosDashboard> createState() => _VideosDashboardState();
}

class _VideosDashboardState extends State<VideosDashboard> {
  @override
  Widget build(BuildContext context) {
    final categories = [
      _buildCategoriesCard(
        subjectName: 'English',
        subjectIcon: "english",
        backgroundColor: AppColors.videoColor1,
      ),
      _buildCategoriesCard(
        subjectName: 'Mathematics',
        subjectIcon: "maths",
        backgroundColor: AppColors.videoColor2,
      ),
      _buildCategoriesCard(
        subjectName: 'Chemistry',
        subjectIcon: "chemistry",
        backgroundColor: AppColors.videoColor3,
      ),
      _buildCategoriesCard(
        subjectName: 'Physics',
        subjectIcon: "physics",
        backgroundColor: AppColors.videoColor4,
      ),
      _buildCategoriesCard(
        subjectName: 'Further Maths',
        subjectIcon: "further_maths",
        backgroundColor: AppColors.videoColor5,
      ),
      _buildCategoriesCard(
        subjectName: 'Biology',
        subjectIcon: "biology",
        backgroundColor: AppColors.videoColor6,
      ),
      _buildCategoriesCard(
        subjectName: 'Geography',
        subjectIcon: "geography",
        backgroundColor: AppColors.videoColor7,
      ),
      _buildCategoriesCard(
        subjectName: 'Agric',
        subjectIcon: "agric",
        backgroundColor: AppColors.videoColor8,
      ),
    ];

    final recommendations = [
      _recommendedForYouCard(),
      _recommendedForYouCard(),
      _recommendedForYouCard(),
      _recommendedForYouCard(),
    ];

    return Scaffold(
      appBar: Constants.customAppBar(context: context),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CustomSearchBar(),
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
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 16.0),
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => E_lib_vids(),
                                ),
                              );
                            },
                            child: _buildWatchHistoryCard(),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => E_lib_vids(),
                                ),
                              );
                            },
                            child: _buildWatchHistoryCard(),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => E_lib_vids(),
                                ),
                              );
                            },
                            child: _buildWatchHistoryCard(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Constants.heading600(
                      title: 'Categories',
                      titleSize: 16.0,
                      titleColor: AppColors.primaryLight,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                  SliverToBoxAdapter(
                    child: LayoutBuilder(builder: (context, constraints) {
                      double screenHeight = MediaQuery.of(context).size.height;
                      double screenWidth = MediaQuery.of(context).size.width;

                      double height = screenHeight * 0.34;
                      double aspectRatio = (screenWidth / 4) / (height / 2);

                      return Container(
                        height: height,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 1.99,
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
                            return categories[index];
                          },
                        ),
                      );
                    }),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 19.0)),
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
                        return recommendations[index];
                      },
                      childCount: recommendations.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchHistoryCard() {
    return Container(
      height: 146,
      width: 150,
      margin: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Image.asset(
            'assets/images/video_1.png',
            fit: BoxFit.cover,
            height: 92, // Adjust the height of the image as needed
            width:150,
          ),
          const SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Mastering the Act of Video editing',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.normal500(
                fontSize: 12.0,
                color: AppColors.backgroundDark,
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                const CircleAvatar(
                  // backgroundImage: NetworkImage('profileImageUrl'),
                  backgroundColor: AppColors.videoColor9,
                  radius: 10.0,
                  child: Icon(Icons.person_2_rounded, size: 14.0, 
                  color: Colors.white,),
                  ),
                const SizedBox(width: 4.0),
                Text(
                  'Toochi Dennis',
                  style: AppTextStyles.normal400(
                    fontSize: 12.0,
                    color: AppColors.videoColor9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCard({
    required String subjectName,
    required String subjectIcon,
    required Color backgroundColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60,
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
        Text(
          subjectName,
          style: AppTextStyles.normal500(fontSize: 12.0, color: Colors.black),
        )
      ],
    );
  }

  Widget _recommendedForYouCard() {
    return Container(
      height: 121,
      
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 8.0, bottom: 8.0),
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
                child: Image.asset(
                  'assets/images/video_1.png',
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
          SizedBox(width: 8.0),
          Expanded(
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'This is a mock data showing the info details of a recording.',
                  style: AppTextStyles.normal400(
                    fontSize: 14.0,
                    color: AppColors.videoColor9,
                  ),
                ),
                SizedBox(height: 4.0),
                Text('1hr 34mins', style: AppTextStyles.normal500(
                    fontSize: 10.0,
                    color: AppColors.videoColor9,
                  )),
                SizedBox(height: 4.0),
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
                      '${'12'}k',
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
