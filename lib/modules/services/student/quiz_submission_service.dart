import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/model/student/quiz_submission_model.dart';

import '../api/api_service.dart';
import '../api/service_locator.dart';

class QuizSubmissionService {
  final ApiService _apiService = locator<ApiService>();

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


  QuizSubmissionService();

  Future<bool> submitAssignment(QuizSubmissionModel submission) async {
    final userBox = Hive.box('userData');
    final token = userBox.get('token');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    final studentid = getuserdata()['profile']['student_id'];
    if (token == null) {
      throw Exception("Authentication token is missing.");
    }
    _apiService.setAuthToken(token);
    print(submission.toJson());

    final response = await _apiService.post(
      endpoint: 'portal/students/${studentid}/quiz-submissions',
      body: submission.toJson(),
    );


    if (response.statusCode == 201) {
      return true;
    } else {
      print('Failed: ${response.message}');
      return false;
    }
  }


}
