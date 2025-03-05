import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/staff_coment_result_screen.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/staff_skill_behaviour_screen.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_attandance_screen.dart';
import 'package:linkschool/modules/staff/home/staff_course_screen.dart';

class FormClassesScreen extends StatefulWidget {
  const FormClassesScreen({super.key});

  @override
  State<FormClassesScreen> createState() => _FormClassesScreenState();
}

class _FormClassesScreenState extends State<FormClassesScreen> {
    late double opacity;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Form Classes',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClassSection(context, 'JSS 2', [
                {'name': 'JSS2 Pink', 'students': '25 Students'},
                {'name': 'JSS2 Red', 'students': '25 Students'},
                {'name': 'JSS2 Red', 'students': '25 Students'},
              ]),
              _buildClassSection(context, 'SS 2', [
                {'name': 'SS2 Pink', 'students': '25 Students'},
                {'name': 'SS2 Red', 'students': '25 Students'},
                {'name': 'SS2 Red', 'students': '25 Students'},
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassSection(
      BuildContext context, String header, List<Map<String, String>> classes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.paymentTxtColor1,
                ),
              ),
              const Divider(
                color: AppColors.paymentTxtColor1,
                thickness: 2,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          // Cards
          Column(
            children: classes
                .map(
                  (classData) => GestureDetector(
                    onTap: () => _showTermOverlay(context),
                    child: Container(
                      width: double.infinity, // Makes the card fill the width
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classData['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.paymentTxtColor1,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                classData['students']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

void _showTermOverlay(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final icons = [
                      'assets/icons/result/comment.svg',
                      'assets/icons/result/skill.svg',
                      'assets/icons/result/course.svg',
                      'assets/icons/result/composite_result.svg',
                    ];
                    final labels = [
                      'Comment on results',
                      'Skills and Behaviour',
                      'Attendance',
                      'Students',
                    ];
                    final colors = [
                      AppColors.bgColor2,
                      AppColors.bgColor3,
                      AppColors.bgColor4,
                      AppColors.bgColor5,
                    ];
                    final iconColors = [
                      AppColors.iconColor1,
                      AppColors.iconColor2,
                      AppColors.iconColor3,
                      AppColors.iconColor4,
                    ];

                    // Define navigation destinations for each index
                    final screens = [
                      const StaffCommentResultScreen(),
                      const StaffSkillsBehaviourScreen(),
                      StaffAttandanceScreen(),
                      StaffCoursesScreen(),
                    ];

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors[index],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            icons[index],
                            color: iconColors[index],
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      title: Text(labels[index]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => screens[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

}