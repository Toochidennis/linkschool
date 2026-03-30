import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/explore/lesson_quiz/lesson_quiz_model.dart';
import '../../../config/env_config.dart';

class LessonQuizService {
  final String _baseUrl = "https://linkskool.net/api/v3/public/learning";

  Future<LessonQuizResponse> fetchQuizzes(int lessonId) async {
    try {
      // Load API key from .env
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final uri = Uri.parse("$_baseUrl/lessons/$lessonId/quizzes");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );


      if (response.statusCode == 200) {

        final decoded = json.decode(response.body);
        return LessonQuizResponse.fromJson(decoded);
      } else {
        throw Exception("Failed to load lesson quizzes: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching lesson quizzes: $e");
    }
  }
}
