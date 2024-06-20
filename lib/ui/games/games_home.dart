import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:linkschool/common/constants.dart';
import 'package:linkschool/common/text_styles.dart';

import '../../common/app_colors.dart';

class GamesHome extends StatefulWidget {
  const GamesHome({super.key});

  @override
  State<GamesHome> createState() => _GamesHomeState();
}

class _GamesHomeState extends State<GamesHome> {
  final PageController _pageController = PageController(viewportFraction: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(context),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Trending now',
                style: AppTextStyles.normal500(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 200,
              child: ListView(
                padding: EdgeInsets.only(right: 16.0),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildTrendingCard(
                    startColor: AppColors.gamesColor1,
                    endColor: AppColors.gamesColor2,
                    imagePath: 'assets/images/games_1.png',
                    gameName: 'Overwatch',
                    platform: 'Cross-platform',
                    rating: 2.5,
                  ),
                  _buildTrendingCard(
                    startColor: AppColors.gamesColor3,
                    endColor: AppColors.gamesColor4,
                    imagePath: 'assets/images/games_2.png',
                    gameName: 'Borderlands 2',
                    platform: 'Cross-platform',
                    rating: 3.5,
                  ),
                  _buildTrendingCard(
                    startColor: AppColors.gamesColor5,
                    endColor: AppColors.gamesColor6,
                    imagePath: 'assets/images/games_3.png',
                    gameName: 'Borderlands 2',
                    platform: 'Cross-platform',
                    rating: 3.5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Suggested for you',
                style: AppTextStyles.normal500(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 12.0),
            SizedBox(
                height: 300.0,
                child: PageView(
                  padEnds: false,
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  scrollBehavior: ScrollBehavior(),
                  children: [
                    _buildSuggestedCard(),
                    _buildSuggestedCard(),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard({
    required Color startColor,
    required Color endColor,
    required String imagePath,
    required String gameName,
    required String platform,
    required double rating,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16.0),
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          width: 125.0,
          height: 125.0,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  startColor,
                  endColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16.0)),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          gameName,
          style: AppTextStyles.normal500(
            fontSize: 15.0,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          platform,
          style: AppTextStyles.normal500(
            fontSize: 13.0,
            color: AppColors.text5Light,
          ),
        ),
        const SizedBox(height: 2.0),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 14.0,
          itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {},
        )
      ],
    );
  }

  Widget _buildSuggestedCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0), // Add borderRadius for ClipRRect
            child: Image.asset(
              'assets/images/millionaire.png',
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          const SizedBox(height: 16.0),
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
                height: 50.0,
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
}
