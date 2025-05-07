import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class AssessmentService {
  final ApiService _apiService = locator<ApiService>();


  Future<ApiResponse<Map<String, dynamic>>> createAssessment(Map<String, dynamic> payload) async {
    try {
      // Get token from local storage
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Set the auth token before making the request
      _apiService.setAuthToken(token);

      return await _apiService.post(
        endpoint: 'portal/assessments',
        body: payload,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getAssessments(String dbName) async {
    try {
      // Get token from local storage
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Set the auth token before making the request
      _apiService.setAuthToken(token);

      return await _apiService.get(
        endpoint: 'portal/assessments',
        queryParams: {'_db': dbName},
      );
    } catch (e) {
      rethrow;
    }
  }


}