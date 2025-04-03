import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/auth/model/user.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  User? _user;
  String? _token;
  bool _isLoggedIn = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(String username, String password, String schoolCode) async {
    try {
      final response = await _authService.login(username, password, schoolCode);

      if (response.success && response.rawData != null) {
        // Save the entire API response to Hive
        final userBox = Hive.box('userData');
        await userBox.put('userData', response.rawData);

        // Extract user data
        final userData = response.rawData!['data'];
        _user = User.fromJson(userData);
        _token = response.rawData!['token'];
        _isLoggedIn = true;

        // Save login state and user details
        await userBox.put('isLoggedIn', true);
        await userBox.put('role', _user!.role);
        await userBox.put('token', _token);

        // Store in SharedPreferences for cross-session persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', _user!.role);
        await prefs.setBool('isLoggedIn', true);

        notifyListeners();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    final userBox = Hive.box('userData');
    await userBox.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _user = null;
    _token = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final userBox = Hive.box('userData');
    final isLoggedIn = userBox.get('isLoggedIn', defaultValue: false);
    final userData = userBox.get('userData');

    if (isLoggedIn && userData != null) {
      final userDataMap = userData['data'];
      _user = User.fromJson(userDataMap);
      _token = userData['token'];
      _isLoggedIn = true;

      notifyListeners();
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/auth/model/user.dart';
// import 'package:linkschool/modules/auth/service/auth_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:shared_preferences/shared_preferences.dart';


// class AuthProvider with ChangeNotifier {
//   final AuthService _authService = locator<AuthService>();
//   User? _user;
//   bool _isLoggedIn = false;

//   User? get user => _user;
//   bool get isLoggedIn => _isLoggedIn;

//   Future<void> login(String username, String password, String schoolCode) async {
//     try {
//       final response = await _authService.login(username, password, schoolCode);

//       if (response.success) {
//         // Save the entire API response to Hive
//         final userBox = Hive.box('userData');
//         await userBox.put('userData', response.rawData);

//         // Extract and save the user profile
//         if (response.rawData != null && response.rawData!.containsKey('profile')) {
//           _user = User.fromJson(response.rawData!['profile']);
//           _isLoggedIn = true;

//           await userBox.put('accessLevel', _user!.accessLevel);
//           await userBox.put('isLoggedIn', true);

//           // Store the user role and login state in SharedPreferences
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString('role', _user!.accessLevel);
//           await prefs.setBool('isLoggedIn', true);
//         }

//         notifyListeners();
//       } else {
//         throw Exception('Invalid credentials');
//       }
//     } catch (e) {
//       throw Exception('Failed to login: $e');
//     }
//   }

//   Future<void> logout() async {
//     final userBox = Hive.box('userData');
//     await userBox.clear();

//     _user = null;
//     _isLoggedIn = false;
//     notifyListeners();
//   }

//   Future<void> checkLoginStatus() async {
//     final userBox = Hive.box('userData');
//     final isLoggedIn = userBox.get('isLoggedIn', defaultValue: false);
//     final userData = userBox.get('userData');
//     final accessLevel = userBox.get('accessLevel');

//     print('Hive - Is Logged In: $isLoggedIn');
//     print('Hive - User Data: $userData');
//     print('Hive - Access Level: $accessLevel');

//     if (isLoggedIn && userData != null) {
//       _user = User.fromJson(userData['profile']);
//       _isLoggedIn = true;
//       notifyListeners();
//     }
//   }
// }