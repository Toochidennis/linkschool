import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_attandance_screen.dart';
import 'package:linkschool/modules/staff/result/staff_add_view_course_result.dart';
import 'package:linkschool/modules/staff/result/staff_view_course_result.dart';
import 'package:linkschool/modules/staff/result/staff_monthly_assesment_screen.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class StaffResultScreen extends StatefulWidget {
  const StaffResultScreen({super.key});

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
    classSubjects =
        _transformStaffCoursesToUIByLevel(staffCourses, formClasses);
  }

  List<Map<String, dynamic>> _transformStaffCoursesToUIByLevel(
      List<Map<String, dynamic>> staffCourses,
      List<Map<String, dynamic>> formClasses) {
    Map<int, Map<String, dynamic>> classToLevelMap = {};
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

    Map<String, Map<String, List<Map<String, dynamic>>>> levelStructure = {};
    for (var classData in staffCourses) {
      int classId = classData['class_id'] ?? 0;
      String className = classData['class_name'] ?? '';
      List<dynamic> courses = classData['courses'] ?? [];
      String levelName = classToLevelMap.containsKey(classId)
          ? classToLevelMap[classId]!['level_name']
          : _extractLevelFromClassName(className);

      if (!levelStructure.containsKey(levelName)) {
        levelStructure[levelName] = {};
      }

      List<Map<String, dynamic>> subjects = [];
      for (var course in courses) {
        subjects.add({
          "name": course['course_name'] ?? '',
          "icon": _getIconForSubject(course['course_name'] ?? ''),
          "students": course['num_of_students'] ?? 0,
          "color": _getColorForSubject(course['course_name'] ?? ''),
          "course_id": course['course_id'] ?? 0,
          "class_id": classId,
          "class_name": className,
        });
      }

      if (subjects.isNotEmpty) {
        levelStructure[levelName]![className] = subjects;
      }
    }

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

    transformedData.sort((a, b) => a["level"].compareTo(b["level"]));
    return transformedData;
  }

  String _extractLevelFromClassName(String className) {
    if (className.length >= 4) {
      return className.substring(0, 4);
    }
    return className;
  }

  int _getClassIdFromName(
      String className, List<Map<String, dynamic>> staffCourses) {
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
    } else if (lowerName.contains('science') ||
        lowerName.contains('biology') ||
        lowerName.contains('chemistry')) {
      return Icons.science;
    } else if (lowerName.contains('english') ||
        lowerName.contains('literature') ||
        lowerName.contains('literacy')) {
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
      return Colors.blue.shade600;
    } else if (lowerName.contains('science') || lowerName.contains('biology')) {
      return Colors.green.shade600;
    } else if (lowerName.contains('chemistry')) {
      return Colors.teal.shade600;
    } else if (lowerName.contains('english') ||
        lowerName.contains('literature')) {
      return Colors.purple.shade600;
    } else if (lowerName.contains('computer') || lowerName.contains('code')) {
      return Colors.indigo.shade600;
    } else if (lowerName.contains('history') || lowerName.contains('civic')) {
      return Colors.orange.shade600;
    } else {
      return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
                    classSubjects.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: classSubjects.map<Widget>((levelData) {
                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        margin: EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.bookText
                                                  .withOpacity(0.1),
                                              AppColors.bookText
                                                  .withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                      ...levelData["classes"]
                                          .map<Widget>((classData) {
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 12),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 6,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            AppColors.bookText,
                                                            AppColors.bookText
                                                                .withOpacity(
                                                                    0.7),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        classData["class_name"],
                                                        style: AppTextStyles
                                                            .normal600(
                                                          fontSize: 18,
                                                          color: AppColors
                                                              .bookText,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ...classData["subjects"]
                                                  .map<Widget>((subject) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 12),
                                                  child: GestureDetector(
                                                    onTap: () =>
                                                        _showOverlayDialog(
                                                      subject["name"],
                                                      subject,
                                                      classData["class_id"],
                                                      classData["class_name"],
                                                    ),
                                                    child: _buildClassItem(
                                                      subject["name"],
                                                      subject["icon"],
                                                      subject["students"],
                                                      subject["color"],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
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
              Icons.school_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No Classes Assigned',
              style: AppTextStyles.normal700(
                fontSize: 20,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You have not been assigned to any classes yet. Contact your administrator.',
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
              child: Icon(Icons.chevron_right,
                  color: Colors.grey.shade600, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showOverlayDialog(String subject, Map<String, dynamic> courseData,
      int classId, String className) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Result',
                    style: AppTextStyles.normal700(
                      fontSize: 18,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogButton(
                          'Add Result',
                          'assets/icons/result/edit.svg',
                          () => _navigateToAddResult(
                              subject, courseData, classId),
                          Colors.blue.shade50,
                          Colors.blue.shade600,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildDialogButton(
                          'View Result',
                          'assets/icons/result/eye.svg',
                          () => _navigateToViewResult(
                              subject, courseData, classId),
                          Colors.green.shade50,
                          Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Assessment',
                    style: AppTextStyles.normal700(
                      fontSize: 18,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogButton(
                          'Add Assessment',
                          'assets/icons/result/edit.svg',
                          () => Navigator.pop(context),
                          Colors.purple.shade50,
                          Colors.purple.shade600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildDialogButton(
                          'View Assessment',
                          'assets/icons/result/eye.svg',
                          () => _navigateToMonthlyAssessment(
                              subject, courseData, classId),
                          Colors.purple.shade50,
                          Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Divider(color: Colors.grey.shade200),
              SizedBox(height: 16),
              _buildAttendanceButton(
                'Take Attendance',
                'assets/icons/result/course.svg',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffAttendanceScreen(
                        classId: classId.toString(),
                        courseId: courseData['course_id'].toString(),
                        className: className,
                        courseName: courseData['name'] ?? '',
                      ),
                    ),
                  );
                },
                Colors.orange.shade50,
                Colors.orange.shade600,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogButton(String text, String iconPath,
      VoidCallback onPressed, Color bgColor, Color iconColor) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              color: iconColor,
              width: 20,
              height: 20,
            ),
            SizedBox(width: 4),
            Text(
              text,
              style: AppTextStyles.normal600(
                fontSize: 14,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceButton(String text, String iconPath,
      VoidCallback onPressed, Color bgColor, Color iconColor) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              color: iconColor,
              width: 24,
              height: 24,
            ),
            SizedBox(width: 12),
            Text(
              text,
              style: AppTextStyles.normal600(
                fontSize: 16,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToViewResult(
      String subject, Map<String, dynamic> courseData, int classId) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffViewCourseResult(
          classId: classId.toString(),
          subject: subject,
          courseData: courseData,
        ),
      ),
    );
  }

  void _navigateToAddResult(
      String subject, Map<String, dynamic> courseData, int classId) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffAddViewCourseResult(
          classId: classId.toString(),
          subject: subject,
          courseData: courseData,
        ),
      ),
    );
  }

  void _navigateToMonthlyAssessment(
      String subject, Map<String, dynamic> courseData, int classId) {
    Navigator.pop(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settings = authProvider.getSettings();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthlyStaffAssessmentScreen(
          classId: classId.toString(),
          year: settings['year']?.toString() ?? '',
          term: settings['term'] ?? '',
          termName: 'Term ${settings['term'] ?? ''}',
          subject: subject,
          courseData: courseData,
        ),
      ),
    );
  }

  Widget buildInputResultsItem(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.bgColor4,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/result/course.svg',
              color: AppColors.iconColor3,
              width: 24,
              height: 24,
            ),
          ),
        ),
        title: Text(
          'Attendance',
          style: AppTextStyles.normal600(
            fontSize: 16,
            color: AppColors.backgroundDark,
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Please select a specific course to take attendance'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }
}
