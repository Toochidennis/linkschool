import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/auth/model/user.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(
      String username, String password, String schoolCode) async {
    try {
      final response = await _authService.login(username, password, schoolCode);
      if (response['status'] == 'success') {
        // Save the entire API response to Hive
        final userBox = Hive.box('userData');
        await userBox.put('userData', response);

        // Extract and save the user profile
        if (response.containsKey('profile')) {
          _user = User.fromJson(response['profile']);
          _isLoggedIn = true;

          await userBox.put('accessLevel', _user!.accessLevel);
          await userBox.put('isLoggedIn', true);

          // Store the user role and login state in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('role', _user!.accessLevel);
          await prefs.setBool('isLoggedIn', true);
        }

        notifyListeners();
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> logout() async {
    final userBox = Hive.box('userData');
    await userBox.clear();

    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final userBox = Hive.box('userData');
    final isLoggedIn = userBox.get('isLoggedIn', defaultValue: false);
    final userData = userBox.get('userData');
    final accessLevel = userBox.get('accessLevel');

    print('Hive - Is Logged In: $isLoggedIn');
    print('Hive - User Data: $userData');
    print('Hive - Access Level: $accessLevel');

    if (isLoggedIn && userData != null) {
      _user = User.fromJson(userData['profile']);
      _isLoggedIn = true;
      notifyListeners();
    }
  }
}

// class AuthProvider extends ChangeNotifier {
//   final AuthService _authService = AuthService();
//   User? _user;
//   bool _isLoading = false;
//   String? _error;

//   User? get user => _user;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> login(String username, String password, String pin) async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();

//       final response = await _authService.login(username, password, pin);
//       final profile = response['profile'];
      
//       _user = User.fromJson(profile);
      
//       // Handle different user roles
//       switch (_user?.accessLevel) {
//         case '2': // Admin
//           await _handleAdminLogin(response);
//           break;
//         case '3': // Staff
//         case '1': // Teacher
//           await _handleStaffLogin(response);
//           break;
//         case '-1': // Student
//           await _handleStudentLogin(response);
//           break;
//         default:
//           throw Exception('Unknown user role');
//       }

//     } catch (e) {
//       _error = e.toString();
//       _user = null;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _handleAdminLogin(Map<String, dynamic> data) async {
//     // Handle admin specific data storage
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('who', 'admin');
//     // Store other admin specific data
//   }

//   Future<void> _handleStaffLogin(Map<String, dynamic> data) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('who', 'staff');
//     // Store other staff specific data
//   }

//   Future<void> _handleStudentLogin(Map<String, dynamic> data) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('who', 'student');
//     // Store other student specific data
//   }

//   Future<void> logout() async {
//     await _authService.logout();
//     _user = null;
//     notifyListeners();
//   }
// }