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


  // payment service

  Future<Map<String, dynamic>> enrollmentPayment(
      Map<String, dynamic> paymentData,
  
      String cohortId,
  ) async {
    // Implementation for creating user profile
     try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }
      // learning/cohorts/2/enrollments
      final url = "$baseUrl/learning/cohorts/$cohortId/enrollments/payment";
      print("📡 creating payment → $url");

      final payload = paymentData.map((key, value) => MapEntry(key, value.toString()));
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
        print("❌ Failed to process payment");
        print("📦 Response: ${response.body}");
        throw Exception("Failed: ${response.body}");

      } else {
        print("✅ payment processed successfully");
        print("📦 Response: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return decoded;
    } catch (e) {
      print("❌ Error processing payment: $e");
        throw Exception("Error processing payment: $e");
      }
  }

  // updating view trials 
  Future<Map<String, dynamic>> updateTrialView(   Map<String, dynamic> trialData,   int cohortId,
  ) async {
    // Implementation for creating user profile
     try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }
      // learning/courses/2/trial-views
      final url = "$baseUrl/learning/courses/$cohortId/enrollments/lessons-taken";
      print("📡 updating trial view → $url");

      final payload = trialData.map((key, value) => MapEntry(key, value.toString()));
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
        print("❌ Failed to update trial view");
        print("📦 Response: ${response.body}");
        throw Exception("Failed: ${response.body}");

      } else {
        print("✅ trial view updated successfully");
        print("📦 Response: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return decoded;
    } catch (e) {
      print("❌ Error updating trial view: $e");
        throw Exception("Error updating trial view: $e");
      }
  }

 

}


