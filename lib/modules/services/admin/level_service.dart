import 'package:linkschool/modules/model/admin/level_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';


class LevelService {
  final ApiService _apiService = locator<ApiService>();

  Future<List<Level>> fetchLevels() async {
    try {
      final response = await _apiService.get(
        endpoint: 'getLevel.php',
        queryParams: {'_db': 'linkskoo_practice'},
      );

      if (response.success) {
        final List<dynamic> levelsJson = response.rawData?['levels'] ?? [];
        return levelsJson.map((json) => Level.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load levels: ${response.message}');
      }
    } catch (e) {
      throw Exception('Failed to load levels: $e');
    }
  }
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:linkschool/modules/model/admin/level_model.dart';
// // import '../models/level_model.dart';



// class LevelService {
//   Future<List<Level>> fetchLevels() async {
//     final response = await http.get(
//       Uri.parse('https://linkskool.com/developmentportal/api/getLevel.php?_db=linkskoo_practice'),
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> levelsJson = data['levels'];
//       return levelsJson.map((json) => Level.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load levels');
//     }
//   }
// }



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:linkschool/modules/model/admin/level_model.dart';
// // import '../models/level_model.dart';



// class LevelService {
//   Future<List<Level>> fetchLevels() async {
//     final response = await http.get(
//       Uri.parse('https://linkskool.com/developmentportal/api/getLevel.php?_db=linkskoo_practice'),
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> levelsJson = data['levels'];
//       return levelsJson.map((json) => Level.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load levels');
//     }
//   }
// }