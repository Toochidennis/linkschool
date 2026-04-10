import 'dart:convert';
import 'package:http/http.dart' as http;
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


      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );


      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        return LessonDetailResponse.fromJson(decoded);
      } else {
        try {
          final errorBody = json.decode(response.body);
          throw Exception(
            errorBody['message'] ?? 'Server error: ${response.statusCode}',
          );
        } catch (jsonError) {
          throw Exception(
            'Server error: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}


