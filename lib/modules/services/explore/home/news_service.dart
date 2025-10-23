import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:http/http.dart' as http;

class NewsService {
  final String baseUrl = "https://linkskool.net/api/v3/public/news";

  Future<List<NewsModel>> getAllNews() async {
    try {
      // Get API key from .env
      final apiKey = dotenv.env['API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API key not found in .env file");
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey, // 👈 API key loaded from .env
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print("✅ News fetched successfully (${jsonData.length} items)");
        return jsonData.map((item) => NewsModel.fromJson(item)).toList();
      } else {
        print("❌ Failed to load news: ${response.statusCode} ${response.body}");
        throw Exception("Failed to load news: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching news: $e");
      throw Exception("Failed to load news: $e");
    }
  }
}
