import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/level_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class LevelService {
  final ApiService _apiService = locator<ApiService>();

  Future<List<Level>> fetchLevels() async {
    try {
      final userBox = Hive.box('userData');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

      final response = await _apiService.get(
        endpoint: 'portal/assessments',
        queryParams: {'_db': dbName},
      );

      if (response.success && response.rawData?['response'] != null) {
        final Map<String, dynamic> levelsData = response.rawData!['response'];
        return levelsData.entries.map((entry) {
          return Level.fromJson({
            'level_id': entry.value['level_id'],
            'level_name': entry.value['level_name'],
            'assessments': entry.value['assessments'],
          });
        }).toList();
      } else {
        throw Exception(response.message ?? 'Failed to load levels');
      }
    } catch (e) {
      throw Exception('Failed to load levels: $e');
    }
  }

  Future<Level> getLevelDetails(String levelId) async {
    try {
      final userBox = Hive.box('userData');
      final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

      final response = await _apiService.get(
        endpoint: 'portal/assessments/$levelId',
        queryParams: {'_db': dbName},
      );

      if (response.success && response.rawData?['response'] != null) {
        final levelData = response.rawData!['response'].values.first;
        return Level.fromJson({
          'level_id': levelData['level_id'],
          'level_name': levelData['level_name'],
          'assessments': levelData['assessments'],
        });
      } else {
        throw Exception(response.message ?? 'Failed to load level details');
      }
    } catch (e) {
      throw Exception('Failed to load level details: $e');
    }
  }
}
