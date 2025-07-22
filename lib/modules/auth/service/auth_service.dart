import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AuthService {
  Future<ApiResponse<Map<String, dynamic>>> login(String username, String password, String schoolCode) async {
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
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseBody['message'],
          rawData: responseBody['response'],
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