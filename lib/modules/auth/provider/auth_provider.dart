import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/auth/model/user.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SilentLoginResult {
  success,
  invalidCredentials,
  networkError,
  unknownError,
}

enum LoginSource {
  none,
  manual,
  silent,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  final _secureStorage = const FlutterSecureStorage();

  User? _user;
  String? _token;
  bool _isLoggedIn = false;
  bool _isDemoLogin = false;
  LoginSource _loginSource = LoginSource.none;
  Map<String, dynamic>? _settings;

  bool _isSilentLoginInProgress = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isDemoLogin => _isDemoLogin;
  LoginSource get loginSource => _loginSource;
  Map<String, dynamic>? get settings => _settings;
  bool get isSilentLoginInProgress => _isSilentLoginInProgress;

  /// Main login method - saves credentials for future silent login
  Future<void> login(
      String username, String password, String schoolCode,
      {bool isDemoLogin = false}) async {
    try {
      final response = await _authService.login(username, password, schoolCode);
      if (response.success && response.rawData != null) {
        // Save login credentials securely for silent re-login
        await _saveLoginCredentials(
          username,
          password,
          schoolCode,
          isDemoLogin: isDemoLogin,
        );

        // Process and save login data
        await _processLoginResponse(
          response.rawData!,
          isDemoLogin: isDemoLogin,
          loginSource: LoginSource.manual,
        );

        notifyListeners();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Save login credentials securely
  Future<void> _saveLoginCredentials(
      String username, String password, String schoolCode,
      {required bool isDemoLogin}) async {
    try {
      // Use flutter_secure_storage for sensitive data

      await _secureStorage.write(key: 'saved_username', value: username);
      await _secureStorage.write(key: 'saved_password', value: password);
      await _secureStorage.write(key: 'saved_school_code', value: schoolCode);

      // Also save in Hive for quick access (non-sensitive flags)
      final userBox = Hive.box('userData');
      await userBox.put('has_saved_credentials', true);
      await userBox.put('saved_username', username); // For display purposes
      await userBox.put('saved_school_code', schoolCode);
      await userBox.put('isDemoLogin', isDemoLogin);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDemoLogin', isDemoLogin);

    } catch (e) {
      // Intentionally ignored.
    }
  }

  /// Process login response and save all data
  Future<void> _processLoginResponse(
    Map<String, dynamic> responseData, {
    required bool isDemoLogin,
    required LoginSource loginSource,
  }) async {
    final userBox = Hive.box('userData');

    // Convert response to proper Map<String, dynamic>
    final convertedData = _deepConvertMap(responseData);

    // Save the entire API response to Hive
    await userBox.put('userData', convertedData);
    await userBox.put('loginResponse', convertedData);

    // Extract user data
    final userData = convertedData!['data'];
    _user = User.fromJson(userData);
    _token = convertedData['token'];
    _isLoggedIn = true;
    _isDemoLogin = isDemoLogin;
    _loginSource = loginSource;

    // Save database identifier
    final db = convertedData['_db'];
    if (db != null) {
      await userBox.put('_db', db);
    }

    // Save settings data
    if (userData.containsKey('settings')) {
      _settings = Map<String, dynamic>.from(userData['settings']);
      await userBox.put('settings', _settings);
    }

    // Save login state and user details
    await userBox.put('isLoggedIn', true);
    await userBox.put('role', _user!.role);
    await userBox.put('token', _token);
    await userBox.put('sessionValid', true);
    await userBox.put('lastLoginTime', DateTime.now().millisecondsSinceEpoch);
    await userBox.put('isDemoLogin', _isDemoLogin);

    // Set the token on ApiService for future requests
    final apiService = locator<ApiService>();
    apiService.setAuthToken(_token!);

    // Save role-specific data
    await _saveRoleSpecificData(userData, userBox);

    // Store in SharedPreferences for additional persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', _user!.role);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('token', _token!);
    await prefs.setBool('sessionValid', true);
    await prefs.setBool('isDemoLogin', _isDemoLogin);
  }

  /// Save role-specific data based on user type
  Future<void> _saveRoleSpecificData(
      Map<String, dynamic> userData, Box userBox) async {
    if (_user!.role == 'admin') {
      if (userData.containsKey('levels')) {
        await userBox.put('levels', userData['levels']);
      }
      if (userData.containsKey('classes')) {
        await userBox.put('classes', userData['classes']);
      }
      if (userData.containsKey('courses')) {
        await userBox.put('courses', userData['courses']);
      }
    } else if (_user!.role == 'staff') {
      if (userData.containsKey('form_classes')) {
        await userBox.put('form_classes', userData['form_classes']);
      }
      if (userData.containsKey('courses')) {
        final staffCourses = userData['courses'];
        await userBox.put('staff_courses', staffCourses);
        await userBox.put('courses', staffCourses);
      }
    } else if (_user!.role == 'student') {
      final profile = userData['profile'] ?? {};
      await userBox.put('student_profile', profile);

      await userBox.put('student_id',
          profile['id']?.toString() ?? profile['staff_id']?.toString());
      await userBox.put('class_id', profile['class_id']?.toString());
      await userBox.put('level_id', profile['level_id']?.toString());
      await userBox.put('registration_no', profile['registration_no']);

      if (_settings != null && _settings!.containsKey('year')) {
        await userBox.put('current_year', _settings!['year'].toString());
      }
    }
  }

  /// Check login status on app startup - always attempts fresh login if credentials exist
  Future<void> checkLoginStatus() async {
    try {

      final userBox = Hive.box('userData');

      // Check if we have saved credentials in secure storage
      final savedUsername = await _secureStorage.read(key: 'saved_username');
      final savedPassword = await _secureStorage.read(key: 'saved_password');
      final savedSchoolCode =
          await _secureStorage.read(key: 'saved_school_code');
      final hasSecureCredentials = savedUsername != null &&
          savedPassword != null &&
          savedSchoolCode != null;


      // If we have saved credentials, always attempt a fresh login
      if (hasSecureCredentials) {
        final result = await _attemptSilentLogin();

        if (result == SilentLoginResult.success) {
          return;
        } else if (result == SilentLoginResult.networkError) {
          await _restoreFromSavedSession();
          return;
        } else {
          // Clear invalid credentials
          await _clearSavedCredentials();
        }
      }

      // No valid credentials - user needs to log in manually
      _isLoggedIn = false;
      _user = null;
      _token = null;
      _isDemoLogin = false;
      _loginSource = LoginSource.none;
      _settings = null;
      notifyListeners();
    } catch (e, stackTrace) {
      await _clearCorruptedSession();
    }
  }

  /// Refresh session in background without blocking UI
  void _attemptSilentLoginInBackground() {
    Future.microtask(() async {
      try {
        await _attemptSilentLogin();
      } catch (e) {
      // Intentionally ignored.
    }
    });
  }

  /// Attempt silent login using saved credentials
  Future<SilentLoginResult> _attemptSilentLogin() async {
    try {
      _isSilentLoginInProgress = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      // Retrieve saved credentials
      final username = await _secureStorage.read(key: 'saved_username');
      final password = await _secureStorage.read(key: 'saved_password');
      final schoolCode = await _secureStorage.read(key: 'saved_school_code');
      final demoLoginHive =
          Hive.box('userData').get('isDemoLogin', defaultValue: false);
      final demoLoginPrefs = prefs.getBool('isDemoLogin') ?? false;

      if (username == null || password == null || schoolCode == null) {
        return SilentLoginResult.invalidCredentials;
      }


      // Perform login in background
      final response = await _authService.login(username, password, schoolCode);

      if (response.success && response.rawData != null) {
        // Process the fresh login data
        await _processLoginResponse(
          response.rawData!,
          isDemoLogin: demoLoginHive == true || demoLoginPrefs == true,
          loginSource: LoginSource.silent,
        );

        _isSilentLoginInProgress = false;
        notifyListeners();

        return SilentLoginResult.success;
      } else {
        final message = response.message.toLowerCase();
        if (message.contains('network') ||
            message.contains('socketexception') ||
            message.contains('failed host lookup')) {
          return SilentLoginResult.networkError;
        }
        return SilentLoginResult.invalidCredentials;
      }
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('network') ||
          message.contains('socketexception') ||
          message.contains('failed host lookup')) {
        return SilentLoginResult.networkError;
      }
      return SilentLoginResult.unknownError;
    } finally {
      _isSilentLoginInProgress = false;
    }
  }

  /// Restore from saved session (fallback method)
  Future<void> _restoreFromSavedSession() async {
    final userBox = Hive.box('userData');
    final prefs = await SharedPreferences.getInstance();

    final isLoggedInHive = userBox.get('isLoggedIn', defaultValue: false);
    final isLoggedInPrefs = prefs.getBool('isLoggedIn') ?? false;
    final sessionValid = userBox.get('sessionValid', defaultValue: false);
    final userData = userBox.get('userData');
    final token = userBox.get('token');
    final demoLoginHive = userBox.get('isDemoLogin', defaultValue: false);
    final demoLoginPrefs = prefs.getBool('isDemoLogin') ?? false;


    if ((isLoggedInHive || isLoggedInPrefs) &&
        userData != null &&
        token != null) {
      final userDataMap = _deepConvertMap(userData);

      if (userDataMap == null || !userDataMap.containsKey('data')) {
        await _clearCorruptedSession();
        return;
      }

      final userDataContent = userDataMap['data'];
      if (userDataContent == null || userDataContent is! Map<String, dynamic>) {
        await _clearCorruptedSession();
        return;
      }

      try {
        _user = User.fromJson(userDataContent);
        _token = token.toString();
        _isLoggedIn = true;
        _isDemoLogin = demoLoginHive == true || demoLoginPrefs == true;
        _loginSource = LoginSource.silent;

        final apiService = locator<ApiService>();
        apiService.setAuthToken(_token!);

        final settings = userBox.get('settings');
        if (settings != null) {
          _settings = _deepConvertMap(settings);
        }

        await userBox.put(
            'lastLoginTime', DateTime.now().millisecondsSinceEpoch);


        notifyListeners();
      } catch (e, stackTrace) {
        await _clearCorruptedSession();
      }
    } else {
      _isLoggedIn = false;
      _user = null;
      _token = null;
      _isDemoLogin = false;
      _loginSource = LoginSource.none;
      _settings = null;
      notifyListeners();
    }
  }

  /// Clear saved credentials from secure storage
  Future<void> _clearSavedCredentials() async {
    try {
      await _secureStorage.delete(key: 'saved_username');
      await _secureStorage.delete(key: 'saved_password');
      await _secureStorage.delete(key: 'saved_school_code');

      final userBox = Hive.box('userData');
      await userBox.delete('has_saved_credentials');
      await userBox.delete('saved_username');
      await userBox.delete('saved_school_code');
      await userBox.delete('isDemoLogin');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isDemoLogin');

    } catch (e) {
      // Intentionally ignored.
    }
  }

  /// Logout - clears all saved user data and credentials
  Future<void> logout() async {
    try {

      // Always clear saved credentials on logout
      await _clearSavedCredentials();

      // Clear Hive user data
      final userBox = Hive.box('userData');
      await userBox.clear();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear API token
      final apiService = locator<ApiService>();
      apiService.setAuthToken('');

      // Reset state
      _user = null;
      _token = null;
      _isLoggedIn = false;
      _isDemoLogin = false;
      _loginSource = LoginSource.none;
      _settings = null;

      notifyListeners();
    } catch (e) {
      _user = null;
      _token = null;
      _isLoggedIn = false;
      _isDemoLogin = false;
      _loginSource = LoginSource.none;
      _settings = null;
      notifyListeners();
    }
  }

  /// Deep convert map helper
  Map<String, dynamic>? _deepConvertMap(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value.map((key, val) => MapEntry(key, _deepConvertValue(val)));
    }

    if (value is Map) {
      return Map<String, dynamic>.from(
        value.map((key, val) => MapEntry(
              key.toString(),
              _deepConvertValue(val),
            )),
      );
    }

    return null;
  }

  dynamic _deepConvertValue(dynamic value) {
    if (value is Map) {
      return _deepConvertMap(value);
    } else if (value is List) {
      return value.map((item) => _deepConvertValue(item)).toList();
    }
    return value;
  }

  /// Clear corrupted session
  Future<void> _clearCorruptedSession() async {
    try {
      final userBox = Hive.box('userData');
      await userBox.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _user = null;
      _token = null;
      _isLoggedIn = false;
      _isDemoLogin = false;
      _loginSource = LoginSource.none;
      _settings = null;

      notifyListeners();
    } catch (e) {
      // Intentionally ignored.
    }
  }

  // Getter methods remain the same
  Map<String, dynamic> getSettings() {
    final userBox = Hive.box('userData');
    final settings = userBox.get('settings');
    if (settings != null) {
      if (settings is Map<String, dynamic>) return settings;
      if (settings is Map) return Map<String, dynamic>.from(settings);
    }
    return {};
  }

  List<Map<String, dynamic>> getLevels() {
    final userBox = Hive.box('userData');
    final levels = userBox.get('levels');
    if (levels != null && levels is List) {
      return levels.map((item) {
        if (item is Map<String, dynamic>) return item;
        if (item is Map) return Map<String, dynamic>.from(item);
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> getClasses() {
    final userBox = Hive.box('userData');
    final classes = userBox.get('classes');
    if (classes != null && classes is List) {
      return classes.map((item) {
        if (item is Map<String, dynamic>) return item;
        if (item is Map) return Map<String, dynamic>.from(item);
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> getCourses() {
    final userBox = Hive.box('userData');
    final courses = userBox.get('courses');
    if (courses != null && courses is List) {
      return courses.map((item) {
        if (item is Map<String, dynamic>) return item;
        if (item is Map) return Map<String, dynamic>.from(item);
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> getFormClasses() {
    final userBox = Hive.box('userData');
    final formClasses = userBox.get('form_classes');
    if (formClasses != null && formClasses is List) {
      return formClasses.map((item) {
        if (item is Map<String, dynamic>) return item;
        if (item is Map) return Map<String, dynamic>.from(item);
        return <String, dynamic>{};
      }).toList();
    }

    final fallback = _getNestedRoleData('form_classes');
    if (fallback.isNotEmpty) return fallback;

    return [];
  }

  List<Map<String, dynamic>> getStaffCourses() {
    final userBox = Hive.box('userData');
    final staffCourses = userBox.get('staff_courses');
    if (staffCourses != null && staffCourses is List) {
      return staffCourses.map((item) {
        if (item is Map<String, dynamic>) return item;
        if (item is Map) return Map<String, dynamic>.from(item);
        return <String, dynamic>{};
      }).toList();
    }

    final fallback = _getNestedRoleData('courses');
    if (fallback.isNotEmpty) return fallback;

    return [];
  }

  Map<String, dynamic> getStudentProfile() {
    final userBox = Hive.box('userData');
    final studentProfile = userBox.get('student_profile');
    if (studentProfile != null) {
      if (studentProfile is Map<String, dynamic>) return studentProfile;
      if (studentProfile is Map) {
        return Map<String, dynamic>.from(studentProfile);
      }
    }
    return {};
  }

  String? getStudentId() => Hive.box('userData').get('student_id');
  String? getClassId() => Hive.box('userData').get('class_id');
  String? getLevelId() => Hive.box('userData').get('level_id');
  String? getCurrentYear() => Hive.box('userData').get('current_year');
  String? getRegistrationNo() => Hive.box('userData').get('registration_no');

  Map<String, dynamic> getUserProfile() {
    final userBox = Hive.box('userData');
    final userData = userBox.get('userData');
    if (userData != null) {
      Map<String, dynamic> userDataMap;
      if (userData is Map<String, dynamic>) {
        userDataMap = userData;
      } else if (userData is Map) {
        userDataMap = Map<String, dynamic>.from(userData);
      } else {
        return {};
      }

      if (userDataMap['data'] != null) {
        final profileData = userDataMap['data']['profile'];
        if (profileData is Map<String, dynamic>) return profileData;
        if (profileData is Map) return Map<String, dynamic>.from(profileData);
      }
    }
    return {};
  }

  String getUserRole() {
    final userBox = Hive.box('userData');
    return userBox.get('role', defaultValue: '');
  }

  Future<void> refreshSession() async {
    if (_isLoggedIn && _token != null) {
      final userBox = Hive.box('userData');
      await userBox.put('lastLoginTime', DateTime.now().millisecondsSinceEpoch);
    }
  }

  List<Map<String, dynamic>> _getNestedRoleData(String key) {
    final userBox = Hive.box('userData');
    final storedLogin = userBox.get('userData') ?? userBox.get('loginResponse');
    if (storedLogin == null) return [];

    final normalized = _deepConvertMap(storedLogin);
    if (normalized == null) return [];

    dynamic data = normalized['data'];
    if (data == null && normalized['response'] is Map) {
      final response = normalized['response'];
      data = response is Map ? response['data'] ?? response : null;
    }
    data ??= normalized;

    if (data is Map && data[key] is List) {
      return (data[key] as List).map((item) {
        if (item is Map<String, dynamic>) return item;
        if (item is Map) return Map<String, dynamic>.from(item);
        return <String, dynamic>{};
      }).toList();
    }

    return [];
  }
}
