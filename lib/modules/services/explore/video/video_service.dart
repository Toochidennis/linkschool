import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/videos/video_model.dart';

class CourseVideoService {
  final String _baseUrl = "https://linkskool.net/api/v3/public/video-library/videos/published";

  Future<CourseVideosResponseModel> fetchCourseVideos({
    required String levelId,
    required String courseId,
  }) async {
    try {
      // Load API key from .env
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      // Build the endpoint URL with levelId and courseId
      final url = "$_baseUrl/$levelId/$courseId";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      print("🛰️ Fetching course videos...");
      print("➡️ Endpoint: $url");
      print("➡️ Level ID: $levelId");
      print("➡️ Course ID: $courseId");
      print("➡️ Headers: X-API-KEY: $apiKey");

      if (response.statusCode == 200) {
        print("✅ Response received: ${response.body}");

        final decoded = json.decode(response.body);
        return CourseVideosResponseModel.fromJson(decoded);
      } else {
        print("❌ Failed to load course videos: ${response.statusCode}");
        print("Body: ${response.body}");
        throw Exception("Failed to load course videos: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching course videos: $e");
      throw Exception("Error fetching course videos: $e");
    }
  }
}