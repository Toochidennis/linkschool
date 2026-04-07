import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class MaterialService {
  final ApiService _apiService;
  MaterialService(this._apiService);
  Future<void> AddMaterial(Map material) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    material['_db'] = dbName;

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/elearning/material',
        body: material,
      );


      if (!response.success) {
        throw Exception("Failed to Add Material: ${response.message}");
      } else {
      }
    } catch (e) {
      throw Exception("Failed to Add Material: $e");
    }
  }

  Future<void> UpDateMaterial(Map material, int id) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    material['_db'] = dbName;

    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/elearning/material/$id',
        body: material,
      );


      if (!response.success) {
        throw Exception("Failed to Add Material: ${response.message}");
      } else {
      }
    } catch (e) {
      throw Exception("Failed to Update Material: $e");
    }
  }

  Future<void> deleteMaterial(int id) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.delete<void>(
        endpoint: 'portal/elearning/material/$id',
        body: {'_db': dbName},
      );

      if (!response.success) {
        throw Exception("Failed to delete material: ${response.message}");
      }
    } catch (e) {
      throw Exception("Failed to delete material: $e");
    }
  }
}

