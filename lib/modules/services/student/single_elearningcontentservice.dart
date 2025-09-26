import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/student/elearningcontent_model.dart';
import 'package:linkschool/modules/model/student/single_elearningcontentmodel.dart';
import '../../model/student/dashboard_model.dart';
import '../api/api_service.dart';
import '../api/service_locator.dart';

class SingleElearningcontentservice {
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
  Future<SingleElearningContentData> getElearningContentData(int contentid) async {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      final dbName = userBox.get('_db')?? 'aalmgzmy_linkskoo_practice' ;

      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      _apiService.setAuthToken(token);
      // print(getuserdata()['settings']);
      final response = await _apiService.get(
        endpoint: 'portal/elearning/contents/${contentid}',
        queryParams: {
          '_db': dbName,
          //add student id and syllabus id
        },
      );

      final data = response;
      print("Dataaaa ${data.rawData?['response']}");

      if (data == null) {
        throw Exception("No dashboard data received.");
      }


      return SingleElearningContentData.fromJson(data.rawData?['response']);
    } catch (e) {
      // You can log this or use a crash reporting service like Sentry
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }
}
