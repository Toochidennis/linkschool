import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepSeekService {
  final String apiKey;
  // Updated to the correct DeepSeek endpoint
  final String apiUrl = "https://api.deepseek.com/v1/chat/completions";

  DeepSeekService({String? apiKey}) : apiKey = apiKey ?? dotenv.env['DEEPSEEK_API_KEY'] ?? '' {
    if (this.apiKey.isEmpty) {
      throw Exception('DeepSeek API key not found. Please check your .env file.');
    }
    print('API Key loaded: ${this.apiKey.substring(0, 10)}...'); // Print first 10 chars for verification
  }

  Future<String> sendMessage(String message) async {
    try {
      print('Attempting API call with key: ${apiKey.substring(0, 10)}...'); // Debug print
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'model': 'deepseek-chat',
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      print('Full response headers: ${response.headers}'); // Debug print
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else if (response.statusCode == 401) {
        throw Exception('''Authentication failed. Please:
1. Verify your API key is correct
2. Make sure you have sufficient credits
3. Check if your account is properly set up at https://platform.deepseek.com''');
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      rethrow;
    }
  }
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class DeepSeekService {
//   final String apiKey;
//   // Updated API endpoint
//   final String apiUrl = "https://api.deepinfra.com/v1/openai/chat/completions";

//   DeepSeekService({String? apiKey}) 
//       : this.apiKey = apiKey ?? dotenv.env['DEEPSEEK_API_KEY'] ?? '';

//   Future<String> sendMessage(String message) async {
//     try {
//       print('Sending request with message: $message'); // Debug print
      
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Authorization': 'Bearer $apiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'model': 'deepseek-33b-chat',  // Updated model name
//           'messages': [
//             {'role': 'user', 'content': message}
//           ],
//           'temperature': 0.7,
//           'max_tokens': 1000,
//         }),
//       );

//       print('Response status code: ${response.statusCode}'); // Debug print
//       print('Response body: ${response.body}'); // Debug print

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['choices'][0]['message']['content'] as String;
//       } else {
//         throw Exception('API Error: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       print('Error in sendMessage: $e'); // Debug print
//       throw Exception('Failed to communicate with DeepSeek API: $e');
//     }
//   }
// }