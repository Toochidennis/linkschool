import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/home/news/ebook_model.dart';

class EbookService {
  final String _baseUrl = kIsWeb
      ? 'https://cors-anywhere.herokuapp.com/http://cbtportal.linkskool.com/api/getBooks.php'
      : 'http://cbtportal.linkskool.com/api/getBooks.php';

  // EbookService({required this._baseUrl});

  Future<Map<String, dynamic>> fetchBooks() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<List<Ebook>> getEbooks() async {
    final data = await fetchBooks();
    final List<dynamic> booksJson = data['books'];
    return booksJson.map((json) => Ebook.fromJson(json)).toList();
  }

  Future<List<String>> getCategories() async {
    final data = await fetchBooks();
    return List<String>.from(data['categories']);
  }
}
