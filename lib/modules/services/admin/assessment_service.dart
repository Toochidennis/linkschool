
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';


class AssessmentService {
  final ApiService _apiService = locator<ApiService>();

  Future<ApiResponse<Map<String, dynamic>>> saveAssessments(List<Map<String, dynamic>> assessments) async {
    return await _apiService.post(
      endpoint: 'assessments.php',
      body: assessments,
    );
  }
  
  // Additional assessment methods can be added here
  Future<ApiResponse<List<dynamic>>> getAssessments(String classId, String termId) async {
    return await _apiService.get(
      endpoint: 'assessments.php',
      queryParams: {
        'class_id': classId,
        'term_id': termId,
      },
    );
  }
}



// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AssessmentService {
//   Future<Map<String, dynamic>> saveAssessments(List<Map<String, dynamic>> assessments) async {
//     final response = await http.post(
//       Uri.parse('http://linkskool.com/developmentportal/api/assessments.php'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(assessments),
//     );

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to save assessments');
//     }
//   }
// }