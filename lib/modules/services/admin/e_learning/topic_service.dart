import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class TopicService {
  final ApiService _apiService;

  TopicService(this._apiService);

  Future<void> createTopic({
    required String topic,
    required String objective,
    required int creatorId,
    required String creatorName,
    required List<ClassModel> classes,
    int syllabusId = 0, // Default value or pass from UI
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

    final classesJson = classes.map((classModel) => classModel.toJson()).toList();
    
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