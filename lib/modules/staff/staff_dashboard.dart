import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/flat_bottom_navigation.dart';
import 'package:linkschool/modules/staff/e_learning/staff_elearning_home_screen.dart';
import 'package:linkschool/modules/staff/home/staff_home_screen.dart';
import 'package:linkschool/modules/staff/result/staff_result_screen.dart';
import 'package:linkschool/modules/staff/staff_logout.dart';

class StaffDashboard extends StatefulWidget {
  final Function(bool) onSwitch;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onLogout;

  const StaffDashboard({
    super.key,
    required this.onSwitch,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  _StaffDashboardState createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  Widget _buildBodyItem(int index) {
    switch (index) {
      case 0:
        return const StaffHomeScreen();
      case 1:
        return StaffResultScreen();

      case 2:
        return const StaffElearningScreen();
      case 3:
        return StaffProfileScreen(
          logout: widget.onLogout,
        );
      default:
        return Container();
    }
  }


  @override
  void didUpdateWidget(StaffDashboard oldWidget) {
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
      key: const ValueKey('staff_dashboard'),
      body: _buildBodyItem(_selectedIndex),
      bottomNavigationBar: FlatBottomNavigation(
        items: [
          NavigationItem(
            iconPath: 'assets/icons/home.svg',
            activeIconPath: 'assets/icons/fill_home.svg',
            label: 'Home',
            iconWidth: 20.0,
            iconHeight: 20.0,
          ),
          //iconPath: 'assets/icons/result.svg',
          NavigationItem(
            iconPath: 'assets/icons/two_pager.svg',
            activeIconPath: 'assets/icons/two_pager_fill.svg',
            label: 'Result',
            iconWidth: 10.0,
            iconHeight: 20.0,
          ),
          NavigationItem(
            iconPath: 'assets/icons/portal.svg',
            label: 'Explore',
            flipIcon: true,
              iconWidth: 24.0,
        iconHeight: 25.0,
            color: const Color(0xFF1E3A8A),
          ),
          // iconPath: 'assets/icons/e-learning.svg',
          NavigationItem(
            iconPath: 'assets/icons/globe_book.svg',
            activeIconPath: 'assets/icons/globe_book.svg',
            label: 'E-learning',
            
          ),
          // profile.svg
          NavigationItem(
            iconPath: 'assets/icons/profile.svg',
            activeIconPath: 'assets/icons/person_fill.svg',
            label: 'Profile',
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
