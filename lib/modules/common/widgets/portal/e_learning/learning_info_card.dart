import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';


class LearningInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const LearningInfoCard({Key? key, required this.title, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.normal600(fontSize: 14, color: AppColors.primaryLight)),
            SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.normal600(fontSize: 14, color: AppColors.primaryLight)),
          ],
        ),
      ),
    );
  }
}