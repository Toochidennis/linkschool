import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/Login/schools_model.dart';
class SchoolService {
  final String baseUrl = "https://linkskool.net/api/v3/portal/schools"; 

  Future<List<School>> fetchSchools() async {
    try {
      // Load API key from .env
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey, // ✅ Use API key here
        },
      );

      print("🛰️ Fetching schools...");
      print("➡️ Endpoint: $baseUrl");
      print("➡️ Headers: X-API-KEY: $apiKey");

      if (response.statusCode == 200) {
        print("✅ Response received: ${response.body}");

        final decoded = json.decode(response.body);

        if (decoded is List) {
          // If API returns a List directly
          return decoded.map((e) => School.fromJson(e)).toList();
        } else if (decoded is Map && decoded['data'] is List) {
          // If API wraps data in { "data": [...] }
          return (decoded['data'] as List)
              .map((e) => School.fromJson(e))
              .toList();
        } else {
          throw Exception("Unexpected response format: $decoded");
        }
      } else {
        print("❌ Failed to load schools: ${response.statusCode}");
        print("Body: ${response.body}");
        throw Exception("Failed to load schools: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching schools: $e");
      throw Exception("Error fetching schools: $e");
    }
  }
}