import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/student/streams_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class StreamsService {
  final ApiService _apiService;
  StreamsService(this._apiService);

  Future<Map<String, dynamic>> getStreams({
  required int syllabusid,
  String? db, // make it optional
}) async {
  final userBox = Hive.box('userData');
  final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

  if (loginData == null || loginData['token'] == null) {
    throw Exception("No valid login data or token found");
  }

  // ✅ Fetch token
  final token = loginData['token'] as String;
  _apiService.setAuthToken(token);

  // ✅ Get _db dynamically
  final dbName = db ??
      userBox.get('_db') ?? // stored earlier from login
      loginData['_db'] ?? // fallback if not saved separately
      loginData['response']?['_db'] ?? // some apps store under 'response'
      'aalmgzmy_linkskoo_practice'; // final fallback

  print("✅ Using DB: $dbName");

  // ✅ Then use dbName in your API call
  final response = await _apiService.get<Map<String, dynamic>>(
    endpoint: 'portal/elearning/${syllabusid}/comments/streams',
    queryParams: {'_db': dbName},
  );

  if (response.statusCode != 200) {
    throw Exception('API request failed with status ${response.statusCode}');
  }

  return response.rawData ?? {};
}


// // Example method to delete a comment
// Future<void> deleteComment(String commentId) async {
//   // Implement the logic to delete a comment from the API or database
// }
}