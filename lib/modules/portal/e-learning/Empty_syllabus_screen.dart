import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/e-learning/create_syllabus.dart';

class EmptySyllabusScreen extends StatefulWidget {
  const EmptySyllabusScreen({super.key});

  @override
  State<EmptySyllabusScreen> createState() => _EmptySyllabusScreenState();
}

class _EmptySyllabusScreenState extends State<EmptySyllabusScreen> {
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
          'Syllabus',
          style: AppTextStyles.normal600(
              fontSize: 24.0, color: AppColors.primaryLight),
        ),
        // centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('No syllabus have been created'),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomMediumElevatedButton(
                  text: 'Create new syllabus',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (BuildContext context) =>
                          CreateSyllabusScreen(),
                    ),
                  ),
                  backgroundColor: AppColors.eLearningBtnColor1,
                  textStyle: AppTextStyles.normal600(
                    fontSize: 16,
                    color: AppColors.backgroundLight,
                  ),
                  padding: EdgeInsets.all(12),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
