import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class DeleteSyllabusService {
  final ApiService _apiService;
  DeleteSyllabusService(this._apiService);

  Future<void> DeleteAssignment(String id) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
          endpoint: 'portal/elearning/contents/$id',
          body: {
            '_db': dbName,
          });


      if (!response.success) {
        throw Exception(
            "Failed to Delete Assignment Content: ${response.message}");
      } else {
      }
    } catch (e) {
      throw Exception("Failed to Delete Assignment Content: $e");
    }
  }

  Future<void> DeleteQuiz(String id) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
          endpoint: 'portal/elearning/contents/$id',
          body: {
            '_db': dbName,
          });


      if (!response.success) {
        throw Exception("Failed to Delete  Quiz  Content: ${response.message}");
      } else {
      }
    } catch (e) {
      throw Exception("Failed to Delete  Quiz  Content: $e");
    }
  }

  Future<void> DeleteMaterial(String id) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
          endpoint: 'portal/elearning/contents/$id',
          body: {
            '_db': dbName,
          });


      if (!response.success) {
        throw Exception(
            "Failed to Delete Syllabus Content: ${response.message}");
      } else {
      }
    } catch (e) {
      throw Exception("Failed to Delete material Content: $e");
    }
  }

  Future<void> DeleteTopic(String id) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
          endpoint: 'portal/elearning/contents/$id',
          body: {
            '_db': dbName,
          });


      if (!response.success) {
        throw Exception("Failed to Delete topic Content: ${response.message}");
      } else {
      }
    } catch (e) {
      throw Exception("Failed to Delete topic Content: $e");
    }
  }

  Future<void> deletesyllabus(int syllabusId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    if (loginData == null) {
      throw Exception('No login data available');
    }
    final token = loginData['token'] ?? userBox.get('token');
    if (token != null) {
      _apiService.setAuthToken(token);
    }
    final response = await _apiService.delete<Map<String, dynamic>>(
      endpoint: 'portal/elearning/contents/$syllabusId',
      body: {'_db': dbName},
    );

    if (!response.success) {
      throw Exception('Failed to delete syllabus: ${response.message}');
    } else {
    }
  }
}

