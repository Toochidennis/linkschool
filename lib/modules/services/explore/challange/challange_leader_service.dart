import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/challange_leader_model.dart';

class LeaderboardService {
  final String _baseUrl = "https://linkskool.net/api/v3/public";

  /// Submit challenge result to the leaderboard
  Future<Map<String, dynamic>> submitChallengeResult({
    required int challengeId,
    required int userId,
    required String username,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int timeTaken,
    required String deviceId,
    required String platform,
  }) async {
    try {
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final url = "$_baseUrl/cbt/challenges/leaderboard";

      final payload = {
        "challenge_id": challengeId,
        "user_id": userId,
        "username": username,
        "score": score.toString(),
        "correct_answers": correctAnswers,
        "total_questions": totalQuestions,
        "time_taken": timeTaken.toString(),
        "device_id": deviceId,
        "platform": platform,
      };

      print("📡 Submitting Challenge Result → $url");
      print("📦 Payload: $payload");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-API-KEY": apiKey,
        },
        body: json.encode(payload),
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to submit result: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return decoded;
    } catch (e) {
      print("❌ Error submitting challenge result: $e");
      throw Exception("Error submitting challenge result: $e");
    }
  }

  /// Fetch leaderboard for a specific challenge
  Future<LeaderboardResponse> fetchLeaderboard(int challengeId) async {
    try {
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final url = "$_baseUrl/cbt/challenges/leaderboard/$challengeId";
      print("📡 Fetching Leaderboard → $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to load leaderboard: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return LeaderboardResponse.fromJson(decoded);
    } catch (e) {
      throw Exception("Error fetching leaderboard: $e");
    }
  }
}
