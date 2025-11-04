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
    print("Set token: $token");
    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
          endpoint: 'portal/elearning/contents/$id',
          body: {
            '_db': dbName,
          });

      print("Response Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to delete Assignment content");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception(
            "Failed to Delete Assignment Content: ${response.message}");
      } else {
        print('Assignmentcontent deleted successfully.');
        print('Status Code: ${response.statusCode}');
        print('Message: ${response.message}');
      }
    } catch (e) {
      print("Error deleting Assignment content: $e");
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
    print("Set token: $token");
    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
          endpoint: 'portal/elearning/contents/$id',
          body: {
            '_db': dbName,
          });

      print("Response Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to delete Quiz content");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to Delete  Quiz  Content: ${response.message}");
      } else {
        print(' Quiz  content deleted successfully.');
        print('Status Code: ${response.statusCode}');
        print('Message: ${response.message}');
      }
    } catch (e) {
      print("Error deleting  Quiz  content: $e");
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
    print("Set token: $token");
    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
          endpoint: 'portal/elearning/contents/$id',
          body: {
            '_db': dbName,
          });

      print("Response Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to delete material content");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception(
            "Failed to Delete Syllabus Content: ${response.message}");
      } else {
        print('material content deleted successfully.');
        print('Status Code: ${response.statusCode}');
        print('Message: ${response.message}');
      }
    } catch (e) {
      print("Error deleting material content: $e");
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
    print("Set token: $token");
    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
          endpoint: 'portal/elearning/contents/$id',
          body: {
            '_db': dbName,
          });

      print("Response Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to delete topic content");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to Delete topic Content: ${response.message}");
      } else {
        print('topic content deleted successfully.');
        print('Status Code: ${response.statusCode}');
        print('Message: ${response.message}');
      }
    } catch (e) {
      print("Error deleting topic content: $e");
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
      print('Token set: $token');
    }
    final response = await _apiService.delete<Map<String, dynamic>>(
      endpoint: 'portal/elearning/contents/$syllabusId',
      body: {'_db': dbName},
    );

    if (!response.success) {
      print('Failed to delete syllabus: ${response.message}');
      throw Exception('Failed to delete syllabus: ${response.message}');
    } else {
      print('Syllabus deleted: ${response.message}');
    }
  }
}
