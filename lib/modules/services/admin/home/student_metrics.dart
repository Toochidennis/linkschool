import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/home/student_metrics.dart';

import 'package:linkschool/modules/services/api/api_service.dart';

class StudentMetricsService {
  final ApiService _apiService;

  StudentMetricsService(this._apiService);

  Future<StudentStatsResponse> fetchMetrics() async {
    final userBox = Hive.box('userData');

    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: "portal/students/metrics",
        queryParams: {
          "_db": dbName,
        },
      );

      print("Metrics Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to fetch student metrics");
        print("Error: ${response.message ?? 'No error message'}");
        throw Exception("Failed to fetch metrics: ${response.message}");
      }

      final raw = response.rawData;
      if (raw is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }

      print("Metrics fetched successfully.");

      return StudentStatsResponse.fromJson(raw);
    } catch (e) {
      print("Error fetching metrics: $e");
      throw Exception("Failed to fetch student metrics: $e");
    }
  }
}
