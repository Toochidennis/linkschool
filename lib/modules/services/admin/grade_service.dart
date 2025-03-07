import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../model/admin/grade _model.dart';

class GradeService {
  final String baseUrl = 'http://linkskool.com/developmentportal/api';

  Future<List<Grade>> getGrades() async {
    final response = await http.get(
      Uri.parse('$baseUrl/grades.php'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // print(response.body);
      if (data['status'] == "success") {
        List<dynamic> gradesJson = data['grades'];
        print("hiiiiiiiii $gradesJson");
        return gradesJson.map((json) => Grade.fromJson(json)).toList();
      } else {
        throw Exception('API returned error: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load grades: ${response.statusCode}');
    }
  }

  // POST to add a grade
  Future<void> addGrade(String gradeSymbol, String start, String remark) async {
    final Map<String, String> requestBody = {
      'grade_symbol': gradeSymbol,
      'start': start,
      'remark': remark,
      '_db': 'linkskoo_practice',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/grades.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] != 'success') {
        throw Exception('Failed to add grade: ${data['message']}');
      }
    } else {
      throw Exception('Failed to add grade: ${response.statusCode}');
    }
  }
}







// import 'package:linkschool/modules/model/admin/grade_model.dart';

// class GradeService {
//   final String baseUrl = 'http://linkskool.com/developmentportal/api/addGrade.php';

//   Future<List<Grade>> getGrades() async {
//     final response = await http.get(Uri.parse(baseUrl));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> gradesJson = data['grades'];
//       return gradesJson.map((json) => Grade.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load grades');
//     }
//   }

//   Future<void> addGrade(String gradeSymbol, String start, String remark) async {
//     final Uri uri = Uri.parse('$baseUrl?grade_symbol=$gradeSymbol&start=$start&remark=$remark&_db=linkskoo_practice');
//     final response = await http.get(uri);

//     if (response.statusCode != 200) {
//       throw Exception('Failed to add grade');
//     }
//   }
// }


