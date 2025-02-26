import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import '../../model/explore/home/game_model.dart';


class GameCard extends StatelessWidget {
  final Game game;
  final Color beginColor;
  final Color endColor;

  const GameCard({
    super.key,
    required this.game,
    required this.beginColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   if (game.title.isNotEmpty) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => GameScreen(game: game),
      //       ),
      //     );
      //   }
      // },
      child: Column(
        children: [
          Container(
            height: 100,
            width: 101,
            margin: const EdgeInsets.only(left: 16.0),
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [beginColor, endColor],
              ),
            ),
            child: game.thumbnail.isEmpty
                ? Container(color: Colors.grey[300])
                : Image.network(
                    game.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, color: Colors.red);
                    },
                  ),
          ),
          SizedBox(height: 8),
          Text(
            game.title.isEmpty ? 'Loading...' : game.title,
            style: AppTextStyles.normal500(fontSize: 13, color: AppColors.libText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Cross-platform',
            style: AppTextStyles.normal500(fontSize: 13, color: AppColors.text5Light),
          ),
          RatingBar.builder(
            allowHalfRating: true,
            direction: Axis.horizontal,
            itemCount: 5,
            initialRating: double.parse(game.rating),
            minRating: 1,
            itemSize: 14,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (_) {},
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import '../../model/explore/home/game_model.dart';


// class GameCard extends StatelessWidget {
//   final Game?gameurl; 
//   final String? gameImage;
//   final String gameTitle;
//   final String platform;
//   final double rating;
//   final Color beginColor;
//   final Color endColor;
//   const GameCard(
//       {super.key,
//       required this.gameTitle,
//       required this.platform,
//       required this.rating,
//       required this.beginColor,
//       required this.endColor,
//       this.gameImage, 
//       this.gameurl});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           height: 100,
//           width: 101,
//           margin: const EdgeInsets.only(left: 16.0),
//           padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//               gradient: LinearGradient(
//                   begin: Alignment.topRight,
//                   end: Alignment.bottomLeft,
//                   colors: [beginColor, endColor])),
//           child: Image.network(
//              gameurl!.thumbnail,
//             fit: BoxFit.contain,
//           ),
//         ),
//         SizedBox(
//           height: 8,
//         ),
//         Text(
//           gameurl!.gameUrl,
//           style:
//               AppTextStyles.normal500(fontSize: 13, color: AppColors.libText),
//         ),
//         Text(
//           platform,
//           style: AppTextStyles.normal500(
//               fontSize: 13, color: AppColors.text5Light),
//         ),
//         RatingBar.builder(
//           allowHalfRating: true,
//           direction: Axis.horizontal,
//           itemCount: 5,
//           initialRating: rating,
//           minRating: 1,
//           itemSize: 14,
//           itemBuilder: (context, index) => Icon(
//             Icons.star,
//             color: Colors.amber,
//           ),
//           onRatingUpdate: (value) {},
//         )
//       ],
//     );
//   }
// }
