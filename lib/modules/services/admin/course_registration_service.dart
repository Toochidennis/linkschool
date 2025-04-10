import 'package:linkschool/modules/model/admin/course_registration_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class CourseRegistrationService {
  final ApiService _apiService = locator<ApiService>();

  Future<ApiResponse<List<CourseRegistrationModel>>> fetchRegisteredCourses(
    String classId, String term, String year) async {
    
    // Use the registered-students endpoint
    final response = await _apiService.get(
      endpoint: 'portal/classes/${classId}/registered-students',
      queryParams: {
        '_db': 'aalmgzmy_linkskoo_practice',
        'year': year,
        'term': term,
      },
    );

    if (response.success && response.rawData != null) {
      // Parse the list of registered students
      final List<dynamic> studentsJson = response.rawData!['registered_students'] ?? [];
      final students = studentsJson
          .map((json) => CourseRegistrationModel.fromJson(json))
          .toList();
      
      return ApiResponse<List<CourseRegistrationModel>>(
        success: true,
        message: 'Registered students fetched successfully',
        statusCode: response.statusCode,
        data: students,
        rawData: response.rawData,
      );
    }
    
    return ApiResponse<List<CourseRegistrationModel>>(
      success: false,
      message: response.message ?? 'Failed to fetch registered students',
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



// import 'package:linkschool/modules/model/admin/course_registration_model.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';

// class CourseRegistrationService {
//   final ApiService _apiService = locator<ApiService>();

//   Future<ApiResponse<List<CourseRegistrationModel>>> fetchRegisteredCourses(
//     String classId, String term, String year) async {
    
//     final response = await _apiService.get(
//       endpoint: 'courseRegistration.php',
//       queryParams: {
//         '_db': 'linksckoo_practice',
//         'class_id': classId,
//         'term': term,
//         'year': year,
//       },
//     );

//     if (response.success && response.rawData != null) {
//       // Parse the list of courses
//       final List<dynamic> coursesJson = response.rawData!['data'] ?? response.rawData!;
//       final courses = coursesJson
//           .map((json) => CourseRegistrationModel.fromJson(json))
//           .toList();
      
//       return ApiResponse<List<CourseRegistrationModel>>(
//         success: true,
//         message: response.message,
//         statusCode: response.statusCode,
//         data: courses,
//         rawData: response.rawData,
//       );
//     }
    
//     return ApiResponse<List<CourseRegistrationModel>>(
//       success: false,
//       message: response.message,
//       statusCode: response.statusCode,
//       data: [],
//       rawData: response.rawData,
//     );
//   }

//   Future<ApiResponse<bool>> registerCourse(CourseRegistrationModel course) async {
//     final response = await _apiService.post(
//       endpoint: 'courseRegistration.php',
//       body: course.toJson(),
//     );
    
//     return ApiResponse<bool>(
//       success: response.success,
//       message: response.message,
//       statusCode: response.statusCode,
//       data: response.success,
//       rawData: response.rawData,
//     );
//   }
// }