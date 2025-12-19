import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChallengeQuestionService {

  Future<Map<String, dynamic>> fetchChallengeQuestions({
    required int examId,
    required int challengeId,
    int? limit,
  }) async {
    try {
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API key not found in .env file");
      }

      // Build URL properly
      final baseUrl =
          "https://linkskool.net/api/v3/public/cbt/challenges/questions";

      final queryParams = {
        "exam_id": examId.toString(),
        "challenge_id": challengeId.toString(),
        if (limit != null) "limit": limit.toString(),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      print("🌐 Requesting: $uri");

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      print("📡 Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        print("📊 Response: $body");
        return body;
      } else {
        throw Exception(
            "Failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("💥 Error: $e");
      throw Exception("Error fetching challenge questions: $e");
    }
  }
}
