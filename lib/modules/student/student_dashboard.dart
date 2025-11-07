// import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/bottom_navigation_bar.dart';
import 'package:linkschool/modules/common/bottom_nav_item.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/student/elearning/student_elearning_home_screen.dart';
import 'package:linkschool/modules/student/home/student_home_screen.dart';
import 'package:linkschool/modules/student/payment/student_payment_home_screen.dart';
import 'package:linkschool/modules/student/result/student_result_screen.dart';

class StudentDashboard extends StatefulWidget {
  final Function(bool) onSwitch;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onLogout;

  const StudentDashboard({
    super.key,
    required this.onSwitch,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late int _selectedIndex;
  int? studentId = 0;
  String studentName = 'Student'; // Default fallback name
  int? creatorId;
  String? creatorName;
  int? academicTerm;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _selectedIndex = widget.selectedIndex;
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');

      if (storedUserData == null) {
        throw Exception('No user data found in Hive');
      }

      final dataMap = storedUserData is String
          ? json.decode(storedUserData)
          : Map<String, dynamic>.from(storedUserData);

      // 🔍 handle all possible nesting patterns safely
      final response = dataMap['response'] ?? dataMap;
      final data = response['data'] ?? {};
      final profile = data['profile'] ?? {};
      final settings = data['settings'] ?? {};

      setState(() {
        studentId = int.tryParse(profile['id']?.toString() ?? '0');
        creatorName = profile['name']?.toString() ?? 'Student';
        userRole = profile['role']?.toString() ?? 'student';
        academicTerm = int.tryParse(settings['term']?.toString() ?? '0');
      });

      print("✅ Student ID: $studentId");
      print("✅ Student Name: $creatorName");
      print("✅ Term: $academicTerm");
      print("✅ Role: $userRole");
    } catch (e, stack) {
      debugPrint('❌ Error loading user data: $e');
      debugPrint(stack.toString());
      if (mounted) {
        CustomToaster.toastError(context, 'Error', 'Failed to load user data');
      }
    }
  }

  Widget _buildBodyItem(int index) {
    switch (index) {
      case 0:
        return StudentHomeScreen(logout: widget.onLogout);
      case 1:
        return StudentResultScreen(
          studentName: creatorName ?? '',
          className: '',
        );
      case 2:
        return StudentElearningScreen();
      case 3:
        return StudentPaymentHomeScreen(logout: widget.onLogout);
      default:
        return Container();
    }
  }

  @override
  void didUpdateWidget(StudentDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = widget.selectedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarItems = [
      createBottomNavIcon(
        imagePath: 'assets/icons/home.svg',
        text: 'Home',
        width: 20.0,
        height: 20.0,
      ),
      createBottomNavIcon(
        imagePath: 'assets/icons/result.svg',
        text: 'Results',
        width: 20.0,
        height: 20.0,
      ),
      createBottomNavIcon(
        imagePath: 'assets/icons/e-learning.svg',
        text: 'E- \n Learning',
        width: 20.0,
        height: 18.0,
      ),
      createBottomNavIcon(
        imagePath: 'assets/icons/payment.svg',
        text: 'Payment',
        width: 20.0,
        height: 20.0,
      ),
    ];

    return Scaffold(
      key: const ValueKey('student_dashboard'),
      body: Stack(
        children: [
          _buildBodyItem(_selectedIndex),
          Positioned(
            top: 16.0,
            right: 16.0, // Place the FAB in the upper right corner
            child: FloatingActionButton(
              onPressed: () {
                print("FAB pressed");
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        actionButtonImagePath: 'assets/icons/explore.svg',
        appBarItems: appBarItems,
        bodyItems: List.generate(4, (index) => _buildBodyItem(index)),
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onTabSelected(index);
        },
        onSwitch: widget.onSwitch,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
