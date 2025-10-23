import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/book_model.dart';
import 'package:linkschool/modules/services/explore/ebook_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _ebookService;
  List<Book> _ebooks = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  BookProvider({required BookService ebookService})
      : _ebookService = ebookService;

  List<Book> get ebooks => _ebooks;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ebooks = await _ebookService.getEbooks();
      _categories = await _ebookService.getCategories();
    } catch (e) {
      _errorMessage = 'Failed to load books: $e';
      print('Error fetching books: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Optional: Clear error method
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}