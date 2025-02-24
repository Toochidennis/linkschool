// import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/bottom_navigation_bar.dart';
import 'package:linkschool/modules/common/bottom_nav_item.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  Widget _buildBodyItem(int index) {
    switch (index) {
      case 0:
        return const StudentHomeScreen();
      case 1:
        return const StudentResultScreen(studentName: 'Tochukwu Dennis', className: 'JSS 1',);
      case 2:
        return  StudentElearningScreen();
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
        text: 'E-Learning',
        width: 20.0,
        height: 20.0,
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
            right: 16.0,  // Place the FAB in the upper right corner
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