import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepSeekService {
  final String apiKey;
  final String apiUrl = "https://api.deepseek.com/v1/chat/completions"; // Replace with the actual DeepSeek API endpoint

  DeepSeekService(this.apiKey);

  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'deepseek-chat', // Replace with the correct model name
        'messages': [
          {'role': 'user', 'content': message}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to load response: ${response.body}');
    }
  }
}