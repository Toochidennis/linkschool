import 'dart:convert';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/services/explore/cache/explore_dashboard_cache.dart';

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
      perPage: json['per_page'] ?? 10,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}

class NewsService {
  final String baseUrl = "https://linkskool.net/api/v3/public/news";

  NewsResponse _parseResponse(Map<String, dynamic> dataWrapper) {
    return NewsResponse.fromJson(dataWrapper);
  }

  Future<NewsResponse> _loadCachedOrThrow() async {
    final cached = await ExploreDashboardCache.load('explore_home:news');
    if (cached?.data is Map<String, dynamic>) {
      return _parseResponse(Map<String, dynamic>.from(cached!.data));
    }
    throw Exception('No cached news available');
  }

  Future<NewsResponse> getAllNews({
    int page = 1,
    int perPage = 10,
    bool allowNetwork = true,
  }) async {
    if (!allowNetwork) {
      return _loadCachedOrThrow();
    }
    try {
      final apiKey = EnvConfig.apiKey;
      if (apiKey.isEmpty) {
        throw Exception("API key not found in .env file");
      }

      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': perPage.toString(),
        },
      );

      final response = await http.get(
        uri,
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
        await ExploreDashboardCache.save('explore_home:news', dataWrapper);
        return _parseResponse(Map<String, dynamic>.from(dataWrapper));
      } else {
        print("❌ Failed to load news: ${response.statusCode} ${response.body}");
        throw Exception("Failed to load news: ${response.statusCode}");
      }
    } catch (e) {
      try {
        return await _loadCachedOrThrow();
      } catch (_) {
        print("❌ Error fetching news: $e");
        throw Exception("Failed to load news: $e");
      }
    }
  }
}
