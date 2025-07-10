
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/staff/home/form_classes_screen.dart';
import 'package:linkschool/modules/staff/home/staff_take_attandance_screen.dart';
import 'package:linkschool/modules/staff/result/add_view_result.dart';
import 'package:linkschool/modules/staff/result/staffViewCourseResult.dart';
import 'package:linkschool/modules/staff/result/staff_monthly_assesment_screen.dart';

class StaffResultScreen extends StatefulWidget {
  @override
  _StaffResultScreenState createState() => _StaffResultScreenState();
}

class _StaffResultScreenState extends State<StaffResultScreen> {
  String searchQuery = "";
  String activeTab = "overview";

  final List<Map<String, dynamic>> classSubjects = [
    {
      "class": "JSS 1",
      "subjects": [
        {
          "name": "Mathematics",
          "icon": Icons.calculate,
          "students": 28,
          "progress": 85,
          "color": Colors.blue
        },
        {
          "name": "Biology",
          "icon": Icons.science,
          "students": 32,
          "progress": 72,
          "color": Colors.green
        },
        {
          "name": "Literature",
          "icon": Icons.menu_book,
          "students": 25,
          "progress": 88,
          "color": Colors.purple
        },
      ]
    },
    {
      "class": "JSS 1B",
      "subjects": [
        {
          "name": "Chemistry",
          "icon": Icons.science_outlined,
          "students": 30,
          "progress": 80,
          "color": Colors.teal
        },
        {
          "name": "History",
          "icon": Icons.history_edu,
          "students": 29,
          "progress": 70,
          "color": Colors.orange
        },
        {
          "name": "History",
          "icon": Icons.history_edu,
          "students": 29,
          "progress": 70,
          "color": Colors.orange
        },
      ]
    },
    {
      "class": "JSS 2",
      "subjects": [
        {
          "name": "Chemistry",
          "icon": Icons.science_outlined,
          "students": 30,
          "progress": 80,
          "color": Colors.teal
        },
        {
          "name": "History",
          "icon": Icons.history_edu,
          "students": 29,
          "progress": 70,
          "color": Colors.orange
        },
        {
          "name": "History",
          "icon": Icons.history_edu,
          "students": 29,
          "progress": 70,
          "color": Colors.orange
        },
      ]
    }
  ];

  
  Color getStatusColor(int value) {
    if (value >= 80) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }

  String getStatusText(int value) {
    if (value >= 80) return "Excellent";
    if (value >= 60) return "Average";
    return "Needs Improvement";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomStudentAppBar(
          title: 'Welcome',
          subtitle: 'Tochukwu',
          showNotification: true,
          // showPostInput: true,
          onNotificationTap: () {},
          // onPostTap: _showNewPostDialog,
        ),
        body: Container(
            decoration: Constants.customBoxDecoration(context),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // My Classes
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Classes",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold,color: AppColors.bookText)),
                       
                          ],
                        ),
                        SizedBox(height: 16),
                        Column(
                          children: classSubjects.map<Widget>((classData) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(classData["class"],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.bookText)),
                                SizedBox(height: 8),
                                ...classData["subjects"].map<Widget>((subject) {
                                  return GestureDetector(
                                    onTap: () => _showOverlayDialog(
                                      subject["name"],
                                      subject,
                                    ),
                                    child: _buildClassItem(
                                      subject["name"],
                                      subject["icon"],
                                      subject["students"],
                                      subject["progress"],
                                      subject["color"],
                                    ),
                                  );
                                }).toList(),
                                SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget _buildClassItem(
      String name, IconData icon, int students, int progress, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.bookText)),
                Text("$students students",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor(progress).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("$progress%",
                style: TextStyle(
                  color: getStatusColor(progress),
                  fontWeight: FontWeight.bold,
                )),
          ),
          SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _showOverlayDialog(String subject, Map<String, dynamic> courseData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Section - Result
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Result',
                      style: AppTextStyles.normal600(
                          fontSize: 16, color: AppColors.backgroundDark),
                    ),
                  ),
                  // Body Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogButton(
                          'Add',
                          'assets/icons/result/edit.svg',
                          () => _navigateToAddResult(subject, courseData),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: _buildDialogButton(
                          'View',
                          'assets/icons/result/eye.svg',
                          () => _navigateToViewResult(subject, courseData),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16.0),

              // Bottom Section - Monthly Assessment
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Monthly assessment',
                      style: AppTextStyles.normal600(
                          fontSize: 16, color: AppColors.backgroundDark),
                    ),
                  ),
                  // Body Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogButton(
                          'Add',
                          'assets/icons/result/edit.svg',
                          () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: _buildDialogButton(
                          'View',
                          'assets/icons/result/eye.svg',
                          () =>
                              _navigateToMonthlyAssessment(subject, courseData),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
               SizedBox(
                height: 16.0,
              ),
              Divider(
                color: Colors.grey[300],
                thickness: 1,
              ),
               _buildAttendanceButton(
                'Take Attendance',
                 'assets/icons/result/course.svg',
                () {
                  Navigator.pop(context); // Close the bottom sheet first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffTakeAttendanceScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogButton(
      String text, String iconPath, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: SvgPicture.asset(
          iconPath,
          color: Colors.grey,
        ),
        label: Text(
          text,
          style: AppTextStyles.normal600(
              fontSize: 14, color: AppColors.backgroundDark),
        ),
      ),
    );
  }
  Widget _buildAttendanceButton(
      String text, String iconPath, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: SvgPicture.asset(
          iconPath,
          color: Colors.grey,
        ),
        label: Text(
          text,
          style: AppTextStyles.normal600(
              fontSize: 14, color: AppColors.backgroundDark),
        ),
      ),
    );
  }

   void _navigateToViewResult(String subject, Map<String, dynamic> courseData) {
    Navigator.pop(context); // Close the bottom sheet first

    // Navigate to ViewCourseResultScreen for read-only viewing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>StaffviewcourseResult(
          // classId: widget.classId,
          // year: widget.year,
          // term: widget.term,
          // termName: widget.termName,
          // subject: subject,
          // courseData: courseData,
        ),
      ),
    );
  }
 void _navigateToAddResult(String subject, Map<String, dynamic> courseData) {
    Navigator.pop(context); // Close the bottom sheet first

    // Navigate to AddViewCourseResultScreen for editing/adding results
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStaffViewCourseResultScreen(
          // classId: "",
          // year:'',
          // term: "",
          // termName: "",
          // subject: subject,
          // courseData: courseData,
        ),
      ),
    );
  }


  Widget buildInputResultsItem(BuildContext context) {
  return ListTile(
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.bgColor4,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/result/course.svg',
          color: AppColors.iconColor3,
          width: 20,
          height: 20,
        ),
      ),
    ),
    title: Text('Attendance',
        style: AppTextStyles.normal600(
            fontSize: 14, color: AppColors.backgroundDark)),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffTakeAttendanceScreen(
              // Pass any required arguments here
          ),
        ),
      );
    },
  );
}

  void _navigateToMonthlyAssessment(
      String subject, Map<String, dynamic> courseData) {
    Navigator.pop(context); // Close the bottom sheet first

    // Navigate to MonthlyAssessmentScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthlyStaffAssessmentScreen(
          // classId: widget.classId,
          // year: widget.year,
          // term: widget.term,
          // termName: widget.termName,
          // subject: subject,
          // courseData: courseData,
        ),
      ),
    );
  }

//   void _showTermOverlay(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (BuildContext context) {
//       return Container(
//         height: MediaQuery.of(context).size.height * 0.2,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
//           child: Column(
//             children: [
//               Expanded(
//                 child: ListView.separated(
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: 2,
//                   separatorBuilder: (context, index) => const Divider(),
//                   itemBuilder: (context, index) {
//                     final icons = [
//                       'assets/icons/result/assessment.svg',
//                       'assets/icons/result/eye.svg',
                      
//                     ];
//                     final labels = [
//                       'Input results',
//                       'View results',
                      
//                     ];
//                     final colors = [
//                       AppColors.bgColor2,
//                       AppColors.bgColor3,
                     
//                     ];
//                     final iconColors = [
//                       AppColors.iconColor1,
//                       AppColors.iconColor2,
                     
//                     ];

//                     // Define navigation destinations for each index
//                     final screens = [
//                       // Add your navigation destinations here
                     
//                     ];

//                     return ListTile(
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: colors[index],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Center(
//                           child: SvgPicture.asset(
//                             icons[index],
//                             color: iconColors[index],
//                             width: 20,
//                             height: 20,
//                           ),
//                         ),
//                       ),
//                       title: Text(labels[index]),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => screens[index]),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
}
