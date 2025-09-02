import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/e-learning/activity_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class OverviewService {
  final ApiService _apiService;

  OverviewService(this._apiService);

  Future<Map<String, dynamic>> getOverview(String term) async {
    final userBox = Hive.box('userData');
  final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
  final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
  
  if (loginData == null || loginData['token'] == null) {
    throw Exception("No valid login data or token found");
  }

  final token = loginData['token'] as String;
  print("Set token: $token");
  _apiService.setAuthToken(token);
    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint: 'portal/elearning/overview',
      queryParams: {
        '_db': 'aalmgzmy_linkskoo_practice',
        'term': term,
      },
      fromJson: (json) {
        if (json['success'] == true && json['response'] is Map) {
          final responseData = json['response'];

          final quizzes = (responseData['recent_quizzes'] as List)
              .map((q) => RecentQuizModel.fromJson(q))
              .toList();

          final activities = (responseData['recent_activities'] as List)
              .map((a) => RecentActivityModel.fromJson(a))
              .toList();

          return {
            'recent_quizzes': quizzes,
            'recent_activities': activities,
          };
        }
        throw Exception('Failed to load overview data');
      },
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    return response.data ?? {};
  }
}
