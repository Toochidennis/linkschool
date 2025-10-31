import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/staff/settings_service.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/staff_comment_result_screen.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/staff_skills_behaviour_screen.dart';
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
  late String currentYear;
  late int currentTerm;
  late String currentTermName;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _loadFormClassesData();
  }

  void _initializeSettings() {
    currentYear = SettingsService.getCurrentYear();
    currentTerm = SettingsService.getCurrentTerm();
    currentTermName = SettingsService.getTermName(currentTerm);
  }

  void _loadFormClassesData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final formClasses = authProvider.getFormClasses();
    final staffCourses = authProvider.getStaffCourses();
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

        int studentCount = _getStudentCountForClass(classId, staffCourses);

        classesForLevel.add({
          "class_id": classId,
          "class_name": className,
          "students": studentCount,
          "color": _getColorForClass(className),
          "icon": Icons.class_,
          "year": currentYear,
          "term": currentTerm,
          "termName": currentTermName,
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

    transformedData.sort((a, b) => a["level"].compareTo(b["level"]));
    return transformedData;
  }

  int _getStudentCountForClass(int classId, List<Map<String, dynamic>> staffCourses) {
    for (var courseData in staffCourses) {
      if (courseData['class_id'] == classId) {
        List<dynamic> courses = courseData['courses'] ?? [];
        if (courses.isNotEmpty) {
          return courses.map((c) => c['num_of_students'] as int? ?? 0).reduce((a, b) => a > b ? a : b);
        }
      }
    }
    return 0;
  }

  Color _getColorForClass(String className) {
    int hash = className.hashCode;
    List<Color> colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.purple.shade600,
      Colors.orange.shade600,
      Colors.teal.shade600,
      Colors.indigo.shade600,
      Colors.pink.shade600,
      Colors.cyan.shade600,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    final screenWidth = MediaQuery.of(context).size.width;

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
              style: AppTextStyles.normal700(
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
              ),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.eLearningBtnColor1,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Academic Session: $currentYear/${int.parse(currentYear) + 1} - $currentTermName',
                                style: AppTextStyles.normal600(
                                  fontSize: 16,
                                  color: AppColors.eLearningBtnColor1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    formClassesData.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: formClassesData.map<Widget>((levelData) {
                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        margin: EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.bookText.withOpacity(0.1),
                                              AppColors.bookText.withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.school,
                                              color: AppColors.bookText,
                                              size: 24,
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                levelData["level"],
                                                style: AppTextStyles.normal700(
                                                  fontSize: 20,
                                                  color: AppColors.bookText,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ...levelData["classes"].map<Widget>((classData) {
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 12),
                                          child: GestureDetector(
                                            onTap: () => _showTermOverlay(
                                              context,
                                              classData["class_name"],
                                              classData["class_id"].toString(),
                                              levelData["level_id"].toString(),
                                              classData["year"],
                                              classData["term"],
                                              classData["termName"],
                                            ),
                                            child: _buildClassItem(
                                              classData["class_name"],
                                              classData["icon"],
                                              classData["students"],
                                              classData["color"],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.class_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No Form Classes Assigned',
              style: AppTextStyles.normal700(
                fontSize: 20,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You have not been assigned as a form teacher to any classes yet.',
              style: AppTextStyles.normal400(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassItem(
      String name, IconData icon, int students, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.normal600(
                      fontSize: 16,
                      color: AppColors.bookText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "$students students",
                    style: AppTextStyles.normal400(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermOverlay(
    BuildContext context,
    String className,
    String classId,
    String levelId,
    String year,
    int term,
    String termName,
  ) {
    final dbName = SettingsService.getDatabaseName();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final icons = [
                      'assets/icons/result/comment.svg',
                      'assets/icons/result/skill.svg',
                      'assets/icons/result/course.svg',
                      'assets/icons/result/composite_result.svg',
                    ];
                    final labels = [
                      'Comment on Results',
                      'Skills and Behaviour',
                      'Attendance',
                      'Students',
                    ];
                    final colors = [
                      Colors.blue.shade50,
                      Colors.purple.shade50,
                      Colors.orange.shade50,
                      Colors.green.shade50,
                    ];
                    final iconColors = [
                      Colors.blue.shade600,
                      Colors.purple.shade600,
                      Colors.orange.shade600,
                      Colors.green.shade600,
                    ];

                    final screens = [
                      StaffCommentCourseResultScreen(
                        classId: classId,
                        levelId: levelId,
                        year: year,
                        term: term,
                        termName: termName,
                      ),
                      StaffSkillsBehaviourScreen(
                        classId: classId,
                        levelId: levelId,
                        year: year,
                        term: term.toString(),
                        db: dbName,
                      ),
                      StaffAttendanceScreen(
                        classId: classId,
                        className: className,
                        isFromFormClasses: true,
                      ),
                      StaffCoursesScreen(

                        classId: classId,
                        levelId: levelId,
                        className: className,
                        ),
                    ]; 

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => screens[index]),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: colors[index],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
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
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                labels[index],
                                style: AppTextStyles.normal600(
                                  fontSize: 14,
                                  color: iconColors[index],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/services/staff/settings_service.dart';
// import 'package:linkschool/modules/staff/e_learning/form_classes/staff_comment_result_screen.dart';
// import 'package:linkschool/modules/staff/e_learning/form_classes/staff_skills_behaviour_screen.dart';
// import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_attandance_screen.dart';
// import 'package:linkschool/modules/staff/home/staff_course_screen.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// // import 'package:linkschool/services/settings_service.dart'; // Import the new service
// import 'package:provider/provider.dart';

// class FormClassesScreen extends StatefulWidget {
//   const FormClassesScreen({super.key});

//   @override
//   State<FormClassesScreen> createState() => _FormClassesScreenState();
// }

// class _FormClassesScreenState extends State<FormClassesScreen> {
//   late double opacity;
//   List<Map<String, dynamic>> formClassesData = [];
  
//   // Get current settings from stored data
//   late String currentYear;
//   late int currentTerm;
//   late String currentTermName;

//   @override
//   void initState() {
//     super.initState();
//     _initializeSettings();
//     _loadFormClassesData();
//   }

//   void _initializeSettings() {
//     // Get current year and term from stored settings
//     currentYear = SettingsService.getCurrentYear();
//     currentTerm = SettingsService.getCurrentTerm();
//     currentTermName = SettingsService.getTermName(currentTerm);
    
//     print('Initialized settings - Year: $currentYear, Term: $currentTerm, Term Name: $currentTermName');
//   }

//   void _loadFormClassesData() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final formClasses = authProvider.getFormClasses();
//     final staffCourses = authProvider.getStaffCourses();
    
//     // Transform form classes data to match UI structure with correct year and term
//     formClassesData = _transformFormClassesToUI(formClasses, staffCourses);
//   }

//   List<Map<String, dynamic>> _transformFormClassesToUI(
//     List<Map<String, dynamic>> formClasses,
//     List<Map<String, dynamic>> staffCourses,
//   ) {
//     List<Map<String, dynamic>> transformedData = [];

//     for (var levelData in formClasses) {
//       String levelName = levelData['level_name'] ?? '';
//       int levelId = levelData['level_id'] ?? 0;
//       List<dynamic> classes = levelData['classes'] ?? [];

//       List<Map<String, dynamic>> classesForLevel = [];

//       for (var classData in classes) {
//         int classId = classData['class_id'] ?? 0;
//         String className = classData['class_name'] ?? '';

//         // Get student count for this class from staff courses
//         int studentCount = _getStudentCountForClass(classId, staffCourses);

//         classesForLevel.add({
//           "class_id": classId,
//           "class_name": className,
//           "students": studentCount,
//           "progress": _calculateProgress(studentCount),
//           "color": _getColorForClass(className),
//           "icon": Icons.class_,
//           // Use the current settings instead of trying to get from class data
//           "year": currentYear,
//           "term": currentTerm,
//           "termName": currentTermName,
//         });
//       }

//       if (classesForLevel.isNotEmpty) {
//         transformedData.add({
//           "level": levelName,
//           "level_id": levelId,
//           "classes": classesForLevel,
//         });
//       }
//     }

//     // Sort levels for consistent display
//     transformedData.sort((a, b) => a["level"].compareTo(b["level"]));
//     return transformedData;
//   }

//   int _getStudentCountForClass(int classId, List<Map<String, dynamic>> staffCourses) {
//     for (var courseData in staffCourses) {
//       if (courseData['class_id'] == classId) {
//         List<dynamic> courses = courseData['courses'] ?? [];
//         if (courses.isNotEmpty) {
//           return courses.map((c) => c['num_of_students'] as int? ?? 0).reduce((a, b) => a > b ? a : b);
//         }
//       }
//     }
//     return 0;
//   }

//   Color _getColorForClass(String className) {
//     int hash = className.hashCode;
//     List<Color> colors = [
//       Colors.blue,
//       Colors.green,
//       Colors.purple,
//       Colors.orange,
//       Colors.teal,
//       Colors.indigo,
//       Colors.pink,
//       Colors.cyan,
//     ];
//     return colors[hash.abs() % colors.length];
//   }

//   int _calculateProgress(int numStudents) {
//     if (numStudents == 0) return 0;
//     if (numStudents <= 10) return 60;
//     if (numStudents <= 20) return 75;
//     if (numStudents <= 30) return 85;
//     return 90;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;

//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, child) {
//         final userProfile = authProvider.getUserProfile();
//         final userName = userProfile['name'] ?? 'Staff';

//         return Scaffold(
//           appBar: AppBar(
//             leading: IconButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               icon: Image.asset(
//                 'assets/icons/arrow_back.png',
//                 color: AppColors.paymentTxtColor1,
//                 width: 34.0,
//                 height: 34.0,
//               ),
//             ),
//             title: Text(
//               'Form Classes',
//               style: AppTextStyles.normal600(
//                 fontSize: 24.0,
//                 color: AppColors.paymentTxtColor1,
//               ),
//             ),
//             backgroundColor: Colors.white,
//             elevation: 0,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Opacity(
//                       opacity: opacity,
//                       child: Image.asset(
//                         'assets/images/background.png',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           body: Container(
//             decoration: Constants.customBoxDecoration(context),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   // Display current academic session info
//                   Container(
//                     margin: EdgeInsets.all(16),
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: AppColors.eLearningBtnColor1.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: AppColors.eLearningBtnColor1.withOpacity(0.3),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.calendar_today,
//                           color: AppColors.eLearningBtnColor1,
//                           size: 20,
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           'Academic Session: $currentYear/${int.parse(currentYear) + 1} - $currentTermName',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.eLearningBtnColor1,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.1),
//                           spreadRadius: 1,
//                           blurRadius: 3,
//                           offset: Offset(0, 1),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 16),
//                         formClassesData.isEmpty
//                             ? _buildEmptyState()
//                             : Column(
//                                 children: formClassesData.map<Widget>((levelData) {
//                                   return Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Container(
//                                         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                                         margin: EdgeInsets.only(bottom: 12),
//                                         decoration: BoxDecoration(
//                                           color: AppColors.bookText.withOpacity(0.1),
//                                           borderRadius: BorderRadius.circular(8),
//                                           border: Border.all(
//                                             color: AppColors.bookText.withOpacity(0.3),
//                                             width: 1,
//                                           ),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Icon(
//                                               Icons.school,
//                                               color: AppColors.bookText,
//                                               size: 20,
//                                             ),
//                                             SizedBox(width: 8),
//                                             Text(
//                                               levelData["level"],
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: AppColors.bookText,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       ...levelData["classes"].map<Widget>((classData) {
//                                         return Container(
//                                           margin: EdgeInsets.only(left: 16, bottom: 16),
//                                           child: GestureDetector(
//                                             onTap: () => _showTermOverlay(
//                                               context,
//                                               classData["class_name"],
//                                               classData["class_id"].toString(),
//                                               levelData["level_id"].toString(),
//                                               classData["year"],
//                                               classData["term"],
//                                               classData["termName"],
//                                             ),
//                                             child: _buildClassItem(
//                                               classData["class_name"],
//                                               classData["icon"],
//                                               classData["students"],
//                                               classData["progress"],
//                                               classData["color"],
//                                             ),
//                                           ),
//                                         );
//                                       }).toList(),
//                                       SizedBox(height: 20),
//                                     ],
//                                   );
//                                 }).toList(),
//                               ),
//                         SizedBox(height: 100),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       padding: EdgeInsets.all(32),
//       child: Column(
//         children: [
//           Icon(
//             Icons.class_outlined,
//             size: 64,
//             color: Colors.grey,
//           ),
//           SizedBox(height: 16),
//           Text(
//             'No form classes assigned',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'You have not been assigned as a form teacher to any classes yet.',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildClassItem(
//       String name, IconData icon, int students, int progress, Color color) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(icon, color: color),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.bookText,
//                   ),
//                 ),
//                 Text(
//                   "$students students",
//                   style: TextStyle(color: Colors.grey, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.chevron_right, color: Colors.grey),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   void _showTermOverlay(
//     BuildContext context,
//     String className,
//     String classId,
//     String levelId,
//     String year,
//     int term,
//     String termName,
//   ) {
//     // Get the database name from settings
//     final dbName = SettingsService.getDatabaseName();
    
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.4,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ListView.separated(
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: 4,
//                     separatorBuilder: (context, index) => const Divider(),
//                     itemBuilder: (context, index) {
//                       final icons = [
//                         'assets/icons/result/comment.svg',
//                         'assets/icons/result/skill.svg',
//                         'assets/icons/result/course.svg',
//                         'assets/icons/result/composite_result.svg',
//                       ];
//                       final labels = [
//                         'Comment on results',
//                         'Skills and Behaviour',
//                         'Attendance',
//                         'Students',
//                       ];
//                       final colors = [
//                         AppColors.bgColor2,
//                         AppColors.bgColor3,
//                         AppColors.bgColor4,
//                         AppColors.bgColor5,
//                       ];
//                       final iconColors = [
//                         AppColors.iconColor1,
//                         AppColors.iconColor2,
//                         AppColors.iconColor3,
//                         AppColors.iconColor4,
//                       ];

//                       // Define navigation destinations with correct parameters
//                       final screens = [
//                         StaffCommentCourseResultScreen(
//                           classId: classId,
//                           levelId: levelId,
//                           year: year, // Now using the correct year from settings
//                           term: term, // Now using the correct term from settings
//                           termName: termName,
//                         ),
//                         StaffSkillsBehaviourScreen(
//                           classId: classId,
//                           levelId: levelId,
//                           year: year, // Now using the correct year from settings
//                           term: term.toString(), // Convert to string as expected
//                           db: dbName, // Use the correct database name
//                         ),
//                         StaffAttandanceScreen(
//                           classId: classId,
//                           className: className,
//                           isFromFormClasses: true,
//                         ),
//                         StaffCoursesScreen(),
//                       ];

//                       return ListTile(
//                         leading: Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: colors[index],
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Center(
//                             child: SvgPicture.asset(
//                               icons[index],
//                               color: iconColors[index],
//                               width: 20,
//                               height: 20,
//                             ),
//                           ),
//                         ),
//                         title: Text(
//                           labels[index],
//                           style: AppTextStyles.normal600(
//                             fontSize: 14,
//                             color: AppColors.backgroundDark,
//                           ),
//                         ),
//                         onTap: () {
//                           Navigator.pop(context); // Close bottom sheet first
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => screens[index]),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }