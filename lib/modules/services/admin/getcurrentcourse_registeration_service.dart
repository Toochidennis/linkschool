import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for JSON conversion
import 'package:linkschool/modules/model/admin/getcurrent_registration_model.dart';

class GetcurrentcourseRegisterationService {
  final String baseUrl =
      "http://linkskool.com/developmentportal/api/courseRegistration.php";

  // Fetch current course registration data
  Future<GetCurrentCourseRegistrationModel> getCurrentCourseRegistration(
      String student_Id, String classID, String term, String year) async {
    if (student_Id.isEmpty || classID.isEmpty || term.isEmpty || year.isEmpty) {
      throw Exception('All parameters must be provided and non-empty');
    }

    final Uri url = Uri.parse(
        '$baseUrl?_db=linkskoo_practice&student_Id=$student_Id&classID=$classID&term=$term&year=$year');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        print(response.body); // Debugging: Print the response body
        return GetCurrentCourseRegistrationModel.fromJsonString(response.body);
      } catch (e) {
        throw Exception('Failed to parse JSON: $e');
      }
    } else {
      throw Exception(
          'Failed to load course registration data: ${response.body}');
    }
  }

// Post current course registration data
  Future<void> postgetCurrentCourseRegistration(
      GetCurrentCourseRegistrationModel registration) async {
    final Uri url = Uri.parse('baseUrl');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registration.toJson()), // Ensure correct JSON format
    );

    if (response.statusCode != 201) {
      throw Exception(
          'Failed to post course registration data: ${response.body}');
    }
  }
}
