import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../model/explore/home/book_model.dart';
import '../../model/explore/home/game_model.dart';
import '../../model/explore/home/video_model.dart';

class ForYouService {
  static const String baseUrl = 'https://linkskool.net/api/v3/public/for-you';

  Future<Map<String, dynamic>> fetchForYouData() async {
    try {
      // ✅ Load API key from .env
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("❌ API key not found in .env file");
      }

      print('🌐 Making request to: $baseUrl');

      final response = await http
          .get(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-API-KEY': apiKey, // ✅ Attach API key
            },
          )
          .timeout(const Duration(seconds: 15)); // Optional safety timeout

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Data fetched successfully!');
        print('$data !');
        return data;
      } else {
        print('🚨 Error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load For You data');
      }
    } catch (e) {
      print('💥 Service error: $e');
      throw Exception('Error fetching For You data: $e');
    }
  }

List<Game> parseGames(Map<String, dynamic> data) {
  final gamesData = data['data']?['games'];
  if (gamesData == null) return [];

  List<Game> games = [];
  gamesData.forEach((category, categoryData) {
    final categoryGames = categoryData['games'] as List?;
    if (categoryGames != null) {
      games.addAll(categoryGames.map((g) => Game.fromJson(g)).toList());
    }
  });
  return games;
}


List<Book> parseBooks(Map<String, dynamic> data) {
  final booksData = data['data']?['books']?['books'];
  if (booksData == null) return [];

  return (booksData as List)
      .map((book) => Book.fromJson(book))
      .toList();
}


List<Video> parseVideos(Map<String, dynamic> data) {
  final videosData = data['data']?['videos'];
  if (videosData == null) return [];

  List<Video> videos = [];
  for (var subject in videosData) {
    final categories = subject['category'] as List?;
    if (categories != null) {
      for (var sub in categories) {
        final videoList = sub['videos'] as List?;
        if (videoList != null) {
          videos.addAll(videoList.map((v) => Video.fromJson(v)).toList());
        }
      }
    }
  }
  return videos;
}

}
