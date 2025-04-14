import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/grade _model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class GradeService {
  final ApiService _apiService;

  GradeService(this._apiService);

  Future<List<Grade>> getGrades() async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

    if (loginData == null) {
      throw Exception('No login data available');
    }

    final token = loginData['token'] ?? userBox.get('token');

    if (token != null) {
      _apiService.setAuthToken(token);
      print('Token set: $token');
    }

    final response = await _apiService.get<List<Grade>>(
      endpoint: 'portal/grades',
      queryParams: {
        '_db': 'aalmgzmy_linkskoo_practice',
      },
      fromJson: (json) {
        if (json['success'] == true && json['grades'] is List) {
          return (json['grades'] as List)
              .map((gradeJson) => Grade.fromJson(gradeJson))
              .toList();
        }
        throw Exception('Failed to load grades: ${json['message']}');
      },
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    return response.data ?? [];
  }

  Future<void> addGrades(List<Grade> grades) async {
    for (var grade in grades) {
      final requestBody = {
        'grade_symbol': grade.grade_Symbol!,
        'start': grade.start!,
        'remark': grade.remark!,
        '_db': 'aalmgzmy_linkskoo_practice',
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/grades',
        body: requestBody,
      );

      if (!response.success) {
        print('Failed to add grade ${grade.grade_Symbol}: ${response.message}');
        throw Exception('Failed to add grade: ${response.message}');
      } else {
        print('Grade added: ${grade.grade_Symbol}');
      }
    }
  }

  Future<void> deleteGrades(String id) async {
    final response = await _apiService.delete<Map<String, dynamic>>(
      endpoint: 'portal/grades',
      body: {
        'id': id,
        '_db': 'aalmgzmy_linkskoo_practice',
      },
    );

    if (!response.success) {
      print('Failed to delete grade with ID  ${response.message}');
      throw Exception('Failed to delete grade: ${response.message}');
    } else {
      print('Grade with ID $id deleted successfully');
    }
  }
}




// Future<void> deleteGrades(String id) async {
//     final response = await _apiService.delete<Map<String, dynamic>>(
//       endpoint: 'portal/grades',
//       body: {'id': id},
//     );


//     if (!response.success) {
//       throw Exception('Failed to delete grades: ${response.message}');
//     }
//   }


// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../../model/admin/grade _model.dart';

// class GradeService {
//   final String baseUrl = 'http://linkskool.com/developmentportal/api';

//   Future<List<Grade>> getGrades() async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/grades.php'),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       // print(response.body);
//       if (data['status'] == "success") {
//         List<dynamic> gradesJson = data['grades'];
//         print("hiiiiiiiii $gradesJson");
//         return gradesJson.map((json) => Grade.fromJson(json)).toList();
//       } else {
//         throw Exception('API returned error: ${data['message']}');
//       }
//     } else {
//       throw Exception('Failed to load grades: ${response.statusCode}');
//     }
//   }

//   // POST to add a grade
//   Future<void> addGrade(String gradeSymbol, String start, String remark) async {
//     final Map<String, String> requestBody = {
//       'grade_symbol': gradeSymbol,
//       'start': start,
//       'remark': remark,
//       '_db': 'linkskoo_practice',
//     };

//     final response = await http.post(
//       Uri.parse('$baseUrl/grades.php'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(requestBody),
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       if (data['status'] != 'success') {
//         throw Exception('Failed to add grade: ${data['message']}');
//       }
//     } else {
//       throw Exception('Failed to add grade: ${response.statusCode}');
//     }
//   }
// }


