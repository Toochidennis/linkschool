import 'dart:convert';
import 'package:http/http.dart' as http;


import '../../model/explore/home/book_model.dart';
import '../../model/explore/home/game_model.dart';
import '../../model/explore/home/video_model.dart';


class ForYouService {
  static const String baseUrl = 'http://www.public.linkskool.com/api/forYou.php';

  Future<Map<String, dynamic>> fetchForYouData() async {
    final response = await http.get(Uri.parse('$baseUrl/forYou.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<Game> parseGames(Map<String, dynamic> data) {
    List<Game> games = [];
    data['games'].forEach((category, categoryData) {
      games.addAll(BoardGamesClass.fromJson(categoryData).games);
    });
    return games;
  }

  List<Video> parseVideos(Map<String, dynamic> data) {
    List<Video> videos = [];
    data['videos'].forEach((category) {
      category['category'].forEach((subCategory) {
        videos.addAll(subCategory['videos'].map<Video>((video) => Video.fromJson(video)).toList());
      });
    });
    return videos;
  }

  List<Book> parseBooks(Map<String, dynamic> data) {
    return (data['books'] as List).map((book) => Book.fromJson(book)).toList();
  }
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ForYouService {
//  static const String baseUrl = 'http://www.cbtportal.linkskool.com/api';

//   // ForYouService({required this.baseUrl});

//   Future<Map<String, dynamic>> fetchForYouData() async {
//     final response = await http.get(Uri.parse('$baseUrl/forYou.php'));

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
// }