import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../model/explore/home/game_model.dart';
import 'package:linkschool/config/env_config.dart';

class GameService {
  final String _baseUrl = "https://linkskool.net/api/v3/public/games";

  Future<Games?> fetchGames() async {
    try {
      // Load API key from .env file
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      print("🕹️ Fetching games from $_baseUrl...");

      final response = await http.get(
        Uri.parse("https://linkskool.net/api/v3/public/games"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey, // ✅ Include your API key
        },
      );

      if (response.statusCode == 200) {
        print("✅ Games fetched successfully!");
        print("Response: ${response.body}");

        final decoded = json.decode(response.body);

        // If the API returns a JSON object directly
        if (decoded is Map<String, dynamic>) {
          return Games.fromJson(decoded);
        }

        // If the API returns a list of games (rare, but check API response)
        if (decoded is List && decoded.isNotEmpty) {
          return Games.fromJson(decoded.first);
        }

        throw Exception("Unexpected response format: $decoded");
      } else {
        print("❌ Failed to load games: ${response.statusCode}");
        print("Response: ${response.body}");
        throw Exception("Failed to load games: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching games: $e");
      throw Exception("Error fetching games: $e");
    }
  }
}
