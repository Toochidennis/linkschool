import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:linkschool/modules/model/explore/home/cbt_board_model.dart';
import 'package:http/http.dart' as http;

class CBTService {
  final String _baseUrl = "https://linkskool.net/api/v3/public/cbt/exams";

  Future<List<CBTBoardModel>> fetchCBTBoards() async {
    try {
      // Load API key from .env
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final response = await http.get(
        Uri.parse("https://linkskool.net/api/v3/public/cbt/exams"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey, // ✅ Use API key here
        },
      );

      print("🛰️ Fetching CBT boards...");
      print("➡️ Endpoint: https://linkskool.net/api/v3/public/cbt/exams");
      print("➡️ Headers: X-API-KEY: $apiKey");

      if (response.statusCode == 200) {
        print("✅ Response received: ${response.body}");

        final decoded = json.decode(response.body);

        if (decoded is List) {
          // If API returns a List directly
          return decoded.map((e) => CBTBoardModel.fromJson(e)).toList();
        } else if (decoded is Map && decoded['data'] is List) {
          // If API wraps data in { "data": [...] }
          return (decoded['data'] as List)
              .map((e) => CBTBoardModel.fromJson(e))
              .toList();
        } else {
          throw Exception("Unexpected response format: $decoded");
        }
      } else {
        print("❌ Failed to load CBT boards: ${response.statusCode}");
        print("Body: ${response.body}");
        throw Exception("Failed to load CBT boards: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching CBT boards: $e");
      throw Exception("Error fetching CBT boards: $e");
    }
  }
}
