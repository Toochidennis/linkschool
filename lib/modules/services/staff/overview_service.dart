import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/staff/overview_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class StaffOverviewService {
  final ApiService _apiService;

  StaffOverviewService(this._apiService);

  Future<DashboardResponse> getOverview(String term, String year ,String staffId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception('No valid login data or token found');
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/elearning/staff/$staffId/overview',
        queryParams: {
          'year': year,
          'term': term,
          '_db': dbName,
        },
        fromJson: (json) => json,
      );

      print("=== Staff Overview API Response ===");
      print("Success: ${response.success}");
      print("Message: ${response.message}");
      print("Raw Data: ${response.data}");
      print("===================================");

      if (!response.success) {
        throw Exception("API Error: ${response.message}");
      }
      if (response.data == null) {
        throw Exception("Empty response from server");
      }

      return DashboardResponse.fromJson(response.data!);
    } catch (e, stack) {
      print("Error in StaffOverviewService.getOverview: $e");
      print(stack);
      rethrow;
    }
  }
}