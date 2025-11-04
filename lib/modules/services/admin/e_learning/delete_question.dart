import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class DeleteQuestionService {
  final ApiService _apiService;
  DeleteQuestionService(this._apiService);

  Future<void> deleteQuestion(String id, String settingId) async {
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
          endpoint: 'portal/elearning/quiz/$settingId/$id',
          body: {
            '_db': dbName,
          });
      if (!response.success) {
        print("Failed to delete Question content");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception(
            "Failed to Delete  Question Content: ${response.message}");
      } else {
        print(' Question content deleted successfully.');
        print('Status Code: ${response.statusCode}');
        print('Message: ${response.message}');
      }
    } catch (e) {
      print("Error deleting  Question content: $e");
      throw Exception("Failed to Delete  Question Content: $e");
    }
  }
}
