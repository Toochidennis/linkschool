import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class TopicService {
  final ApiService _apiService;

  TopicService(this._apiService);

  Future<List<Topic>> FetchTopic({required int syllabusId}) async {
    try {

      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

      if (loginData == null) {
        throw Exception('No login data available');
      }

      // Get database name from settings or use default
      String dbName = 'aalmgzmy_linkskoo_practice';
      try {
        final processedData =
            loginData is String ? json.decode(loginData) : loginData;
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final settings = data['settings'] ?? {};
        dbName = settings['db_name']?.toString() ?? dbName;
      } catch (e) {
      // Intentionally ignored.
    }

      // Get token
      final token = loginData is Map
          ? (loginData['token'] ?? userBox.get('token'))
          : userBox.get('token');

      if (token == null) {
        throw Exception('No valid token found');
      }

      _apiService.setAuthToken(token);

      final response = await _apiService.get<List<Topic>>(
        endpoint: 'portal/elearning/syllabus/$syllabusId/topics',
        queryParams: {'_db': dbName},
        fromJson: (json) {
          if (json['success'] == true && json['response'] is List) {
            return (json['response'] as List)
                .map((topicJson) =>
                    Topic.fromJson(topicJson as Map<String, dynamic>))
                .toList();
          }
          throw Exception(
              'Failed to load topics: ${json['message'] ?? 'Unknown error'}');
        },
      );


      if (!response.success) {
        throw Exception(response.message);
      }

      final topics = response.data ?? [];
      return topics;
    } catch (e) {
      rethrow; // Re-throw to let the provider handle it
    }
  }

  Future<void> createTopic(
      {required String topic,
      required String objective,
      required int creatorId,
      required String courseName,
      required String courseId,
      required String creatorName,
      required String levelId,
      required String term,
      required List<ClassModel> classes,
      required int syllabusId}) async {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

      if (loginData == null) {
        throw Exception('No login data available');
      }

      // Get database name
      String dbName = 'aalmgzmy_linkskoo_practice';
      try {
        final processedData =
            loginData is String ? json.decode(loginData) : loginData;
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final settings = data['settings'] ?? {};
        dbName = settings['db_name']?.toString() ?? dbName;
      } catch (e) {
      // Intentionally ignored.
    }

      final token = loginData is Map
          ? (loginData['token'] ?? userBox.get('token'))
          : userBox.get('token');

      if (token != null) {
        _apiService.setAuthToken(token);
      }

      final classesJson =
          classes.map((classModel) => classModel.toJson()).toList();

      final requestBody = {
        'syllabus_id': syllabusId,
        'topic': topic,
        'creator_name': creatorName,
        'objective': objective,
        'creator_id': creatorId,
        'course_name': courseName,
        'course_id': courseId,
        'level_id': levelId,
        'term': term,
        'classes': classesJson,
        '_db': dbName,
      };


      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/elearning/topic',
        body: requestBody,
      );

      if (!response.success) {
        throw Exception('Failed to create topic: ${response.message}');
      } else {
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> UpdateTopic(
      {required String topicId,
      required String topic,
      required String objective,
      required int creatorId,
      required String courseName,
      required String courseId,
      required String creatorName,
      required String levelId,
      required String term,
      required List<ClassModel> classes,
      required int syllabusId}) async {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

      if (loginData == null) {
        throw Exception('No login data available');
      }

      // Get database name
      String dbName = 'aalmgzmy_linkskoo_practice';
      try {
        final processedData =
            loginData is String ? json.decode(loginData) : loginData;
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final settings = data['settings'] ?? {};
        dbName = settings['db_name']?.toString() ?? dbName;
      } catch (e) {
      // Intentionally ignored.
    }

      final token = loginData is Map
          ? (loginData['token'] ?? userBox.get('token'))
          : userBox.get('token');

      if (token != null) {
        _apiService.setAuthToken(token);
      }

      final classesJson =
          classes.map((classModel) => classModel.toJson()).toList();

      final requestBody = {
        'syllabus_id': syllabusId,
        'topic': topic,
        'creator_name': creatorName,
        'objective': objective,
        'creator_id': creatorId,
        'course_name': courseName,
        'course_id': courseId,
        'level_id': levelId,
        'term': term,
        'classes': classesJson,
        '_db': dbName,
      };


      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/elearning/topic/$topicId',
        body: requestBody,
      );

      if (!response.success) {
        throw Exception('Failed to create topic: ${response.message}');
      } else {
      }
    } catch (e) {
      rethrow;
    }
  }
}

// import 'dart:convert';

// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/model/e-learning/topic_model.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';

// class TopicService {
//   final ApiService _apiService;

//   TopicService(this._apiService);

// Future<List<Topic>> FetchTopic({required int syllabusId}) async {
//   try {
//     final userBox = Hive.box('userData');
//     final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
//     final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

//     if (loginData == null) {
//       throw Exception('No login data available');
//     }

//     final token = loginData['token'] ?? userBox.get('token');
//     if (token == null) {
//       throw Exception('No valid token found');
//     }
//     _apiService.setAuthToken(token);

//     final response = await _apiService.get<List<Topic>>(
//       endpoint: 'portal/elearning/topic/$syllabusId',
//       queryParams: {'_db': dbName},
//       fromJson: (json) {
//         if (json['success'] == true && json['response'] is List) {
//           return (json['response'] as List)
//               .map((topicJson) => Topic.fromJson(topicJson as Map<String, dynamic>))
//               .toList();
//         }
//         throw Exception('Failed to load topics: ${json['message'] ?? 'Unknown error'}');
//       },
//     );


//     if (!response.success) {
//       throw Exception(response.message);
//     }

//     return response.data ?? [];
//   } catch (e, stackTrace) {
//     return [];
//   }
// }

//   Future<void> createTopic({
//     required String topic,
//     required String objective,
//     required int creatorId,
//     required String creatorName,
//     required List<ClassModel> classes,
//     required int syllabusId
//   }) async {
//     final userBox = Hive.box('userData');
//     final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

//     final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

//     if (loginData == null) {
//       throw Exception('No login data available');
//     }

//     final token = loginData['token'] ?? userBox.get('token');

//     if (token != null) {
//       _apiService.setAuthToken(token);
//     }

//     final classesJson =
//         classes.map((classModel) => classModel.toJson()).toList();

//     final requestBody = {
//       'syllabus_id': syllabusId,
//       'topic': topic,
//       'creator_name': creatorName,
//       'objective': objective,
//       'creator_id': creatorId,
//       'classes': classesJson,
//       '_db': dbName,
//     };


//     final response = await _apiService.post<Map<String, dynamic>>(
//       endpoint: 'portal/elearning/topic',
//       body: requestBody,
//     );

//     if (!response.success) {
//       throw Exception('Failed to create topic: ${response.message}');
//     } else {
//     }
//   }
// }


