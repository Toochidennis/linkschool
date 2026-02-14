import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/cbt_plan_model.dart';

class CbtPlanService {
  final String baseUrl =
      'https://linkskool.net/api/v3/public/cbt/license/plans/mobile';
  final apiKey = EnvConfig.apiKey;

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
          return (decoded['data'] as List)
              .map((e) => CbtPlanModel.fromJson(e as Map<String, dynamic>))
              .toList();
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
