import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/search_bar.dart';
import '../../common/text_styles.dart';

class VideosHome extends StatefulWidget {
  const VideosHome({super.key});

  @override
  State<VideosHome> createState() => _VideosHomeState();
}

class _VideosHomeState extends State<VideosHome> {
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
                      titleSize: 18.0,
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
                          _buildWatchHistoryCard(),
                          _buildWatchHistoryCard(),
                          _buildWatchHistoryCard(),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Constants.heading600(
                      title: 'Categories',
                      titleSize: 18.0,
                      titleColor: AppColors.primaryLight,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 240,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
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
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: .8,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return categories[index];
                        },
                      ),
                    ),
                  ),
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
      height: 150,
      width: 180,
      margin: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Image.asset(
            'assets/images/video_1.png',
            fit: BoxFit.cover,
            height: 100, // Adjust the height of the image as needed
            width: double.infinity,
          ),
          const SizedBox(height: 4.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Mastering the Act of Video editing',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.normal500(
                fontSize: 14.0,
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
                  backgroundImage: NetworkImage('profileImageUrl'),
                  radius: 10.0,
                ),
                const SizedBox(width: 4.0),
                Text(
                  'Toochi Dennis',
                  style: AppTextStyles.normal500(
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
          padding: const EdgeInsets.all(24.0),
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
          style: AppTextStyles.normal500(fontSize: 11.0, color: Colors.black),
        )
      ],
    );
  }

  Widget _recommendedForYouCard() {
    return Container(
      height: 140,
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
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
                  height: 110.0,
                  width: 140.0,
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
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'This is a mock data showing the info details of a recording.',
                ),
                SizedBox(height: 8.0),
                Text('1hr 34mins'),
                SizedBox(height: 8.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/views.png',
                      width: 16.0,
                      height: 16.0,
                    ),
                    Text(
                      "345",
                      style: AppTextStyles.normal500(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    const Icon(Icons.file_download_outlined, size: 16.0),
                    Text(
                      '${'12'}k',
                      style: AppTextStyles.normal500(
                        fontSize: 14.0,
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
