import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/admin/grade_model.dart';

class GradeService {
  final String baseUrl = 'http://linkskool.com/developmentportal/api/addGrade.php';

  Future<List<Grade>> getGrades() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> gradesJson = data['grades'];
      return gradesJson.map((json) => Grade.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load grades');
    }
  }

  Future<void> addGrade(String gradeSymbol, String start, String remark) async {
    final Uri uri = Uri.parse('$baseUrl?grade_symbol=$gradeSymbol&start=$start&remark=$remark&_db=linkskoo_practice');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to add grade');
    }
  }
}