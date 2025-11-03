import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class TermService {
  late ApiService _apiService;

  TermService([ApiService? apiService]) {
    _apiService = apiService ?? locator<ApiService>();
  }

  set apiService(ApiService service) => _apiService = service;

  Future<List<Map<String, dynamic>>> fetchTerms(String classId) async {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
      
      if (loginData == null) {
        throw Exception('No login data available');
      }

      final responseData = loginData['response'] ?? loginData;
      final data = responseData['data'] ?? {};
      final settings = data['settings'] ?? {};
      final db = loginData['_db'] ?? 'aalmgzmy_linkskoo_practice';
      final year = settings['year']?.toString() ?? '2023';
      final term = settings['term']?.toString() ?? '1';
      final token = loginData['token'] ?? userBox.get('token');

      if (token != null) {
        _apiService.setAuthToken(token);
      }

      print('Fetching terms for class $classId (year: $year, term: $term, db: $db)');

      final response = await _apiService.get(
        endpoint: 'portal/course-registrations/terms',
        queryParams: {
          'year': year,
          'class_id': classId,
          '_db': db,
          'term': term,
        },
      );

      print('API Response: ${response.rawData}, Success: ${response.success}, Message: ${response.message}');

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to fetch terms');
      }

      final resData = response.rawData;
      if (resData == null || resData['response'] == null || resData['response']['sessions'] == null) {
        return [];
      }

      final sessions = resData['response']['sessions'] as List;
      final terms = <Map<String, dynamic>>[];

      for (var session in sessions) {
        final sessionYear = session['year'].toString();
        final sessionTerms = session['terms'] as List;
        
        for (var term in sessionTerms) {
          terms.add({
            'year': sessionYear,
            'termId': term['term_value'],
            'termName': term['term_name'],
            'averageScore': term['average_score']?.toDouble() ?? 0.0,
          });
        }
      }

      print('Successfully fetched ${terms.length} terms');
      return terms;
    } catch (e) {
      print('Error fetching terms: $e');
      throw Exception('Failed to load terms: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> fetchTermsAndChartData(String classId) async {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
      
      if (loginData == null) {
        throw Exception('No login data available');
      }

      final responseData = loginData['response'] ?? loginData;
      final data = responseData['data'] ?? {};
      final settings = data['settings'] ?? {};
      final db = loginData['_db'] ?? 'aalmgzmy_linkskoo_practice';
      final year = settings['year']?.toString() ?? '2023';
      final term = settings['term']?.toString() ?? '1';
      final token = loginData['token'] ?? userBox.get('token');

      if (token != null) {
        _apiService.setAuthToken(token);
      }

      print('Fetching terms and chart data for class $classId (year: $year, term: $term, db: $db)');

      final response = await _apiService.get(
        endpoint: 'portal/course-registrations/terms',
        queryParams: {
          'year': year,
          'class_id': classId,
          '_db': db,
          'term': term,
        },
      );

      print('API Response: ${response.rawData}, Success: ${response.success}, Message: ${response.message}');

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to fetch terms');
      }

      final resData = response.rawData;
      if (resData == null || resData['response'] == null || resData['response']['sessions'] == null) {
        return {'terms': [], 'chart_data': []};
      }

      final sessions = resData['response']['sessions'] as List;
      final terms = <Map<String, dynamic>>[];

      for (var session in sessions) {
        final sessionYear = session['year'].toString();
        final sessionTerms = session['terms'] as List;
        
        for (var term in sessionTerms) {
          terms.add({
            'year': sessionYear,
            'termId': term['term_value'],
            'termName': term['term_name'],
            'averageScore': term['average_score']?.toDouble() ?? 0.0,
          });
        }
      }

      final chartData = (resData['response']['chart_data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      print('Successfully fetched ${terms.length} terms and ${chartData.length} chart data entries');
      return {'terms': terms, 'chart_data': chartData};
    } catch (e) {
      print('Error fetching terms and chart data: $e');
      throw Exception('Failed to load terms: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAverageScores(String classId, String year, int term) async {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
      
      if (loginData == null) {
        throw Exception('No login data available');
      }

      final db = loginData['_db'] ?? 'aalmgzmy_linkskoo_practice';
      final token = loginData['token'] ?? userBox.get('token');

      if (token != null) {
        _apiService.setAuthToken(token);
      }

      print('Fetching average scores for class $classId (year: $year, term: $term, db: $db)');

      final response = await _apiService.get(
        endpoint: 'portal/classes/$classId/course-registrations/average-scores',
        queryParams: {
          'year': year,
          'term': term.toString(),
          '_db': db,
        },
      );

      print('API Response: ${response.rawData}, Success: ${response.success}, Message: ${response.message}');

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to fetch average scores');
      }

      final resData = response.rawData;
      if (resData == null || resData['data'] == null) {
        return [];
      }

      final scores = resData['data'] as List;
      final averageScores = scores.map((score) => ({
        'course_id': score['course_id'],
        'course_name': score['course_name'],
        'average_score': score['average_score'],
      })).toList();

      print('Successfully fetched ${averageScores.length} average scores');
      return averageScores;
    } catch (e) {
      print('Error fetching average scores: $e');
      throw Exception('Failed to load average scores: ${e.toString()}');
    }
  }
}


