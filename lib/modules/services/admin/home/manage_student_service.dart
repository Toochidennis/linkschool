import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/home/manage_student_model.dart';

import 'package:linkschool/modules/services/api/api_service.dart';

class ManageStudentService {
  final ApiService _apiService;

  ManageStudentService(this._apiService);

  Future<void> createStudent(Map<String, dynamic> newStudent) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    newStudent['_db'] = dbName;
    print("Request Payload: $newStudent");
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/students',
        body: newStudent,
      );
      print("Response Status Code: ${response.statusCode}");
      if (!response.success) {
        print("Failed to create student");
        print("Error: ${response.message ?? 'No error message provided'}");
        ScaffoldMessenger.of(GlobalKey<NavigatorState>().currentContext!).showSnackBar(
          SnackBar(
            content: Text("${response.message}"),
            backgroundColor: Colors.red,
          ),
        );
        throw Exception("Failed to create student: ${response.message}");
      } else {
        print('Student created successfully.');
        ScaffoldMessenger.of(GlobalKey<NavigatorState>().currentContext!).showSnackBar(
          SnackBar(
            content: Text('Student created successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error creating student: $e");
      throw Exception("Failed to create student: $e");
    }
  }

  Future<void> updateStudent(String studentId, Map<String, dynamic> updatedStudent) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    updatedStudent['_db'] = dbName;
    print("Update Request Payload: $updatedStudent");
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/students/$studentId',
        body: updatedStudent,
      );
      if (!response.success) {
        print("Failed to update student");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to update student: ${response.message}");
      } else {
        print('Student updated successfully.');
      }
    } catch (e) {
      print("Error updating student: $e");
      throw Exception("Failed to update student: $e");
    }
  }

  Future<void> deleteStudent(String studentId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint: 'portal/students/$studentId',
        body: {
          '_db': dbName,
        },
      );
      if (!response.success) {
        print("Failed to delete student");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to delete student: ${response.message}");
      } else {
        print('Student deleted successfully.');
      }
    } catch (e) {
      print("Error deleting student: $e");
      throw Exception("Failed to delete student: $e");
    }
  }

  Future<List<Students>> fetchStudents() async {
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
        endpoint: 'portal/students',
        queryParams: {
          '_db': dbName,
        },
      );
      print("Fetch Students Response Status Code: ${response.statusCode}");
      if (!response.success) {
        print("Failed to fetch students");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to fetch students: ${response.message}");
      }

      final data = response.rawData?['response'];
      if (data is List) {
        print('Students fetched successfully: ${data.length} students found.');
        return data.map((json) => Students.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        print("Unexpected response format");
        throw Exception("Unexpected response format");
      }
    } catch (e) {
      print("Error fetching students: $e");
      throw Exception("Failed to fetch students: $e");
    }
  }
}