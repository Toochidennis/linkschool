import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/e-learning/activity_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';


class RecentService {
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
  Future<RecentData> getDashboardData(String classId, String levelId, String term) async {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
      final studentid = getuserdata()['profile']['staff_id'];

      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      _apiService.setAuthToken(token);
      print(getuserdata()['settings']);
      final response = await _apiService.get(
        endpoint: 'portal/students/${studentid}/elearning/dashboard',
        queryParams: {
          '_db': dbName,
          'class_id': classId,
          'level_id': levelId,
          'year':getuserdata()['settings']['year'],
          'term':getuserdata()['settings']['term']

        //add student id and year
        },
      );

      final data = response;
      print("it is gott ${RecentData.fromJson(data.rawData?['data']).recentActivities[0].title}");
      int? syllabusid = userBox.get('syllabusid');

      if (syllabusid == null) {
        syllabusid=RecentData.fromJson(data.rawData?['data']).recentActivities[0].syllabusId;
        await userBox.put('syllabusid', syllabusid);
      }
      if (data == null) {
        throw Exception("No dashboard data received.");
      }
      return RecentData.fromJson(data.rawData?['data']);
    } catch (e) {
      // You can log this or use a crash reporting service like Sentry
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }
}
//