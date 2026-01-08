import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/courses/lesson_model.dart';


class LessonService {
  final String _baseUrl = "https://linkskool.net/api/v3/public/learning/lessons";

  Future<LessonsResponseModel> fetchLessons({
    String? categoryId,
    String? courseId,
  }) async {
    try {
      // Load API key from .env
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      // Build query parameters
      final queryParams = {
        'category_id': categoryId ?? '',
        'course_id': courseId ?? '',
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      print("🛰️ Fetching lessons...");
      print("➡️ Endpoint: $uri");
      print("➡️ Headers: X-API-KEY: $apiKey");

      if (response.statusCode == 200) {
        print("✅ Response received: ${response.body}");

        final decoded = json.decode(response.body);
        return LessonsResponseModel.fromJson(decoded);
      } else {
        print("❌ Failed to load lessons: ${response.statusCode}");
        print("Body: ${response.body}");
        throw Exception("Failed to load lessons: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching lessons: $e");
      throw Exception("Error fetching lessons: $e");
    }
  }
}