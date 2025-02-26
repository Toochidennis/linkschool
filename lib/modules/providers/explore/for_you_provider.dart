import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/explore/home/game_model.dart';
import 'package:linkschool/modules/services/explore/for_you_service.dart';

import '../../model/explore/home/book_model.dart';
import '../../model/explore/home/video_model.dart';
// import '../services/api_service.dart';
// import '../models/game_model.dart';
// import '../models/video_model.dart';
// import '../models/book_model.dart';

class ForYouProvider with ChangeNotifier {
  final ForYouService _apiService = ForYouService();
  List<Game> _games = [];
  List<Video> _videos = [];
  List<Book> _books = [];
  bool _isLoading = false;

  List<Game> get games => _games;
  List<Video> get videos => _videos;
  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  Future<void> fetchForYouData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.fetchForYouData();
      _games = _apiService.parseGames(data);
      _videos = _apiService.parseVideos(data);
      _books = _apiService.parseBooks(data);
    } catch (e) {
      print('Error fetching data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/model/explore/home/game_model.dart';

// import '../../model/explore/home/book_model.dart';
// import '../../model/explore/home/video_model.dart';
// import '../../services/explore/for_you_service.dart';
// // import '../models/game_model.dart';
// // import '../models/video_model.dart';
// // import '../models/book_model.dart';
// // import '../services/for_you_service.dart';

// class ForYouProvider with ChangeNotifier {
//   final ForYouService _forYouService;

//   List<Game> _games = [];
//   List<Video> _videos = [];
//   List<Book> _books = [];

//   ForYouProvider({required ForYouService forYouService})
//       : _forYouService = forYouService;

//   List<Game> get games => _games;
//   List<Video> get videos => _videos;
//   List<Book> get books => _books;

//   Future<void> fetchForYouData() async {
//     try {
//       final data = await _forYouService.fetchForYouData();

//       _games = (data['games'] as Map<String, dynamic>)
//           .values
//           .expand((category) => (category['games'] as List)
//               .map((game) => Game.fromJson(game))
//               .toList())
//           .toList();

//       _videos = (data['videos'] as List)
//           .expand((category) => (category['category'] as List)
//               .expand((level) => (level['videos'] as List)
//                   .map((video) => Video.fromJson(video))
//                   .toList())
//               .toList())
//           .toList();

//       _books = (data['books'] as List)
//           .map((book) => Book.fromJson(book))
//           .toList();

//       notifyListeners();
//     } catch (e) {
//       throw Exception('Failed to fetch data: $e');
//     }
//   }
// }