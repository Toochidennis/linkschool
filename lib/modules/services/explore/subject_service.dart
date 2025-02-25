import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/explore/games/game_model.dart';
 

class SubjectService {
   final String _baseUrl = kIsWeb
 ? 'https://cors-anywhere.herokuapp.com/http://www.cbtportal.linkskool.com/api/getVideo.php'
      : 'http://www.cbtportal.linkskool.com/api/getVideo.php';
  
  Future<Games?> fetchSubject() async {
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
  }

  getAllSubjects() {}
}





