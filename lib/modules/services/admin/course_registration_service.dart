import 'package:linkschool/modules/model/admin/course_registration_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class CourseRegistrationService {
  final ApiService _apiService = locator<ApiService>();

  Future<ApiResponse<List<CourseRegistrationModel>>> fetchRegisteredCourses(
    String classId, String term, String year) async {
    
    final response = await _apiService.get(
      endpoint: 'portal/courseRegistration',
      queryParams: {
        '_db': 'aamlmgzmy_linksckoo_practice',
        'class_id': classId,
        'term': term,
        'year': year,
      },
    );

    if (response.success && response.rawData != null) {
      // Parse the list of courses
      final List<dynamic> coursesJson = response.rawData!['data'] ?? response.rawData!;
      final courses = coursesJson
          .map((json) => CourseRegistrationModel.fromJson(json))
          .toList();
      
      return ApiResponse<List<CourseRegistrationModel>>(
        success: true,
        message: response.message,
        statusCode: response.statusCode,
        data: courses,
        rawData: response.rawData,
      );
    }
    
    return ApiResponse<List<CourseRegistrationModel>>(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
      data: [],
      rawData: response.rawData,
    );
  }

  Future<ApiResponse<bool>> registerCourse(CourseRegistrationModel course) async {
    final response = await _apiService.post(
      endpoint: 'courseRegistration.php',
      body: course.toJson(),
    );
    
    return ApiResponse<bool>(
      success: response.success,
      message: response.message,
      statusCode: response.statusCode,
      data: response.success,
      rawData: response.rawData,
    );
  }
}




// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:linkschool/modules/model/admin/course_registration_model.dart';

// class CourseRegistrationService {
//   final String baseUrl =
//       "http://linkskool.com/developmentportal/api/courseRegistration.php";

//   // Fetch registered courses (GET)
//   Future<List<CourseRegistrationModel>> fetchRegisteredCourses(
//       String classId, String term, String year) async {
//     try {
//       final Uri url = Uri.parse(
//           "$baseUrl?_db=linksckoo_practice&class_id=$classId&term=$term&year=$year");
//       final http.Response response = await http.get(url);

//       if (response.statusCode == 200) {
//         List<dynamic> data = jsonDecode(response.body);
//         print(data);
//         return data
//             .map((json) => CourseRegistrationModel.fromJson(json))
//             .toList();
//       } else {
//         print("Error: ${response.statusCode}");
//         return [];
//       }
//     } catch (e) {
//       print("Error fetching courses: $e");
//       return [];
//     }
//   }

//   // Register a course (POST)
//   Future<bool> registerCourse(CourseRegistrationModel course) async {
//     try {
//       final Uri url = Uri.parse("$baseUrl");
//       final http.Response response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(course.toJson()),
//       );

//       if (response.statusCode == 200) {
//         print("Course registered successfully!");
//         return true;
//       } else {
//         print("Failed to register course. Status Code: ${response.statusCode}");
//         return false;
//       }
//     } catch (e) {
//       print("Error registering course: $e");
//       return false;
//     }
//   }
// }
