import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class AttendanceHistoryHeader extends StatelessWidget {
  const AttendanceHistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Attendance history', style: AppTextStyles.normal600(fontSize: 18, color: AppColors.primaryLight)),
          Text('See all', style: AppTextStyles.normal600(fontSize: 14, color: AppColors.primaryLight)),
        ],
      ),
    );
  }
}