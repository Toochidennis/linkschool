import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/explore/courses/course_leaderboard_model.dart';

class CourseLeaderboardService {
  final String _baseUrl = '${EnvConfig.apiBaseUrl}/public/learning/cohorts';

  Future<CourseLeaderboardResponseModel> fetchLeaderboard({
    required String cohortId,
    required int profileId,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception('API key not found');
      }

      final uri = Uri.parse(
        '$_baseUrl/$cohortId/profiles/$profileId/leaderboard',
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch leaderboard: ${response.body}');
      }

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return CourseLeaderboardResponseModel.fromJson(decoded);
    } catch (e) {
      throw Exception('Error fetching leaderboard: $e');
    }
  }
}
