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
      print("ðŸ“¡ creating enrollment â†’ $url");

      final payload = enrollmentData.map((key, value) => MapEntry(key, value.toString()));
      print("ðŸ“¦ Payload: $payload");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: payload,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("âŒ Failed to enroll user");
        print("ðŸ“¦ Response: ${response.body}");
        throw Exception("Failed: ${response.body}");

      } else {
        print("âœ… user enrollment  successfully");
        print("ðŸ“¦ Response: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return decoded;
    } catch (e) {
      print("âŒ Error enrolling user: $e");
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
      print("ðŸ“¡ creating payment â†’ $url");

      final payload = paymentData.map((key, value) => MapEntry(key, value.toString()));
      print("ðŸ“¦ Payload: $payload");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: payload,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("âŒ Failed to process payment");
        print("ðŸ“¦ Response: ${response.body}");
        throw Exception("Failed: ${response.body}");

      } else {
        print("âœ… payment processed successfully");
        print("ðŸ“¦ Response: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return decoded;
    } catch (e) {
      print("âŒ Error processing payment: $e");
        throw Exception("Error processing payment: $e");
      }
  }


  Future<bool> fetchPaymentStatus({
    required String cohortId,
    required int profileId,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final uri = Uri.parse(
        "$baseUrl/learning/cohorts/$cohortId/enrollments/payment-status",
      ).replace(queryParameters: {
        "profile_id": profileId.toString(),
      });
      print("📡 fetching payment status → $uri");

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      if (response.statusCode != 200) {
        print("❌ Failed to fetch payment status");
        print("📦 Response: ${response.body}");
        throw Exception("Failed: ${response.body}");
      }

      final decoded = json.decode(response.body);
      final data = decoded['data'] as Map<String, dynamic>?;
      return data?['payment_status'] == true;
    } catch (e) {
      print("❌ Error fetching payment status: $e");
      throw Exception("Error fetching payment status: $e");
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
      print("ðŸ“¡ updating trial view â†’ $url");

      final payload = trialData.map((key, value) => MapEntry(key, value.toString()));
      print("ðŸ“¦ Payload: $payload");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: payload,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("âŒ Failed to update trial view");
        print("ðŸ“¦ Response: ${response.body}");
        throw Exception("Failed: ${response.body}");

      } else {
        print("âœ… trial view updated successfully");
        print("ðŸ“¦ Response: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return decoded;
    } catch (e) {
      print("âŒ Error updating trial view: $e");
        throw Exception("Error updating trial view: $e");
      }
  }

 

}



