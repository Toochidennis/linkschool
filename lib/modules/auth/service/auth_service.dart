import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:linkschool/config/env_config.dart';

class AuthService {
  Future<ApiResponse<Map<String, dynamic>>> login(
      String username, String password, String schoolCode) async {
    final apiBaseUrl = EnvConfig.apiBaseUrl;
    final apiKey = EnvConfig.apiKey;

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

        // Print the entire response structure

        if (responseData is Map) {
          responseData.forEach((key, value) {
          });
        }

        // Print token
        if (responseData['token'] != null) {
        }

        // Print database identifier
        if (responseData['_db'] != null) {
        }

        // Print user data structure
        if (responseData['data'] != null) {
          final userData = responseData['data'];
          if (userData is Map) {
            userData.forEach((key, value) {
              if (value is Map || value is List) {
              } else {
              }
            });
          }

          // Print role

          // Print settings if available
          if (userData['settings'] != null) {
          }

          // Print role-specific data
          if (userData['role'] == 'admin') {
            if (userData['levels'] != null) {
            }
            if (userData['classes'] != null) {
            }
            if (userData['courses'] != null) {
            }
          } else if (userData['role'] == 'staff') {
            if (userData['form_classes'] != null) {
            }
            if (userData['courses'] != null) {
            }
          } else if (userData['role'] == 'student') {
            if (userData['profile'] != null) {
            }
          }
        }

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
      String username, String password, String schoolCode) async {
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
