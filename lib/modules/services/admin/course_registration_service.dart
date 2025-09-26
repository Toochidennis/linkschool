import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/admin/course_registration_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class CourseRegistrationService {
  final ApiService _apiService = locator<ApiService>();

  Future<ApiResponse<List<CourseRegistrationModel>>> fetchRegisteredCourses(
    String classId, String term, String year) async {
    
    final response = await _apiService.get(
      endpoint: 'portal/classes/$classId/registered-students',
      queryParams: {
        '_db': EnvConfig.dbName,
        'year': year,
        'term': term,
      },
    );

    if (response.success && response.rawData != null) {
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

  // New method to fetch registered courses for a single student
  Future<ApiResponse<List<Map<String, dynamic>>>> fetchStudentRegisteredCourses({
    required int studentId,
    required String classId,
    required String year,
    required String term,
    required String dbName,
  }) async {
    final response = await _apiService.get(
      endpoint: 'portal/students/$studentId/registered-courses',
      queryParams: {
        '_db': dbName,
        'year': year,
        'term': term,
        'class_id': classId,
      },
    );

    if (response.success && response.rawData != null) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: true,
        message: 'Student registered courses fetched successfully',
        statusCode: response.statusCode,
        data: [],  // We'll handle data extraction in the provider
        rawData: response.rawData,
      );
    }
    
    return ApiResponse<List<Map<String, dynamic>>>(
      success: false,
      message: response.message ?? 'Failed to fetch student registered courses',
      statusCode: response.statusCode,
      data: [],
      rawData: response.rawData,
    );
  }

  Future<ApiResponse<bool>> registerCourse(
    CourseRegistrationModel course, {
    Map<String, dynamic>? payload,
  }) async {
    // Use the custom endpoint if payload is provided
    if (payload != null) {
      final response = await _apiService.post(
        endpoint: 'portal/students/${course.studentId}/course-registrations',
        body: payload,
      );
      
      return ApiResponse<bool>(
        success: response.success,
        message: response.message,
        statusCode: response.statusCode,
        data: response.success,
        rawData: response.rawData,
      );
    }

    // Fallback to original implementation if no payload
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
//       endpoint: 'portal/classes/$classId/registered-students',
//       queryParams: {
//         '_db': 'aalmgzmy_linkskoo_practice',
//         'year': year,
//         'term': term,
//       },
//     );

//     if (response.success && response.rawData != null) {
//       final List<dynamic> studentsJson = response.rawData!['registered_students'] ?? [];
//       final students = studentsJson
//           .map((json) => CourseRegistrationModel.fromJson(json))
//           .toList();
      
//       return ApiResponse<List<CourseRegistrationModel>>(
//         success: true,
//         message: 'Registered students fetched successfully',
//         statusCode: response.statusCode,
//         data: students,
//         rawData: response.rawData,
//       );
//     }
    
//     return ApiResponse<List<CourseRegistrationModel>>(
//       success: false,
//       message: response.message ?? 'Failed to fetch registered students',
//       statusCode: response.statusCode,
//       data: [],
//       rawData: response.rawData,
//     );
//   }

//   Future<ApiResponse<bool>> registerCourse(
//     CourseRegistrationModel course, {
//     Map<String, dynamic>? payload,
//   }) async {
//     // Use the custom endpoint if payload is provided
//     if (payload != null) {
//       final response = await _apiService.post(
//         endpoint: 'portal/students/${course.studentId}/course-registrations',
//         body: payload,
//       );
      
//       return ApiResponse<bool>(
//         success: response.success,
//         message: response.message,
//         statusCode: response.statusCode,
//         data: response.success,
//         rawData: response.rawData,
//       );
//     }

//     // Fallback to original implementation if no payload
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