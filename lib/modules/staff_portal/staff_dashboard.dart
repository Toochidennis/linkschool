import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/bottom_navigation_bar.dart';
import 'package:linkschool/modules/common/bottom_nav_item.dart';
import 'package:linkschool/modules/staff_portal/home_screen/staff_home_screen.dart';

class StaffDashboard extends StatefulWidget {
  final Function(bool) onSwitch;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onLogout;

  const StaffDashboard({
    Key? key,
    required this.onSwitch,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  }) : super(key: key);

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
        return Container(
          color: Colors.orange,
          child: const Center(child: Text('Classes')),
        );
      case 2:
        return Container(
          color: Colors.green,
          child: const Center(child: Text('Assignments')),
        );
      case 3:
        return _buildProfileScreen();
      default:
        return Container();
    }
  }

  Widget _buildProfileScreen() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.blue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profile', style: TextStyle(fontSize: 24, color: Colors.white)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onLogout,
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
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
    final appBarItems = [
      createBottomNavIcon(
        imagePath: 'assets/icons/home.svg',
        text: 'Home',
        width: 20.0,
        height: 20.0,
      ),
      createBottomNavIcon(
        imagePath: 'assets/icons/class.svg',
        text: 'Classes',
        width: 20.0,
        height: 20.0,
      ),
      createBottomNavIcon(
        imagePath: 'assets/icons/assignment.svg',
        text: 'Assignments',
        width: 20.0,
        height: 20.0,
      ),
      createBottomNavIcon(
        imagePath: 'assets/icons/profile.svg',
        text: 'Profile',
        width: 20.0,
        height: 20.0,
      ),
    ];

    return Scaffold(
      key: const ValueKey('staff_dashboard'),
      body: _buildBodyItem(_selectedIndex),
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
        selectedIndex: widget.selectedIndex,
      ),
    );
  }
}