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

        // Save levels, classes and courses separately for easier access
        if (userData.containsKey('levels')) {
          await userBox.put('levels', userData['levels']);
        }
        
        if (userData.containsKey('classes')) {
          await userBox.put('classes', userData['classes']);
        }
        
        // New code: Save courses data separately for easier access
        if (userData.containsKey('courses')) {
          await userBox.put('courses', userData['courses']);
        }

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
  
  // New getter methods for easy access to stored data
  List<Map<String, dynamic>> getLevels() {
    final userBox = Hive.box('userData');
    final levels = userBox.get('levels');
    if (levels != null && levels is List) {
      return List<Map<String, dynamic>>.from(levels);
    }
    return [];
  }

  List<Map<String, dynamic>> getClasses() {
    final userBox = Hive.box('userData');
    final classes = userBox.get('classes');
    if (classes != null && classes is List) {
      return List<Map<String, dynamic>>.from(classes);
    }
    return [];
  }
  
  // New method to access courses data from Hive
  List<Map<String, dynamic>> getCourses() {
    final userBox = Hive.box('userData');
    final courses = userBox.get('courses');
    if (courses != null && courses is List) {
      return List<Map<String, dynamic>>.from(courses);
    }
    return [];
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
//   String? _token;
//   bool _isLoggedIn = false;

//   User? get user => _user;
//   String? get token => _token;
//   bool get isLoggedIn => _isLoggedIn;

//   Future<void> login(String username, String password, String schoolCode) async {
//     try {
//       final response = await _authService.login(username, password, schoolCode);

//       if (response.success && response.rawData != null) {
//         // Save the entire API response to Hive
//         final userBox = Hive.box('userData');
//         await userBox.put('userData', response.rawData);

//         // Extract user data
//         final userData = response.rawData!['data'];
//         _user = User.fromJson(userData);
//         _token = response.rawData!['token'];
//         _isLoggedIn = true;

//         // Save login state and user details
//         await userBox.put('isLoggedIn', true);
//         await userBox.put('role', _user!.role);
//         await userBox.put('token', _token);

//         // Store in SharedPreferences for cross-session persistence
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('role', _user!.role);
//         await prefs.setBool('isLoggedIn', true);

//         notifyListeners();
//       } else {
//         throw Exception(response.message);
//       }
//     } catch (e) {
//       throw Exception('Login failed: $e');
//     }
//   }

//   Future<void> logout() async {
//     final userBox = Hive.box('userData');
//     await userBox.clear();

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();

//     _user = null;
//     _token = null;
//     _isLoggedIn = false;
//     notifyListeners();
//   }

//   Future<void> checkLoginStatus() async {
//     final userBox = Hive.box('userData');
//     final isLoggedIn = userBox.get('isLoggedIn', defaultValue: false);
//     final userData = userBox.get('userData');

//     if (isLoggedIn && userData != null) {
//       final userDataMap = userData['data'];
//       _user = User.fromJson(userDataMap);
//       _token = userData['token'];
//       _isLoggedIn = true;

//       notifyListeners();
//     }
//   }
// }