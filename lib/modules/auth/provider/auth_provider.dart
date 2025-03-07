import 'package:flutter/material.dart';
import 'package:linkschool/modules/auth/model/user.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String username, String password, String pin) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authService.login(username, password, pin);
      final profile = response['profile'];
      
      _user = User.fromJson(profile);
      
      // Handle different user roles
      switch (_user?.accessLevel) {
        case '2': // Admin
          await _handleAdminLogin(response);
          break;
        case '3': // Staff
        case '1': // Teacher
          await _handleStaffLogin(response);
          break;
        case '-1': // Student
          await _handleStudentLogin(response);
          break;
        default:
          throw Exception('Unknown user role');
      }

    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleAdminLogin(Map<String, dynamic> data) async {
    // Handle admin specific data storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('who', 'admin');
    // Store other admin specific data
  }

  Future<void> _handleStaffLogin(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('who', 'staff');
    // Store other staff specific data
  }

  Future<void> _handleStudentLogin(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('who', 'student');
    // Store other student specific data
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}