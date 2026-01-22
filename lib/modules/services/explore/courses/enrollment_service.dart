import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

class EnrollmentService {
// baseurl: String
  final String baseUrl = "https://linkskool.net/api/v3/public";

  Future<Map<String, dynamic>> enrollmentService(
      Map<String, dynamic> enrollmentData,
  
      String cohortId,
  ) async {
    // Implementation for creating user profile
     try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }
      // learning/cohorts/2/enrollments
      final url = "$baseUrl/learning/cohorts/$cohortId/enrollments";
      print("📡 creating enrollment → $url");

      final payload = enrollmentData.map((key, value) => MapEntry(key, value.toString()));
      print("📦 Payload: $payload");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: payload,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("❌ Failed to enroll user");
        print("📦 Response: ${response.body}");
        throw Exception("Failed: ${response.body}");

      } else {
        print("✅ user enrollment  successfully");
        print("📦 Response: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return decoded;
    } catch (e) {
      print("❌ Error enrolling user: $e");
        throw Exception("Error enrolling user: $e");
      }
  }


 

}
