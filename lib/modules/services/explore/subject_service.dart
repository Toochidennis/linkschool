import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:linkschool/config/env_config.dart';

import '../../model/explore/home/subject_model2.dart';
import '../../model/explore/home/level_model.dart';
import '../../model/explore/videos/dashboard_video_model.dart';

class SubjectService {
  static const String _subjectsUrl =
      'https://linkskool.net/api/v3/public/video-library/courses/public';
  static const String _levelsUrl = 'https://linkskool.net/api/v3/public/levels';
  static const String _dashboardUrl =
      'https://linkskool.net/api/v3/public/video-library/courses/by-level';

  Future<List<SubjectModel2>> getAllSubjects() async {
    try {
      final apiKey = EnvConfig.apiKey;
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }


      final response = await http.get(
        Uri.parse(_subjectsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );


      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'];
          if (data is List) {
            return data.map((e) => SubjectModel2.fromJson(e)).toList();
          }
        }

        throw Exception('Unexpected response format');
      } else {
        throw Exception(
            'Failed to load subjects: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching subjects: $e');
    }
  }

  Future<List<LevelModel>> getAllLevels() async {
    try {
      final apiKey = EnvConfig.apiKey;
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }


      final response = await http.get(
        Uri.parse(_levelsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );


      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'];
          if (data is List) {
            return data.map((e) => LevelModel.fromJson(e)).toList();
          }
        }

        throw Exception('Unexpected response format');
      } else {
        throw Exception(
            'Failed to load levels: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching levels: $e');
    }
  }

  Future<DashboardResponseModel> getDashboardData(int levelId) async {
    try {
      final apiKey = EnvConfig.apiKey;
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = '$_dashboardUrl?level_id=$levelId';

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

        return DashboardResponseModel.fromJson(decoded);
      } else {
        throw Exception(
            'Failed to load dashboard data: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }
}
