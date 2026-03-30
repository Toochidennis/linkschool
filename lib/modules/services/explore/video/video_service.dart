import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/videos/video_model.dart';
import 'package:linkschool/config/env_config.dart';

class CourseVideoService {
  final String _baseUrl =
      "https://linkskool.net/api/v3/public/video-library/videos/published";

  Future<CourseVideosResponseModel> fetchCourseVideos({
    required String levelId,
    required String courseId,
  }) async {
    try {
      // Load API key from .env
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
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


      if (response.statusCode == 200) {

        final decoded = json.decode(response.body);
        return CourseVideosResponseModel.fromJson(decoded);
      } else {
        throw Exception("Failed to load course videos: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching course videos: $e");
    }
  }
}

