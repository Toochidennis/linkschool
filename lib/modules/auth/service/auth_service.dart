import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  Future<ApiResponse<Map<String, dynamic>>> login(
    String username, 
    String password, 
    String schoolCode
  ) async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final apiKey = dotenv.env['API_KEY'] ?? '';
    
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/portal/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'school_code': int.parse(schoolCode),
        }),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        final responseData = responseBody['response'];
        
        // ========== PRINT DATA STRUCTURE ==========
        print('\n' + '='*60);
        print('🔐 LOGIN RESPONSE DATA STRUCTURE');
        print('='*60);
        
        // Print the entire response structure
        print('\n📦 Full Response:');
        print(JsonEncoder.withIndent('  ').convert(responseBody));
        
        print('\n📊 Response Data Keys:');
        if (responseData is Map) {
          responseData.forEach((key, value) {
            print('  - $key: ${value.runtimeType}');
          });
        }
        
        // Print token
        if (responseData['token'] != null) {
          print('\n🔑 Token: ${responseData['token'].toString().substring(0, 20)}...');
        }
        
        // Print database identifier
        if (responseData['_db'] != null) {
          print('💾 Database: ${responseData['_db']}');
        }
        
        // Print user data structure
        if (responseData['data'] != null) {
          final userData = responseData['data'];
          print('\n👤 User Data Structure:');
          if (userData is Map) {
            userData.forEach((key, value) {
              if (value is Map || value is List) {
                print('  - $key: ${value.runtimeType} (${_getSize(value)} items)');
              } else {
                print('  - $key: $value');
              }
            });
          }
          
          // Print role
          print('\n🎭 User Role: ${userData['role']}');
          
          // Print settings if available
          if (userData['settings'] != null) {
            print('\n⚙️ Settings:');
            print(JsonEncoder.withIndent('  ').convert(userData['settings']));
          }
          
          // Print role-specific data
          if (userData['role'] == 'admin') {
            print('\n👨‍💼 ADMIN DATA:');
            if (userData['levels'] != null) {
              print('  - Levels: ${_getSize(userData['levels'])} items');
            }
            if (userData['classes'] != null) {
              print('  - Classes: ${_getSize(userData['classes'])} items');
            }
            if (userData['courses'] != null) {
              print('  - Courses: ${_getSize(userData['courses'])} items');
            }
          } else if (userData['role'] == 'staff') {
            print('\n👨‍🏫 STAFF DATA:');
            if (userData['form_classes'] != null) {
              print('  - Form Classes: ${_getSize(userData['form_classes'])} items');
            }
            if (userData['courses'] != null) {
              print('  - Courses: ${_getSize(userData['courses'])} items');
            }
          } else if (userData['role'] == 'student') {
            print('\n🎓 STUDENT DATA:');
            if (userData['profile'] != null) {
              print('  - Profile:');
              print(JsonEncoder.withIndent('    ').convert(userData['profile']));
            }
          }
        }
        
        print('\n' + '='*60 + '\n');
        // ========== END PRINT DATA STRUCTURE ==========

        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseBody['message'],
          rawData: responseData,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseBody['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      print('❌ Login Error: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // Helper method to get size of collections
  int _getSize(dynamic value) {
    if (value is List) return value.length;
    if (value is Map) return value.length;
    return 0;
  }

  // Method to refresh user data (re-fetch with saved credentials)
  Future<ApiResponse<Map<String, dynamic>>> refreshUserData(
    String username, 
    String password, 
    String schoolCode
  ) async {
    print('🔄 Refreshing user data...');
    return await login(username, password, schoolCode);
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? rawData;

  ApiResponse({
    required this.success,
    required this.message,
    this.rawData,
  });
}


// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';


// class AuthService {
//   Future<ApiResponse<Map<String, dynamic>>> login(String username, String password, String schoolCode) async {
//     final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
//     final apiKey = dotenv.env['API_KEY'] ?? '';

//     try {
//       final response = await http.post(
//         Uri.parse('$apiBaseUrl/portal/auth/login'),
//         headers: {
//           'Content-Type': 'application/json',
//           'X-API-KEY': apiKey,
//         },
//         body: jsonEncode({
//           'username': username,
//           'password': password,
//           'school_code': int.parse(schoolCode),
//         }),
//       );

//       final Map<String, dynamic> responseBody = jsonDecode(response.body);

//       if (response.statusCode == 200 && responseBody['success'] == true) {
//         return ApiResponse<Map<String, dynamic>>(
//           success: true,
//           message: responseBody['message'],
//           rawData: responseBody['response'],
//         );
//       } else {
//         return ApiResponse<Map<String, dynamic>>(
//           success: false,
//           message: responseBody['message'] ?? 'Login failed',
//         );
//       }
//     } catch (e) {
//       return ApiResponse<Map<String, dynamic>>(
//         success: false,
//         message: 'Network error: $e',
//       );
//     }
//   }
// }

// class ApiResponse<T> {
//   final bool success;
//   final String message;
//   final T? rawData;

//   ApiResponse({
//     required this.success,
//     required this.message,
//     this.rawData,
//   });
// }