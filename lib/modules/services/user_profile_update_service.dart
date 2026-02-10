import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

class UserProfileUpdateService {
  final String baseUrl = 'https://linkskool.net/api/v3/public/cbt/users';
  final apiKey = EnvConfig.apiKey;

  Future<void> updateUserPhone({
    required int userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String attempt,
    required String email,
    required String gender,
    required String birthDate,
  }) async {
    final url = '$baseUrl/$userId/phone';
    final body = {
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
      "attempt": attempt,
      "email": email,
      "gender": gender,
      "birth_date": birthDate,
    };
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-KEY': apiKey,
      },
      body: json.encode(body),
    );
    print("Updateeeee $body");
    if (response.statusCode != 200 && response.statusCode != 201) {
      print("Updateeeee Error: ${response.body}");
      throw Exception('Failed to update user phone: ${response.body}');
    }
  }
}
