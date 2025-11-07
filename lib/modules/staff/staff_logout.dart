import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';


class StaffProfileScreen extends StatefulWidget {
  final VoidCallback logout;
  const StaffProfileScreen({super.key, required this.logout});
 

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  // User data variables
  int staffId = 0;
  String staffName = '';
  String email = '';
  String schoolName = '';
  int academicYear = 0;
  int academicTerm = 0;
  String userRole = '';
  List<Map<String, dynamic>> formClasses = [];
  List<Map<String, dynamic>> courses = [];
  int totalClasses = 0;
  int totalCourses = 0;
  int totalStudents = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
      final dataMap = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData as Map<String, dynamic>;
      final data = dataMap['response']?['data'] ?? dataMap['data'] ?? {};
      final profile = data['profile'] ?? {};
      final settings = data['settings'] ?? {};
      final formClassesData = data['form_classes'] ?? [];
      final coursesData = data['courses'] ?? [];

      // Calculate totals
      int classCount = 0;
      int courseCount = 0;
      int studentCount = 0;

      // Count form classes
      for (var level in formClassesData) {
        final classes = level['classes'] ?? [];
        classCount += (classes as List).length;
      }

      // Count courses and students
      for (var classData in coursesData) {
        final classCourses = classData['courses'] ?? [];
        courseCount += (classCourses as List).length;
        for (var course in classCourses) {
          studentCount += int.tryParse(course['num_of_students'].toString()) ?? 0;
        }
      }

      setState(() {
        staffId = int.tryParse(profile['staff_id'].toString()) ?? 0;
        staffName = profile['name']?.toString() ?? 'Staff';
        email = profile['email']?.toString() ?? 'N/A';
        userRole = profile['role']?.toString() ?? 'staff';
        schoolName = settings['school_name']?.toString() ?? '';
        academicYear = int.tryParse(settings['year'].toString()) ?? 0;
        academicTerm = int.tryParse(settings['term'].toString()) ?? 0;
        formClasses = List<Map<String, dynamic>>.from(formClassesData);
        courses = List<Map<String, dynamic>>.from(coursesData);
        totalClasses = classCount;
        totalCourses = courseCount;
        totalStudents = studentCount;
        isLoading = false;
      });

    } catch (e) {
      print("❌ Error loading user data: $e");
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double opacity = brightness == Brightness.light ? 0.1 : 0.15;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.paymentTxtColor1,
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.paymentTxtColor1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section - Now scrollable
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.paymentTxtColor1,
                
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.paymentTxtColor1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    staffName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  
                  
               
                ],
              ),
            ),
           
            // Bottom Section - Now part of the scrollable content
            Container(
              decoration: Constants.customBoxDecoration(context),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildSectionHeader('School Information'),
                  _buildInfoRow('School', schoolName),
                  const Divider(),
                  _buildInfoRow('Academic Year', academicYear.toString()),
                  const Divider(),
                  _buildInfoRow('Term', 'Term $academicTerm'),
                  const Divider(),

                  _buildSectionHeader('Staff Information'),
                  _buildInfoRow('Staff ID', staffId.toString()),
                  const Divider(),
                  _buildInfoRow('Name', staffName),
                  const Divider(),
                  _buildInfoRow('Email', email),
                  const Divider(),
                  _buildInfoRow('Role', userRole),
                  const Divider(),

                  _buildSectionHeader('Teaching Statistics'),
                  _buildInfoRow('Total Classes', totalClasses.toString()),
                  const Divider(),
                  _buildInfoRow('Total Courses', totalCourses.toString()),
                  const Divider(),
                  _buildInfoRow('Total Students', totalStudents.toString()),
                  const Divider(),

                  if (formClasses.isNotEmpty) ...[
                    _buildSectionHeader('Form Classes'),
                    ...formClasses.map((level) => _buildFormClassInfo(level)).toList(),
                  ],

                  if (courses.isNotEmpty) ...[
                    _buildSectionHeader('Courses'),
                    ...courses.map((classData) => _buildCourseInfo(classData)).toList(),
                  ],

                  const SizedBox(height: 20.0),

                  // Logout Button
                  ElevatedButton(
                    onPressed: () {
                     widget.logout(); // Perform logout action
     
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 8.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    if (staffName.isEmpty) return 'S';
    final names = staffName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  Widget _buildFormClassInfo(Map<String, dynamic> level) {
    final levelName = level['level_name']?.toString() ?? 'N/A';
    final classes = level['classes'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            levelName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.paymentTxtColor1,
            ),
          ),
        ),
        ...classes.map<Widget>((classInfo) {
          final className = classInfo['class_name']?.toString() ?? 'N/A';
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Text(
              '• $className',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          );
        }).toList(),
        const Divider(),
      ],
    );
  }

  Widget _buildCourseInfo(Map<String, dynamic> classData) {
    final className = classData['class_name']?.toString() ?? 'N/A';
    final courses = classData['courses'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            className,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.paymentTxtColor1,
            ),
          ),
        ),
        ...courses.map<Widget>((courseInfo) {
          final courseName = courseInfo['course_name']?.toString() ?? 'N/A';
          final numStudents = courseInfo['num_of_students']?.toString() ?? '0';
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Text(
              '• $courseName ($numStudents students)',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          );
        }).toList(),
        const Divider(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.paymentTxtColor1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconColumn(String svgPath) {
    return SvgPicture.asset(svgPath);
  }

  Widget _buildRowWithIcon({required String svgIcon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SvgPicture.asset(svgIcon, width: 24, height: 24),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}