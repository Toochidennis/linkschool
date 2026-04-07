import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/home/add_course_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class CourseService {
  final ApiService _apiService;

  CourseService(this._apiService);

  Future<void> createCourse(Map<String, dynamic> newCourse) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);
    newCourse['_db'] = dbName;
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/courses',
        body: newCourse,
      );
      if (!response.success) {
        // Remove the use of GlobalKey<NavigatorState>().currentContext!
        // Instead, just throw the error and let the UI handle the snackbar
        throw Exception("Failed to create course: ${response.message}");
      } else {
        // Do not throw or show snackbar here, just return
        return;
      }
    } catch (e) {
      // Only throw if the error is not a success
      throw Exception("Failed to create course: $e");
    }
  }

  Future<void> updateCourse(
      String courseId, Map<String, dynamic> updatedCourse) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }
    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);
    updatedCourse['_db'] = dbName;
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/courses/$courseId',
        body: updatedCourse,
      );
      if (!response.success) {
        throw Exception("Failed to update course: ${response.message}");
      } else {
      }
    } catch (e) {
      throw Exception("Failed to update course: $e");
    }
  }

  Future<void> deleteCourse(String courseId) async {
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
        endpoint: 'portal/courses/$courseId',
        body: {
          '_db': dbName,
        },
      );
      if (!response.success) {
        throw Exception("Failed to delete course: ${response.message}");
      } else {
      }
    } catch (e) {
      throw Exception("Failed to delete course: $e");
    }
  }

  Future<List<Courses>> fetchCourses() async {
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
        endpoint: 'portal/courses',
        queryParams: {
          '_db': dbName,
        },
      );
      if (!response.success) {
        throw Exception("Failed to fetch courses: ${response.message}");
      }
      final data = response.rawData?['response'];
      if (data is List) {
        return data
            .map((json) => Courses.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception("Unexpected response format");
      }
    } catch (e) {
      throw Exception("Failed to fetch courses: $e");
    }
  }
}

