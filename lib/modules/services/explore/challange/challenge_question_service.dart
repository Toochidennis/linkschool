import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

class ChallengeQuestionService {
  Future<Map<String, dynamic>> fetchChallengeQuestions({
    required int courseId,
    required int challengeId,
    int? limit,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;
      if (apiKey.isEmpty) {
        throw Exception("API key not found in .env file");
      }

      // Build URL properly
      final baseUrl =
          "https://linkskool.net/api/v3/public/cbt/challenges/questions";

      final queryParams = {
        "course_id": courseId.toString(),
        "challenge_id": challengeId.toString(),
        if (limit != null) "limit": limit.toString(),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

print("Fetching challenge questions from URL: $uri ");
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );


      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        print("Received response: $body");
        return body;
      } else {
        throw Exception("Failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching challenge questions: $e");
    }
  }
}

