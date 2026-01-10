import 'dart:convert';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';

class NewsResponse {
  final Map<String, List<int>> groups;
  final Map<String, List<int>> categories;
  final List<NewsModel> news;
  final NewsMetaData meta;

  NewsResponse({
    required this.groups,
    required this.categories,
    required this.news,
    required this.meta,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final dataSection = json['data'] ?? {};

    return NewsResponse(
      groups: (dataSection['groups'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<int>.from(value ?? [])),
          ) ??
          {},
      categories: (dataSection['categories'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<int>.from(value ?? [])),
          ) ??
          {},
      news: (dataSection['news'] as List<dynamic>?)
              ?.map((item) => NewsModel.fromJson(item))
              .toList() ??
          [],
      meta: NewsMetaData.fromJson(json['meta'] ?? {}),
    );
  }
}

class NewsMetaData {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final bool hasNext;
  final bool hasPrev;

  NewsMetaData({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory NewsMetaData.fromJson(Map<String, dynamic> json) {
    return NewsMetaData(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 25,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}

class NewsService {
  final String baseUrl = "https://linkskool.net/api/v3/public/news";

  Future<NewsResponse> getAllNews() async {
    try {
      final apiKey = EnvConfig.apiKey;
      if (apiKey.isEmpty) {
        throw Exception("API key not found in .env file");
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-KEY': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Check if API call was successful
        if (jsonData['success'] != true) {
          throw Exception(jsonData['message'] ?? 'Failed to load news');
        }

        // Extract the nested data structure
        final dataWrapper = jsonData['data'] ?? {};

        print("✅ News fetched successfully: ${jsonData['message']}");
        return NewsResponse.fromJson(dataWrapper);
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
