import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/explore/cohorts/cohort_model.dart';

class CohortService {
  final String _baseUrl = "https://linkskool.net/api/v3/public/learning/cohorts";

  Future<CohortResponseModel> fetchCohort(
    String cohortId, {
    String? ref,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }
      final trimmedRef = ref?.trim() ?? '';
      final url = trimmedRef.isNotEmpty
          ? '${EnvConfig.apiBaseUrl}/public/programs/cohorts/${Uri.encodeComponent(trimmedRef)}'
          : '$_baseUrl/$cohortId';
      final uri = Uri.parse(url);
     
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
        final normalized = _normalizeCohortResponse(
          Map<String, dynamic>.from(decoded as Map),
        );
        return CohortResponseModel.fromJson(normalized);
      } else {

        throw Exception('Failed to fetch cohort: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _normalizeCohortResponse(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return json;
    }

    final cohort = data['cohort'];
    if (cohort is! Map<String, dynamic>) {
      return json;
    }

    final course = data['course'];
    final program = data['program'];

    final merged = <String, dynamic>{...Map<String, dynamic>.from(cohort)};

    if (course is Map<String, dynamic>) {
      final courseMap = Map<String, dynamic>.from(course);
      merged.putIfAbsent('course_id', () => courseMap['courseId'] ?? courseMap['course_id']);
      merged.putIfAbsent('course_name', () => courseMap['courseName'] ?? courseMap['course_name']);
      merged.putIfAbsent('description', () => courseMap['description']);
      merged.putIfAbsent('image_url', () => courseMap['image_url']);
      merged.putIfAbsent('video_url', () => courseMap['video_url']);
      merged.putIfAbsent('program_id', () => courseMap['program_id']);
      merged.putIfAbsent('slug', () => courseMap['slug']);
      merged.putIfAbsent('start_date', () => courseMap['start_date']);
    }

    if (program is Map<String, dynamic>) {
      final programMap = Map<String, dynamic>.from(program);
      merged.putIfAbsent('program_id', () => programMap['id'] ?? programMap['program_id']);
      merged.putIfAbsent('program_name', () => programMap['name']);
      merged.putIfAbsent('provider', () => programMap['name']);
      merged.putIfAbsent('program_slug', () => programMap['slug']);
      merged.putIfAbsent('sponsor', () => programMap['sponsor']);
      merged.putIfAbsent('whatsapp_group_link', () => programMap['whatsapp_group_link']);
    }

    return <String, dynamic>{
      ...json,
      'data': merged,
    };
  }
}

