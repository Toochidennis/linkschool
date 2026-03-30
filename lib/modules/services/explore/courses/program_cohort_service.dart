import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/explore/cohorts/program_cohort_model.dart';

class ProgramCohortService {
  Future<ProgramCohortResponseModel> fetchProgramCohortByRef(String ref) async {
    final apiKey = EnvConfig.apiKey;
    if (apiKey.isEmpty) {
      throw Exception('API key not found');
    }

    final safeRef = ref.trim();
    if (safeRef.isEmpty) {
      throw Exception('Missing cohort reference');
    }

    final uri = Uri.parse(
      '${EnvConfig.apiBaseUrl}/public/programs/cohorts/$safeRef',
    );

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
      return ProgramCohortResponseModel.fromJson(
        Map<String, dynamic>.from(decoded as Map),
      );
    }

    throw Exception(
      'Failed to load program cohort by ref: ${response.statusCode}',
    );
  }
}
