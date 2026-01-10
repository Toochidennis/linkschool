import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';

class StudentProfileScreen extends StatefulWidget {
  final VoidCallback logout;
  const StudentProfileScreen({super.key, required this.logout});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  // User data variables
  int studentId = 0;
  String studentName = '';
  String registrationNo = '';
  String className = '';
  int classId = 0;
  int levelId = 0;
  String pictureUrl = '';
  String schoolName = '';
  int academicYear = 0;
  int academicTerm = 0;
  String userRole = '';
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

      setState(() {
        studentId = int.tryParse(profile['id'].toString()) ?? 0;
        studentName = profile['name']?.toString() ?? 'Student';
        registrationNo = profile['registration_no']?.toString() ?? 'N/A';
        className = profile['class_name']?.toString() ?? 'N/A';
        classId = int.tryParse(profile['class_id'].toString()) ?? 0;
        levelId = int.tryParse(profile['level_id'].toString()) ?? 0;
        pictureUrl = profile['picture_url']?.toString() ?? '';
        userRole = profile['role']?.toString() ?? 'student';
        schoolName = settings['school_name']?.toString() ?? '';
        academicYear = int.tryParse(settings['year'].toString()) ?? 0;
        academicTerm = int.tryParse(settings['term'].toString()) ?? 0;
        isLoading = false;
      });
    } catch (e) {
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
                    backgroundImage: _getStudentImage(),
                    child: _getStudentImage() == null
                        ? Text(
                            _getInitials(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.paymentTxtColor1,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

                  _buildSectionHeader('Class Information'),
                  _buildInfoRow('Class', className),
                  const Divider(),
                  _buildInfoRow('Class ID', classId.toString()),
                  const Divider(),
                  _buildInfoRow('Level ID', levelId.toString()),
                  const Divider(),

                  _buildSectionHeader('Student Information'),
                  _buildInfoRow('Student ID', studentId.toString()),
                  const Divider(),
                  _buildInfoRow('Registration No', registrationNo),
                  const Divider(),
                  _buildInfoRow('Role', userRole),
                  const Divider(),
                  const SizedBox(height: 20.0),

                  // Logout Button
                  ElevatedButton(
                    onPressed: () {
                      widget.logout(); // Perform logout action
                      Navigator.pop(context);
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
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getStudentImage() {
    try {
      if (pictureUrl.isNotEmpty) {
        return NetworkImage(pictureUrl);
      }
    } catch (e) {
      // Error loading image - will use default
    }
    return null;
  }

  String _getInitials() {
    if (studentName.isEmpty) return 'S';
    final names = studentName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  Widget _buildIconColumn(String svgPath) {
    return SvgPicture.asset(svgPath);
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
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
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
