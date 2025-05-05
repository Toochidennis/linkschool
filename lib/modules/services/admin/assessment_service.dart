import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class AssessmentService {
  final ApiService _apiService = locator<ApiService>();
  
  // Helper method to set authentication token
  Future<String> _getAndSetAuthToken() async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

    if (loginData == null) {
      throw Exception('No login data available');
    }

    final token = loginData['token'] ?? userBox.get('token');

    if (token == null) {
      throw Exception('No authentication token available');
    }
    
    _apiService.setAuthToken(token);
    return token;
  }

  // Add multiple assessments to the API
  Future<void> addAssessments(List<Map<String, dynamic>> assessments) async {
    await _getAndSetAuthToken();
    
    // Track failed assessments for better error reporting
    final List<String> failedAssessments = [];

    for (var assessment in assessments) {
      try {
        final response = await _apiService.post<Map<String, dynamic>>(
          endpoint: 'portal/assessments',
          body: assessment,
        );

        if (!response.success) {
          failedAssessments.add(assessment['assessment_name'] ?? 'Unnamed assessment');
        }
      } catch (e) {
        failedAssessments.add(assessment['assessment_name'] ?? 'Unnamed assessment');
      }
    }
    
    // If any assessments failed, throw an exception with details
    if (failedAssessments.isNotEmpty) {
      throw Exception('Failed to add the following assessments: ${failedAssessments.join(', ')}');
    }
  }

  // Get assessments from the API
    Future<ApiResponse<Map<String, dynamic>>> getAssessments() async {
    await _getAndSetAuthToken();
    
    final dbName = 'aalmgzmy_linkskoo_practice'; // Database name
    
    try {
      return await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/assessments',
        queryParams: {
          '_db': dbName,
        },
      );
    } catch (e) {
      print('Assessment API error: ${e.toString()}');
      throw Exception('Assessment API error: ${e.toString()}');
    }
  }
  
  // Update a specific assessment
  Future<ApiResponse<Map<String, dynamic>>> updateAssessment(String id, Map<String, dynamic> assessmentData) async {
    await _getAndSetAuthToken();
    
    return _apiService.put<Map<String, dynamic>>(
      endpoint: 'portal/assessments/$id',
      body: assessmentData,
    );
  }
  
  // Delete a specific assessment
  Future<ApiResponse<Map<String, dynamic>>> deleteAssessment(String id) async {
    await _getAndSetAuthToken();
    
    return _apiService.delete<Map<String, dynamic>>(
      endpoint: 'portal/assessments/$id',
    );
  }
}