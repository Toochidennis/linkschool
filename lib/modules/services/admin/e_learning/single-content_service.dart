import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/e-learning/single_content_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class SingleAssessmentService {
  final ApiService _apiService = locator<ApiService>();

  Map<String, dynamic> getUserData() {
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData =
        storedUserData is String ? json.decode(storedUserData) : storedUserData;
    final response = processedData['response'] ?? processedData;
    final data = response['data'] ?? response;
    return data;
  }

  Future<AssessmentContentItem> fetchQuiz(int syllabusId) async {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      _apiService.setAuthToken(token);

      final response = await _apiService.get(
        endpoint: 'portal/elearning/contents/$syllabusId',
        queryParams: {
          '_db': dbName,
        },
      );

      final data = response.rawData?['response'];
      if (data == null) {
        throw Exception("No quiz data received.");
      }

      return AssessmentContentItem.fromJson({
        ...data['settings'],
        'questions': data['questions'],
      });
    } catch (e) {
      throw Exception('Failed to fetch quiz: $e');
    }
  }

  Future<AssessmentContentItem> fetchAssignment(int syllabusId) async {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      _apiService.setAuthToken(token);

      final response = await _apiService.get(
        endpoint: 'portal/elearning/contents/$syllabusId',
        queryParams: {
          '_db': dbName,
        },
      );

      final data = response.rawData?['response'];
      if (data == null) {
        throw Exception("No assignment data received.");
      }

      return AssessmentContentItem.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch assignment: $e');
    }
  }

  Future<AssessmentContentItem> fetchMaterial(int itemId) async {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

      if (token == null) {
        throw Exception("Authentication token is missing.");
      }

      _apiService.setAuthToken(token);

      final response = await _apiService.get(
        endpoint: 'portal/elearning/contents/$itemId', // Updated endpoint
        queryParams: {
          '_db': dbName,
        },
      );

      print('Raw API response: ${response.rawData}'); // Log raw response

      final data = response.rawData?['response'];
      if (data == null) {
        throw Exception("No material data received.");
      }

      print('Parsed response data: $data'); // Log parsed data

      return AssessmentContentItem.fromJson(data); // Parse directly
    } catch (e) {
      throw Exception('Failed to fetch material: $e');
    }
  }
}
