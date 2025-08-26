import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/student/streams_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class StreamsService {
  final ApiService _apiService;
  StreamsService(this._apiService);

  Future<Map<String, dynamic>> getStreams({
    required int syllabusid,

    String db = 'aalmgzmy_linkskoo_practice',
  }) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/elearning/${syllabusid}/comments/streams',
        queryParams: {
          '_db': db,
        },
      );


      if(response.statusCode == 200) {
        final data = response.rawData?['data'] as List<dynamic> ?? [];
        if (data.isNotEmpty) {
          return {
            'streams': data.map((json) => StreamsModel.fromJson(json)).toList(),
          };}

      }

      throw Exception("Failed to Fetch Streams: ${response.message}");
    } catch (e) {
      print("Error fetching Streams: $e");
      throw Exception("Failed to Fetch Streams: $e");
    }
  }

// // Example method to delete a comment
// Future<void> deleteComment(String commentId) async {
//   // Implement the logic to delete a comment from the API or database
// }
}