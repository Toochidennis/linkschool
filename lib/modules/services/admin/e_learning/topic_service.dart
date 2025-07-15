import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class TopicService {
  final ApiService _apiService;

  TopicService(this._apiService);


//   Future<List<Topic>> FetchTopic({int? syllabusId}) async {
//   try {
//     // Mock response for testing
//     final mockResponse = {
//       'statusCode': 200,
//       'success': true,
//       'response': [
//         {
//           'content': 'kamso 2o',
//           'objective': 'hello world',
//           'classes': [
//             {'id': '64', 'name': 'JSS1B'},
//             {'id': '69', 'name': 'JSS1A'}
//           ]
//         },
//         // Add other topics from your JSON
//       ]
//     };
  

//     final data = (mockResponse['response'] ?? []) as List;
//     if (data.isEmpty) {
//       print('No topics found in mock response for syllabusId: $syllabusId');
//       return [];
//     }
//     return data.map((json) => Topic.fromJson(json as Map<String, dynamic>)).toList();
    
//   } catch (e, stackTrace) {
//     print('Error processing mock response for syllabusId: $syllabusId, error: $e');
//     print('Stack trace: $stackTrace');
//     return [];
//   }
// }


Future<List<Topic>> FetchTopic({required int syllabusId}) async {
  try {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('No login data available');
    }

    final token = loginData['token'] ?? userBox.get('token');
    print('Token: $token');
    if (token == null) {
      throw Exception('No valid token found');
    }
    _apiService.setAuthToken(token);


    final response = await _apiService.get<List<Topic>>(
      endpoint: 'portal/elearning/topic/$syllabusId',
      queryParams: {'_db': dbName},
      fromJson: (json) {
        print('Raw JSON response: ${const JsonEncoder.withIndent('  ').convert(json)}');
        if (json['success'] == true && json['response'] is List) {
          return (json['response'] as List)
              .map((topicJson) => Topic.fromJson(topicJson as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Failed to load topics: ${json['message'] ?? 'Unknown error'}');
      },
    );

    print('API Response: status=${response.statusCode}, message=${response.message}, data=${response.data != null}');

    if (!response.success) {
      print('Failed to fetch topics: ${response.message}');
      throw Exception(response.message);
    }

    return response.data ?? [];
  } catch (e, stackTrace) {
    print('Error fetching topics for syllabusId: $syllabusId, error: $e');
    print('Stack trace: $stackTrace');
    return [];
  }
}

  Future<void> createTopic({
    required String topic,
    required String objective,
    required int creatorId,
    required String creatorName,
    required List<ClassModel> classes,
    required int syllabusId
  }) async {
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
        classes.map((classModel) => classModel.toJson()).toList();

    final requestBody = {
      'syllabus_id': syllabusId,
      'topic': topic,
      'creator_name': creatorName,
      'objective': objective,
      'creator_id': creatorId,
      'classes': classesJson,
      '_db': dbName,
    };

    print('Request Body: $requestBody');

    final response = await _apiService.post<Map<String, dynamic>>(
      endpoint: 'portal/elearning/topic',
      body: requestBody,
    );

    if (!response.success) {
      print('Failed to create topic: ${response.message}');
      throw Exception('Failed to create topic: ${response.message}');
    } else {
      print('Topic created successfully: ${response.message}');
    }
  }
}
