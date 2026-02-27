import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

class CbtFcmTokenService {
  final String baseUrl = 'https://linkskool.net/api/v3/public/cbt/users';
  final apiKey = EnvConfig.apiKey;

  Future<bool> updateFcmToken({
    required int userId,
    required String fcmToken,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }
      if (fcmToken.trim().isEmpty) {
        throw Exception("❌ FCM token is empty");
      }

      final url = '$baseUrl/$userId/fcm-token';
      final body = {'fcm_token': fcmToken};

      print("🛠️ [UPDATE FCM TOKEN] PUT $url");
      print("➡️ Headers: X-API-KEY: $apiKey");
      print("➡️ Body: ${json.encode(body)}");
     

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(body),
      );

      print("⬅️ Response status: ${response.statusCode}");
      print("⬅️ Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      print("❌ Failed to update FCM token: ${response.statusCode}");
      return false;
    } catch (e) {
      print("❌ Error updating FCM token: $e");
      return false;
    }
  }
}
