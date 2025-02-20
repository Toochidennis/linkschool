import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';

class NewsService {
  // Base URL setup based on whether it's web or mobile
  final String _baseUrl = kIsWeb
      ? 'https://cors-anywhere.herokuapp.com/http://www.cbtportal.linkskool.com/api/linkfeed.php'
      : 'http://www.cbtportal.linkskool.com/api/linkfeed.php';

  // Fetching all news data from the API
  Future<List<NewsModel>> getAllNews() async {
    try {
      // Sending the HTTP GET request
      final response = await http.get(Uri.parse(_baseUrl),
          headers: {'Content-Type': 'application/json'});

      // If response is successful (HTTP 200)
      if (response.statusCode == 200) {
        print('API Response: ${response.body}');

        // Decode the JSON response body
        final List<dynamic> jsonData = json.decode(response.body);

        // Ensure that we return a list of NewsModel objects
        return jsonData.map((item) => NewsModel.fromJson(item)).toList();
      } else {
        // If the server responds with an error code, throw an exception
        throw Exception('Error: Server responded with ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors (e.g., network issues, JSON parsing issues)
      print('Error: $e');
      throw Exception('Error fetching News: $e');
    }
  }
}


// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:linkschool/modules/model/explore/home/news/news_model.dart';

// class NewsService {
//   // final String _baseUrl = 'https://cors-anywhere.herokuapp.com/http://linkskool.com/developmentportal/api/allNews.php';
//   final String _baseUrl = kIsWeb
//       ? 'https://cors-anywhere.herokuapp.com/http://www.cbtportal.linkskool.com/api/linkfeed.php'
//       : 'http://www.cbtportal.linkskool.com/api/linkfeed.php';

//   Future<List<NewsModel>> getAllNews() async {
//     try {
//       final response = await http.get(Uri.parse(_baseUrl),
//           headers: {'Content-Type': 'application/json'});

//       if (response.statusCode == 200) {
//         print('API Response: ${response.body}');
//         // return NewsModel.fromJson(jsonDecode(response.body));
//         // Map<String, dynamic> data = json.decode(response.body);
//         // List<dynamic> rows = data['allNews']['rows'];

//         // print('Rows: $rows');
//         final List<dynamic> jsonData = jsonDecode(response.body);
//         return jsonData.map((item) => NewsModel.fromJson(item)).toList();
//       } else {
//         throw Exception('Error: Server responded with ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//       throw Exception('Error fetching News: $e');
//     }
//   }
// }



// // import 'dart:convert';

// // import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
// // import 'package:http/http.dart' as http;

// // class NewsService {
// //   final String _baseUrl =
// //       'http://linkskool.com/developmentportal/api/allNews.php';

// //   Future<List<NewsModel>> getAllNews() async {
// //     try {
// //       final response = await http.get(Uri.parse('$_baseUrl'),
// //           headers: {'Content-Type': 'application/json'});

// //       if (response.statusCode == 200) {
// //         print(response.body);
// //         List<dynamic> data = json.decode(response.body);
// //         return data.map((json) => NewsModel.fromJson(json)).toList();
// //       } else {
// //         throw Exception('Error: Server responded with ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       print('Error: $e');
// //       throw Exception('Error fetching News: $e');
// //     }
// //   }
// // }