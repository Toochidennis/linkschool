import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/courses/category_model.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

class CourseResponse {
  final int statusCode;
  final bool success;
  final String message;
  final List<CategoryModel> categories;

  CourseResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.categories,
  });

  factory CourseResponse.fromJson(Map<String, dynamic> json) {
    return CourseResponse(
      statusCode: json['statusCode'],
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      categories: (json['data'] as List<dynamic>?)
              ?.map((item) => CategoryModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CourseService {
  final String baseUrl =
      "https://linkskool.net/api/v3/public/learning/programs";
  final String _enrollmentBaseUrl =
      "https://linkskool.net/api/v3/public/learning/cohorts";

  Future<CourseResponse> getAllCategoriesAndCourses({int? profileId, String? dateOfBirth}) async {
    try {
      final apiKey = EnvConfig.apiKey;

      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        if (profileId != null) 'profile_id': profileId.toString(),
     //   if (dateOfBirth != null) 'birth_date': dateOfBirth,
      });


      print("🔔 Fetching categories and courses from: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        debugPrint("🔔 CourseService Response: $jsonData");

        // Check if API call was successful
        if (jsonData['success'] != true) {
          throw Exception(
              jsonData['message'] ?? 'Failed to load categories and courses');
        }

        debugPrint(
            "✅ Categories and courses fetched successfully: ${jsonData['message']}");
        return CourseResponse.fromJson(jsonData);
      } else {
        throw Exception(
            "Failed to load categories and courses: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to load categories and courses: $e");
    }
  }
  Future<bool> checkIsEnrolled({
    required int cohortId,
    required int profileId,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      final uri = Uri.parse("$_enrollmentBaseUrl/$cohortId/enrollments/is-enrolled")
          .replace(queryParameters: {
        'profile_id': profileId.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        debugPrint("Enrollment Check Response: $jsonData");

        final data = jsonData['data'] as Map<String, dynamic>?;

        debugPrint("Is Enrolled: ${data?['is_enrolled']}");

        return data?['is_enrolled'] == true;
      }

      throw Exception("Failed to verify enrollment: ");
    } catch (e) {
      throw Exception("Failed to verify enrollment: ");
    }
  }
}


