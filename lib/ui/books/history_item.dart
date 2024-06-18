import 'package:flutter/material.dart';

import '../../common/app_colors.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 290,
            width: 130,
            // Ensure width is set for the SizedBox containing the image
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  // Add back the borderRadius if needed
                  child: Image.asset(
                    'assets/images/video_1.png',
                    fit: BoxFit.cover,
                    height: 180, // Adjust the height of the image as needed
                    width: 130,
                  ),
                ),
                const SizedBox(height: 4.0),
                const LinearProgressIndicator(
                  value: 0.5, // Adjust the value (0.5 means 50% progress)
                  color: AppColors.primaryLight,
                ),
                const SizedBox(height: 4.0),
                const Text(
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
