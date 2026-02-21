import 'dart:convert';
import 'package:linkschool/modules/model/explore/home/cbt_board_model.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/services/explore/cache/explore_dashboard_cache.dart';

class CBTService {
  final String _baseUrl = "https://linkskool.net/api/v3/public/cbt/exams";

  Future<List<CBTBoardModel>> _loadCachedOrThrow() async {
    final cached = await ExploreDashboardCache.load('cbt:boards');
    final data = cached?.data;
    if (data is List) {
      return data.map((e) => CBTBoardModel.fromJson(e)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => CBTBoardModel.fromJson(e))
          .toList();
    }
    throw Exception('No cached CBT boards available');
  }

  Future<List<CBTBoardModel>> fetchCBTBoards({
    bool allowNetwork = true,
  }) async {
    if (!allowNetwork) {
      return _loadCachedOrThrow();
    }
    try {
      // Load API key from .env
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
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
          await ExploreDashboardCache.save('cbt:boards', decoded);
          return decoded.map((e) => CBTBoardModel.fromJson(e)).toList();
        } else if (decoded is Map && decoded['data'] is List) {
          // If API wraps data in { "data": [...] }
          await ExploreDashboardCache.save('cbt:boards', decoded);
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
      try {
        return await _loadCachedOrThrow();
      } catch (_) {
        print("❌ Error fetching CBT boards: $e");
        throw Exception("Error fetching CBT boards: $e");
      }
    }
  }
}
