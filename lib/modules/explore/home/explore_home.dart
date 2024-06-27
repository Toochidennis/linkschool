import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/search_bar.dart';

import '../../common/text_styles.dart';
import '../../../modules/explore/games/games_home.dart';
import '../../../modules/explore/videos/videos_home.dart';
import '../../common/app_colors.dart';
import '../../../modules/explore/ebooks/ebooks_dashboard.dart';
import '../../common/constants.dart';
import '../../../modules/explore/cbt/cbt_home.dart';
import 'custom_button.dart';

class ExploreHome extends StatefulWidget {
  const ExploreHome({super.key});

  @override
  State<ExploreHome> createState() => _ExploreHomeState();
}

class _ExploreHomeState extends State<ExploreHome> {
  @override
  Widget build(BuildContext context) {
    final newsItems = [
      _buildNewsItem(
        profileImageUrl: 'https://via.placeholder.com/300',
        name: 'John Doe',
        newsContent:
            'This is a mock data showing the info details of a recording.',
        time: '2 hours ago',
        imageUrl:
            'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
      ),
      _buildNewsItem(
        profileImageUrl:
            'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
        name: 'Vanguard news',
        newsContent:
            'This is a mock data showing the info details of a recording.',
        time: '2 minutes ago',
        imageUrl: 'https://via.placeholder.com/300',
      ),
      _buildNewsItem(
        profileImageUrl:
            'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
        name: 'Vanguard news',
        newsContent:
            'This is a mock data showing the info details of a recording.',
        time: '2 minutes ago',
        imageUrl: 'https://via.placeholder.com/300',
      ),
    ];

    return Container(
      decoration: Constants.customBoxDecoration(context),
      padding: const EdgeInsets.only(bottom: 90.0),
      child: Column(
        children: [
          const CustomSearchBar(),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: CarouselSlider(
                    items: [
                      _buildSuggestedCard(left: 16.0),
                      _buildSuggestedCard(),
                      _buildSuggestedCard(right: 16.0),
                    ],
                    options: CarouselOptions(
                      height: 280.0,
                      padEnds: false,
                      viewportFraction: 0.95,
                      autoPlay: true,
                      enableInfiniteScroll: false,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                SliverToBoxAdapter(
                  child: Constants.heading600(
                    title: 'Explore',
                    titleSize: 20.0,
                    titleColor: AppColors.text2Light,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              CustomIconButton(
                                backgroundColor: AppColors.exploreButton1Light,
                                borderColor:
                                    AppColors.exploreButton1BorderLight,
                                text: 'CBT',
                                iconPath: 'assets/icons/cbt.svg',
                                destination: CBTHome(),
                              ),
                              SizedBox(height: 14.0),
                              CustomIconButton(
                                backgroundColor: AppColors.exploreButton2Light,
                                borderColor:
                                    AppColors.exploreButton2BorderLight,
                                text: 'Videos',
                                iconPath: 'assets/icons/video.svg',
                                destination: VideosHome(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            children: [
                              CustomIconButton(
                                backgroundColor: AppColors.exploreButton3Light,
                                borderColor:
                                    AppColors.exploreButton3BorderLight,
                                text: 'E-Books',
                                iconPath: 'assets/icons/e-books.svg',
                                destination: BooksHome(),
                              ),
                              SizedBox(height: 14.0),
                              CustomIconButton(
                                backgroundColor: AppColors.exploreButton4Light,
                                borderColor:
                                    AppColors.exploreButton4BorderLight,
                                text: 'Games',
                                iconPath: 'assets/icons/games.svg',
                                destination: GamesHome(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Constants.headingWithSeeAll600(
                    title: 'News',
                    titleSize: 20.0,
                    titleColor: AppColors.text2Light,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return newsItems[index];
                    },
                    childCount: newsItems.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedCard({
    double? left,
    double? right,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: left ?? 10.0, right: right ?? 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            // Add borderRadius for ClipRRect
            child: Image.asset(
              'assets/images/millionaire.png',
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Millionaire Game',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'By Digital Dreams',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              Container(
                height: 45.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.buttonColor2,
                      AppColors.buttonColor3,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Play',
                        style: AppTextStyles.normal500(
                            fontSize: 14.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem({
    required String profileImageUrl,
    required String name,
    required String newsContent,
    required String time,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.newsBorderColor,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Align children at the top
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    newsContent,
                    style: AppTextStyles.normal3Light,
                  ),
                ),
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    time,
                    style: AppTextStyles.normal4Light,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_outline),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/comment.svg',
                        height: 20.0,
                        width: 20.0,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/share.svg',
                        height: 22.0,
                        width: 22.0,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          Align(
            alignment: Alignment.topCenter,
            // Align the image container to the top
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                width: 140.0,
                height: 100.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 0.4),
                      blurRadius: 1.05,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    imageUrl,
                    width: 140.33,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
