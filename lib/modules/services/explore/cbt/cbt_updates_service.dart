import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class CbtUpdatesService {
  final ApiService _apiService = locator<ApiService>();

  Future<ApiResponse<Map<String, dynamic>>> fetchUpdates({
    int page = 1,
    int perPage = 25,
  }) {
    return _apiService.get<Map<String, dynamic>>(
      endpoint: 'public/cbt-updates',
      queryParams: {
        'page': page,
        'limit': perPage,
      },
      addDatabaseParam: false,
      fromJson: (json) => json,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> fetchUpdateById(int id) {
    return _apiService.get<Map<String, dynamic>>(
      endpoint: 'public/cbt-updates/$id',
      addDatabaseParam: false,
      fromJson: (json) => json,
    );
  }
}
