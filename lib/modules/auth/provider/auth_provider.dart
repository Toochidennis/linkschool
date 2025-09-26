import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/auth/model/user.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  User? _user;
  String? _token;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _settings;

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get settings => _settings;

  Future<void> login(String username, String password, String schoolCode) async {
    try {
      final response = await _authService.login(username, password, schoolCode);
      if (response.success && response.rawData != null) {
        // Save the entire API response to Hive
        final userBox = Hive.box('userData');
        await userBox.put('userData', response.rawData);
        await userBox.put('loginResponse', response.rawData); // Also save as loginResponse for compatibility

        // Extract user data
        final userData = response.rawData!['data'];
        _user = User.fromJson(userData);
        _token = response.rawData!['token'];
        _isLoggedIn = true;

        // Save database identifier
        final db = response.rawData!['_db'];
        if (db != null) {
          await userBox.put('_db', db);
        }

        // Save settings data
        if (userData.containsKey('settings')) {
          _settings = Map<String, dynamic>.from(userData['settings']);
          await userBox.put('settings', _settings);
        }

        // CRITICAL: Save login state and user details with explicit flags
        await userBox.put('isLoggedIn', true);
        await userBox.put('role', _user!.role);
        await userBox.put('token', _token);
        await userBox.put('sessionValid', true); // Additional flag for session validation
        await userBox.put('lastLoginTime', DateTime.now().millisecondsSinceEpoch);

        // Set the token on ApiService for future requests
        final apiService = locator<ApiService>();
        apiService.setAuthToken(_token!);

        // Save role-specific data
        if (_user!.role == 'admin') {
          // Save admin-specific data
          if (userData.containsKey('levels')) {
            await userBox.put('levels', userData['levels']);
          }
          if (userData.containsKey('classes')) {
            await userBox.put('classes', userData['classes']);
          }
          if (userData.containsKey('courses')) {
            await userBox.put('courses', userData['courses']);
          }
        } else if (_user!.role == 'staff') {
          // Save staff-specific data
          if (userData.containsKey('form_classes')) {
            await userBox.put('form_classes', userData['form_classes']);
          }
          if (userData.containsKey('courses')) {
            await userBox.put('staff_courses', userData['courses']);
          }
        } else if (_user!.role == 'student') {
          // Save student-specific data
          final profile = userData['profile'] ?? {};
          await userBox.put('student_profile', profile);
          
          // Store student-specific parameters for API calls
          await userBox.put('student_id', profile['id']?.toString() ?? profile['staff_id']?.toString());
          await userBox.put('class_id', profile['class_id']?.toString());
          await userBox.put('level_id', profile['level_id']?.toString());
          await userBox.put('registration_no', profile['registration_no']);
          
          // Store current year from settings for API calls
          if (_settings != null && _settings!.containsKey('year')) {
            await userBox.put('current_year', _settings!['year'].toString());
          }
        }

        // Store in SharedPreferences for additional persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', _user!.role);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', _token!);
        await prefs.setBool('sessionValid', true);

        print('Login successful - User role: ${_user!.role}');
        notifyListeners();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Clear Hive data
      final userBox = Hive.box('userData');
      await userBox.clear();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear ApiService token
      final apiService = locator<ApiService>();
      apiService.setAuthToken('');

      // Reset state
      _user = null;
      _token = null;
      _isLoggedIn = false;
      _settings = null;

      print('Logout successful');
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      // Even if there's an error, reset the state
      _user = null;
      _token = null;
      _isLoggedIn = false;
      _settings = null;
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      print('Checking login status...');
      
      final userBox = Hive.box('userData');
      final prefs = await SharedPreferences.getInstance();
      
      // Check multiple sources for login status
      final isLoggedInHive = userBox.get('isLoggedIn', defaultValue: false);
      final isLoggedInPrefs = prefs.getBool('isLoggedIn') ?? false;
      final sessionValid = userBox.get('sessionValid', defaultValue: false);
      final userData = userBox.get('userData');
      final token = userBox.get('token');
      
      print('Hive isLoggedIn: $isLoggedInHive');
      print('Prefs isLoggedIn: $isLoggedInPrefs');
      print('Session valid: $sessionValid');
      print('Has userData: ${userData != null}');
      print('Has token: ${token != null}');

      // Validate session integrity
      if ((isLoggedInHive || isLoggedInPrefs) && 
          sessionValid && 
          userData != null && 
          token != null) {
        
        // Safely convert userData to Map<String, dynamic>
        Map<String, dynamic> userDataMap;
        if (userData is Map<String, dynamic>) {
          userDataMap = userData;
        } else if (userData is Map) {
          userDataMap = Map<String, dynamic>.from(userData);
        } else {
          print('Invalid userData format, clearing login status');
          await _clearCorruptedSession();
          return;
        }

        // Extract user data safely
        final userDataContent = userDataMap['data'];
        Map<String, dynamic> userDataContentMap;
        if (userDataContent is Map<String, dynamic>) {
          userDataContentMap = userDataContent;
        } else if (userDataContent is Map) {
          userDataContentMap = Map<String, dynamic>.from(userDataContent);
        } else {
          print('Invalid user data content format, clearing login status');
          await _clearCorruptedSession();
          return;
        }

        // Restore user state
        try {
          _user = User.fromJson(userDataContentMap);
          _token = token.toString();
          _isLoggedIn = true;

          // Set the token on ApiService for future requests
          final apiService = locator<ApiService>();
          apiService.setAuthToken(_token!);

          // Handle settings safely
          final settings = userBox.get('settings');
          if (settings != null) {
            if (settings is Map<String, dynamic>) {
              _settings = settings;
            } else if (settings is Map) {
              _settings = Map<String, dynamic>.from(settings);
            }
          }

          print('Session restored successfully - User: ${_user!.name}, Role: ${_user!.role}');
          notifyListeners();
          
        } catch (e) {
          print('Error restoring user from session data: $e');
          await _clearCorruptedSession();
        }
        
      } else {
        print('No valid session found or session expired');
        _isLoggedIn = false;
        _user = null;
        _token = null;
        _settings = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error checking login status: $e');
      await _clearCorruptedSession();
    }
  }

  Future<void> _clearCorruptedSession() async {
    try {
      final userBox = Hive.box('userData');
      await userBox.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _user = null;
      _token = null;
      _isLoggedIn = false;
      _settings = null;

      print('Corrupted session cleared');
      notifyListeners();
    } catch (e) {
      print('Error clearing corrupted session: $e');
    }
  }

  // Get settings data
  Map<String, dynamic> getSettings() {
    final userBox = Hive.box('userData');
    final settings = userBox.get('settings');
    if (settings != null) {
      if (settings is Map<String, dynamic>) {
        return settings;
      } else if (settings is Map) {
        return Map<String, dynamic>.from(settings);
      }
    }
    return {};
  }

  // Admin-specific getter methods
  List<Map<String, dynamic>> getLevels() {
    final userBox = Hive.box('userData');
    final levels = userBox.get('levels');
    if (levels != null && levels is List) {
      return levels.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> getClasses() {
    final userBox = Hive.box('userData');
    final classes = userBox.get('classes');
    if (classes != null && classes is List) {
      return classes.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> getCourses() {
    final userBox = Hive.box('userData');
    final courses = userBox.get('courses');
    if (courses != null && courses is List) {
      return courses.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  // Staff-specific getter methods
  List<Map<String, dynamic>> getFormClasses() {
    final userBox = Hive.box('userData');
    final formClasses = userBox.get('form_classes');
    if (formClasses != null && formClasses is List) {
      return formClasses.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> getStaffCourses() {
    final userBox = Hive.box('userData');
    final staffCourses = userBox.get('staff_courses');
    if (staffCourses != null && staffCourses is List) {
      return staffCourses.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  // Student-specific getter methods
  Map<String, dynamic> getStudentProfile() {
    final userBox = Hive.box('userData');
    final studentProfile = userBox.get('student_profile');
    if (studentProfile != null) {
      if (studentProfile is Map<String, dynamic>) {
        return studentProfile;
      } else if (studentProfile is Map) {
        return Map<String, dynamic>.from(studentProfile);
      }
    }
    return {};
  }

  String? getStudentId() {
    final userBox = Hive.box('userData');
    return userBox.get('student_id');
  }

  String? getClassId() {
    final userBox = Hive.box('userData');
    return userBox.get('class_id');
  }

  String? getLevelId() {
    final userBox = Hive.box('userData');
    return userBox.get('level_id');
  }

  String? getCurrentYear() {
    final userBox = Hive.box('userData');
    return userBox.get('current_year');
  }

  String? getRegistrationNo() {
    final userBox = Hive.box('userData');
    return userBox.get('registration_no');
  }

  // Helper method to get user profile data
  Map<String, dynamic> getUserProfile() {
    final userBox = Hive.box('userData');
    final userData = userBox.get('userData');
    if (userData != null) {
      Map<String, dynamic> userDataMap;
      if (userData is Map<String, dynamic>) {
        userDataMap = userData;
      } else if (userData is Map) {
        userDataMap = Map<String, dynamic>.from(userData);
      } else {
        return {};
      }

      if (userDataMap['data'] != null) {
        final profileData = userDataMap['data']['profile'];
        if (profileData is Map<String, dynamic>) {
          return profileData;
        } else if (profileData is Map) {
          return Map<String, dynamic>.from(profileData);
        }
      }
    }
    return {};
  }

  // Helper method to check user role
  String getUserRole() {
    final userBox = Hive.box('userData');
    return userBox.get('role', defaultValue: '');
  }

  // Method to refresh session (call this periodically if needed)
  Future<void> refreshSession() async {
    if (_isLoggedIn && _token != null) {
      final userBox = Hive.box('userData');
      await userBox.put('lastLoginTime', DateTime.now().millisecondsSinceEpoch);
      print('Session refreshed');
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
//   String? _token;
//   bool _isLoggedIn = false;
//   Map<String, dynamic>? _settings;

//   User? get user => _user;
//   String? get token => _token;
//   bool get isLoggedIn => _isLoggedIn;
//   Map<String, dynamic>? get settings => _settings;

//   Future<void> login(String username, String password, String schoolCode) async {
//     try {
//       final response = await _authService.login(username, password, schoolCode);
//       if (response.success && response.rawData != null) {
//         // Save the entire API response to Hive
//         final userBox = Hive.box('userData');
//         await userBox.put('userData', response.rawData);
//         await userBox.put('loginResponse', response.rawData); // Also save as loginResponse for compatibility

//         // Extract user data
//         final userData = response.rawData!['data'];
//         _user = User.fromJson(userData);
//         _token = response.rawData!['token'];
//         _isLoggedIn = true;

//         // Save database identifier
//         final db = response.rawData!['_db'];
//         if (db != null) {
//           await userBox.put('_db', db);
//         }

//         // Save settings data
//         if (userData.containsKey('settings')) {
//           _settings = Map<String, dynamic>.from(userData['settings']);
//           await userBox.put('settings', _settings);
//         }

//         // Save login state and user details
//         await userBox.put('isLoggedIn', true);
//         await userBox.put('role', _user!.role);
//         await userBox.put('token', _token);

//         // Save role-specific data
//         if (_user!.role == 'admin') {
//           // Save admin-specific data
//           if (userData.containsKey('levels')) {
//             await userBox.put('levels', userData['levels']);
//           }
//           if (userData.containsKey('classes')) {
//             await userBox.put('classes', userData['classes']);
//           }
//           if (userData.containsKey('courses')) {
//             await userBox.put('courses', userData['courses']);
//           }
//         } else if (_user!.role == 'staff') {
//           // Save staff-specific data
//           if (userData.containsKey('form_classes')) {
//             await userBox.put('form_classes', userData['form_classes']);
//           }
//           if (userData.containsKey('courses')) {
//             await userBox.put('staff_courses', userData['courses']);
//           }
//         } else if (_user!.role == 'student') {
//           // Save student-specific data
//           final profile = userData['profile'] ?? {};
//           await userBox.put('student_profile', profile);
          
//           // Store student-specific parameters for API calls
//           await userBox.put('student_id', profile['id']?.toString() ?? profile['staff_id']?.toString());
//           await userBox.put('class_id', profile['class_id']?.toString());
//           await userBox.put('level_id', profile['level_id']?.toString());
//           await userBox.put('registration_no', profile['registration_no']);
          
//           // Store current year from settings for API calls
//           if (_settings != null && _settings!.containsKey('year')) {
//             await userBox.put('current_year', _settings!['year'].toString());
//           }
//         }

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
//     _settings = null;
//     notifyListeners();
//   }

//   Future<void> checkLoginStatus() async {
//     final userBox = Hive.box('userData');
//     final isLoggedIn = userBox.get('isLoggedIn', defaultValue: false);
//     final userData = userBox.get('userData');
//     final settings = userBox.get('settings');

//     if (isLoggedIn && userData != null) {
//       final userDataMap = userData['data'];
//       _user = User.fromJson(userDataMap);
//       _token = userData['token'];
//       _isLoggedIn = true;
//       if (settings != null) {
//         _settings = Map<String, dynamic>.from(settings);
//       }
//       notifyListeners();
//     }
//   }

//   // Get settings data
//   Map<String, dynamic> getSettings() {
//     final userBox = Hive.box('userData');
//     final settings = userBox.get('settings');
//     if (settings != null) {
//       return Map<String, dynamic>.from(settings);
//     }
//     return {};
//   }

//   // Admin-specific getter methods
//   List<Map<String, dynamic>> getLevels() {
//     final userBox = Hive.box('userData');
//     final levels = userBox.get('levels');
//     if (levels != null && levels is List) {
//       return List<Map<String, dynamic>>.from(levels);
//     }
//     return [];
//   }

//   List<Map<String, dynamic>> getClasses() {
//     final userBox = Hive.box('userData');
//     final classes = userBox.get('classes');
//     if (classes != null && classes is List) {
//       return List<Map<String, dynamic>>.from(classes);
//     }
//     return [];
//   }

//   List<Map<String, dynamic>> getCourses() {
//     final userBox = Hive.box('userData');
//     final courses = userBox.get('courses');
//     if (courses != null && courses is List) {
//       return List<Map<String, dynamic>>.from(courses);
//     }
//     return [];
//   }

//   // Staff-specific getter methods
//   List<Map<String, dynamic>> getFormClasses() {
//     final userBox = Hive.box('userData');
//     final formClasses = userBox.get('form_classes');
//     if (formClasses != null && formClasses is List) {
//       return List<Map<String, dynamic>>.from(formClasses);
//     }
//     return [];
//   }

//   List<Map<String, dynamic>> getStaffCourses() {
//     final userBox = Hive.box('userData');
//     final staffCourses = userBox.get('staff_courses');
//     if (staffCourses != null && staffCourses is List) {
//       return List<Map<String, dynamic>>.from(staffCourses);
//     }
//     return [];
//   }

//   // Student-specific getter methods
//   Map<String, dynamic> getStudentProfile() {
//     final userBox = Hive.box('userData');
//     final studentProfile = userBox.get('student_profile');
//     if (studentProfile != null) {
//       return Map<String, dynamic>.from(studentProfile);
//     }
//     return {};
//   }

//   String? getStudentId() {
//     final userBox = Hive.box('userData');
//     return userBox.get('student_id');
//   }

//   String? getClassId() {
//     final userBox = Hive.box('userData');
//     return userBox.get('class_id');
//   }

//   String? getLevelId() {
//     final userBox = Hive.box('userData');
//     return userBox.get('level_id');
//   }

//   String? getCurrentYear() {
//     final userBox = Hive.box('userData');
//     return userBox.get('current_year');
//   }

//   String? getRegistrationNo() {
//     final userBox = Hive.box('userData');
//     return userBox.get('registration_no');
//   }

//   // Helper method to get user profile data
//   Map<String, dynamic> getUserProfile() {
//     final userBox = Hive.box('userData');
//     final userData = userBox.get('userData');
//     if (userData != null && userData['data'] != null) {
//       return userData['data']['profile'] ?? {};
//     }
//     return {};
//   }

//   // Helper method to check user role
//   String getUserRole() {
//     final userBox = Hive.box('userData');
//     return userBox.get('role', defaultValue: '');
//   }
// }