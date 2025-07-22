import 'package:linkschool/modules/services/api/api_service.dart';

class SyllabusContentService {
  final ApiService _apiService;

  SyllabusContentService(this._apiService);

  Future<ApiResponse<Map<String, dynamic>>> getSyllabusContents(int syllabusId, String dbName) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/elearning/syllabus/contents/$syllabusId',
        queryParams: {
          '_db': dbName,
        },
      );
      
      return response;
    } catch (e) {
      print('Error fetching syllabus contents: $e');
      return ApiResponse<Map<String, dynamic>>.error(
        'Failed to fetch syllabus contents: $e',
        500,
      );
    }
  }
}
