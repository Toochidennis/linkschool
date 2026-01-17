// import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/flat_bottom_navigation.dart';
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
    } catch (e, stack) {
      debugPrint('Error loading user data: $e');
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


    return Scaffold(
      key: const ValueKey('student_dashboard'),
      body: _buildBodyItem(_selectedIndex),
    
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: FlatBottomNavigation(
        items: [
         NavigationItem(
            iconPath: 'assets/icons/home.svg',
            activeIconPath: 'assets/icons/fill_home.svg',
            label: 'Home',
            iconWidth: 20.0,
            iconHeight: 20.0,
          ),
          NavigationItem(
            iconPath: 'assets/icons/two_pager.svg',
            activeIconPath: 'assets/icons/two_pager_fill.svg',
            label: 'Result',
            
          ),
          NavigationItem(
            iconPath: 'assets/icons/portal.svg',
            label: 'Explore',
            color: const Color(0xFF1E3A8A),
          ),
           NavigationItem(
            iconPath: 'assets/icons/globe_book.svg',
            activeIconPath: 'assets/icons/globe_book.svg',
            label: 'E-learning',
            
          ),
          NavigationItem(
            iconPath: 'assets/icons/assured_workload.svg',
            activeIconPath: 'assets/icons/assured_workload_fill.svg',
            label: 'Payments',
            iconWidth: 10.0,
            iconHeight: 20.0,
          ),
        ],
        selectedIndex: _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex,
        onTabSelected: (index) {
          if (index == 2) {
            widget.onSwitch(true);
            return;
          }
          final adjustedIndex = index > 2 ? index - 1 : index;
          setState(() {
            _selectedIndex = adjustedIndex;
          });
          widget.onTabSelected(adjustedIndex);
        },
      ),
    );
  }
}
