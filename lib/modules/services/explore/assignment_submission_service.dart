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
    String? submissionType,
    String? linkUrl,
    String? textContent,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = "$_baseUrl/learning/lessons/$lessonId/assignments";


      final payload = <String, dynamic>{
        "name": name,
        "email": email,
        "phone": phone,
        "quiz_score": quizScore,
        'cohort_id': cohortId,
        'profile_id': profileId,
      };
      if (submissionType != null && submissionType.isNotEmpty) {
        payload["submission_type"] = submissionType;
      }
      if (linkUrl != null && linkUrl.isNotEmpty) {
        payload["link_url"] = linkUrl;
      }
      if (textContent != null && textContent.isNotEmpty) {
        payload["text_content"] = textContent;
      }
      if (assignments.isNotEmpty) {
        payload["assignment"] = assignments;
      }

      

      // Encode JSON in background isolate to avoid blocking UI
      final jsonBody = await compute(_encodePayloadToJson, payload);
     

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: jsonBody,
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return {
          'success': true,
          'message': decoded['message'] ?? 'Assignment submitted successfully',
          'data': decoded['data'] ?? {},
        };
      } else {
        try {
          final errorBody = json.decode(response.body);
          throw Exception(
            errorBody['message'] ?? "Server error: ${response.statusCode}",
          );
        } catch (jsonError) {
          throw Exception(
              "Server error: ${response.statusCode} - ${response.body}");
        }
      }
    } catch (e) {
      rethrow; // ✅ Rethrow to let provider handle it
    }
  }
}


