import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/student/streams_model.dart';
import 'package:linkschool/modules/model/student/submitted_assignment_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class MarkedAssignmentService {
  final ApiService _apiService;
  MarkedAssignmentService(this._apiService);

  Future<MarkedAssignmentModel> getMarkedAssignment({
    required int contentid,
    required int term,
    required int year,
    String db = 'aalmgzmy_linkskoo_practice',
  }) async {
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
        endpoint: 'portal/students/${contentid}/assignment-submissions',
        queryParams: {
          '_db': dbName,
          'year':year,
          'term': term,
          'content_id':contentid
        },
      );


      if(response.statusCode == 200) {
        print("Gottt  ${MarkedAssignmentModel.fromJson(response.rawData!['response'])}");
          return
           MarkedAssignmentModel.fromJson(response.rawData!['response']);




      }

      throw Exception("Failed to Fetch Marked assignment: ${response.message}");
    } catch (e) {
      print("Error fetching Streams: $e");
      throw Exception("Failed to Fetch ma: ${e}");
    }
  }

// // Example method to delete a comment
// Future<void> deleteComment(String commentId) async {
//   // Implement the logic to delete a comment from the API or database
// }
}