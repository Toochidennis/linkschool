import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/explore/cohorts/upcoming_cohort_model.dart';

class UpcomingCohortService {
  final String _baseUrl = "${EnvConfig.apiBaseUrl}/public/learning/profiles";

  Future<UpcomingCohortResponseModel> fetchUpcomingCohort({
    required int profileId,
    required String slug,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;
      if (apiKey.isEmpty) {
        throw Exception("API key not found");
      }

      final safeSlug = slug.trim();
      final uri = Uri.parse("$_baseUrl/$profileId/upcoming-cohorts/$safeSlug");
      print("Fetching upcoming cohort -> $uri");

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
        return UpcomingCohortResponseModel.fromJson(decoded);
      }

      print("Failed to fetch upcoming cohort: ${response.statusCode}");
      print("Body: ${response.body}");
      throw Exception('Failed to fetch upcoming cohort: ${response.statusCode}');
    } catch (e) {
      print('Error fetching upcoming cohort: $e');
      rethrow;
    }
  }
}
