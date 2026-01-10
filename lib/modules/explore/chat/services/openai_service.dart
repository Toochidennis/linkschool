import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart' show EnvConfig;

class OpenAIService {
  final String apiKey;
  final String apiUrl = "https://api.openai.com/v1/chat/completions";

  OpenAIService({String? apiKey})
      : apiKey = apiKey ?? dotenv.env['OPENAI_API_KEY'] ?? '' {
    if (this.apiKey.isEmpty) {
      throw Exception('OpenAI API key not found. Please check your .env file.');
    }
    print(
        'API Key loaded: ${this.apiKey.substring(0, 10)}...'); // Print first 10 chars for verification
  }

  final int _maxRequestsPerMinute = 20;
  final _requestTimestamps = <DateTime>[];

  Future<void> _waitForRateLimit() async {
    final now = DateTime.now();
    _requestTimestamps.add(now);

    if (_requestTimestamps.length > _maxRequestsPerMinute) {
      final oldestTimestamp = _requestTimestamps.removeAt(0);
      final timeSinceOldest = now.difference(oldestTimestamp);

      if (timeSinceOldest < const Duration(minutes: 1)) {
        final timeToWait = const Duration(minutes: 1) - timeSinceOldest;
        await Future.delayed(timeToWait);
      }
    }
  }

  Future<String> sendMessage(String message) async {
    // Wait for rate limit to reset before making a new request. This prevents hitting the API too quickly.
    await _waitForRateLimit();
    try {
      print(
          'Attempting API call with key: ${apiKey.substring(0, 10)}...'); // Debug print

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else if (response.statusCode == 401) {
        throw Exception('''Authentication failed. Please:
1. Verify your API key is correct
2. Make sure you have sufficient credits
3. Check if your account is properly set up at https://platform.openai.com''');
      } else if (response.statusCode == 429) {
        final data = jsonDecode(response.body);
        throw Exception(
            'Quota exceeded: ${data['error']['message']}. Please check your OpenAI account and billing details.');
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      rethrow;
    }
  }
}



class DeepSeekService {
  final String apiKey;
  // Updated API endpoint
  final String apiUrl = EnvConfig.deepSeekUrl;

  DeepSeekService({String? apiKey})
      : this.apiKey = apiKey ?? EnvConfig.deepSeekApiKey;

  Future<String> sendMessage(String message) async {
    try {
      print('Sending request with message: $message'); // Debug print

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek-33b-chat',  // Updated model name
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      print('Response status code: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in sendMessage: $e'); // Debug print
      throw Exception('Failed to communicate with DeepSeek API: $e');
    }
  }
}
