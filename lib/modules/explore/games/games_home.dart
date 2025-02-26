import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:linkschool/modules/explore/games/game_details.dart';
import 'package:linkschool/modules/model/explore/games/game_model.dart';
import 'package:linkschool/modules/providers/explore/game/game_provider.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';
import '../../common/app_colors.dart';

class GamesDashboard extends StatefulWidget {
  const GamesDashboard({super.key});

  @override
  State<GamesDashboard> createState() => _GamesDashboardState();
}

class _GamesDashboardState extends State<GamesDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).fetchGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(context: context, showBackButton: true),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final games = gameProvider.games;

          if (games == null) {
            return const Center(
                child: Skeletonizer(
              child: SizedBox(
                height: 100,
                width: 200,
              ),
            ));
          }

          // Prepare a list of all game categories to display
          final gameCategories = [
            games.cardGames,
            games.boardGames,
            games.puzzleGames,
            games.actionGames,
            games.sportsGames
          ];

          // Define color pairs for each category
          final colorPairs = [
            [AppColors.gamesColor1, AppColors.gamesColor2],
            [AppColors.gamesColor3, AppColors.gamesColor4],
            [AppColors.gamesColor5, AppColors.gamesColor6],
            [AppColors.gamesColor3, AppColors.gamesColor4],
            [AppColors.gamesColor5, AppColors.gamesColor6],
          ];

          return Container(
            padding: const EdgeInsets.only(top: 16),
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
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: gameCategories.length,
                      itemBuilder: (context, index) {
                        return _buildGameCard(
                          context,
                          gameCategories[index],
                          colorPairs[index][0],
                          colorPairs[index][1],
                        );
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
                  child: CarouselSlider.builder(
                    itemCount: games.puzzleGames.games.length,
                    itemBuilder: (context, index, realIndex) {
                      final game = games.puzzleGames.games[index];
                      return _buildSuggestedCard(
                        game: game,
                        left: index == 0 ? 16.0 : 10.0,
                        right: index == games.puzzleGames.games.length - 1
                            ? 16.0
                            : 0.0,
                      );
                    },
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
                        final game = games.puzzleGames.games[index];
                        return GestureDetector(
                          onTap: () => GameDetails(game: game),
                          child: _buildYouMightLikeCard(
                            game: game,
                            startColor: AppColors.gamesColor5,
                            endColor: AppColors.gamesColor6,
                          ),
                        );
                      },
                      childCount: 2,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Constants.heading600(
                    title: 'Sports Game',
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
                        final game = games.sportsGames.games[index];
                        return GestureDetector(
                          onTap: () => GameDetails(game: game),
                          child: _buildYouMightLikeCard(
                            game: game,
                            startColor: AppColors.gamesColor5,
                            endColor: AppColors.gamesColor6,
                          ),
                        );
                      },
                      childCount: games.sportsGames.games.length,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Constants.heading600(
                    title: 'Action Game',
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
                        final game = games.actionGames.games[index];
                        return GestureDetector(
                          onTap: () => GameDetails(game: game),
                          child: _buildYouMightLikeCard(
                            game: game,
                            startColor: AppColors.gamesColor5,
                            endColor: AppColors.gamesColor6,
                          ),
                        );
                      },
                      childCount: games.actionGames.games.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingCard({
    required Game game,
    required Color startColor,
    required Color endColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16.0),
          padding: const EdgeInsets.all(16.0),
          width: 125.0,
          height: 125.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [startColor, endColor],
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Image.network(
            game.thumbnail,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error);
            },
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          game.title,
          style: AppTextStyles.normal500(
            fontSize: 15.0,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          game.date,
          style: AppTextStyles.normal500(
            fontSize: 13.0,
            color: AppColors.text5Light,
          ),
        ),
        const SizedBox(height: 2.0),
        RatingBar.builder(
          initialRating: double.tryParse(game.rating) ?? 0.0,
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
    required Game game,
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
            child: Image.network(
              game.thumbnail,
              fit: BoxFit.cover,
              height: 200,
              width: 400,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: 400,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    game.date,
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
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GameDetails(game: game)));
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
                        style: AppTextStyles.normal500(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
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
    required Game game,
    required Color startColor,
    required Color endColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            width: 90.0,
            height: 95.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [startColor, endColor],
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Image.network(
              game.thumbnail,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
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
                        game.title,
                        maxLines: 2,
                        style: AppTextStyles.normal500(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        game.date,
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
                            game.rating,
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
                    width: 80,
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
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      GameDetails(game: game)));
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.backgroundLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: Text(
                          'Play',
                          style: AppTextStyles.normal600(
                            fontSize: 14.0,
                            color: AppColors.buttonColor1,
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

Widget _buildGameCard(BuildContext context, BoardGamesClass category,
    Color startColor, Color endColor) {
  final game = category.games.isNotEmpty ? category.games[0] : null;

  if (game == null) {
    return const SizedBox.shrink();
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameDetails(game: game),
        ),
      );
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10.0),
          padding: const EdgeInsets.only(left: 16.0, right: 10.0, top: 16.0),
          width: 100.0,
          height: 101.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [startColor, endColor],
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Image.network(
            game.thumbnail,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error);
            },
          ),
        ),
        const SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: SizedBox(
            width: 90,
            child: Text(
              game.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.normal500(
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          category.name,
          style: AppTextStyles.normal500(
            fontSize: 13.0,
            color: AppColors.text5Light,
          ),
        ),
      const SizedBox(height: 2.0),
        RatingBar.builder(
          initialRating: double.tryParse(game.rating) ?? 0.0,
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
    ),
  );
}
