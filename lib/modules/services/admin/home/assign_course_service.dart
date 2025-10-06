import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class AssignCourseService {
  final ApiService _apiService;

  AssignCourseService(this._apiService);
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
          content: Text("${response.message}"),
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