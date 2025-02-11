import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2nd Continuous Assessment Test', style: AppTextStyles.normal700(fontSize: 16.0, color: AppColors.attBorderColor1),),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.bookText1,
        ),
        child: Column(
          children: [
            
            Container(
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/exams/alarm_clock.png',
                    width: 24.0,
                    height: 24.0,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error);
                    },
                  ),
                  Text(
                    '58:22',
                    style: AppTextStyles.normal500(
                        fontSize: 32.0, color: AppColors.bookText2),
                  ),
                ],
              ),
            ),
            Container(
              height: 60,
              width: 328,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.eLearningContColor1,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '02 of 15',
                        style: AppTextStyles.normal700(
                            fontSize: 16.0, color: AppColors.bookText2),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Completed',
                        style: AppTextStyles.normal500(
                            fontSize: 16.0, color: AppColors.bookText2),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      height: 8,
                      width: 280,
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(64),
                        value: 0.3,
                        color: AppColors.eLearningContColor3,
                        backgroundColor: AppColors.bookText1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 328,
              height: 458,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.textFieldLight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2nd Continuous Assessment Test', style: AppTextStyles.normal700(fontSize: 16.0, color: AppColors.attBorderColor1),),
                    Text('What is the reason for corruption in Nigeria?', style: AppTextStyles.normal700(fontSize: 20.0, color: AppColors.profiletext),),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
