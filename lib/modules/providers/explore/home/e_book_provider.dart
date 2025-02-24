import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/explore/home/news/e_book_model.dart'; // Adjust the import path
import 'package:linkschool/modules/services/explore/home/e-bookservice.dart'; // Adjust the import path

class BookProvider with ChangeNotifier {
  List<BookModel> _books = [];
  Set<String> _categories = {};
  bool _isLoading = false;
  String? _errorMessage = '';
  int _selectedCategoryIndex = 0; // Track the selected category index

  List<BookModel> get books => _books;
  bool get isLoading => _isLoading;
  Set<String> get categories => _categories;
  String? get errorMessage => _errorMessage;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  final BookService _bookService = BookService();

  // Fetch books and categories from the service
  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _books = await _bookService.getBooks();
      _categories = _extractCategories(_books);
    } catch (e) {
      _errorMessage = 'Failed to load books: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Extract unique categories from books
  Set<String> _extractCategories(List<BookModel> books) {
    return books.expand((book) => book.categories).toSet();
  }

  // Update the selected category index
  void updateSelectedCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  // Get books filtered by the selected category
  List<BookModel> getBooksByCategory(int categoryIndex) {
    if (categoryIndex == 0) {
      // If "All" is selected, return all books
      return _books;
    } else {
      // Filter books by the selected category
      final selectedCategory =
          _categories.elementAt(categoryIndex - 1); // Adjust index for "All"
      return _books
          .where((book) => book.categories.contains(selectedCategory))
          .toList();
    }
  }
}
