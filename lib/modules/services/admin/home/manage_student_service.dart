import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/home/manage_student_model.dart';

import 'package:linkschool/modules/services/api/api_service.dart';

class ManageStudentService {
  final ApiService _apiService;

  ManageStudentService(this._apiService);

  Future<void> createStudent(Map<String, dynamic> newStudent) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    newStudent['_db'] = dbName;
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/students',
        body: newStudent,
      );
      if (!response.success) {
       
        throw Exception("Failed to create student: ${response.message}");
      } else {
      }
    } catch (e) {

      throw Exception("Failed to create student: $e");
    }
  }

  Future<void> updateStudent(
      String studentId, Map<String, dynamic> updatedStudent) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    updatedStudent['_db'] = dbName;
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/students/$studentId',
        body: updatedStudent,
      );
      if (!response.success) {
        throw Exception("Failed to update student: ${response.message}");
      } else {
      }
    } catch (e) {
      throw Exception("Failed to update student: $e");
    }
  }

  Future<void> deleteStudent(String studentId) async {
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
        endpoint: 'portal/students/$studentId',
        body: {
          '_db': dbName,
        },
      );
      if (!response.success) {
        throw Exception("Failed to delete student: ${response.message}");
      } else {
      }
    } catch (e) {
      throw Exception("Failed to delete student: $e");
    }
  }

  Future<List<Students>> fetchStudents() async {
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
        endpoint: 'portal/students',
        queryParams: {
          '_db': dbName,
        },
      );
      if (!response.success) {
        throw Exception("Failed to fetch students: ${response.message}");
      }

      final data = response.rawData?['response'];
      if (data is List) {
        return data
            .map((json) => Students.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception("Unexpected response format");
      }
    } catch (e) {
      throw Exception("Failed to fetch students: $e");
    }
  }

  Future<StudentListResponse> fetchStudentsByLevel({
    required int levelId,
    int page = 1,
    int limit = 15,
  }) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? '';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    
    final queryParams = {
      '_db': dbName,
      'page': page.toString(),
      'limit': limit.toString(),
      'level_id': levelId.toString(),
    };
    
    
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        
        endpoint: 'portal/students',
        queryParams: queryParams,
      );
      if (!response.success) {
        throw Exception("Failed to fetch students: ${response.message}");
      }

      return StudentListResponse.fromJson(response.rawData!);
    } catch (e) {
      throw Exception("Failed to fetch students: $e");
    }
  }

  Future<StudentListResponse> fetchStudentsByClass({
    required int classId,
    int page = 1,
    int limit = 15,
  }) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? '';

    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;

    _apiService.setAuthToken(token);
    
    final queryParams = {
      '_db': dbName,
      'page': page.toString(),
      'limit': limit.toString(),
      'class_id': classId.toString(),
    };
    
    
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/students',
        queryParams: queryParams,
      );
      if (!response.success) {
        throw Exception("Failed to fetch students: ${response.message}");
      }

      return StudentListResponse.fromJson(response.rawData!);
    } catch (e) {
      throw Exception("Failed to fetch students: $e");
    }
  }
}

