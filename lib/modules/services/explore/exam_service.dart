import 'dart:convert';
import 'package:http/http.dart' as http;


class ExamService {
  static const String baseUrl = 'http://www.cbtportal.linkskool.com/api';
  
  Future<Map<String, dynamic>> fetchExamData({
    required String appCode,
    required String examId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exam_json.php?json=10&appCode=$appCode&exam=$examId'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load exam data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exam data: $e');
    }
  }
}