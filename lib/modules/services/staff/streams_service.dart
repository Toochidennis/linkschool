import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/staff/streams_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class StaffStreamsService {
  final ApiService _apiService;
  StaffStreamsService(this._apiService);

  Future<Map<String, dynamic>> getStreams({
    required int syllabusid,
  }) async {
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

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/elearning/$syllabusid/comments/streams',
        queryParams: {
          '_db': dbName,
        },
      );

      if (response.statusCode == 200) {
        final data = response.rawData?['data'] as List<dynamic>? ?? [];
        if (data.isNotEmpty) {
          return {
            'streams': data.map((json) => StreamsModel.fromJson(json)).toList(),
          };
        }
      }

      throw Exception("Failed to fetch streams: ${response.message}");
    } catch (e) {
      print("Error fetching streams: $e");
      throw Exception("Failed to fetch streams: $e");
    }
  }

  // Example method to delete a comment
  // Future<void> deleteComment(String commentId) async {
  //   // Implement delete logic here
  // }
}
