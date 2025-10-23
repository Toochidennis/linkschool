import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/explore/home/news/ebook_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class EbookService {
  final ApiService _apiService;
  EbookService(this._apiService);
Future<Map<String, dynamic>> fetchBooks() async {
  try {
    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint: 'public/books',
    );

    if (response.statusCode == 200) {
      print("Ebooks fetched successfully");
      print(response);
      // Remove the ['response'] accessor since the data is at the root level
      return response.rawData ?? {};
    }

    throw Exception("Failed to load ebooks: ${response.message}");
  } catch (e) {
    print("Error fetching ebooks: $e");
    throw Exception("Failed to load ebooks: $e");
  }
}
  Future<List<Ebook>> getEbooks() async {
    final data = await fetchBooks();
    final List<dynamic> booksJson = data['books'] ?? [];
    return booksJson.map((json) => Ebook.fromJson(json)).toList();
  }

  Future<List<String>> getCategories() async {
    final data = await fetchBooks();
    return List<String>.from(data['categories'] ?? []);
  }
}