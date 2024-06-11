import 'package:flutter/material.dart';
import 'package:linkschool/common/text_styles.dart';

class HistoryItem extends StatelessWidget {
  final double? marginRight;

  const HistoryItem({super.key, this.marginRight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 180,
      margin: EdgeInsets.only(left: 16.0, right: marginRight ?? 0.0),
      child: Column(
        children: [
          ClipRRect(
            //borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'assets/images/video_1.png',
              fit: BoxFit.cover,
              height: 100, // Adjust the height of the image as needed
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 4.0),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'Mastering the Act of Video editing',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.normalDark2,
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('profileImageUrl'),
                  radius: 10.0,
                ),
                SizedBox(width: 4.0),
                Text('Toochi Dennis'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
