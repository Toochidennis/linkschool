import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:linkschool/config/env_config.dart';
import '../../model/explore/courses/lesson_detail_model.dart';

class LessonDetailService {
  final String _baseUrl = 'https://linkskool.net/api/v3/public';

  Future<LessonDetailResponse> fetchLessonDetail({
    required int lessonId,
    required int profileId,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception('API key not found in .env file');
      }

      final url = '$_baseUrl/learning/lessons/$lessonId?profile_id=$profileId';

      debugPrint('Fetching lesson detail $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      debugPrint('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        print('Decoded response: $decoded');
        debugPrint('Lesson detail fetched successfully');
        return LessonDetailResponse.fromJson(decoded);
      } else {
        debugPrint('Server returned error status: ${response.statusCode}');
        try {
          final errorBody = json.decode(response.body);
          debugPrint('Error response body: $errorBody');
          throw Exception(
            errorBody['message'] ?? 'Server error: ${response.statusCode}',
          );
        } catch (jsonError) {
          debugPrint('Could not parse error response: $jsonError');
          throw Exception(
            'Server error: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching lesson detail: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

