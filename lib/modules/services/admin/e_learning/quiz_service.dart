import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class QuizService {
  final ApiService _apiService;
  QuizService(this._apiService);
  Future<void> addTest(Map<String, dynamic> QuizPayload) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    QuizPayload['_db'] = dbName;

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/elearning/quiz',
        body: QuizPayload,
      );


      if (!response.success) {

        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        );
        throw Exception("Failed to Add Test: ${response.message}");
      } else {
        SnackBar(
          content: Text('Test added successfully.'),
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      throw Exception("Failed to Add Test: $e");
    }
  }

  Future<void> updateTest(Map<String, dynamic> QuizPayload) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    QuizPayload['_db'] = dbName;

    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/elearning/quiz',
        body: QuizPayload,
      );


      if (!response.success) {

        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        );
        throw Exception("Failed to Update Test: ${response.message}");
      } else {
        SnackBar(
          content: Text('Test updated successfully.'),
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      throw Exception("Failed to Update Test: $e");
    }
  }

  Future<void> DeleteQuiz(int id) async {
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
        endpoint: 'portal/elearning/quiz/$id',
        body: dbName,
      );


      if (!response.success) {

        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        );
        throw Exception("Failed to delete: ${response.message}");
      } else {
        SnackBar(
          content: Text('question deleted successfully.'),
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      throw Exception("Failed to delete question: $e");
    }
  }
}

