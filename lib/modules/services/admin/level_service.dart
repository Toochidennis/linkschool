import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/admin/level_model.dart';
// import '../models/level_model.dart';



class LevelService {
  Future<List<Level>> fetchLevels() async {
    final response = await http.get(
      Uri.parse('https://linkskool.com/developmentportal/api/getLevel.php?_db=linkskoo_practice'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> levelsJson = data['levels'];
      return levelsJson.map((json) => Level.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load levels');
    }
  }
}



// class LevelService {
//   Future<List<Level>> fetchLevels() async {
//     final response = await http.get(Uri.parse('https://linkskool.com/developmentportal/api/getLevel.php?_db=linkskoo_practice'));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       print('API Response: $data'); // Log the API response
//       final List<dynamic> levelsJson = data['levels'];
//       return levelsJson.map((json) => Level.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load levels');
//     }
//   }
// }