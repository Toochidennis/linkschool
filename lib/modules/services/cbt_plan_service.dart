import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/cbt_plan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CbtPlanService {
  final String baseUrl =
      'https://linkskool.net/api/v3/public/cbt/license/plans/mobile';
  final apiKey = EnvConfig.apiKey;

  static const String _cacheKey = 'cbt_plan_cache';
  static const String _cacheTsKey = 'cbt_plan_cache_ts';

  Future<List<CbtPlanModel>> getCachedPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((e) => CbtPlanModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading cached plans: $e');
      return [];
    }
  }

  Future<void> _saveCachedPlans(List<CbtPlanModel> plans) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = json.encode(plans.map((e) => e.toJson()).toList());
      await prefs.setString(_cacheKey, payload);
      await prefs.setInt(_cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ Error saving cached plans: $e');
    }
  }

  Future<List<CbtPlanModel>> fetchPlans() async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      print("🛠️ [FETCH PLANS] GET $baseUrl");
      print("➡️ Headers: X-API-KEY: $apiKey");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          final plans = (decoded['data'] as List)
              .map((e) => CbtPlanModel.fromJson(e as Map<String, dynamic>))
              .toList();
          await _saveCachedPlans(plans);
          return plans;
        }
        throw Exception(
            "Failed to fetch plans: ${decoded['message'] ?? 'Unknown error'}");
      }

      print("❌ Failed to fetch plans: ${response.statusCode}");
      print("Body: ${response.body}");
      throw Exception("Failed to fetch plans: ${response.statusCode}");
    } catch (e) {
      print("❌ Error fetching plans: $e");
      throw Exception("Error fetching plans: $e");
    }
  }
}
