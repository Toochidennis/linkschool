import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../model/explore/home/cbt_board_model.dart';
import 'package:http/http.dart' as http;

class CBTService {
  final String _baseUrl = kIsWeb
      ? 'https://cors-anywhere.herokuapp.com/http://www.cbtportal.linkskool.com/api/get_course.php?json'
      : 'http://www.cbtportal.linkskool.com/api/get_course.php?json';

  Future<List<CBTBoardModel>> fetchCBTBoards() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('Fetched data: $jsonData'); // Log the fetched data
        return jsonData.map((board) {
          try {
            return CBTBoardModel.fromJson(board);
          } catch (e) {
            print('Error parsing board: $e');
            return null;
          }
        }).whereType<CBTBoardModel>().toList();
      } else {
        throw Exception('Failed to load CBT boards: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching CBT boards: $e'); // Log the error
      throw Exception('Error fetching CBT boards: $e');
    }
  }
}




// import 'dart:convert';

// import 'package:flutter/foundation.dart';

// import '../../model/explore/home/cbt_board_model.dart';
// import 'package:http/http.dart' as http;

// class CBTService {
//   final String _baseUrl = kIsWeb
//       ? 'https://cors-anywhere.herokuapp.com/http://www.cbtportal.linkskool.com/api/get_course.php?json'
//       : 'http://www.cbtportal.linkskool.com/api/get_course.php?json';

//   Future<List<CBTBoardModel>> fetchCBTBoards() async {
//     try {
//       final response = await http.get(Uri.parse(_baseUrl));


//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         print('Fetched data: $jsonData'); // Log the fetched data
//         return jsonData
//             .map((board) => CBTBoardModel.fromJson(board))
//             .where((board) => board.boardCode.isNotEmpty)
//             .toList();
//       } else {
//                 throw Exception('Failed to load CBT boards: ${response.statusCode}');
//       }
//     } catch (e) {
//             print('Error fetching CBT boards: $e'); // Log the error
//       throw Exception('Error fetching CBT boards: $e');
//     }
//   }
// }