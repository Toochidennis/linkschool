import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChallengeService {
  final String _baseUrl = "https://linkskool.net/api/v3/public";

  Future<void> createChallenge({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final url = "$_baseUrl/cbt/challenge";

      print("🛰️ Creating Challenge...");
      print("➡️ Endpoint: $url");
      print("➡️ Payload: $payload");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(payload),
      );

      print("➡️ Response Status: ${response.statusCode}");
      print("➡️ Response Body: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Server error: ${response.body}");
      }
    } catch (e) {
      print("❌ Error creating Challenge: $e");
      throw Exception("Error creating Challenge: $e.");
    }
  }
}
