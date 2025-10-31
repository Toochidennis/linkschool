import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkschool/modules/explore/home/explore_dashboard.dart';
import 'package:linkschool/modules/auth/ui/login_screen.dart';
import 'package:linkschool/modules/student/student_dashboard.dart';
import 'package:linkschool/modules/staff/staff_dashboard.dart';
import 'package:linkschool/modules/admin/home/portal_dashboard.dart';
import 'package:linkschool/routes/select_school.dart';

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
  bool _showSchoolSelection = false;
  bool _isInitialized = false;
  String? _selectedSchoolCode; // ✅ Add this

  @override
  void initState() {
    super.initState();
    _flipController = FlipCardController();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();
    await _checkLoginStatus();

    setState(() {
      _isInitialized = true;
    });

    if (_isLoggedIn && _flipController.state?.isFront == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _flipController.toggleCard();
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _userRole = authProvider.user?.role ?? '';
      _isLoggedIn = authProvider.isLoggedIn;
      _showLogin = false;
      _showSchoolSelection = false;
    });

    print('User Role: $_userRole');
    print('Is Logged In: $_isLoggedIn');
  }

  void _handleSwitchFromExplore(bool value) {
    if (_isLoggedIn) {
      if (_flipController.state?.isFront == true) {
        _flipController.toggleCard();
      }
    } else {
      setState(() {
        _showSchoolSelection = true;
        _showLogin = false;
      });

      if (_flipController.state?.isFront == true) {
        _flipController.toggleCard();
      }
    }
  }

  void _handleSwitchFromDashboard(bool value) {
    if (_flipController.state?.isFront == false) {
      _flipController.toggleCard();
    }
  }

  /// ✅ This is now updated to receive a school code
  void _navigateToLogin(String selectedSchoolCode) {
    setState(() {
      _selectedSchoolCode = selectedSchoolCode;
      _showLogin = true;
      _showSchoolSelection = false;
    });
  }

  void _updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    setState(() {
      _isLoggedIn = false;
      _userRole = '';
      _showLogin = false;
      _showSchoolSelection = false;
    });

    if (_flipController.state?.isFront == false) {
      _flipController.toggleCard();
    }
  }

  Widget _getFrontWidget() {
    return ExploreDashboard(
      onSwitch: _handleSwitchFromExplore,
      selectedIndex: _selectedIndex,
      onTabSelected: _updateSelectedIndex,
    );
  }

  Widget _getBackWidget() {
    if (_showSchoolSelection) {
      return SelectSchool(
        onSchoolSelected: (String selectedSchoolCode) {
          _navigateToLogin(selectedSchoolCode); // ✅ Pass selected school code
        },
      );
    }

    if (_showLogin) {
      return LoginScreen(
        schoolCode: _selectedSchoolCode ?? '', // ✅ Receive here
        onLoginSuccess: () async {
          await _checkLoginStatus();
          setState(() {});
        },
      );
    }

    if (_isLoggedIn) {
      switch (_userRole) {
        case 'staff':
          return StaffDashboard(
            onSwitch: _handleSwitchFromDashboard,
            selectedIndex: _selectedIndex,
            onTabSelected: _updateSelectedIndex,
            onLogout: _handleLogout,
          );
        case 'admin':
          return PortalDashboard(
            onSwitch: _handleSwitchFromDashboard,
            selectedIndex: _selectedIndex,
            onTabSelected: _updateSelectedIndex,
            onLogout: _handleLogout,
          );
        case 'student':
          return StudentDashboard(
            onSwitch: _handleSwitchFromDashboard,
            selectedIndex: _selectedIndex,
            onTabSelected: _updateSelectedIndex,
            onLogout: _handleLogout,
          );
        default:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Unknown user role: $_userRole'),
                ElevatedButton(
                  onPressed: _handleLogout,
                  child: Text('Logout'),
                ),
              ],
            ),
          );
      }
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: FlipCard(
        controller: _flipController,
        flipOnTouch: false,
        front: _getFrontWidget(),
        back: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _getBackWidget(),
        ),
      ),
    );
  }
}
