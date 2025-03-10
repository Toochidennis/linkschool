import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class GameCard extends StatelessWidget {
  final String game;
  final String gameTitle;
  final String platform;
  final double rating;
  final Color beginColor;
  final Color endColor;

  const GameCard({
    super.key,
    required this.gameTitle,
    required this.platform,
    required this.rating,
    required this.beginColor,
    required this.endColor,
    required this.game,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
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
                  colors: [beginColor, endColor])),
          child: Image.asset(
            game,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          platform,
          style:
              AppTextStyles.normal500(fontSize: 13, color: AppColors.libText),
        ),
        Text(
          platform,
          style: AppTextStyles.normal500(
              fontSize: 13, color: AppColors.text5Light),
        ),
        RatingBar.builder(
          allowHalfRating: true,
          direction: Axis.horizontal,
          itemCount: 5,
          initialRating: rating,
          minRating: 1,
          itemSize: 14,
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (value) {},
        )
      ],
    );
  }
}
