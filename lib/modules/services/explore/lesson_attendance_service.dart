import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

class LessonAttendanceService {
   final _baseUrl = EnvConfig.apiBaseUrl;
 // final String _baseUrl = 'https://linkskool.net/api/v3/public';

  Future<Map<String, dynamic>> submitAttendance({
    required int lessonId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception('API key not found in .env file');
      }

      final url = '$_baseUrl/public/learning/lessons/$lessonId/attendance';
      debugPrint('Submitting lesson attendance to $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(payload),
      );

      debugPrint('Attendance response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('Attendance submitted successfully');
        return decoded;
      }

      try {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Server error: ${response.statusCode}',
        );
      } catch (_) {
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error submitting lesson attendance: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
