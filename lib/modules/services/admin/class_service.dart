import 'package:linkschool/modules/model/admin/class_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';


class ClassService {
  final ApiService _apiService = locator<ApiService>();

  Future<List<Class>> fetchClasses(String levelId) async {
    try {
      final response = await _apiService.get(
        endpoint: 'getClass.php',
        queryParams: {'level_id': levelId},
      );

      if (response.success) {
        final List<dynamic> classesJson = response.rawData?['data'] ?? [];
        return classesJson.map((json) => Class.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load classes: ${response.message}');
      }
    } catch (e) {
      throw Exception('Failed to load classes: $e');
    }
  }
}
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:linkschool/modules/model/admin/class_model.dart';


// class ClassService {
//   Future<List<Class>> fetchClasses(String levelId) async {
//     final response = await http.get(Uri.parse('https://linkskool.com/developmentportal/api/getClass.php?level_id=$levelId'));

//     if (response.statusCode == 200) {
//       final List<dynamic> classesJson = json.decode(response.body);
//       return classesJson.map((json) => Class.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load classes');
//     }
//   }
// }