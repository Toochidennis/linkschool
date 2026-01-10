import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/services/explore/home/news_service.dart';

class NewsProvider with ChangeNotifier {
  List<NewsModel> _newsmodel = [];
  Map<String, List<int>> _groups = {};
  Map<String, List<int>> _categories = {};
  NewsMetaData? _meta;
  bool _isLoading = false;
  String _errorMessage = '';

  List<NewsModel> get newsmodel => _newsmodel;
  Map<String, List<int>> get groups => _groups;
  Map<String, List<int>> get categories => _categories;
  NewsMetaData? get meta => _meta;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Get news by group
  List<NewsModel> get latestNews {
    final latestIds = _groups['latest'] ?? [];
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

  void fetchNews() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final response = await _newsService.getAllNews();
      _newsmodel = response.news;
      _groups = response.groups;
      _categories = response.categories;
      _meta = response.meta;
      
      // Log the fetched news for debugging
      print('✅ Fetched ${_newsmodel.length} news items');
      print('📊 Groups: ${_groups.keys.join(", ")}');
      print('🏷️ Categories: ${_categories.keys.join(", ")}');
    } catch (e) {
      _errorMessage = 'Error fetching News: $e';
      // Log the error for debugging
      print('❌ Error in NewsProvider: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
