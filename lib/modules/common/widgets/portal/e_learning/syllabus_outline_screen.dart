import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class SyllabusOutlineScreen extends StatelessWidget {
  final String title;
  final String description;
  final String selectedClass;
  final String selectedTeacher;

  const SyllabusOutlineScreen({
    super.key,
    required this.title,
    required this.description,
    required this.selectedClass,
    required this.selectedTeacher,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Syllabus Outline',
            style: AppTextStyles.normal600(
                fontSize: 20.0, color: AppColors.backgroundDark)),
        backgroundColor: AppColors.backgroundLight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title:',
                  style: AppTextStyles.normal600(
                      fontSize: 16.0, color: Colors.black),
                ),
                const SizedBox(height: 8.0),
                Text(
                  title,
                  style: AppTextStyles.normal400(
                      fontSize: 14.0, color: Colors.black),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Description:',
                  style: AppTextStyles.normal600(
                      fontSize: 16.0, color: Colors.black),
                ),
                const SizedBox(height: 8.0),
                Text(
                  description,
                  style: AppTextStyles.normal400(
                      fontSize: 14.0, color: Colors.black),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Class:',
                  style: AppTextStyles.normal600(
                      fontSize: 16.0, color: Colors.black),
                ),
                const SizedBox(height: 8.0),
                Text(
                  selectedClass,
                  style: AppTextStyles.normal400(
                      fontSize: 14.0, color: Colors.black),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Teacher:',
                  style: AppTextStyles.normal600(
                      fontSize: 16.0, color: Colors.black),
                ),
                const SizedBox(height: 8.0),
                Text(
                  selectedTeacher,
                  style: AppTextStyles.normal400(
                      fontSize: 14.0, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle save action
        },
        backgroundColor: AppColors.primaryLight,
        child: SvgPicture.asset(
          'assets/icons/e_learning/save_icon.svg', // Ensure this path is correct
          color: Colors.white,
        ),
      ),
    );
  }
}
