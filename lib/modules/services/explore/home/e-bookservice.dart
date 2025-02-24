// BookService.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/home/news/e_book_model.dart';

class BookService {
  final String _baseUrl = kIsWeb
      ? 'https://cors-anywhere.herokuapp.com/http://cbtportal.linkskool.com/api/getBooks.php'
      : 'http://cbtportal.linkskool.com/api/getBooks.php';
  Future<List<BookModel>> getBooks() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['booksmodel'];
        return data.map((bookmodel) => BookModel.fromJson(bookmodel)).toList();
      } else {
        throw Exception("Failed to load books");
      }
    } catch (e) {
      throw Exception("Error:$e");
    }
  }
}

  //   if (response.statusCode == 200) {
  //     // Parse the JSON response
  //     final Map<String, dynamic> json = jsonDecode(response.body);
  //     return BookResponse.fromJson(json);
  //   } else {
  //     throw Exception('Failed to load books');
  //   }
  // }
  // }