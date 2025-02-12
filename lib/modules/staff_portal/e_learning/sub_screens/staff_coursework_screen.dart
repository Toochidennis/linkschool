import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/staff_portal/e_learning/staff_create_syllabus_screen.dart';

class StaffCourseworkScreen extends StatelessWidget {
  final Map<String, dynamic>? currentSyllabus;
  final List<Topic> topics;

  const StaffCourseworkScreen({
    super.key, 
    required this.currentSyllabus, 
    required this.topics
  });

  void _addNewSyllabus(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => const StaffCreateSyllabusScreen(),
      ),
    );

    // Note: In a real app, you'd need to pass back the updated syllabus to the parent widget
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: Constants.customBoxDecoration(context),
      child: currentSyllabus == null
          ? _buildEmptyState(context)
          : _buildSyllabusDetails(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('No syllabus have been created'),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomMediumElevatedButton(
              text: 'Create new syllabus',
              onPressed: () => _addNewSyllabus(context),
              backgroundColor: AppColors.eLearningBtnColor1,
              textStyle: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundLight,
              ),
              padding: const EdgeInsets.all(12),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSyllabusDetails(BuildContext context) {
    if (currentSyllabus == null) return _buildEmptyState(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSyllabusHeader(context),
            const SizedBox(height: 16),
            _buildDescription(),
            _buildAssignmentRow(),
            _buildQuestionRow(),
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
              'Description:',
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

  Widget _buildAssignmentRow() {
    if (topics.isEmpty || topics.first.assignments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/e_learning/assignment.svg',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assignment',
                    style: AppTextStyles.normal600(
                      fontSize: 16,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                  Text(
                    topics.first.assignments.first.title,
                    style: AppTextStyles.normal500(
                      fontSize: 14,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created on ${DateFormat('dd MMMM, yyyy hh.mm a').format(topics.first.assignments.first.createdAt)}',
                    style: AppTextStyles.normal400(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionRow() {
    if (topics.isEmpty || topics.first.questions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/e_learning/question_icon.svg',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question',
                    style: AppTextStyles.normal600(
                      fontSize: 16,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                  Text(
                    topics.first.questions.first.title,
                    style: AppTextStyles.normal500(
                      fontSize: 14,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created on ${DateFormat('dd MMMM, yyyy hh.mm a').format(topics.first.questions.first.createdAt)}',
                    style: AppTextStyles.normal400(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}