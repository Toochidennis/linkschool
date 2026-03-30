import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/explore/courses/program_courses_model.dart';

class ProgramCoursesService {
  final String baseUrl = EnvConfig.apiBaseUrl;

  Future<ProgramCoursesResponseModel> fetchProgramCoursesBySlug(
    String slug,
  ) async {
    final trimmedSlug = slug.trim();
    if (trimmedSlug.isEmpty) {
      throw Exception('Program slug is required');
    }

    final uri = Uri.parse(
      '$baseUrl/public/programs/${Uri.encodeComponent(trimmedSlug)}/courses',
    );

    debugPrint('Fetching program courses from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-KEY': EnvConfig.apiKey,
      },
    );


    if (response.statusCode != 200) {
      throw Exception('Failed to load program courses: ${response.statusCode}');
    }

    final Map<String, dynamic> decoded =
        json.decode(response.body) as Map<String, dynamic>;

    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Failed to load program courses');
    }

    return ProgramCoursesResponseModel.fromJson(decoded);
  }
}

