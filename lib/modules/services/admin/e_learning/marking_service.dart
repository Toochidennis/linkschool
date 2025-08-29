import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import '../../../model/e-learning/mark_assignment_model.dart';

class MarkingService {
  final ApiService _apiService;

  MarkingService(this._apiService);

  Future<Map<String, dynamic>> getAssignment(String itemId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('User not logged in');
    }

    final processedData = loginData is String
        ? json.decode(loginData)
        : loginData as Map<String, dynamic>;
    final responseData = processedData['response'] ?? processedData;
    final data = responseData['data'] ?? responseData;
    final profile = data['profile'] ?? {};
    final settings = data['settings'] ?? {};
    final academicYear = settings['year']?.toString();
    final academicTerm = settings['term'] as int?;

    final token = processedData['token'] as String? ?? loginData['token'] as String?;
    if (token == null) {
      throw Exception('No auth token found');
    }
    print("Set token: $token");
    _apiService.setAuthToken(token);
  print('portal/elearning/assignment/$academicTerm');
  print('portal/elearning/assignment/$academicYear');
  print('portal/elearning/assignment/$itemId');
  print('portal/elearning/assignment/');
    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint: 'portal/elearning/assignment/$itemId/submissions',
      
      queryParams: {
        "term": academicTerm,
        "year": academicYear,
        '_db': dbName,
      },
      fromJson: (json) {
        if (json['success'] == true && json['response'] is Map) {
          final responseData = json['response'] as Map<String, dynamic>;
          return {
            'submitted': responseData['submitted'] ?? [],
            'unmarked': responseData['unmarked'] ?? [],
            'marked': responseData['marked'] ?? [],
            'notSubmitted': responseData['not_submitted'] ?? [],
          };
        }
        throw Exception('Failed to load assignment data');
      },
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    return response.data ?? {};
  }

  Future<void> markAssignment(String itemId ,String score) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('User not logged in');
    }

    final processedData = loginData is String
        ? json.decode(loginData)
        : loginData as Map<String, dynamic>;
    final responseData = processedData['response'] ?? processedData;


    final token = processedData['token'] as String? ?? loginData['token'] as String?;
    if (token == null) {
      throw Exception('No auth token found');
    }
    print("Set token: $token");
    _apiService.setAuthToken(token);

    final response = await _apiService.put<Map<String, dynamic>>(
      endpoint: 'portal/elearning/assignment/mark',
      body: {
        'id': itemId,
        'score':score,
        '_db': dbName,
      },
      fromJson: (json) {
        if (json['success'] == true) {
          return json;
        }
        throw Exception('Failed to submit marking data');
      },
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> returnAssignment(
String publish,
String contentId
  ) async {
      final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('User not logged in');
    }

    final processedData = loginData is String
        ? json.decode(loginData)
        : loginData as Map<String, dynamic>;
    final responseData = processedData['response'] ?? processedData;
    final data = responseData['data'] ?? responseData;
    final profile = data['profile'] ?? data;
    final settings = data['settings'] ?? profile;
    final academicYear = settings['year']?.toString();  
    final academicTerm = settings['term'] as int?;

    final token = processedData['token'] as String? ?? loginData['token'] as String?;
    if (token == null) {
      throw Exception('No auth token found');
    }
    print("Set token: $token");
    _apiService.setAuthToken(token);

    final response = _apiService.put<Map<String, dynamic>>(
      endpoint: 'portal/elearning/assignment/$contentId/publish',
      body: {
        '_db': dbName,
        "term": academicTerm,
        "year": academicYear,
        "publish": publish, 
      },

    
      fromJson: (json) {
        if (json['success'] == true) {
          return json;
        }
        throw Exception('Failed to submit marking data');
      },
    );
    
  }

  // ---------------quiz--------------------------------

    Future<Map<String, dynamic>> getQuiz(String itemId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('User not logged in');
    }

    final processedData = loginData is String
        ? json.decode(loginData)
        : loginData as Map<String, dynamic>;
    final responseData = processedData['response'] ?? processedData;
    final data = responseData['data'] ?? responseData;
    final profile = data['profile'] ?? {};
    final settings = data['settings'] ?? {};
    final academicYear = settings['year']?.toString();
    final academicTerm = settings['term'] as int?;

    final token = processedData['token'] as String? ?? loginData['token'] as String?;
    if (token == null) {
      throw Exception('No auth token found');
    }
    print("Set token: $token");
    _apiService.setAuthToken(token);
  print('portal/elearning/assignment/$academicTerm');
  print('portal/elearning/assignment/$academicYear');
  print('portal/elearning/assignment/$itemId');
  print('portal/elearning/assignment/');
    final response = await _apiService.get<Map<String, dynamic>>(
      endpoint: 'portal/elearning/quiz/$itemId/submissions',
      
      queryParams: {
        "term": academicTerm,
        "year": academicYear,
        '_db': dbName,
      },
    fromJson: (json) {
  if (json['success'] == true && json['data'] is Map) {
    final responseData = json['data'] as Map<String, dynamic>;
    return {
      'submitted': responseData['submitted'] ?? [],
      'unmarked': responseData['unmarked'] ?? [],
      'marked': responseData['marked'] ?? [],
    };
  }
  throw Exception('Failed to load quiz data');
},

    );

    if (!response.success) {
      throw Exception(response.message);
    }

    return response.data ?? {};
  }


    Future<void> markQuiz(String itemId ,String score) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('User not logged in');
    }

    final processedData = loginData is String
        ? json.decode(loginData)
        : loginData as Map<String, dynamic>;
    final responseData = processedData['response'] ?? processedData;


    final token = processedData['token'] as String? ?? loginData['token'] as String?;
    if (token == null) {
      throw Exception('No auth token found');
    }
    print("Set token: $token");
    _apiService.setAuthToken(token);

    final response = await _apiService.put<Map<String, dynamic>>(
      endpoint: 'portal/elearning/quiz/mark',
      body: {
        'id': itemId,
        'score':score,
        '_db': dbName,
      },
      fromJson: (json) {
        if (json['success'] == true) {
          return json;
        }
        throw Exception('Failed to submit marking data');
      },
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

   Future<void> returnQuiz(
String publish,
String contentId
  ) async {
      final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';

    if (loginData == null) {
      throw Exception('User not logged in');
    }

    final processedData = loginData is String
        ? json.decode(loginData)
        : loginData as Map<String, dynamic>;
    final responseData = processedData['response'] ?? processedData;
    final data = responseData['data'] ?? responseData;
    final profile = data['profile'] ?? data;
    final settings = data['settings'] ?? profile;
    final academicYear = settings['year']?.toString();  
    final academicTerm = settings['term'] as int?;

    final token = processedData['token'] as String? ?? loginData['token'] as String?;
    if (token == null) {
      throw Exception('No auth token found');
    }
    print("Set token: $token");
    _apiService.setAuthToken(token);

    final response = _apiService.put<Map<String, dynamic>>(
      endpoint: 'portal/elearning/quiz/$contentId/publish',
      body: {
        '_db': dbName,
        "term": academicTerm,
        "year": academicYear,
        "publish": publish, 
      },

    
      fromJson: (json) {
        if (json['success'] == true) {
          return json;
        }
        throw Exception('Failed to submit marking data');
      },
    );
    
  }


}