import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/services/explore/home/news_service.dart';
import 'package:linkschool/modules/services/network/connectivity_service.dart';

class NewsProvider with ChangeNotifier {
  List<NewsModel> _newsmodel = [];
  Map<String, List<int>> _groups = {};
  Map<String, List<int>> _categories = {};
  List<int> _latestIds = [];
  NewsMetaData? _meta;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasNextPage = true;
  static const int _pageSize = 10;
  final Set<int> _newsIds = {};

  List<NewsModel> get newsmodel => _newsmodel;
  Map<String, List<int>> get groups => _groups;
  Map<String, List<int>> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;
  NewsMetaData? get meta => _meta;

  // Get news by group
  List<NewsModel> get latestNews {
    final latestIds = _latestIds.isNotEmpty ? _latestIds : (_groups['latest'] ?? []);
    return _newsmodel.where((news) => latestIds.contains(news.id)).toList();
  }

  List<NewsModel> get relatedNews {
    final relatedIds = _groups['related'] ?? [];
    return _newsmodel.where((news) => relatedIds.contains(news.id)).toList();
  }

  List<NewsModel> get recommendedNews {
    final recommendedIds = _groups['recommended'] ?? [];
    return _newsmodel.where((news) => recommendedIds.contains(news.id)).toList();
  }

  // Get news by category
  List<NewsModel> getNewsByCategory(String category) {
    final categoryIds = _categories[category] ?? [];
    return _newsmodel.where((news) => categoryIds.contains(news.id)).toList();
  }

  // Get category name for a specific news item
  String? getCategoryForNews(int newsId) {
    for (var entry in _categories.entries) {
      if (entry.value.contains(newsId)) {
        return entry.key;
      }
    }
    return null;
  }

  // Get all available categories
  List<String> get availableCategories => _categories.keys.toList();

  final NewsService _newsService = NewsService();

  Future<void> fetchNews({bool refresh = true}) async {
    if (_isLoading || _isLoadingMore) return;

    final isOnline = await ConnectivityService.isOnline();

    if (refresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _newsmodel.clear();
      _groups.clear();
      _categories.clear();
      _latestIds.clear();
      _newsIds.clear();
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }

    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _newsService.getAllNews(
        page: _currentPage,
        perPage: _pageSize,
        allowNetwork: isOnline,
      );

      // Merge news items by id (avoid duplicates)
      for (final item in response.news) {
        if (_newsIds.add(item.id)) {
          _newsmodel.add(item);
        }
      }

      // Merge groups
      response.groups.forEach((key, ids) {
        final existing = _groups.putIfAbsent(key, () => []);
        for (final id in ids) {
          if (!existing.contains(id)) {
            existing.add(id);
          }
        }
      });
      if (refresh) {
        _latestIds = List<int>.from(response.groups['latest'] ?? const []);
      }

      // Merge categories
      response.categories.forEach((key, ids) {
        final existing = _categories.putIfAbsent(key, () => []);
        for (final id in ids) {
          if (!existing.contains(id)) {
            existing.add(id);
          }
        }
      });

      _meta = response.meta;
      _hasNextPage = response.meta.hasNext;
      _currentPage = response.meta.currentPage + 1;

      if (!isOnline) {
        _errorMessage = 'You are offline. Showing saved news.';
      }

      // Log the fetched news for debugging
      print('✅ Fetched ${response.news.length} news items (page ${response.meta.currentPage})');
      print('📊 Groups: ${_groups.keys.join(", ")}');
      print('🏷️ Categories: ${_categories.keys.join(", ")}');
    } catch (e) {
      _errorMessage = isOnline
          ? 'Network error. Please try again.'
          : 'No internet connection. Connect and try again.';
      print('❌ Error in NewsProvider: $_errorMessage');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasNextPage) return;
    await fetchNews(refresh: false);
  }
}
