import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:linkschool/modules/model/explore/courses/category_model.dart';
import 'package:http/http.dart' as http;

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
      statusCode: json['statusCode'] ?? 200,
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
  final String baseUrl = "https://linkskool.net/api/v3/public/learning/categories-and-courses";

  Future<CourseResponse> getAllCategoriesAndCourses() async {
    try {
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API key not found in .env file");
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Check if API call was successful
        if (jsonData['success'] != true) {
          throw Exception(
              jsonData['message'] ?? 'Failed to load categories and courses');
        }

        print("✅ Categories and courses fetched successfully: ${jsonData['message']}");
        return CourseResponse.fromJson(jsonData);
      } else {
        print(
            "❌ Failed to load categories and courses: ${response.statusCode} ${response.body}");
        throw Exception("Failed to load categories and courses: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching categories and courses: $e");
      throw Exception("Failed to load categories and courses: $e");
    }
  }
}
