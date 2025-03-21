import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/admin/class_course_registration_model.dart';

class ClassCourseApiService {
  static const String _baseUrl = 'http://linkskool.com/developmentportal/api/classRegistration.php';

  Future<void> postClassCourse(ClassCourseModel data) async {
    final url = Uri.parse(_baseUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(data.toJson());

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print('Data posted successfully');
      print('Response body: ${response.body}');
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }
}
// import 'package:http/http.dart' as http;
// import 'package:linkschool/modules/model/admin/class_course_registration_model.dart';

// class ClassCousreRegistrationApiService {
//   final String baseUrl =
//       "http://linkskool.com/developmentportal/api/classRegistration.php"; // Change this to your API

//   Future<bool> postStudentClass(
//       StudentClassCourseRegistration studentClass) async {
//     final url = Uri.parse(baseUrl);

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(studentClass.toJson()),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print(response.body);
//         return true; // Success
//       } else {
//         print("Error: ${response.body}");
//         return false;
//       }
//     } catch (e) {
//       print("Exception: $e");
//       return false;
//     }
//   }
// }
