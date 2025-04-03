import 'package:hive/hive.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

// https://linkskool.net/api/v3/portal/courses/registrations/terms?year=2025&class_id=69&_db={{DB}}

class TermService {
  late ApiService _apiService;

  // Constructor
  TermService([ApiService? apiService]) {
    _apiService = apiService ?? locator<ApiService>();
  }

  set apiService(ApiService service) => _apiService = service;

  Future<List<Map<String, dynamic>>> fetchTerms(String classId) async {
    try {
      // Get required parameters from Hive
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
      
      if (loginData == null) {
        throw Exception('No login data available');
      }

      // Extract needed parameters
      final responseData = loginData['response'] ?? loginData;
      final data = responseData['data'] ?? {};
      final settings = data['settings'] ?? {};
      final db = loginData['_db'] ?? 'aalmgzmy_linkskoo_practice';
      final year = settings['year']?.toString() ?? '2025';
      final token = loginData['token'] ?? userBox.get('token');

      // Set authentication token
      if (token != null) {
        _apiService.setAuthToken(token);
      }

      print('Fetching terms for class $classId (year: $year, db: $db)');

      // Make API request
      final response = await _apiService.get(
        endpoint: 'portal/courses/registrations/terms',
        queryParams: {
          'year': year,
          'class_id': classId,
          '_db': db,
        },
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to fetch terms');
      }

      // Parse response
      final resData = response.rawData;
      if (resData == null || resData['sessions'] == null) {
        return [];
      }

      final sessions = resData['sessions'] as Map<String, dynamic>;
      final terms = <Map<String, dynamic>>[];

      sessions.forEach((year, sessionData) {
        if (sessionData is Map && sessionData['terms'] is List) {
          for (var term in (sessionData['terms'] as List)) {
            terms.add({
              'year': year,
              'termId': term,
              'termName': 'Term $term',
            });
          }
        }
      });

      print('Successfully fetched ${terms.length} terms');
      return terms;
    } catch (e) {
      print('Error fetching terms: $e');
      throw Exception('Failed to load terms: ${e.toString()}');
    }
  }
}