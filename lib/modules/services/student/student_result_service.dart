import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/student/student_result_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class StudentResultService {
  final ApiService _apiService;
  StudentResultService(this._apiService);

  getuserdata(){
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData = storedUserData is String
        ? json.decode(storedUserData)
        : storedUserData;
    final response = processedData['response'] ?? processedData;
    final data = response['data'] ?? response;
    return data;
  }

  Future<StudentResultModel> getStudentResult({
    required int levelid,
    required int classid,


    required int term,
    required String year,

    String db = 'aalmgzmy_linkskoo_practice',
  }) async {

    final studentid = getuserdata()['profile']['id'];

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
        endpoint: 'portal/students/${studentid}/result/${term}',
        queryParams: {
          '_db': dbName,
          'year':year,
          'term': term,
          'class_id':classid,
          'level_id':levelid

        },
      );


      if(response.statusCode == 200) {

        return
          StudentResultModel.fromJson(response.rawData!['response']);




      }

      throw Exception("Failed to Fetch Student Result: ${response.message}");
    } catch (e) {
      print("Error fetching Student Result: $e");
      throw Exception("Failed to Fetch ma: ${e}");
    }
  }

// // Example method to delete a comment
// Future<void> deleteComment(String commentId) async {
//   // Implement the logic to delete a comment from the API or database
// }
}