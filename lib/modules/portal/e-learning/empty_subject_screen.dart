import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/e-learning/assignment_screen.dart';
import 'package:linkschool/modules/portal/e-learning/question_screen.dart';
import 'package:linkschool/modules/portal/e-learning/topic_screen.dart';

class EmptySubjectScreen extends StatelessWidget {
  final String title;

  const EmptySubjectScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.normal600(
              fontSize: 24.0, color: AppColors.primaryLight),
        ),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nothing has been created for this subject',
              style: AppTextStyles.normal500(fontSize: 16.0, color: AppColors.backgroundDark),
            ),
            const SizedBox(height: 20),
            CustomMediumElevatedButton(text: 'Create', onPressed: () => _showCreateOptionsBottomSheet(context), backgroundColor: AppColors.eLearningBtnColor1, textStyle: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundLight), padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0))
            // ElevatedButton(
            //   child: Text('Create'),
            //   onPressed: () => _showCreateOptionsBottomSheet(context),
            // ),
          ],
        ),
      ),
    );
  }

  void _showCreateOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What do you want to create?',
                style: AppTextStyles.normal600(fontSize: 18.0, color: AppColors.backgroundDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildOptionRow(context, 'Assignment', 'assets/icons/e_learning/assignment.svg'),
              _buildOptionRow(context, 'Question', 'assets/icons/e_learning/question.svg'),
              _buildOptionRow(context, 'Material', 'assets/icons/e_learning/material.svg'),
              _buildOptionRow(context, 'Topic', 'assets/icons/e_learning/topic.svg'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              _buildOptionRow(context, 'Reuse content', 'assets/icons/e_learning/share.svg'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionRow(BuildContext context, String text, String iconPath) {
    return InkWell(
    onTap: () {
      Navigator.pop(context); // Close the bottom sheet
      // Navigate to the appropriate screen based on the selected text option
      switch (text) {
        case 'Assignment':
          Navigator.push(context, MaterialPageRoute(builder: (context) => AssignmentScreen()));
          break;
        case 'Topic':
          Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) => TopicScreen()));
          break;
        case 'Question':
          Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionScreen()));
          break;
        // case 'Material':
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => MaterialScreen()));
        //   break;
        // case 'Share again':
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => ShareAgainScreen()));
        //   break;
      }
    },

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color:  AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset(iconPath, width: 24, height: 24),
            const SizedBox(width: 16),
            Text(text, style: AppTextStyles.normal500(fontSize: 16, color: AppColors.backgroundDark)),
          ],
        ),
      ),
    );
  }

  // void _addNewSyllabus() async {
  //   final result = await Navigator.of(context).push(
  //     MaterialPageRoute(
  //       fullscreenDialog: true,
  //       builder: (BuildContext context) => TopicScreen(),
  //     ),
  //   );
  //   if (result != null) {
  //     setState(() {
  //       _syllabusList.add(result);
  //     });
  //   }
  // }
}