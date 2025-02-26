import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/games/game_model.dart';
 // Ensure the path is correct

class GameService {
   final String _baseUrl = kIsWeb
 ? 'https://cors-anywhere.herokuapp.com/http://www.cbtportal.linkskool.com/api/getGame.php'
      : 'http://www.cbtportal.linkskool.com/api/getGame.php';
  
  Future<Games?> fetchGames() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = json.decode(response.body);
        return Games.fromJson(data);
      } else {
        print("Failed to load games. Status Code: ${response.statusCode}");
     
      }
    } catch (e) {
      print("Error fetching games: $e");

    }
    return null;
  }
}





