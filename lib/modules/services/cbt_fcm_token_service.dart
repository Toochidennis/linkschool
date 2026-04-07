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

     

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(body),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

