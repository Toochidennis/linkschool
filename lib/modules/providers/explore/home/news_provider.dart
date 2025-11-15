import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/services/explore/home/news_service.dart';

class NewsProvider with ChangeNotifier {
  List<NewsModel> _newsmodel = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<NewsModel> get newsmodel => _newsmodel;
  List<NewsModel> get latestNews => _newsmodel.where((news) => news.group == 'latest').toList();
  List<NewsModel> get relatedNews => _newsmodel.where((news) => news.group == 'related').toList();
  List<NewsModel> get recommendedNews => _newsmodel.where((news) => news.group == 'recommended').toList();
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final NewsService _newsService = NewsService();

  void fetchNews() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _newsmodel = await _newsService.getAllNews();
      // Log the fetched news for debugging
      print('Fetched News: $_newsmodel');
    } catch (e) {
      _errorMessage = 'Error fetching News: $e';
      // Log the error for debugging
      print('Error in NewsProvider: $_errorMessage');
      // debugPrint('Error fetching News: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
