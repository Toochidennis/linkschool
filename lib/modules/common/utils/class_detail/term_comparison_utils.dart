import 'package:hive/hive.dart';

class TermComparisonUtils {
  /// Compare user's login year/term with selected term year/term_value
  /// Returns true if they match, false otherwise
  static bool isCurrentUserTerm(String selectedYear, int selectedTermValue) {
    try {
      final userBox = Hive.box('userData');

      // Get user's login data
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
      if (loginData == null) {
        print('No login data found for term comparison');
        return false;
      }

      // Extract settings from login response
      final responseData = loginData['response'] ?? loginData;
      final data = responseData['data'] ?? {};
      final settings = data['settings'] ?? {};

      // Get user's year and term from settings
      final userYear = settings['year']?.toString();
      final userTerm = settings['term'];

      print('User login year: $userYear, term: $userTerm');
      print('Selected year: $selectedYear, term: $selectedTermValue');

      if (userYear == null || userTerm == null) {
        print('User year or term is null');
        return false;
      }

      // Convert user term to int for comparison
      final userTermInt =
          userTerm is int ? userTerm : int.tryParse(userTerm.toString());

      if (userTermInt == null) {
        print('Could not parse user term to int');
        return false;
      }

      // Compare year and term
      final yearMatch = userYear == selectedYear;
      final termMatch = userTermInt == selectedTermValue;

      print('Year match: $yearMatch, Term match: $termMatch');

      return yearMatch && termMatch;
    } catch (e) {
      print('Error in term comparison: $e');
      return false;
    }
  }

  /// Get user's current year and term from login data
  static Map<String, dynamic> getUserYearTerm() {
    try {
      final userBox = Hive.box('userData');
      final loginData = userBox.get('userData') ?? userBox.get('loginResponse');

      if (loginData == null) {
        return {'year': null, 'term': null};
      }

      final responseData = loginData['response'] ?? loginData;
      final data = responseData['data'] ?? {};
      final settings = data['settings'] ?? {};

      return {
        'year': settings['year']?.toString(),
        'term': settings['term'],
      };
    } catch (e) {
      print('Error getting user year/term: $e');
      return {'year': null, 'term': null};
    }
  }
}
