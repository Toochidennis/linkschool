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

    // If user is logged in, automatically show their dashboard
    if (_isLoggedIn && _flipController.state!.isFront) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _flipController.toggleCard();
        }
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
    // When switching from explore dashboard
    if (_isLoggedIn) {
      // User is logged in, flip to their dashboard
      if (_flipController.state!.isFront) {
        _flipController.toggleCard();
      }
    } else {
      // User not logged in, show school selection
      setState(() {
        _showSchoolSelection = true;
        _showLogin = false;
      });
      
      if (_flipController.state!.isFront) {
        _flipController.toggleCard();
      }
    }
  }

  void _handleSwitchFromDashboard(bool value) {
    // When switching from user dashboard back to explore
    if (!_flipController.state!.isFront) {
      _flipController.toggleCard();
    }
  }

  void _navigateToLogin() {
    setState(() {
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
    
    // Navigate back to explore dashboard
    if (!_flipController.state!.isFront) {
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
        onSchoolSelected: _navigateToLogin,
      );
    }

    if (_showLogin) {
      return LoginScreen(
        onLoginSuccess: () async {
          await _checkLoginStatus();
          // After successful login, navigate to user dashboard
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

    // Fallback - this shouldn't happen but just in case
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Something went wrong'),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showSchoolSelection = true;
                  _showLogin = false;
                });
              },
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while initializing
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
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

// import 'package:flutter/material.dart';
// import 'package:flip_card/flip_card.dart';
// import 'package:flip_card/flip_card_controller.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:linkschool/modules/explore/home/explore_dashboard.dart';
// import 'package:linkschool/modules/auth/ui/login_screen.dart';
// import 'package:linkschool/modules/student/student_dashboard.dart';
// import 'package:linkschool/modules/staff/staff_dashboard.dart';
// import 'package:linkschool/modules/admin/home/portal_dashboard.dart';

// class AppNavigationFlow extends StatefulWidget {
//   const AppNavigationFlow({super.key});

//   @override
//   _AppNavigationFlowState createState() => _AppNavigationFlowState();
// }

// class _AppNavigationFlowState extends State<AppNavigationFlow> {
//   bool _isLoggedIn = false;
//   String _userRole = '';
//   int _selectedIndex = 0;
//   late FlipCardController _flipController;
//   bool _showLogin = false;

//   @override
//   void initState() {
//     super.initState();
//     _flipController = FlipCardController();
//     _checkLoginStatus();
//     Provider.of<AuthProvider>(context, listen: false).checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
//     setState(() {
//       _userRole = authProvider.user?.role ?? '';
//       _isLoggedIn = authProvider.isLoggedIn;
//       _showLogin = false;
//     });

//     print('User Role: $_userRole');
//     print('Is Logged In: $_isLoggedIn');
//   }

//   void _handleSwitch(bool value) {
//     if (!_isLoggedIn) {
//       setState(() {
//         _showLogin = true;
//       });
//     }
//     _flipController.toggleCard();
//   }

//   void _updateSelectedIndex(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   Future<void> _handleLogout() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.logout();
    
//     setState(() {
//       _isLoggedIn = false;
//       _userRole = '';
//       _showLogin = false;
//     });
//     _flipController.toggleCard();
//   }

//   Widget _getBackWidget() {
//     if (_showLogin) {
//       return LoginScreen(
//         onLoginSuccess: () async {
//           await _checkLoginStatus();
//           setState(() {});
//         },
//       );
//     }

//     if (_isLoggedIn) {
//       switch (_userRole) {
//         case 'staff':
//           return StaffDashboard(
//             onSwitch: _handleSwitch,
//             selectedIndex: _selectedIndex,
//             onTabSelected: _updateSelectedIndex,
//             onLogout: _handleLogout,
//           );
//         case 'admin':
//           return PortalDashboard(
//             onSwitch: _handleSwitch,
//             selectedIndex: _selectedIndex,
//             onTabSelected: _updateSelectedIndex,
//             onLogout: _handleLogout,
//           );
//         case 'student':
//           return StudentDashboard(
//             onSwitch: _handleSwitch,
//             selectedIndex: _selectedIndex,
//             onTabSelected: _updateSelectedIndex,
//             onLogout: _handleLogout,
//           );
//         default:
//           return Center(
//             child: Text('Unknown user role: $_userRole'),
//           );
//       }
//     }

//     return Container(); 
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FlipCard(
//         controller: _flipController,
//         flipOnTouch: false,
//         front: ExploreDashboard(
//           onSwitch: _handleSwitch,
//           selectedIndex: _selectedIndex,
//           onTabSelected: _updateSelectedIndex,
//         ),
//         back: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 300),
//           child: _getBackWidget(),
//         ),
//       ),
//     );
//   }
// }