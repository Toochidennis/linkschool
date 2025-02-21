import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/explore/games/game_model.dart';
import 'package:linkschool/modules/services/explore/game/games_services.dart';


class GameProvider with ChangeNotifier {
  final GameService _gameService = GameService();
  Games? _games;
  bool _isLoading = false;

  Games? get games => _games;
  bool get isLoading => _isLoading;

  /// Fetch games from the API and update state
  Future<void> fetchGames() async {
    _isLoading = true;
    notifyListeners();

    _games = await _gameService.fetchGames();

    _isLoading = false;
    notifyListeners();
  }
}
