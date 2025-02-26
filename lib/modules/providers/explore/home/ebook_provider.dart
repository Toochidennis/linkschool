import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/news/ebook_model.dart';
import 'package:linkschool/modules/services/explore/home/ebook_service.dart';
// import 'ebook_model.dart';
// import 'ebook_service.dart';

class EbookProvider with ChangeNotifier {
  final EbookService _ebookService;
  List<Ebook> _ebooks = [];
  List<String> _categories = [];
  bool _isLoading = false;

  EbookProvider({required EbookService ebookService})
      : _ebookService = ebookService;

  List<Ebook> get ebooks => _ebooks;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _ebooks = await _ebookService.getEbooks();
      _categories = await _ebookService.getCategories();
    } catch (e) {
      // Handle error (e.g., show a snackbar or log the error)
      print('Error fetching books: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
