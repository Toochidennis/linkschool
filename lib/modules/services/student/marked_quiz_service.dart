import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/student/streams_model.dart';
import 'package:linkschool/modules/model/student/submitted_quiz_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class MarkedQuizService {
  final ApiService _apiService;
  MarkedQuizService(this._apiService);

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

  Future<MarkedQuizModel> getMarkedQuiz({
    required int contentid,
    required int term,
    required int year,

    String db = 'aalmgzmy_linkskoo_practice',
  }) async {

    final studentid = getuserdata()['profile']['id'];

    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/students/${studentid}/quiz-submissions',
        queryParams: {
          '_db': db,
          'year':year,
          'term': term,
          'content_id':contentid
        },
      );


      if(response.statusCode == 200) {
        print("Gottt  ${response.rawData!['response']}");

        print("Gottt  ${MarkedQuizModel.fromJson(response.rawData!['response'])}");
        return
          MarkedQuizModel.fromJson(response.rawData!['response']);




      }

      throw Exception("Failed to Fetch Marked assignment: ${response.message}");
    } catch (e) {
      print("Error fetching Marked Quiz: $e");
      throw Exception("Failed to Fetch ma: ${e}");
    }
  }

// // Example method to delete a comment
// Future<void> deleteComment(String commentId) async {
//   // Implement the logic to delete a comment from the API or database
// }
}