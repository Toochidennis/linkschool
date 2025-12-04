import 'dart:convert';

import 'package:hive/hive.dart';
import '../../model/student/dashboard_model.dart';
import '../api/api_service.dart';

class DashboardService {
  final ApiService _apiService;
  DashboardService(this._apiService);
  getuserdata() {
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData =
        storedUserData is String ? json.decode(storedUserData) : storedUserData;
    final response = processedData['response'] ?? processedData;
    final data = response['data'] ?? response;
    return data;
  }

  Future<DashboardData> getDashboardData(
      String classId, String levelId, String term) async {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
      final studentid = getuserdata()['profile']['id'];
      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      _apiService.setAuthToken(token);
      print(getuserdata()['settings']);
      final response = await _apiService.get(
        endpoint: 'portal/students/$studentid/elearning/dashboard',
        queryParams: {
          '_db': dbName,
          'class_id': classId,
          'level_id': levelId,
          'year': getuserdata()['settings']['year'],
          'term': getuserdata()['settings']['term']

          //add student id and year
        },
      );

      final data = response;
      print("Dashboard data received successfully");
      
      // Parse the dashboard data
      final dashboardData = DashboardData.fromJson(data.rawData?['data']);
      
      // Store syllabus ID if available from recent quizzes
      int? syllabusid = userBox.get('syllabusid');
      if (syllabusid == null && dashboardData.recentQuizzes.isNotEmpty) {
        syllabusid = dashboardData.recentQuizzes[0].syllabusId;
        if (syllabusid != null) {
          await userBox.put('syllabusid', syllabusid);
        }
      }
      
      return dashboardData;
    } catch (e) {
      // You can log this or use a crash reporting service like Sentry
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }
}
//
