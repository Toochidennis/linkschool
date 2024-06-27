import 'package:flutter/material.dart';
import 'package:linkschool/common/text_styles.dart';

import '../../common/app_colors.dart';

class AllTabItem1 extends StatelessWidget {
  final String coverImage;
  final String bookTitle;
  final String authorName;
  final double bookProgress;

  const AllTabItem1({
    super.key,
    required this.coverImage,
    required this.bookTitle,
    required this.authorName,
    required this.bookProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    coverImage,
                    fit: BoxFit.cover,
                    height: 180,
                    width: 130,
                  ),
                ),
                const SizedBox(height: 4.0),
                LinearProgressIndicator(
                  value: bookProgress,
                  // Adjust the value (0.5 means 50% progress)
                  color: AppColors.primaryLight,
                ),
                const SizedBox(height: 4.0),
                Text(
                  bookTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal500(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal500(
                    fontSize: 12.0,
                    color: AppColors.text5Light,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
