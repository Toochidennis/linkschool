import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/staff/syllabus_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class StaffSyllabusService {
  final ApiService _apiService;

  StaffSyllabusService(this._apiService);

  Future<List<StaffSyllabusModel>> getSyllabus(
      String levelId, String term, String courseId, String classId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('No login data available');
    }

    final token = loginData['token'] ?? userBox.get('token');

    if (token != null) {
      _apiService.setAuthToken(token);
      print('Token set: $token');
    }
    print("servers:$classId");
    print("servers:$levelId");
    print("servers:$term");
    print("servers:$courseId");

    final response = await _apiService.get<List<StaffSyllabusModel>>(
      endpoint: 'portal/elearning/syllabus/staff',
      queryParams: {
        '_db': dbName,
        'level_id': levelId,
        'term': term,
        'course_id': courseId,
        "class_id": classId
      },
      fromJson: (json) {
        if (json['success'] == true && json['response'] is List) {
          return (json['response'] as List)
              .map((syllabusJson) => StaffSyllabusModel.fromJson(syllabusJson))
              .toList();
        }
        throw Exception('Failed to load syllabus: ${json['message']}');
      },
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    return response.data ?? [];
  }

  Future<void> addSyllabus(StaffSyllabusModel syllabus) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('No login data available');
    }

    final token = loginData['token'] ?? userBox.get('token');

    if (token != null) {
      _apiService.setAuthToken(token);
      print('Token set: $token');
    }
    final classesJson =
        syllabus.classes.map((classModel) => classModel.toJson()).toList();
    final requestBody = {
      'title': syllabus.title,
      'description': syllabus.description,
      'course_id': syllabus.courseId,
      'course_name': syllabus.courseName,
      'level_id': syllabus.levelId,
      'creator_name': syllabus.authorName,
      'creator_id': syllabus.creatorId,
      'term': syllabus.term,
      'classes': classesJson,
      '_db': dbName
    };

    print('Request Body: $requestBody');

    final response = await _apiService.post<Map<String, dynamic>>(
      endpoint: 'portal/elearning/syllabus',
      body: requestBody,
    );

    if (!response.success) {
      print('Failed to add syllabus: ${response.message}');
      throw Exception('Failed to add syllabus: ${response.message}');
    } else {
      print('Syllabus added: ${response.message}');
    }
  }

  Future<void> UpdateSyllabus(
      StaffSyllabusModel syllabus, int syllabusId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('No login data available');
    }

    final token = loginData['token'] ?? userBox.get('token');

    if (token != null) {
      _apiService.setAuthToken(token);
      print('Token set: $token');
    }
    final classesJson =
        syllabus.classes.map((classModel) => classModel.toJson()).toList();
    final requestBody = {
      'title': syllabus.title,
      'description': syllabus.description,
      'classes': classesJson,
      '_db': dbName
    };

    print('Request Body: $requestBody');

    final response = await _apiService.put<Map<String, dynamic>>(
      endpoint: 'portal/elearning/syllabus/$syllabusId',
      body: requestBody,
    );

    if (!response.success) {
      print('Failed to add syllabus: ${response.message}');
      throw Exception('Failed to add syllabus: ${response.message}');
    } else {
      print('Syllabus added: ${response.message}');
    }
  }

  Future<void> deletesyllabus(int syllabusId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('No login data available');
    }

    final token = loginData['token'] ?? userBox.get('token');

    if (token != null) {
      _apiService.setAuthToken(token);
      print('Token set: $token');
    }

    final response = await _apiService.delete<Map<String, dynamic>>(
      endpoint: 'portal/elearning/syllabus/$syllabusId',
      body: {'_db': dbName},
    );

    if (!response.success) {
      print('Failed to delete syllabus: ${response.message}');
      throw Exception('Failed to delete syllabus: ${response.message}');
    } else {
      print('Syllabus deleted: ${response.message}');
    }
  }
}
