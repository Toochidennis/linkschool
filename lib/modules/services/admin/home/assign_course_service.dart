import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/home/add_course_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class AssignCourseService {
  final ApiService _apiService;

  AssignCourseService(this._apiService);
Future<CourseAssignmentResponse> fetchCourseAssignments(int staffId, String term, String year) async {
  final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    

    
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/course-assignments',
        queryParams: {
          'term': term,
          'staff_id': staffId,
          'year': year,
          '_db': dbName,
        },

      );

      if (response.rawData == null) {
        print("Response data is ${response.rawData}");
        throw Exception("Empty response from server.");
      }

      final result =
          CourseAssignmentResponse.fromJson(response.rawData as Map<String, dynamic>);

      if (!result.success) {
        throw Exception("Failed to fetch course assignments.");
      }

      return result;
    } catch (e) {
      debugPrint("Error fetching course assignments: $e");
      throw Exception("Error fetching course assignments: $e");
    }
  }


  Future<void> Assigncourse(Map<String, dynamic> AssignedCourse) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    AssignedCourse['_db'] = dbName;
    print("Request Payload: $AssignedCourse");
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/course-assignments',
        body: AssignedCourse,
      );
      print("Response Status Code: ${response.statusCode}");
      if (!response.success) {
        print("Failed to Assigned courses and classes ");
        print("Error: ${response.message ?? 'No error message provided'}");
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        );
        throw Exception("Failed to Assign course : ${response.message}");
      } else {
        SnackBar(
          content: Text('course assigned  successfully.'),
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      print("Error assigning course: $e");
      throw Exception("Failed to assigning course: $e");
    }
  }
}
