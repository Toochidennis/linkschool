import 'package:flutter/material.dart';
import '../../common/app_colors.dart';

class AllTab extends StatelessWidget {
  const AllTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            width: 130, // Ensure width is set for the SizedBox containing the image
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0), // Add back the borderRadius if needed
                  child: Image.asset(
                    'assets/images/video_1.png',
                    fit: BoxFit.cover,
                    height: 180, // Adjust the height of the image as needed
                    width: 130,
                  ),
                ),
                SizedBox(height: 4.0),
                LinearProgressIndicator(
                  value: 0.5, // Adjust the value (0.5 means 50% progress)
                  color: AppColors.primaryLight,
                ),
                SizedBox(height: 4.0),
                Text(
                  'Purple Hibicus',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  'Chimamanda N. Adichie',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.0,),
          SizedBox(
            height: 300,
            width: 130, // Ensure width is set for the SizedBox containing the image
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0), // Add back the borderRadius if needed
                  child: Image.asset(
                    'assets/images/video_1.png',
                    fit: BoxFit.cover,
                    height: 180, // Adjust the height of the image as needed
                    width: 130,
                  ),
                ),
                SizedBox(height: 4.0),
                LinearProgressIndicator(
                  value: 0.5, // Adjust the value (0.5 means 50% progress)
                  color: AppColors.primaryLight,
                ),
                SizedBox(height: 4.0),
                Text(
                  'Purple Hibicus',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  'Chimamanda N. Adichie',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
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