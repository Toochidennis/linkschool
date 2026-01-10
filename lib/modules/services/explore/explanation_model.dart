import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

class DeepSeekService {
  static String get _apiKey => EnvConfig.deepSeekApiKey;
  static String get _baseUrl => EnvConfig.deepSeekUrl;

  /// Get explanation from DeepSeek API
  static Future<String> getExplanation({
    required String question,
    required String selectedAnswer,
    required String correctAnswer,
    required bool isCorrect,
  }) async {
    try {
      final url = Uri.parse(_baseUrl);

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: json.encode({
          "model": "deepseek-chat",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful tutor for students preparing for exams. "
                  "Provide clear, concise explanations in simple modern English. "
                  "Keep explanations under 100 words and focus on the key concept."
            },
            {
              "role": "user",
              "content": """
Question: $question

Student's Answer: $selectedAnswer
Correct Answer: $correctAnswer

The student answered ${isCorrect ? 'correctly' : 'incorrectly'}.

${isCorrect ? 'Explain why this answer is correct and reinforce the concept.' : 'Explain why the student\'s answer is wrong, why the correct answer is right, and teach the underlying concept.'}

Keep it brief and educational.
"""
            }
          ],
          "temperature": 0.7,
          "max_tokens": 300,
        }),
      );

      print("lll ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["choices"][0]["message"]["content"].trim();
      } else {
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("DeepSeek API Error: $e");
      // Return a fallback explanation
      return _getFallbackExplanation(isCorrect, correctAnswer);
    }
  }

  /// Fallback explanation if API fails
  static String _getFallbackExplanation(bool isCorrect, String correctAnswer) {
    if (isCorrect) {
      return "Great job! You selected the correct answer: $correctAnswer. "
          "Keep up the good work and continue practicing.";
    } else {
      return "The correct answer is: $correctAnswer. "
          "Review this topic and try similar questions to improve your understanding.";
    }
  }

  /// Get follow-up explanation from DeepSeek API for chat conversations
  static Future<String> getFollowUpExplanation({
    required String question,
    required String originalExplanation,
    required String followUpQuestion,
  }) async {
    try {
      final url = Uri.parse(_baseUrl);

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: json.encode({
          "model": "deepseek-chat",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful tutor for students preparing for exams. "
                  "Provide clear, concise answers to follow-up questions. "
                  "Keep answers under 150 words and use simple, easy-to-understand language. "
                  "Be patient and encouraging."
            },
            {
              "role": "user",
              "content": """
Original Question: $question

Previous Explanation: $originalExplanation

Student's Follow-up Question: $followUpQuestion

Please answer the student's follow-up question clearly and concisely.
"""
            }
          ],
          "temperature": 0.7,
          "max_tokens": 400,
        }),
      );

      print("Follow-up response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["choices"][0]["message"]["content"].trim();
      } else {
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("DeepSeek Follow-up API Error: $e");
      throw Exception(
          "Failed to get follow-up explanation. Please try again.");
    }
  }
}
