import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/explore/challange_subject_model.dart';

class ChallengeSubjectService {
  static const String _baseUrl =
      'https://linkskool.net/api/v3/public/cbt/exams';

  Future<List<ChallengeCourseModel>> fetchChallengeSubjects(
    int examTypeId,
  ) async {
    try {
      final apiKey = EnvConfig.apiKey;
      if (apiKey.isEmpty) {
        throw Exception('API key not found in .env file');
      }

      final uri = Uri.parse('$_baseUrl/$examTypeId/courses');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );


      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load challenge subjects: ${response.statusCode} - ${response.body}',
        );
      }

      final decoded = json.decode(response.body);
      final List<dynamic> rawList;

      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        rawList = decoded['data'] as List;
      } else {
        throw Exception('Unexpected challenge subject response format');
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(ChallengeCourseModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Error fetching challenge subjects: $e');
    }
  }
}

