import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/staff_coment_result_screen.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/staff_skill_behaviour_screen.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_attandance_screen.dart';
import 'package:linkschool/modules/staff/home/staff_course_screen.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class FormClassesScreen extends StatefulWidget {
  const FormClassesScreen({super.key});

  @override
  State<FormClassesScreen> createState() => _FormClassesScreenState();
}

class _FormClassesScreenState extends State<FormClassesScreen> {
  late double opacity;
  List<Map<String, dynamic>> formClassesData = [];

  @override
  void initState() {
    super.initState();
    _loadFormClassesData();
  }

  void _loadFormClassesData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final formClasses = authProvider.getFormClasses();
    final staffCourses = authProvider.getStaffCourses();

    // Transform form classes data to match UI structure
    formClassesData = _transformFormClassesToUI(formClasses, staffCourses);
  }

  List<Map<String, dynamic>> _transformFormClassesToUI(
    List<Map<String, dynamic>> formClasses,
    List<Map<String, dynamic>> staffCourses,
  ) {
    List<Map<String, dynamic>> transformedData = [];

    for (var levelData in formClasses) {
      String levelName = levelData['level_name'] ?? '';
      int levelId = levelData['level_id'] ?? 0;
      List<dynamic> classes = levelData['classes'] ?? [];

      List<Map<String, dynamic>> classesForLevel = [];

      for (var classData in classes) {
        int classId = classData['class_id'] ?? 0;
        String className = classData['class_name'] ?? '';

        // Get student count for this class from staff courses
        int studentCount = _getStudentCountForClass(classId, staffCourses);

        classesForLevel.add({
          "class_id": classId,
          "class_name": className,
          "students": studentCount,
          "progress": _calculateProgress(studentCount),
          "color": _getColorForClass(className),
          "icon": Icons.class_,
        });
      }

      if (classesForLevel.isNotEmpty) {
        transformedData.add({
          "level": levelName,
          "level_id": levelId,
          "classes": classesForLevel,
        });
      }
    }

    // Sort levels for consistent display
    transformedData.sort((a, b) => a["level"].compareTo(b["level"]));

    return transformedData;
  }

  int _getStudentCountForClass(int classId, List<Map<String, dynamic>> staffCourses) {
    // Find the class in staff courses and sum up students from all subjects
    for (var courseData in staffCourses) {
      if (courseData['class_id'] == classId) {
        List<dynamic> courses = courseData['courses'] ?? [];
        int totalStudents = 0;
        for (var course in courses) {
          totalStudents += (course['num_of_students'] as int? ?? 0);
        }
        // If multiple subjects, take the maximum (assuming same students across subjects)
        if (courses.isNotEmpty) {
          return courses.map((c) => c['num_of_students'] as int? ?? 0).reduce((a, b) => a > b ? a : b);
        }
        return totalStudents;
      }
    }
    return 0; // Default if no data found
  }

  Color _getColorForClass(String className) {
    // Generate colors based on class name
    int hash = className.hashCode;
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[hash.abs() % colors.length];
  }

  int _calculateProgress(int numStudents) {
    // Simple progress calculation based on number of students
    if (numStudents == 0) return 0;
    if (numStudents <= 10) return 60;
    if (numStudents <= 20) return 75;
    if (numStudents <= 30) return 85;
    return 90;
  }

  Color getStatusColor(int value) {
    if (value >= 80) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userProfile = authProvider.getUserProfile();
        final userName = userProfile['name'] ?? 'Staff';

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
                children: [
                  // Form Classes Content
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
                            Text(
                              "My Form Classes",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: AppColors.bookText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        formClassesData.isEmpty
                            ? _buildEmptyState()
                            : Column(
                                children: formClassesData.map<Widget>((levelData) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Level Header
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        margin: EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: AppColors.bookText.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppColors.bookText.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.school,
                                              color: AppColors.bookText,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              levelData["level"],
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.bookText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Classes under this level
                                      ...levelData["classes"].map<Widget>((classData) {
                                        return Container(
                                          margin: EdgeInsets.only(left: 16, bottom: 16),
                                          child: GestureDetector(
                                            onTap: () => _showTermOverlay(
                                              context,
                                              classData["class_name"],
                                              classData["class_id"].toString(),
                                              levelData["level_id"].toString(),
                                            ),
                                            child: _buildClassItem(
                                              classData["class_name"],
                                              classData["icon"],
                                              classData["students"],
                                              classData["progress"],
                                              classData["color"],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      SizedBox(height: 20),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.class_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No form classes assigned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You have not been assigned as a form teacher to any classes yet.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.bookText,
                  ),
                ),
                Text(
                  "$students students",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _showTermOverlay(BuildContext context, String className, String classId, String levelId) {
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
                // Header showing selected class
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bookText.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.class_,
                        color: AppColors.bookText,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        className,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.bookText,
                        ),
                      ),
                    ],
                  ),
                ),
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

                      // Define navigation destinations for each index with real data
                      final screens = [
                        const StaffCommentResultScreen(),
                        StaffSkillsBehaviourScreen(
                          classId: classId,
                          levelId: levelId,
                        ),
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
                        title: Text(
                          labels[index],
                          style: AppTextStyles.normal600(
                            fontSize: 14,
                            color: AppColors.backgroundDark,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close bottom sheet first
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


          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //   decoration: BoxDecoration(
          //     color: getStatusColor(progress).withOpacity(0.2),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Text(
          //     "$progress%",
          //     style: TextStyle(
          //       color: getStatusColor(progress),
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          // SizedBox(width: 12),



// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/staff/e_learning/form_classes/staff_coment_result_screen.dart';
// import 'package:linkschool/modules/staff/e_learning/form_classes/staff_skill_behaviour_screen.dart';
// import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_attandance_screen.dart';
// import 'package:linkschool/modules/staff/home/staff_course_screen.dart';

// class FormClassesScreen extends StatefulWidget {
//   const FormClassesScreen({super.key});

//   @override
//   State<FormClassesScreen> createState() => _FormClassesScreenState();
// }

// class _FormClassesScreenState extends State<FormClassesScreen> {
//     late double opacity;

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
    
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Form Classes',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.paymentTxtColor1,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildClassSection(context, 'JSS 2', [
//                 {'name': 'JSS2 Pink', 'students': '25 Students'},
//                 {'name': 'JSS2 Red', 'students': '25 Students'},
//                 {'name': 'JSS2 Red', 'students': '25 Students'},
//               ]),
//               _buildClassSection(context, 'SS 2', [
//                 {'name': 'SS2 Pink', 'students': '25 Students'},
//                 {'name': 'SS2 Red', 'students': '25 Students'},
//                 {'name': 'SS2 Red', 'students': '25 Students'},
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildClassSection(
//       BuildContext context, String header, List<Map<String, String>> classes) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 header,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.paymentTxtColor1,
//                 ),
//               ),
//               const Divider(
//                 color: AppColors.paymentTxtColor1,
//                 thickness: 2,
//               ),
//             ],
//           ),
//           const SizedBox(height: 8.0),
//           // Cards
//           Column(
//             children: classes
//                 .map(
//                   (classData) => GestureDetector(
//                     onTap: () => _showTermOverlay(context),
//                     child: Container(
//                       width: double.infinity, // Makes the card fill the width
//                       margin: const EdgeInsets.only(bottom: 8.0),
//                       child: Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 classData['name']!,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: AppColors.paymentTxtColor1,
//                                 ),
//                               ),
//                               const SizedBox(height: 4.0),
//                               Text(
//                                 classData['students']!,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.black54,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }

// void _showTermOverlay(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (BuildContext context) {
//       return Container(
//         height: MediaQuery.of(context).size.height * 0.4,
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
//                   itemCount: 4,
//                   separatorBuilder: (context, index) => const Divider(),
//                   itemBuilder: (context, index) {
//                     final icons = [
//                       'assets/icons/result/comment.svg',
//                       'assets/icons/result/skill.svg',
//                       'assets/icons/result/course.svg',
//                       'assets/icons/result/composite_result.svg',
//                     ];
//                     final labels = [
//                       'Comment on results',
//                       'Skills and Behaviour',
//                       'Attendance',
//                       'Students',
//                     ];
//                     final colors = [
//                       AppColors.bgColor2,
//                       AppColors.bgColor3,
//                       AppColors.bgColor4,
//                       AppColors.bgColor5,
//                     ];
//                     final iconColors = [
//                       AppColors.iconColor1,
//                       AppColors.iconColor2,
//                       AppColors.iconColor3,
//                       AppColors.iconColor4,
//                     ];

//                     // Define navigation destinations for each index
//                     final screens = [
//                       const StaffCommentResultScreen(),
//                       const StaffSkillsBehaviourScreen(classId: '', levelId: '',),
//                       StaffAttandanceScreen(),
//                       StaffCoursesScreen(),
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
// }