
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/model/e-learning/quiz_model.dart';
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
    print("Set token: $token");
    _apiService.setAuthToken(token);

    QuizPayload['_db'] = dbName;
    print("Request Payload: $QuizPayload");

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/elearning/quiz',
        body: QuizPayload,
      );

      print("Response Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to add Test");
        
        print("Error: ${response.message ?? 'No error message provided'}");
       SnackBar(
          content: Text("${response.message }"),
          backgroundColor: Colors.red,
        );
        throw Exception("Failed to Add Test: ${response.message}");
      } else {
        print('Test added successfully.');
        print('Status Code: ${response.statusCode}');
        SnackBar(
          content: Text('Test added successfully.'),
          backgroundColor: Colors.green,
        );
        print('${response.message}');
      }
    } catch (e) {
      print("Error adding test: $e");
      throw Exception("Failed to Add Test: $e");
    }
  }

Future<ContentResponse> fetchContent(int syllabusId) async {
  final userBox = Hive.box('userData');
  final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
  final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

  if (loginData == null || loginData['token'] == null) {
    throw Exception("No valid login data or token found");
  }

  final token = loginData['token'] ?? userBox.get('token');

  print("Set token: $token");
  _apiService.setAuthToken(token);

  final response = await _apiService.get(
    endpoint: 'portal/elearning/syllabus/contents/$syllabusId',
    queryParams: {
      "_db": dbName,
    },
  );

  if (response.statusCode == 200) {
    final jsonData = response.data ?? response.message; // Adjust based on your _apiService
    if (jsonData['success'] == true && jsonData['response'] is List) {
      return ContentResponse.fromJson(jsonData);
    } else {
      throw Exception('API call succeeded but response format is invalid');
    }
  } else {
    throw Exception('Failed to load content');
  }
}
 Future<void> DeleteQuiz(int id) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';;

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    print("Set token: $token");
    _apiService.setAuthToken(token);

   
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint: 'portal/elearning/quiz/$id',
        body: dbName,
      );

      print("Response Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to delete");
        
        print("Error: ${response.message ?? 'No error message provided'}");
       SnackBar(
          content: Text("${response.message }"),
          backgroundColor: Colors.red,
        );
        throw Exception("Failed to delete: ${response.message}");
      } else {
        print('Test added successfully.');
        print('Status Code: ${response.statusCode}');
        SnackBar(
          content: Text('question deleted successfully.'),
          backgroundColor: Colors.green,
        );
        print('${response.message}');
      }
    } catch (e) {
      print("Error deleting questions: $e");
      throw Exception("Failed to delete question: $e");
    }
  }

}
  
  

