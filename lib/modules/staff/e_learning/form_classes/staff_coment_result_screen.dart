import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/staff_input_result_screen.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/staff_view_result_screen.dart';

class StaffCommentResultScreen extends StatefulWidget {
  const StaffCommentResultScreen({super.key});

  @override
  State<StaffCommentResultScreen> createState() =>
      _StaffCommentResultScreenState();
}

class _StaffCommentResultScreenState extends State<StaffCommentResultScreen> {
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
          'Comment on result',
          style: AppTextStyles.normal600(
            fontSize: 18.0,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two containers per row
              crossAxisSpacing: 16.0, // Space between columns
              mainAxisSpacing: 16.0, // Space between rows
              childAspectRatio: 3, // Adjust height relative to width
            ),
            itemCount: courseList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showTermOverlay(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    children: [
                      // SVG Background
                      Positioned.fill(
                        child: SvgPicture.asset(
                          svgBackgrounds[index % svgBackgrounds.length],
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Content Row
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // SVG Icon
                            SvgPicture.asset(
                              svgIcons[index % svgIcons.length],
                              color: Colors.white,
                              width: 32.0,
                              height: 32.0,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              courseList[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 2, // Change to match the number of items
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final icons = [
                        'assets/icons/staff/input_icon.svg',
                        'assets/icons/staff/view_icon.svg',
                      ];
                      final labels = [
                        'Input result',
                        'View result',
                      ];
                      final colors = [
                        AppColors.bgColor2,
                        AppColors.bgColor3,
                      ];
                      final iconColors = [
                        AppColors.iconColor1,
                        AppColors.iconColor2,
                      ];

                      // Define navigation destinations for each index
                      final screens = [
                        const StaffInputResultScreen(),
                        StaffViewResultScreen(),
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
                            MaterialPageRoute(
                                builder: (context) => screens[index]),
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

// Placeholder data for courses
final List<String> courseList = [
  'Civic Education',
  'Mathematics',
  'English',
  'Biology',
  'Physics',
  'Chemistry',
  'Economics',
  'Literature',
  'History',
  'Geography',
];

// SVG background images for course cards (replace with your actual asset paths)
final List<String> svgBackgrounds = [
  'assets/images/student/bg-light-blue.svg',
  'assets/images/student/bg-green.svg',
  'assets/images/student/bg-dark-blue.svg',
  'assets/images/student/bg-purple.svg',
  'assets/images/student/bg-light-blue.svg',
  'assets/images/student/bg-green.svg',
  'assets/images/student/bg-dark-blue.svg',
  'assets/images/student/bg-purple.svg',
  'assets/images/student/bg-light-blue.svg',
  'assets/images/student/bg-green.svg',
];

// SVG icons for course cards (replace with your actual asset paths)
final List<String> svgIcons = [
  'assets/icons/course-icon.svg',
  'assets/icons/course-icon.svg',
  'assets/icons/course-icon.svg',
  'assets/icons/course-icon.svg',
  'assets/icons/course-icon.svg',
];



  // void _showBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
  //     ),
  //     builder: (context) {
  //       return Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             title: const Text('Input result'),
  //             onTap: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => StaffInputResultScreen(),
  //                 ),
  //               );
  //             },
  //           ),
  //           const Divider(),
  //           ListTile(
  //             title: const Text('View result'),
  //             onTap: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => StaffViewResultScreen(),
  //                 ),
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }