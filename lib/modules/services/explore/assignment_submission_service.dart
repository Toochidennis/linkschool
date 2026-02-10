import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

// Top-level function for JSON encoding in isolate
String _encodePayloadToJson(Map<String, dynamic> payload) {
  return json.encode(payload);
}

class AssignmentSubmissionService {
  final String _baseUrl = "https://linkskool.net/api/v3/public";

  /// Submit assignment with quiz score and file
  Future<Map<String, dynamic>> submitAssignment({
    required String name,
    required String email,
    required String phone,
    required String lessonId,
    required String quizScore,
    required String cohortId,
    required String profileId,
    required List<Map<String, dynamic>> assignments,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = "$_baseUrl/learning/lessons/$lessonId/assignments";

      print("📡 Submitting assignment → $url");

      final payload = <String, dynamic>{
        "name": name,
        "email": email,
        "phone": phone,
        "quiz_score": quizScore,
        'cohort_id': cohortId,
        'profile_id': profileId,
      };
      if (assignments.isNotEmpty) {
        payload["assignment"] = assignments;
      }

      print("📦 Payload structure:");
      print("  - name: $name");
      print("  - email: $email");
      print("  - phone: $phone");
      print("  - quiz_score: $quizScore");
      print("  - assignment array length: ${assignments.length}");
      if (assignments.isNotEmpty) {
        print("  - first assignment file_name: ${assignments[0]['file_name']}");
        print("  - first assignment type: ${assignments[0]['type']}");
        print(
            "  - first assignment file length: ${assignments[0]['file']?.length ?? 0} chars");
      }

      // Encode JSON in background isolate to avoid blocking UI
      print("🔄 Encoding payload to JSON in background...");
      final jsonBody = await compute(_encodePayloadToJson, payload);
      print("✅ JSON encoding complete, size: ${jsonBody.length} bytes");

      print("📤 Sending HTTP request...");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: jsonBody,
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        print("✅ Assignment submitted successfully");
        return {
          'success': true,
          'message': decoded['message'] ?? 'Assignment submitted successfully',
          'data': decoded['data'] ?? {},
        };
      } else {
        print("❌ Server returned error status: ${response.statusCode}");
        try {
          final errorBody = json.decode(response.body);
          print("❌ Error response body: $errorBody");
          throw Exception(
            errorBody['message'] ?? "Server error: ${response.statusCode}",
          );
        } catch (jsonError) {
          print("❌ Could not parse error response: $jsonError");
          throw Exception(
              "Server error: ${response.statusCode} - ${response.body}");
        }
      }
    } catch (e, stackTrace) {
      print("❌ Error submitting assignment: $e");
      print("❌ Stack trace: $stackTrace");
      rethrow; // ✅ Rethrow to let provider handle it
    }
  }
}
