import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/home/level_class_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class LevelClassService {
  final ApiService _apiService;

  LevelClassService(this._apiService);

  Future<void> createLevel(Map<String, dynamic> newLevel) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    newLevel['_db'] = dbName;
    print("Request Payload: $newLevel");
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/levels',
        body: newLevel,
      );
      print("Response Status Code: ${response.statusCode}");
      if (!response.success) {
        print("Failed to create level");
        print("Error: ${response.message ?? 'No error message provided'}");
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        );
        throw Exception("Failed to create level: ${response.message}");
      } else {
        print('Level created successfully.');
        SnackBar(
          content: Text('Level created successfully.'),
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      print("Error creating level: $e");
      throw Exception("Failed to create level: $e");
    }
  }

  Future<void> createClass(Map<String, dynamic> newClass) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    newClass['_db'] = dbName;
    print("Request Payload: $newClass");
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/classes',
        body: newClass,
      );
      print("Response Status Code: ${response.statusCode}");
      if (!response.success) {
        print("Failed to create class");
        print("Error: ${response.message ?? 'No error message provided'}");
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        );
        throw Exception("Failed to create class: ${response.message}");
      } else {
        print('Class created successfully.');
        SnackBar(
          content: Text('Class created successfully.'),
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      print("Error creating class: $e");
      throw Exception("Failed to create class: $e");
    }
  }

  Future<void> updateLevel(
      String levelId, Map<String, dynamic> updatedLevel) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    updatedLevel['_db'] = dbName;
    print("Update Request Payload: $updatedLevel");
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/levels/$levelId',
        body: updatedLevel,
      );
      if (!response.success) {
        print("Failed to update level");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to update level: ${response.message}");
      } else {
        print('Level updated successfully.');
      }
    } catch (e) {
      print("Error updating level: $e");
      throw Exception("Failed to update level: $e");
    }
  }

  Future<void> updateClass(
      String className, Map<String, dynamic> updatedClass) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    updatedClass['_db'] = dbName;
    print("Update Request Payload: $updatedClass");
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/classes/$className',
        body: updatedClass,
      );
      if (!response.success) {
        print("Failed to update class");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to update class: ${response.message}");
      } else {
        print('Class updated successfully.');
      }
    } catch (e) {
      print("Error updating class: $e");
      throw Exception("Failed to update class: $e");
    }
  }

  Future<void> deleteLevel(String levelId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint: 'portal/levels/$levelId',
        body: {
          '_db': dbName,
        },
      );
      if (!response.success) {
        print("Failed to delete level");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to delete level: ${response.message}");
      } else {
        print('Level deleted successfully.');
      }
    } catch (e) {
      print("Error deleting level: $e");
      throw Exception("Failed to delete level: $e");
    }
  }

  Future<void> deleteClass(String className) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint: 'portal/classes/$className',
        body: {
          '_db': dbName,
        },
      );
      if (!response.success) {
        print("Failed to delete class");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to delete class: ${response.message}");
      } else {
        print('Class deleted successfully.');
      }
    } catch (e) {
      print("Error deleting class: $e");
      throw Exception("Failed to delete class: $e");
    }
  }

  Future<List<Levels>> fetchLevels() async {
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
        endpoint: 'portal/levels',
        queryParams: {
          '_db': dbName,
        },
      );
      print("Fetch Levels Response Status Code: ${response.statusCode}");
      if (!response.success) {
        print("Failed to fetch levels");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to fetch levels: ${response.message}");
      }

      final data = response.rawData?['data'];
      if (data is List) {
        print('Levels fetched successfully: ${data.length} levels found.');
        return data
            .map((json) => Levels.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print("Unexpected response format");
        throw Exception("Unexpected response format");
      }
    } catch (e) {
      print("Error fetching levels: $e");
      throw Exception("Failed to fetch levels: $e");
    }
  }

  Future<List<Class>> fetchClasses() async {
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
        endpoint: 'portal/classes',
        queryParams: {
          '_db': dbName,
        },
      );
      print("Fetch Classes Response Status Code: ${response.statusCode}");
      if (!response.success) {
        print("Failed to fetch classes");
        print("Error: ${response.message ?? 'No error message provided'}");
        throw Exception("Failed to fetch classes: ${response.message}");
      }

      final data = response.rawData?['data'];
      if (data is List) {
        print('Classes fetched successfully: ${data.length} classes found.');
        return data
            .map((json) => Class.fromJson(json as Map<String, dynamic>))
            .where((classItem) => classItem.className.isNotEmpty)
            .toList();
      } else {
        print("Unexpected response format");
        throw Exception("Unexpected response format");
      }
    } catch (e) {
      print("Error fetching classes: $e");
      throw Exception("Failed to fetch classes: $e");
    }
  }
}
