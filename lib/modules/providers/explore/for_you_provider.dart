import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/explore/home/game_model.dart';
import 'package:linkschool/modules/services/explore/for_you_service.dart';

import '../../model/explore/home/book_model.dart';
import '../../model/explore/home/video_model.dart';


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
