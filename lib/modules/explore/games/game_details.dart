import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/explore/home/game_model.dart';
import 'package:linkschool/modules/providers/explore/game/game_provider.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';

// import '../../providers/explore/game/game_provider.dart';

class GameDetails extends StatefulWidget {
  const GameDetails({super.key, required this.game});
  final Game game;

  @override
  State<GameDetails> createState() => _GameDetailsState();
}

class _GameDetailsState extends State<GameDetails> {
  @override
  void initState() {
    super.initState();

    // Fetch games only once when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).fetchGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    // Prepare recommended games list
    final recommendedGames = gameProvider.games?.puzzleGames.games ?? [];
    
    // Prepare games you might like list
    final gamesYouMightLike = gameProvider.games?.cardGames.games ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.game.title,
          style: AppTextStyles.normal600(
              fontSize: 20, color: AppColors.detailsbutton),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Game thumbnail image
            Container(
              height: 326,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.game.thumbnail),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game title
                  Text(
                    widget.game.title,
                    style: AppTextStyles.normal600(
                        fontSize: 22, color: AppColors.gametitle),
                  ),
                  
                  // Game info row
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'May contain ads and In-app purchases',
                          style: AppTextStyles.normal500(
                              fontSize: 14, color: AppColors.gameText),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ReviewWidget(
                          image: 'assets/icons/gamesicon/stars.png',
                          reviews: widget.game.rating.toString(),
                          reviewDes: '1k reviews',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Play now button
                  CustomLongElevatedButton(
                    text: 'Play now',
                    onPressed: () {
                      // Implementation for playing the game
                    },
                    backgroundColor: AppColors.bgXplore3,
                    textStyle: AppTextStyles.normal500(
                        fontSize: 16, color: AppColors.assessmentColor1),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // About this game section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About this game',
                        style: AppTextStyles.normal700(
                            fontSize: 16, color: AppColors.gametitle),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.game.description,
                        style: AppTextStyles.normal400(
                            fontSize: 16, color: AppColors.gameText),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Recommended games section
                  Text(
                    'Recommended',
                    style: AppTextStyles.normal700(
                      fontSize: 16,
                      color: AppColors.gametitle,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: recommendedGames.isEmpty
                        ? const Center(child: Text('No recommended games available'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommendedGames.length,
                            itemBuilder: (context, index) => RecommendedCard(
                              game: recommendedGames[index],
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Games you may like section
                  Text(
                    'Games you may like',
                    style: AppTextStyles.normal700(
                      fontSize: 16,
                      color: AppColors.gametitle,
                    ),
                  ),
                  const SizedBox(height: 10),
                  gamesYouMightLike.isEmpty
                      ? const Center(child: Text('No suggested games available'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: gamesYouMightLike.length,
                          itemBuilder: (context, index) => GameCard(
                            game: gamesYouMightLike[index],
                            startColor: AppColors.gamesColor5,
                            endColor: AppColors.gamesColor6,
                            onPlay: () {
                              // Navigate to the game page, but not to itself again
                              if (widget.game.id != gamesYouMightLike[index].id) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GameDetails(
                                      game: gamesYouMightLike[index],
                                    ),
                                  ),
                                );
                              }
                            },
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
}

// Widget for recommended card - renamed to follow PascalCase convention
class RecommendedCard extends StatelessWidget {
  final Game game;
  
  const RecommendedCard({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      height: 150,
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.gameCard, 
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          // Using thumbnail instead of gameUrl for consistency
          game.thumbnail,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => 
            const Center(child: Icon(Icons.error)),
        ),
      ),
    );
  }
}

// Widget for review - converted to StatelessWidget for better organization
class ReviewWidget extends StatelessWidget {
  final String? reviews;
  final String reviewDes;
  final IconData? icons;
  final String image;

  const ReviewWidget({
    super.key,
    this.reviews,
    required this.reviewDes,
    this.icons,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reviews != null)
              Text(
                reviews!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            const SizedBox(width: 4),
            Image.asset(
              image,
              width: 24,
              height: 24,
            ),
            if (icons != null) Icon(icons!),
          ],
        ),
        Text(
          reviewDes,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// Widget for games you might like - renamed for consistency and clarity
class GameCard extends StatelessWidget {
  final Game game;
  final Color startColor;
  final Color endColor;
  final VoidCallback onPlay;

  const GameCard({
    super.key,
    required this.game,
    required this.startColor,
    required this.endColor,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          // Game thumbnail with gradient background
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
              errorBuilder: (context, error, stackTrace) => 
                const Center(child: Icon(Icons.error, color: Colors.white)),
            ),
          ),
          
          const SizedBox(width: 10.0),
          
          // Game details area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: AppColors.gamesColor9,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left column with game info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          style: AppTextStyles.normal500(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          game.title,
                          style: AppTextStyles.normal500(
                            fontSize: 13.0,
                            color: AppColors.text5Light,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        
                        // Rating and downloads
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16.0),
                            const SizedBox(width: 2),
                            Text(
                              game.rating,
                              style: AppTextStyles.normal500(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            const Icon(Icons.file_download_outlined, size: 16.0),
                            const SizedBox(width: 2),
                            Text(
                              '150k', // Hardcoded value should be replaced
                              style: AppTextStyles.normal500(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Play button
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
                        onPressed: onPlay,
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
                              fontSize: 14.0, 
                              color: AppColors.buttonColor1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/explore/home/game_model.dart';
// import 'package:provider/provider.dart';
// import '../../model/explore/games/game_model.dart';
// import '../../providers/explore/game/game_provider.dart';

// class GameDetails extends StatefulWidget {
//   const GameDetails({super.key, required this.game});
//   final Game game;


//   @override
//   State<GameDetails> createState() => _GameDetailsState();
// }

// class _GameDetailsState extends State<GameDetails> {
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<GameProvider>(context, listen: false).fetchGames();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final gameProvider = Provider.of<GameProvider>(context);

//     final likes = gameProvider.games?.cardGames.games
//        .map((game) => _buildYouMightLikeCard(
//               game: game,
//               startColor: AppColors.gamesColor5,
//               endColor: AppColors.gamesColor6,
//             ))
//        .toList() ??[];

//     final recommendedGames =
//         gameProvider.games?.puzzleGames.games.map((game) => game).toList();

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Text(
//           widget.game.title,
//           style: AppTextStyles.normal600(
//               fontSize: 20, color: AppColors.detailsbutton),
//         ),
//         title: Text(
//           widget.game.title,
//           style: AppTextStyles.normal600(
//               fontSize: 20, color: AppColors.detailsbutton),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Game thumbnail image
//             Container(
//               height: 326,
//               width: double.infinity,
//               decoration: BoxDecoration(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage(widget.game.thumbnail),
//                   image: NetworkImage(widget.game.thumbnail),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Game title
//                   Text(
//                     widget.game.title,
//                     style: AppTextStyles.normal600(
//                         fontSize: 22, color: AppColors.gametitle),
//                     widget.game.title,
//                     style: AppTextStyles.normal600(
//                         fontSize: 22, color: AppColors.gametitle),
//                   ),
                  
//                   // Game info row
//                   Row(
//                     children: [
//                       Expanded(
//                         flex: 3,
//                         child: Text(
//                           'May contain ads and In-app purchases',
//                           style: AppTextStyles.normal500(
//                               fontSize: 14, color: AppColors.gameText),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: ReviewWidget(
//                           image: 'assets/icons/gamesicon/stars.png',
//                           reviews: widget.game.rating.toString(),
//                           reviewDes: '1k reviews',
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 20),
                  
//                   // Play now button
//                   CustomLongElevatedButton(
//                     text: 'Play now',
//                     onPressed: () {
//                       // Implementation for playing the game
//                     },
//                     backgroundColor: AppColors.bgXplore3,
//                     textStyle: AppTextStyles.normal500(
//                         fontSize: 16, color: AppColors.assessmentColor1),
//                   ),
                  
//                   const SizedBox(height: 30),
                  
//                   // About this game section
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'About this game',
//                         style: AppTextStyles.normal700(
//                             fontSize: 16, color: AppColors.gametitle),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         widget.game.description,
//                         style: AppTextStyles.normal400(
//                             fontSize: 16, color: AppColors.gameText),
//                       ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 30),
                  
//                   // Recommended games section
//                   Text(
//                     'Recommended',
//                     style: AppTextStyles.normal700(
//                       fontSize: 16,
//                       color: AppColors.gametitle,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     height: 150,
//                     child: recommendedGames.isEmpty
//                         ? const Center(child: Text('No recommended games available'))
//                         : ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: recommendedGames.length,
//                             itemBuilder: (context, index) => RecommendedCard(
//                               game: recommendedGames[index],
//                             ),
//                           ),
//                   ),
                  
//                   const SizedBox(height: 20),
                  
//                   // Games you may like section
//                   Text(
//                     'Games you may like',
//                     style: AppTextStyles.normal700(
//                       fontSize: 16,
//                       color: AppColors.gametitle,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   gamesYouMightLike.isEmpty
//                       ? const Center(child: Text('No suggested games available'))
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: gamesYouMightLike.length,
//                           itemBuilder: (context, index) => GameCard(
//                             game: gamesYouMightLike[index],
//                             startColor: AppColors.gamesColor5,
//                             endColor: AppColors.gamesColor6,
//                             onPlay: () {
//                               // Navigate to the game page, but not to itself again
//                               if (widget.game.id != gamesYouMightLike[index].id) {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => GameDetails(
//                                       game: gamesYouMightLike[index],
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Widget for recommended card - renamed to follow PascalCase convention
// class RecommendedCard extends StatelessWidget {
//   final Game game;
  
//   const RecommendedCard({
//     super.key,
//     required this.game,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 10),
//       height: 150,
//       width: 300,
//       decoration: BoxDecoration(
//         color: AppColors.gameCard, 
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Image.network(
//           // Using thumbnail instead of gameUrl for consistency
//           game.thumbnail,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) => 
//             const Center(child: Icon(Icons.error)),
//         ),
//       ),
//     );
//   }
// }

// // Widget for review - converted to StatelessWidget for better organization
// class ReviewWidget extends StatelessWidget {
//   final String? reviews;
//   final String reviewDes;
//   final IconData? icons;
//   final String image;

//   const ReviewWidget({
//     super.key,
//     this.reviews,
//     required this.reviewDes,
//     this.icons,
//     required this.image,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (reviews != null)
//               Text(
//                 reviews!,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             const SizedBox(width: 4),
//             Image.asset(
//               image,
//               width: 24,
//               height: 24,
//             ),
//             if (icons != null) Icon(icons!),
//           ],
//         ),
//         Text(
//           reviewDes,
//           style: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//       ],
//     );
//   }
// }

// // Widget for games you might like - renamed for consistency and clarity
// class GameCard extends StatelessWidget {
//   final Game game;
//   final Color startColor;
//   final Color endColor;
//   final VoidCallback onPlay;

//   const GameCard({
//     super.key,
//     required this.game,
//     required this.startColor,
//     required this.endColor,
//     required this.onPlay,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 10.0),
//       child: Row(
//         children: [
//           // Game thumbnail with gradient background
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             width: 90.0,
//             height: 95.0,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [startColor, endColor],
//               ),
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             child: Image.network(
//               game.thumbnail,
//               fit: BoxFit.contain,
//               errorBuilder: (context, error, stackTrace) => 
//                 const Center(child: Icon(Icons.error, color: Colors.white)),
//             ),
//           ),
          
//           const SizedBox(width: 10.0),
          
//           // Game details area
//           Expanded(
//             child: Container(
//               decoration: const BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     width: 0.5,
//                     color: AppColors.gamesColor9,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Left column with game info
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text(
//                           game.title,
//                           style: AppTextStyles.normal500(
//                             fontSize: 16.0,
//                             color: Colors.black,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 2.0),
//                         Text(
//                           game.title,
//                           style: AppTextStyles.normal500(
//                             fontSize: 13.0,
//                             color: AppColors.text5Light,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 2.0),
                        
//                         // Rating and downloads
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.star, color: Colors.amber, size: 16.0),
//                             const SizedBox(width: 2),
//                             Text(
//                               "${game.rating}",
//                               style: AppTextStyles.normal500(
//                                 fontSize: 14.0,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             const SizedBox(width: 16.0),
//                             const Icon(Icons.file_download_outlined, size: 16.0),
//                             const SizedBox(width: 2),
//                             Text(
//                               '150k', // Hardcoded value should be replaced
//                               style: AppTextStyles.normal500(
//                                 fontSize: 14.0,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   // Play button
//                   Container(
//                     height: 45.0,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           AppColors.gamesColor7,
//                           AppColors.gamesColor8,
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(4.0),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(2.0),
//                       child: OutlinedButton(
//                         onPressed: onPlay,
//                         style: OutlinedButton.styleFrom(
//                           backgroundColor: AppColors.backgroundLight,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(4.0),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                           child: Text(
//                             'Play',
//                             style: AppTextStyles.normal600(
//                               fontSize: 14.0, 
//                               color: AppColors.buttonColor1,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }