import 'dart:convert';
import 'package:http/http.dart' as http;

class AssessmentService {
  Future<Map<String, dynamic>> saveAssessments(List<Map<String, dynamic>> assessments) async {
    final response = await http.post(
      Uri.parse('http://linkskool.com/developmentportal/api/assessments.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(assessments),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to save assessments');
    }
  }
}