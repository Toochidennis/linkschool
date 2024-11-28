import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class StaffCoursesScreen extends StatelessWidget {
  const StaffCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses',
          style: AppTextStyles.normal600(
            fontSize: 20,
            color: AppColors.primaryLight,
          ),
        ),
      ),
      body: const Center(
        child: Text('Staff Courses Management Screen'),
      ),
    );
  }
}