import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardSwitcher extends StatefulWidget {
  const DashboardSwitcher({super.key});

  @override
  _DashboardSwitcherState createState() => _DashboardSwitcherState();
}

class _DashboardSwitcherState extends State<DashboardSwitcher> {
  String _userRole = '';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('role') ?? '';
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Container(); // Return an empty container or any other desired widget
    }

    return Container(); // Return an empty container or any other desired widget
  }
}
