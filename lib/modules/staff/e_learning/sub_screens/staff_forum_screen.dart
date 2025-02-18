import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class StaffForumScreen extends StatelessWidget {
  final Map<String, dynamic>? currentSyllabus;

  const StaffForumScreen({
    super.key, 
    required this.currentSyllabus
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: Constants.customBoxDecoration(context),
      child: currentSyllabus == null 
        ? _buildEmptyState(context) 
        : _buildForumContent(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No forum content available',
            style: AppTextStyles.normal500(
              fontSize: 16,
              color: AppColors.backgroundDark,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Create a syllabus to start discussions',
            style: AppTextStyles.normal400(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSyllabusHeader(context),
            const SizedBox(height: 16),
            _buildDescription(),
            _buildForumSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildSyllabusHeader(BuildContext context) {
    return Container(
      height: 95,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            currentSyllabus!['backgroundImagePath'],
            width: MediaQuery.of(context).size.width,
            height: 95,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentSyllabus!['title'],
                    style: AppTextStyles.normal700(
                      fontSize: 18,
                      color: AppColors.backgroundLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Class: ${currentSyllabus!['selectedClass']}',
                    style: AppTextStyles.normal500(
                      fontSize: 14,
                      color: AppColors.backgroundLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Teacher: ${currentSyllabus!['selectedTeacher']}',
                    style: AppTextStyles.normal600(
                      fontSize: 12,
                      color: AppColors.backgroundLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (currentSyllabus!['description'] == null ||
        currentSyllabus!['description'].isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Description:',
              style: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentSyllabus!['description'],
              style: AppTextStyles.normal500(
                fontSize: 14,
                color: AppColors.backgroundDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForumSections() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forum Sections',
              style: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundDark,
              ),
            ),
            const SizedBox(height: 10),
            _buildForumSectionItem(
              icon: Icons.question_answer,
              title: 'General Discussions',
              description: 'Share course-related thoughts and ideas',
            ),
            _buildForumSectionItem(
              icon: Icons.help_outline,
              title: 'Q&A',
              description: 'Ask and answer course-related questions',
            ),
            _buildForumSectionItem(
              icon: Icons.assignment,
              title: 'Assignment Discussions',
              description: 'Discuss course assignments and projects',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForumSectionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.eLearningBtnColor1,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.normal600(
                    fontSize: 14,
                    color: AppColors.backgroundDark,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.normal400(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }
}