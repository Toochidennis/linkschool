import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/cbt_settings_model.dart';
import 'package:linkschool/config/env_config.dart';

class CbtSettingsService {
  final String _baseUrl = "https://linkskool.net/api/v3/public";

  Future<CbtSettingsModel> fetchCbtSettings() async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final url = "$_baseUrl/cbt/settings";
      print("📡 Fetching CBT Settings → $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed: ${response.body}");
      } else {
        print("✅ CBT Settings fetched successfully");
        print("📦 Response: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return CbtSettingsModel.fromJson(decoded);
    } catch (e) {
      throw Exception("Error fetching CBT Settings: $e");
    }
  }
}
