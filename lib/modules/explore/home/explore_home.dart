import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/search_bar.dart';
import 'package:linkschool/modules/explore/home/explore_item.dart';

import '../../common/text_styles.dart';
import '../../../modules/explore/games/games_home.dart';
import '../../../modules/explore/videos/videos_dashboard.dart';
import '../../common/app_colors.dart';
import '../../../modules/explore/ebooks/ebooks_dashboard.dart';
import '../../common/constants.dart';
import '../../../modules/explore/cbt/cbt_dashboard.dart';
import 'custom_button_item.dart';

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
        newsContent:
            'This is a mock data showing the info details of a recording.',
        time: '2 hours ago',
        imageUrl:
            'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
      ),
      _buildNewsItem(
        profileImageUrl:
            'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
        newsContent:
            'This is a mock data showing the info details of a recording.',
        time: '2 minutes ago',
        imageUrl: 'https://via.placeholder.com/300',
      ),
      _buildNewsItem(
        profileImageUrl:
            'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
        newsContent:
            'This is a mock data showing the info details of a recording.',
        time: '2 minutes ago',
        imageUrl: 'https://via.placeholder.com/300',
      ),
    ];

    List<ExploreItem> exploreItemsList = [
      ExploreItem(
        backgroundColor: AppColors.exploreButton1Light,
        borderColor: AppColors.exploreButton1BorderLight,
        label: 'CBT',
        iconPath: 'assets/icons/cbt.svg',
        destination: const CBTDashboard(),
      ),
      ExploreItem(
        backgroundColor: AppColors.exploreButton3Light,
        borderColor: AppColors.exploreButton3BorderLight,
        label: 'E-Books',
        iconPath: 'assets/icons/e-books.svg',
        destination: const EbooksDashboard(),
      ),
      ExploreItem(
        backgroundColor: AppColors.exploreButton2Light,
        borderColor: AppColors.exploreButton2BorderLight,
        label: 'Videos',
        iconPath: 'assets/icons/video.svg',
        destination: const VideosDashboard(),
      ),
      ExploreItem(
        backgroundColor: AppColors.exploreButton4Light,
        borderColor: AppColors.exploreButton4BorderLight,
        label: 'Games',
        iconPath: 'assets/icons/games.svg',
        destination: const GamesDashboard(),
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
                      _buildSuggestedGameCard(leftPadding: 16.0),
                      _buildSuggestedGameCard(),
                      _buildSuggestedGameCard(rightPadding: 16.0),
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
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 14.0,
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 14.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = exploreItemsList[index];
                        return exploreButtonItem(
                          backgroundColor: item.backgroundColor,
                          borderColor: item.backgroundColor,
                          label: item.label,
                          iconPath: item.iconPath,
                          destination: item.destination,
                        );
                      },
                      childCount: exploreItemsList.length,
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

  Widget _buildSuggestedGameCard({
    double? leftPadding,
    double? rightPadding,
  }) {
    return Padding(
      padding: EdgeInsets.only(
          left: leftPadding ?? 10.0, right: rightPadding ?? 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGameImage(),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGameInfo(),
              _buildPlayButton(),
            ],
          ),
        ],
      ),
    );
  }

// Widget for the game image
  Widget _buildGameImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.asset(
        'assets/images/millionaire.png',
        fit: BoxFit.cover,
        height: 200,
      ),
    );
  }

// Widget for the game title and developer information
  Widget _buildGameInfo() {
    return Column(
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
    );
  }

// Widget for the play button
  Widget _buildPlayButton() {
    return Container(
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
          onPressed: () {
            // Handle button press
          },
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
              style:
                  AppTextStyles.normal500(fontSize: 14.0, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget exploreButtonItem({
    required Color backgroundColor,
    required Color borderColor,
    required String label,
    required String iconPath,
    required Widget destination,
  }) {
    return CustomButtonItem(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      label: label,
      iconPath: iconPath,
      destination: destination,
    );
  }

  Widget _buildNewsItem({
    required String profileImageUrl,
    required String newsContent,
    required String time,
    required String imageUrl,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    newsContent,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.normal500(
                      fontSize: 14.0,
                      color: AppColors.text4Light,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    time,
                    style: AppTextStyles.normal500(
                      fontSize: 12.0,
                      color: AppColors.text4Light,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _buildActionButtons(),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            _buildNewsImage(imageUrl),
          ],
        ),
      ),
    );
  }

// Widget for action buttons (like, comment, share)
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.favorite_outline),
          onPressed: () {}, // Add your onPressed logic here
        ),
        const SizedBox(width: 4.0),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/comment.svg',
            height: 20.0,
            width: 20.0,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4.0),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/share.svg',
            height: 22.0,
            width: 22.0,
          ),
          onPressed: () {}, // Add your onPressed logic here
        ),
      ],
    );
  }

// Widget for the news image
  Widget _buildNewsImage(String imageUrl) {
    return SizedBox(
      width: 140.0,
      height: 100.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
