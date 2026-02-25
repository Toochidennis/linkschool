import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/explore/courses/lesson_performance_model.dart';

class LessonPerformanceService {
  final String _baseUrl = "${EnvConfig.apiBaseUrl}/public/learning/cohorts";

  Future<LessonPerformanceResponseModel> fetchLessonPerformance({
    required String cohortId,
    required int profileId,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final uri = Uri.parse(
        "$_baseUrl/$cohortId/profiles/$profileId/lesson-performance",
      );
      print("📡 fetching lesson performance → $uri");

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      if (response.statusCode != 200) {
        print("❌ Failed to fetch lesson performance");
        print("📦 Response: ${response.body}");
        throw Exception("Failed: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return LessonPerformanceResponseModel.fromJson(decoded);
    } catch (e) {
      print("❌ Error fetching lesson performance: $e");
      throw Exception("Error fetching lesson performance: $e");
    }
  }
}
