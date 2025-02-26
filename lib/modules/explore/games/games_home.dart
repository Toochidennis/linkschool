import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:linkschool/modules/providers/explore/game/game_provider.dart';
import 'package:provider/provider.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';
import '../../common/app_colors.dart';
import '../e_library/e_games/game_details.dart';

class GamesDashboard extends StatefulWidget {
  const GamesDashboard({super.key});

  @override
  State<GamesDashboard> createState() => _GamesDashboardState();
}

class _GamesDashboardState extends State<GamesDashboard> {
  @override
  void initState() {
    super.initState();
    Provider.of<GameProvider>(context, listen: false).fetchGames();
  }

  @override
  Widget build(BuildContext context) {
    final trendingItems = [
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
    ];
    final likes = [
      _buildYouMightLikeCard(
        startColor: AppColors.gamesColor5,
        endColor: AppColors.gamesColor6,
        imagePath: 'assets/images/games_3.png',
        gameName: 'Borderlands 2',
        platform: 'Cross-platform',
        rating: 3.5,
        downloadCount: 10,
      ),
      _buildYouMightLikeCard(
        startColor: AppColors.gamesColor3,
        endColor: AppColors.gamesColor4,
        imagePath: 'assets/images/games_2.png',
        gameName: 'Borderlands 2',
        platform: 'Cross-platform',
        rating: 3.5,
        downloadCount: 10,
      ),
      _buildYouMightLikeCard(
        startColor: AppColors.gamesColor1,
        endColor: AppColors.gamesColor2,
        imagePath: 'assets/images/games_1.png',
        gameName: 'Borderlands 2',
        platform: 'Cross-platform',
        rating: 3.5,
        downloadCount: 10,
      ),
      _buildYouMightLikeCard(
        startColor: AppColors.gamesColor5,
        endColor: AppColors.gamesColor6,
        imagePath: 'assets/images/games_3.png',
        gameName: 'Borderlands 2',
        platform: 'Cross-platform',
        rating: 3.5,
        downloadCount: 10,
      ),
    ];

    final gameProvider = Provider.of<GameProvider>(context);
  final games = gameProvider.games;

    return Scaffold(
      appBar: Constants.customAppBar(context: context, showBackButton: true),
      body: Container(
        padding: EdgeInsets.only(top: 35),
        decoration: Constants.customBoxDecoration(context),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Constants.heading600(
                title: 'Trending now',
                titleSize: 20.0,
                titleColor: Colors.black,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10.0)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  padding: const EdgeInsets.only(right: 16.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingItems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameDetails(),
                            )),
                        child: trendingItems[index]);
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            SliverToBoxAdapter(
              child: Constants.heading600(
                title: 'Suggested for you',
                titleSize: 20.0,
                titleColor: Colors.black,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10.0)),
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
                title: 'You might like',
                titleSize: 20.0,
                titleColor: Colors.black,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10.0)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return likes[index];
                  },
                  childCount: likes.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard(
      {required Color startColor,
      required Color endColor,
      required String imagePath,
      required String gameName,
      required String platform,
      required double rating}) {
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

  Widget _buildYouMightLikeCard({
    required Color startColor,
    required Color endColor,
    required String imagePath,
    required String gameName,
    required String platform,
    required double rating,
    required int downloadCount,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            width: 90.0,
            height: 95.0,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    startColor,
                    endColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(10.0)),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: .5,
                    color: AppColors.gamesColor9,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        gameName,
                        style: AppTextStyles.normal500(
                          fontSize: 16.0,
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16.0),
                          Text(
                            "$rating",
                            style: AppTextStyles.normal500(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          const Icon(Icons.file_download_outlined, size: 16.0),
                          Text(
                            '${downloadCount}k',
                            style: AppTextStyles.normal500(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(
                    height: 45.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.gamesColor7,
                          AppColors.gamesColor8,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.backgroundLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Play',
                            style: AppTextStyles.normal600(
                                fontSize: 14.0, color: AppColors.buttonColor1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
