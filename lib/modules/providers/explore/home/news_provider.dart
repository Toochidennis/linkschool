import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/services/explore/home/news_service.dart';
import 'package:linkschool/modules/services/network/connectivity_service.dart';

class NewsProvider with ChangeNotifier {
  // All news state (used by All News screen)
  final List<NewsModel> _newsmodel = [];
  final Map<String, List<int>> _groups = {};
  final Map<String, List<int>> _categories = {};
  NewsMetaData? _meta;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  final Set<int> _newsIds = {};

  // Latest news state (used by Explore Home)
  final List<NewsModel> _latestNews = [];
  final Set<int> _latestNewsIds = {};
  NewsMetaData? _metaLatest;
  bool _isLoadingLatest = false;
  bool _isLoadingMoreLatest = false;
  int _currentPageLatest = 1;
  bool _hasNextPageLatest = true;

  static const int _pageSize = 10;
  String _errorMessage = '';

  List<NewsModel> get newsmodel => _newsmodel;
  Map<String, List<int>> get groups => _groups;
  Map<String, List<int>> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingLatest => _isLoadingLatest;
  bool get isLoadingMoreLatest => _isLoadingMoreLatest;
  String get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;
  bool get hasNextPageLatest => _hasNextPageLatest;
  NewsMetaData? get meta => _meta;
  NewsMetaData? get metaLatest => _metaLatest;

  // Latest list used by Explore Home
  List<NewsModel> get latestNews => _latestNews;

  // Get news by group (all-news stream)
  List<NewsModel> get relatedNews {
    final relatedIds = _groups['related'] ?? [];
    return _newsmodel.where((news) => relatedIds.contains(news.id)).toList();
  }

  List<NewsModel> get recommendedNews {
    final recommendedIds = _groups['recommended'] ?? [];
    return _newsmodel.where((news) => recommendedIds.contains(news.id)).toList();
  }

  // Get news by category (all-news stream)
  List<NewsModel> getNewsByCategory(String category) {
    final categoryIds = _categories[category] ?? [];
    return _newsmodel.where((news) => categoryIds.contains(news.id)).toList();
  }

  // Get category name for a specific news item (all-news stream)
  String? getCategoryForNews(int newsId) {
    for (var entry in _categories.entries) {
      if (entry.value.contains(newsId)) {
        return entry.key;
      }
    }
    return null;
  }

  // Get all available categories (all-news stream)
  List<String> get availableCategories => _categories.keys.toList();

  final NewsService _newsService = NewsService();

  Future<void> fetchAllNews({bool refresh = true}) async {
    if (_isLoading || _isLoadingMore) return;

    final isOnline = await ConnectivityService.isOnline();

    if (refresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _newsmodel.clear();
      _groups.clear();
      _categories.clear();
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

  Future<void> fetchLatestNews({bool refresh = true}) async {
    if (_isLoadingLatest || _isLoadingMoreLatest) return;

    final isOnline = await ConnectivityService.isOnline();

    if (refresh) {
      _currentPageLatest = 1;
      _hasNextPageLatest = true;
      _latestNews.clear();
      _latestNewsIds.clear();
      _isLoadingLatest = true;
    } else {
      _isLoadingMoreLatest = true;
    }

    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _newsService.getAllNews(
        page: _currentPageLatest,
        perPage: _pageSize,
        allowNetwork: isOnline,
      );

      final latestIds = response.groups['latest'] ?? const [];
      final Map<int, NewsModel> newsById = {
        for (final item in response.news) item.id: item
      };

      for (final id in latestIds) {
        final item = newsById[id];
        if (item != null && _latestNewsIds.add(id)) {
          _latestNews.add(item);
        }
      }

      _metaLatest = response.meta;
      _hasNextPageLatest = response.meta.hasNext;
      _currentPageLatest = response.meta.currentPage + 1;

      if (!isOnline) {
        _errorMessage = 'You are offline. Showing saved news.';
      }

      print('✅ Fetched ${latestIds.length} latest ids (page ${response.meta.currentPage})');
    } catch (e) {
      _errorMessage = isOnline
          ? 'Network error. Please try again.'
          : 'No internet connection. Connect and try again.';
      print('❌ Error in NewsProvider (latest): $_errorMessage');
    } finally {
      _isLoadingLatest = false;
      _isLoadingMoreLatest = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreAll() async {
    if (_isLoading || _isLoadingMore || !_hasNextPage) return;
    await fetchAllNews(refresh: false);
  }

  Future<void> loadMoreLatest() async {
    if (_isLoadingLatest || _isLoadingMoreLatest || !_hasNextPageLatest) return;
    await fetchLatestNews(refresh: false);
  }

  // Backward compatibility
  Future<void> fetchNews({bool refresh = true}) async {
    await fetchAllNews(refresh: refresh);
  }

  Future<void> loadMore() async {
    await loadMoreAll();
  }
}
