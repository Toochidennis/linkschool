// lib/modules/services/admin/performance_service.dart
import 'package:linkschool/modules/services/api/api_service.dart';

class PerformanceData {
  final int id;
  final String levelName;
  final double averageScore;

  PerformanceData({
    required this.id,
    required this.levelName,
    required this.averageScore,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      id: json['id'] ?? 0,
      levelName: json['level_name'] ?? '',
      averageScore: double.tryParse(json['average_score'].toString()) ?? 0.0,
    );
  }
}

class PerformanceService {
  final ApiService _apiService;

  PerformanceService(this._apiService);

  Future<ApiResponse<List<PerformanceData>>> getClassPerformance({
    required String year,
    required String term,
  }) async {
    try {
      final response = await _apiService.get<List<PerformanceData>>(
        endpoint: 'portal/levels/result/performance',
        queryParams: {
          'year': year,
          'term': term,
        },
        fromJson: (json) {
          final responseData = json['response'] as List?;
          if (responseData != null) {
            return responseData
                .map((item) => PerformanceData.fromJson(item))
                .toList();
          }
          return <PerformanceData>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<PerformanceData>>.error(
        'Failed to fetch performance data: $e',
        500,
      );
    }
  }
}
