import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkschool/modules/explore/home/explore_dashboard.dart';
import 'package:linkschool/modules/auth/login_screen.dart';
import 'package:linkschool/modules/student_portal/student_dashboard.dart';
import 'package:linkschool/modules/staff_portal/staff_dashboard.dart';
import 'package:linkschool/modules/admin_portal/home/portal_dashboard.dart';

class AppNavigationFlow extends StatefulWidget {
  const AppNavigationFlow({super.key});

  @override
  _AppNavigationFlowState createState() => _AppNavigationFlowState();
}

class _AppNavigationFlowState extends State<AppNavigationFlow> {
  bool _isLoggedIn = false;
  String _userRole = '';
  int _selectedIndex = 0;
  late FlipCardController _flipController;
  bool _showLogin = false;

  @override
  void initState() {
    super.initState();
    _flipController = FlipCardController();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role') ?? '';
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _showLogin = false;
    });
  }

  void _handleSwitch(bool value) {
    if (!_isLoggedIn) {
      setState(() {
        _showLogin = true;
      });
    }
    _flipController.toggleCard();
  }

  void _updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _isLoggedIn = false;
      _userRole = '';
      _showLogin = false;
    });
    _flipController.toggleCard();
  }

  Widget _getBackWidget() {
    if (_showLogin) {
      return LoginScreen(
        onLoginSuccess: () async {
          await _checkLoginStatus();
          setState(() {});
        },
      );
    }

    if (_isLoggedIn) {
      switch (_userRole) {
        case 'student':
          return StudentDashboard(
            onSwitch: _handleSwitch,
            selectedIndex: _selectedIndex,
            onTabSelected: _updateSelectedIndex,
            onLogout: _handleLogout,
          );
        case 'staff':
          return StaffDashboard(
            onSwitch: _handleSwitch,
            selectedIndex: _selectedIndex,
            onTabSelected: _updateSelectedIndex,
            onLogout: _handleLogout,
          );
        case 'admin':
          return PortalDashboard(
            onSwitch: _handleSwitch,
            selectedIndex: _selectedIndex,
            onTabSelected: _updateSelectedIndex,
            onLogout: _handleLogout,
          );
        default:
          return Container();
      }
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlipCard(
        controller: _flipController,
        flipOnTouch: false,
        front: ExploreDashboard(
          onSwitch: _handleSwitch,
          selectedIndex: _selectedIndex,
          onTabSelected: _updateSelectedIndex,
        ),
        back: AnimatedSwitcher(
          duration:  const Duration(milliseconds: 300),
          child: _getBackWidget(),
        ),
      ),
    );
  }
}