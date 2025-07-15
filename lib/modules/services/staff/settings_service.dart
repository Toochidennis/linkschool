import 'package:hive/hive.dart';

class SettingsService {
  static const String _userDataBoxName = 'userData';
  
  /// Get current school year from stored settings
  static String getCurrentYear() {
    final userBox = Hive.box(_userDataBoxName);
    final settings = userBox.get('settings');
    
    if (settings != null && settings is Map<String, dynamic>) {
      return settings['year']?.toString() ?? DateTime.now().year.toString();
    }
    
    // Fallback: try to get from userData
    final userData = userBox.get('userData');
    if (userData != null && userData['data'] != null && userData['data']['settings'] != null) {
      return userData['data']['settings']['year']?.toString() ?? DateTime.now().year.toString();
    }
    
    return DateTime.now().year.toString();
  }
  
  /// Get current school term from stored settings
  static int getCurrentTerm() {
    final userBox = Hive.box(_userDataBoxName);
    final settings = userBox.get('settings');
    
    if (settings != null && settings is Map<String, dynamic>) {
      return settings['term'] ?? 1;
    }
    
    // Fallback: try to get from userData
    final userData = userBox.get('userData');
    if (userData != null && userData['data'] != null && userData['data']['settings'] != null) {
      return userData['data']['settings']['term'] ?? 1;
    }
    
    return 1;
  }
  
  /// Get current school name from stored settings
  static String getSchoolName() {
    final userBox = Hive.box(_userDataBoxName);
    final settings = userBox.get('settings');
    
    if (settings != null && settings is Map<String, dynamic>) {
      return settings['school_name']?.toString() ?? '';
    }
    
    // Fallback: try to get from userData
    final userData = userBox.get('userData');
    if (userData != null && userData['data'] != null && userData['data']['settings'] != null) {
      return userData['data']['settings']['school_name']?.toString() ?? '';
    }
    
    return '';
  }
  
  /// Get term name from term number
  static String getTermName(int term) {
    switch (term) {
      case 1:
        return 'First Term';
      case 2:
        return 'Second Term';
      case 3:
        return 'Third Term';
      default:
        return 'Unknown Term';
    }
  }
  
  /// Get all settings as a map
  static Map<String, dynamic> getAllSettings() {
    final userBox = Hive.box(_userDataBoxName);
    final settings = userBox.get('settings');
    
    if (settings != null && settings is Map<String, dynamic>) {
      return Map<String, dynamic>.from(settings);
    }
    
    // Fallback: try to get from userData
    final userData = userBox.get('userData');
    if (userData != null && userData['data'] != null && userData['data']['settings'] != null) {
      return Map<String, dynamic>.from(userData['data']['settings']);
    }
    
    return {
      'school_name': '',
      'year': DateTime.now().year.toString(),
      'term': 1,
    };
  }
  
  /// Get database name from stored data
  static String getDatabaseName() {
    final userBox = Hive.box(_userDataBoxName);
    final userData = userBox.get('userData');
    
    if (userData != null && userData['_db'] != null) {
      return userData['_db'].toString();
    }
    
    // Fallback to environment config
    return 'aalmgzmy_linkskoo_practice'; // You can replace this with your env config
  }
}
