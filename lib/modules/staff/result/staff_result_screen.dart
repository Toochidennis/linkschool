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
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class StaffResultScreen extends StatefulWidget {
  @override
  _StaffResultScreenState createState() => _StaffResultScreenState();
}

class _StaffResultScreenState extends State<StaffResultScreen> {
  String searchQuery = "";
  String activeTab = "overview";
  List<Map<String, dynamic>> classSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  void _loadStaffData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final staffCourses = authProvider.getStaffCourses();
    final formClasses = authProvider.getFormClasses();
    final userProfile = authProvider.getUserProfile();

    // Transform staff courses data to match UI structure organized by levels
    classSubjects = _transformStaffCoursesToUIByLevel(staffCourses, formClasses);
  }

  List<Map<String, dynamic>> _transformStaffCoursesToUIByLevel(
    List<Map<String, dynamic>> staffCourses, 
    List<Map<String, dynamic>> formClasses) {
  
  // Create a map to store level information for each class
  Map<int, Map<String, dynamic>> classToLevelMap = {};
  
  // First, map classes to their levels from form_classes data
  for (var levelData in formClasses) {
    String levelName = levelData['level_name'] ?? '';
    int levelId = levelData['level_id'] ?? 0;
    List<dynamic> classes = levelData['classes'] ?? [];
    
    for (var classData in classes) {
      int classId = classData['class_id'] ?? 0;
      classToLevelMap[classId] = {
        'level_id': levelId,
        'level_name': levelName,
      };
    }
  }
  
  // Group courses by level, then by class
  Map<String, Map<String, List<Map<String, dynamic>>>> levelStructure = {};
  
  for (var classData in staffCourses) {
    int classId = classData['class_id'] ?? 0;
    String className = classData['class_name'] ?? '';
    List<dynamic> courses = classData['courses'] ?? [];
    
    // Determine level for this class
    String levelName = 'Unknown Level';
    if (classToLevelMap.containsKey(classId)) {
      levelName = classToLevelMap[classId]!['level_name'];
    } else {
      // If not in form_classes, try to extract level from class name
      levelName = _extractLevelFromClassName(className);
    }
    
    // Initialize level structure if not exists
    if (!levelStructure.containsKey(levelName)) {
      levelStructure[levelName] = {};
    }
    
    // Process courses for this class
    List<Map<String, dynamic>> subjects = [];
    for (var course in courses) {
      subjects.add({
        "name": course['course_name'] ?? '',
        "icon": _getIconForSubject(course['course_name'] ?? ''),
        "students": course['num_of_students'] ?? 0,
        "progress": _calculateProgress(course['num_of_students'] ?? 0),
        "color": _getColorForSubject(course['course_name'] ?? ''),
        "course_id": course['course_id'] ?? 0,
      });
    }
    
    if (subjects.isNotEmpty) {
      levelStructure[levelName]![className] = subjects;
    }
  }
  
  // Transform to UI structure
  List<Map<String, dynamic>> transformedData = [];
  
  levelStructure.forEach((levelName, classesData) {
    List<Map<String, dynamic>> classesForLevel = [];
    
    classesData.forEach((className, subjects) {
      classesForLevel.add({
        "class_name": className,
        "class_id": _getClassIdFromName(className, staffCourses),
        "subjects": subjects,
      });
    });
    
    if (classesForLevel.isNotEmpty) {
      transformedData.add({
        "level": levelName,
        "classes": classesForLevel,
      });
    }
  });
  
  // Sort levels for consistent display
  transformedData.sort((a, b) => a["level"].compareTo(b["level"]));
  
  return transformedData;
}

String _extractLevelFromClassName(String className) {
  // Extract level from class name (e.g., "JSS1B" -> "JSS1", "SSS2A" -> "SSS2")
  if (className.length >= 4) {
    return className.substring(0, 4);
  }
  return className;
}

int _getClassIdFromName(String className, List<Map<String, dynamic>> staffCourses) {
  for (var classData in staffCourses) {
    if (classData['class_name'] == className) {
      return classData['class_id'] ?? 0;
    }
  }
  return 0;
}

  IconData _getIconForSubject(String subjectName) {
    String lowerName = subjectName.toLowerCase();
    if (lowerName.contains('math') || lowerName.contains('numerical')) {
      return Icons.calculate;
    } else if (lowerName.contains('science') || lowerName.contains('biology') || lowerName.contains('chemistry')) {
      return Icons.science;
    } else if (lowerName.contains('english') || lowerName.contains('literature') || lowerName.contains('literacy')) {
      return Icons.menu_book;
    } else if (lowerName.contains('computer') || lowerName.contains('code')) {
      return Icons.computer;
    } else if (lowerName.contains('history') || lowerName.contains('civic')) {
      return Icons.history_edu;
    } else if (lowerName.contains('security')) {
      return Icons.security;
    } else if (lowerName.contains('catering') || lowerName.contains('craft')) {
      return Icons.restaurant;
    } else {
      return Icons.book;
    }
  }

  Color _getColorForSubject(String subjectName) {
    String lowerName = subjectName.toLowerCase();
    if (lowerName.contains('math') || lowerName.contains('numerical')) {
      return Colors.blue;
    } else if (lowerName.contains('science') || lowerName.contains('biology')) {
      return Colors.green;
    } else if (lowerName.contains('chemistry')) {
      return Colors.teal;
    } else if (lowerName.contains('english') || lowerName.contains('literature')) {
      return Colors.purple;
    } else if (lowerName.contains('computer') || lowerName.contains('code')) {
      return Colors.indigo;
    } else if (lowerName.contains('history') || lowerName.contains('civic')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  int _calculateProgress(int numStudents) {
    // Simple progress calculation based on number of students
    // You can modify this logic based on your requirements
    if (numStudents == 0) return 0;
    if (numStudents <= 5) return 60;
    if (numStudents <= 15) return 75;
    if (numStudents <= 25) return 85;
    return 90;
  }

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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userProfile = authProvider.getUserProfile();
        final userName = userProfile['name'] ?? 'Staff';

        return Scaffold(
          appBar: CustomStudentAppBar(
            title: 'Welcome',
            subtitle: userName,
            showNotification: true,
            onNotificationTap: () {},
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
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       "My Classes & Subjects",
                        //       style: TextStyle(
                        //         fontSize: 25,
                        //         fontWeight: FontWeight.bold,
                        //         color: AppColors.bookText,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 16),
                        classSubjects.isEmpty
                            ? _buildEmptyState()
                            : Column(
                                children: classSubjects.map<Widget>((levelData) {
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Class Header
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 8),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 4,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: AppColors.bookText.withOpacity(0.6),
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      classData["class_name"],
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.bookText.withOpacity(0.8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Subjects under this class
                                              ...classData["subjects"].map<Widget>((subject) {
                                                return Container(
                                                  margin: EdgeInsets.only(left: 12, bottom: 8),
                                                  child: GestureDetector(
                                                    onTap: () => _showOverlayDialog(
                                                      subject["name"],
                                                      subject,
                                                      classData["class_id"],
                                                    ),
                                                    child: _buildClassItem(
                                                      subject["name"],
                                                      subject["icon"],
                                                      subject["students"],
                                                      subject["progress"],
                                                      subject["color"],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
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
            Icons.school_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No classes assigned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You have not been assigned to any classes yet.',
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor(progress).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$progress%",
              style: TextStyle(
                color: getStatusColor(progress),
                fontWeight: FontWeight.bold,
              ),
            ),
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

  void _showOverlayDialog(String subject, Map<String, dynamic> courseData, int classId) {
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
                          () => _navigateToAddResult(subject, courseData, classId),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: _buildDialogButton(
                          'View',
                          'assets/icons/result/eye.svg',
                          () => _navigateToViewResult(subject, courseData, classId),
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
                          () => _navigateToMonthlyAssessment(subject, courseData, classId),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0),
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

  void _navigateToViewResult(String subject, Map<String, dynamic> courseData, int classId) {
    Navigator.pop(context); // Close the bottom sheet first
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settings = authProvider.getSettings();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffviewcourseResult(
          classId: classId.toString(),
          year: settings['year']?.toString() ?? '',
          term: settings['term']?.toString() ?? '',
          termName: 'Term ${settings['term'] ?? ''}',
          subject: subject,
          courseData: courseData,
        ),
      ),
    );
  }

  void _navigateToAddResult(String subject, Map<String, dynamic> courseData, int classId) {
    Navigator.pop(context); // Close the bottom sheet first
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settings = authProvider.getSettings();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStaffViewCourseResultScreen(
          classId: classId.toString(),
          year: settings['year']?.toString() ?? '',
          term: settings['term']?.toString() ?? '',
          termName: 'Term ${settings['term'] ?? ''}',
          subject: subject,
          courseData: courseData,
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
      title: Text(
        'Attendance',
        style: AppTextStyles.normal600(
            fontSize: 14, color: AppColors.backgroundDark),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffTakeAttendanceScreen(),
          ),
        );
      },
    );
  }

  void _navigateToMonthlyAssessment(
      String subject, Map<String, dynamic> courseData, int classId) {
    Navigator.pop(context); // Close the bottom sheet first
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settings = authProvider.getSettings();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthlyStaffAssessmentScreen(
          classId: classId.toString(),
          year: settings['year']?.toString() ?? '',
          term: settings['term']?.toString() ?? '',
          termName: 'Term ${settings['term'] ?? ''}',
          subject: subject,
          courseData: courseData,
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
// import 'package:linkschool/modules/staff/home/form_classes_screen.dart';
// import 'package:linkschool/modules/staff/home/staff_take_attandance_screen.dart';
// import 'package:linkschool/modules/staff/result/add_view_result.dart';
// import 'package:linkschool/modules/staff/result/staffViewCourseResult.dart';
// import 'package:linkschool/modules/staff/result/staff_monthly_assesment_screen.dart';

// class StaffResultScreen extends StatefulWidget {
//   @override
//   _StaffResultScreenState createState() => _StaffResultScreenState();
// }

// class _StaffResultScreenState extends State<StaffResultScreen> {
//   String searchQuery = "";
//   String activeTab = "overview";

//   final List<Map<String, dynamic>> classSubjects = [
//     {
//       "class": "JSS 1",
//       "subjects": [
//         {
//           "name": "Mathematics",
//           "icon": Icons.calculate,
//           "students": 28,
//           "progress": 85,
//           "color": Colors.blue
//         },
//         {
//           "name": "Biology",
//           "icon": Icons.science,
//           "students": 32,
//           "progress": 72,
//           "color": Colors.green
//         },
//         {
//           "name": "Literature",
//           "icon": Icons.menu_book,
//           "students": 25,
//           "progress": 88,
//           "color": Colors.purple
//         },
//       ]
//     },
//     {
//       "class": "JSS 1B",
//       "subjects": [
//         {
//           "name": "Chemistry",
//           "icon": Icons.science_outlined,
//           "students": 30,
//           "progress": 80,
//           "color": Colors.teal
//         },
//         {
//           "name": "History",
//           "icon": Icons.history_edu,
//           "students": 29,
//           "progress": 70,
//           "color": Colors.orange
//         },
//         {
//           "name": "History",
//           "icon": Icons.history_edu,
//           "students": 29,
//           "progress": 70,
//           "color": Colors.orange
//         },
//       ]
//     },
//     {
//       "class": "JSS 2",
//       "subjects": [
//         {
//           "name": "Chemistry",
//           "icon": Icons.science_outlined,
//           "students": 30,
//           "progress": 80,
//           "color": Colors.teal
//         },
//         {
//           "name": "History",
//           "icon": Icons.history_edu,
//           "students": 29,
//           "progress": 70,
//           "color": Colors.orange
//         },
//         {
//           "name": "History",
//           "icon": Icons.history_edu,
//           "students": 29,
//           "progress": 70,
//           "color": Colors.orange
//         },
//       ]
//     }
//   ];

  
//   Color getStatusColor(int value) {
//     if (value >= 80) return Colors.green;
//     if (value >= 60) return Colors.orange;
//     return Colors.red;
//   }

//   String getStatusText(int value) {
//     if (value >= 80) return "Excellent";
//     if (value >= 60) return "Average";
//     return "Needs Improvement";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: CustomStudentAppBar(
//           title: 'Welcome',
//           subtitle: 'Tochukwu',
//           showNotification: true,
//           // showPostInput: true,
//           onNotificationTap: () {},
//           // onPostTap: _showNewPostDialog,
//         ),
//         body: Container(
//             decoration: Constants.customBoxDecoration(context),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   // My Classes
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
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Classes",
//                                 style: TextStyle(
//                                     fontSize: 25, fontWeight: FontWeight.bold,color: AppColors.bookText)),
                       
//                           ],
//                         ),
//                         SizedBox(height: 16),
//                         Column(
//                           children: classSubjects.map<Widget>((classData) {
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(classData["class"],
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: AppColors.bookText)),
//                                 SizedBox(height: 8),
//                                 ...classData["subjects"].map<Widget>((subject) {
//                                   return GestureDetector(
//                                     onTap: () => _showOverlayDialog(
//                                       subject["name"],
//                                       subject,
//                                     ),
//                                     child: _buildClassItem(
//                                       subject["name"],
//                                       subject["icon"],
//                                       subject["students"],
//                                       subject["progress"],
//                                       subject["color"],
//                                     ),
//                                   );
//                                 }).toList(),
//                                 SizedBox(height: 16),
//                               ],
//                             );
//                           }).toList(),
//                         ),
//                         SizedBox(height: 100),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             )));
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
//                 Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.bookText)),
//                 Text("$students students",
//                     style: TextStyle(color: Colors.grey, fontSize: 12)),
//               ],
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: getStatusColor(progress).withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text("$progress%",
//                 style: TextStyle(
//                   color: getStatusColor(progress),
//                   fontWeight: FontWeight.bold,
//                 )),
//           ),
//           SizedBox(width: 12),
//           IconButton(
//             icon: Icon(Icons.chevron_right, color: Colors.grey),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   void _showOverlayDialog(String subject, Map<String, dynamic> courseData) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           color: Colors.white,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Top Section - Result
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header Row
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Text(
//                       'Result',
//                       style: AppTextStyles.normal600(
//                           fontSize: 16, color: AppColors.backgroundDark),
//                     ),
//                   ),
//                   // Body Row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildDialogButton(
//                           'Add',
//                           'assets/icons/result/edit.svg',
//                           () => _navigateToAddResult(subject, courseData),
//                         ),
//                       ),
//                       const SizedBox(width: 8.0),
//                       Expanded(
//                         child: _buildDialogButton(
//                           'View',
//                           'assets/icons/result/eye.svg',
//                           () => _navigateToViewResult(subject, courseData),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16.0),

//               // Bottom Section - Monthly Assessment
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header Row
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Text(
//                       'Monthly assessment',
//                       style: AppTextStyles.normal600(
//                           fontSize: 16, color: AppColors.backgroundDark),
//                     ),
//                   ),
//                   // Body Row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildDialogButton(
//                           'Add',
//                           'assets/icons/result/edit.svg',
//                           () {
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 8.0),
//                       Expanded(
//                         child: _buildDialogButton(
//                           'View',
//                           'assets/icons/result/eye.svg',
//                           () =>
//                               _navigateToMonthlyAssessment(subject, courseData),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//                SizedBox(
//                 height: 16.0,
//               ),
//               Divider(
//                 color: Colors.grey[300],
//                 thickness: 1,
//               ),
//                _buildAttendanceButton(
//                 'Take Attendance',
//                  'assets/icons/result/course.svg',
//                 () {
//                   Navigator.pop(context); // Close the bottom sheet first
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => StaffTakeAttendanceScreen(),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDialogButton(
//       String text, String iconPath, VoidCallback onPressed) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: TextButton.icon(
//         onPressed: onPressed,
//         icon: SvgPicture.asset(
//           iconPath,
//           color: Colors.grey,
//         ),
//         label: Text(
//           text,
//           style: AppTextStyles.normal600(
//               fontSize: 14, color: AppColors.backgroundDark),
//         ),
//       ),
//     );
//   }
//   Widget _buildAttendanceButton(
//       String text, String iconPath, VoidCallback onPressed) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: TextButton.icon(
//         onPressed: onPressed,
//         icon: SvgPicture.asset(
//           iconPath,
//           color: Colors.grey,
//         ),
//         label: Text(
//           text,
//           style: AppTextStyles.normal600(
//               fontSize: 14, color: AppColors.backgroundDark),
//         ),
//       ),
//     );
//   }

//    void _navigateToViewResult(String subject, Map<String, dynamic> courseData) {
//     Navigator.pop(context); // Close the bottom sheet first

//     // Navigate to ViewCourseResultScreen for read-only viewing
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>StaffviewcourseResult(
//           // classId: widget.classId,
//           // year: widget.year,
//           // term: widget.term,
//           // termName: widget.termName,
//           // subject: subject,
//           // courseData: courseData,
//         ),
//       ),
//     );
//   }
//  void _navigateToAddResult(String subject, Map<String, dynamic> courseData) {
//     Navigator.pop(context); // Close the bottom sheet first

//     // Navigate to AddViewCourseResultScreen for editing/adding results
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddStaffViewCourseResultScreen(
//           // classId: "",
//           // year:'',
//           // term: "",
//           // termName: "",
//           // subject: subject,
//           // courseData: courseData,
//         ),
//       ),
//     );
//   }


//   Widget buildInputResultsItem(BuildContext context) {
//   return ListTile(
//     leading: Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         color: AppColors.bgColor4,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Center(
//         child: SvgPicture.asset(
//           'assets/icons/result/course.svg',
//           color: AppColors.iconColor3,
//           width: 20,
//           height: 20,
//         ),
//       ),
//     ),
//     title: Text('Attendance',
//         style: AppTextStyles.normal600(
//             fontSize: 14, color: AppColors.backgroundDark)),
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => StaffTakeAttendanceScreen(
//               // Pass any required arguments here
//           ),
//         ),
//       );
//     },
//   );
// }

//   void _navigateToMonthlyAssessment(
//       String subject, Map<String, dynamic> courseData) {
//     Navigator.pop(context); // Close the bottom sheet first

//     // Navigate to MonthlyAssessmentScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MonthlyStaffAssessmentScreen(
//           // classId: widget.classId,
//           // year: widget.year,
//           // term: widget.term,
//           // termName: widget.termName,
//           // subject: subject,
//           // courseData: courseData,
//         ),
//       ),
//     );
//   }

// //   void _showTermOverlay(BuildContext context) {
// //   showModalBottomSheet(
// //     context: context,
// //     isScrollControlled: true,
// //     backgroundColor: Colors.transparent,
// //     builder: (BuildContext context) {
// //       return Container(
// //         height: MediaQuery.of(context).size.height * 0.2,
// //         decoration: const BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //         ),
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
// //           child: Column(
// //             children: [
// //               Expanded(
// //                 child: ListView.separated(
// //                   physics: const NeverScrollableScrollPhysics(),
// //                   itemCount: 2,
// //                   separatorBuilder: (context, index) => const Divider(),
// //                   itemBuilder: (context, index) {
// //                     final icons = [
// //                       'assets/icons/result/assessment.svg',
// //                       'assets/icons/result/eye.svg',
                      
// //                     ];
// //                     final labels = [
// //                       'Input results',
// //                       'View results',
                      
// //                     ];
// //                     final colors = [
// //                       AppColors.bgColor2,
// //                       AppColors.bgColor3,
                     
// //                     ];
// //                     final iconColors = [
// //                       AppColors.iconColor1,
// //                       AppColors.iconColor2,
                     
// //                     ];

// //                     // Define navigation destinations for each index
// //                     final screens = [
// //                       // Add your navigation destinations here
                     
// //                     ];

// //                     return ListTile(
// //                       leading: Container(
// //                         width: 40,
// //                         height: 40,
// //                         decoration: BoxDecoration(
// //                           color: colors[index],
// //                           borderRadius: BorderRadius.circular(4),
// //                         ),
// //                         child: Center(
// //                           child: SvgPicture.asset(
// //                             icons[index],
// //                             color: iconColors[index],
// //                             width: 20,
// //                             height: 20,
// //                           ),
// //                         ),
// //                       ),
// //                       title: Text(labels[index]),
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(builder: (context) => screens[index]),
// //                         );
// //                       },
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     },
// //   );
// // }
// }
