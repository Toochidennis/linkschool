import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/explore/cohorts/cohort_model.dart';

class CohortService {
  final String _baseUrl = "https://linkskool.net/api/v3/public/learning/cohorts";

  Future<CohortResponseModel> fetchCohort(String cohortId) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }
      final cohortIdInt = int.tryParse(cohortId);

      final url = '$_baseUrl/${cohortId}';
      final uri = Uri.parse(url);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      print('🛰️ Fetching cohort...');
      print('➡️ Endpoint: $uri');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return CohortResponseModel.fromJson(decoded);
      } else {
        print('❌ Failed to fetch cohort: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception('Failed to fetch cohort: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching cohort: $e');
      rethrow;
    }
  }
}
