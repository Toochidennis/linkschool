import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/explore/home/book_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class BookService {
  final ApiService _apiService;
  BookService(this._apiService);

  Future<Map<String, dynamic>> fetchBooks() async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'public/books',
        queryParams: {
          '_db': dbName,
        },
      );

      if (response.statusCode == 200) {
        print("Books fetched successfully");
        return response.rawData?['response'] ?? {};
      }

      throw Exception("Failed to load books: ${response.message}");
    } catch (e) {
      print("Error fetching books: $e");
      throw Exception("Failed to load books: $e");
    }
  }

  Future<List<Book>> getEbooks() async {
    final data = await fetchBooks();
    final List<dynamic> booksJson = data['books'] ?? [];
    return booksJson.map((json) => Book.fromJson(json)).toList();
  }

  Future<List<String>> getCategories() async {
    final data = await fetchBooks();
    return List<String>.from(data['categories'] ?? []);
  }
}