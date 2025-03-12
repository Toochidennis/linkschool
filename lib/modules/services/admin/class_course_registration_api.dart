import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/admin/class_course_registration_model.dart';

class ClassCousreRegistrationApiService {
  final String baseUrl =
      "http://linkskool.com/developmentportal/api/classRegistration.php"; // Change this to your API

  Future<bool> postStudentClass(StudentClassCourseRegistration studentClass) async {
    final url = Uri.parse("$baseUrl/post-student-class");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(studentClass.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Success
      } else {
        print("Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
}
