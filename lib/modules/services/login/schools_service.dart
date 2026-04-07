import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/login/schools_model.dart';
import 'package:linkschool/config/env_config.dart';

class SchoolService {
  final String baseUrl = "https://linkskool.net/api/v3/portal/schools";

  Future<List<School>> fetchSchools() async {
    try {
      // Load API key from .env
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
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

      if (response.statusCode == 200) {
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
        throw Exception("Failed to load schools: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching schools: $e");
    }
  }
}
