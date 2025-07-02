import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/modules/config/env_config.dart';

class CourseResultService {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<Map<String, dynamic>>> fetchCourseResults({
    required String classId,
    required String courseId,
    required String term,
    required String year,
    required String levelId,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/classes/$classId/courses/$courseId/results',
        queryParams: {
          'term': term,
          'year': year,
          '_db': EnvConfig.dbName,
          'level_id': levelId,
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(
        'Failed to fetch course results: $e',
        500,
      );
    }
  }
}