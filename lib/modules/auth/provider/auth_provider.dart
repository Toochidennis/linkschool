import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/auth/model/user.dart';
import 'package:linkschool/modules/auth/service/auth_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  final _secureStorage = const FlutterSecureStorage();

  User? _user;
  String? _token;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _settings;

  bool _isSilentLoginInProgress = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get settings => _settings;
  bool get isSilentLoginInProgress => _isSilentLoginInProgress;

  /// Main login method - saves credentials for future silent login
  Future<void> login(
      String username, String password, String schoolCode) async {
    try {
      final response = await _authService.login(username, password, schoolCode);
      if (response.success && response.rawData != null) {
        // Save login credentials securely for silent re-login
        await _saveLoginCredentials(username, password, schoolCode);

        // Process and save login data
        await _processLoginResponse(response.rawData!);

        print('✅ Login successful - User role: ${_user!.role}');
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
      String username, String password, String schoolCode) async {
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

      print('🔐 Login credentials saved securely');
    } catch (e) {
      print('⚠️ Warning: Could not save credentials: $e');
    }
  }

  /// Process login response and save all data
  Future<void> _processLoginResponse(Map<String, dynamic> responseData) async {
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
        await userBox.put('staff_courses', userData['courses']);
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

  /// Check login status on app startup - attempts silent login if credentials exist
  Future<void> checkLoginStatus() async {
    try {
      print('🔍 Checking login status...');

      final userBox = Hive.box('userData');
      final prefs = await SharedPreferences.getInstance();

      // OPTIMIZATION: First check if we have a valid cached session
      final sessionValid = userBox.get('sessionValid', defaultValue: false);
      final hasUserData = userBox.get('userData') != null;
      final hasToken = userBox.get('token') != null;

      print('📊 Quick Session Check:');
      print('  - Session valid: $sessionValid');
      print('  - Has userData: $hasUserData');
      print('  - Has token: $hasToken');

      // If we have a valid session, restore it immediately (FAST PATH)
      if (sessionValid && hasUserData && hasToken) {
        print('⚡ Valid session found - using fast restore');
        await _restoreFromSavedSession();

        // Only attempt silent login in background if session is old (e.g., > 24 hours)
        final lastLoginTime =
            userBox.get('lastLoginTime', defaultValue: 0) as int;
        final hoursSinceLogin =
            (DateTime.now().millisecondsSinceEpoch - lastLoginTime) /
                (1000 * 60 * 60);

        if (hoursSinceLogin > 24) {
          print(
              '🔄 Session is old (${hoursSinceLogin.toStringAsFixed(1)}h), refreshing in background...');
          // Refresh session in background without blocking UI
          _attemptSilentLoginInBackground();
        }
        return;
      }

      // SLOW PATH: No valid session, attempt full silent login
      final hasSavedCredentials =
          userBox.get('has_saved_credentials', defaultValue: false);

      if (hasSavedCredentials) {
        print('🔑 No valid session - attempting silent login');
        final success = await _attemptSilentLogin();

        if (success) {
          print('✅ Silent login successful');
          return;
        } else {
          print('⚠️ Silent login failed - will try session restore');
        }
      }

      // Fallback: Try to restore from saved session (old behavior)
      await _restoreFromSavedSession();
    } catch (e, stackTrace) {
      print('❌ Error checking login status: $e');
      print('Stack trace: $stackTrace');
      await _clearCorruptedSession();
    }
  }

  /// Refresh session in background without blocking UI
  void _attemptSilentLoginInBackground() {
    Future.microtask(() async {
      try {
        print('🔄 Background session refresh started...');
        await _attemptSilentLogin();
        print('✅ Background session refresh completed');
      } catch (e) {
        print('⚠️ Background session refresh failed: $e');
      }
    });
  }

  /// Attempt silent login using saved credentials
  Future<bool> _attemptSilentLogin() async {
    try {
      _isSilentLoginInProgress = true;
      notifyListeners();

      // Retrieve saved credentials
      final username = await _secureStorage.read(key: 'saved_username');
      final password = await _secureStorage.read(key: 'saved_password');
      final schoolCode = await _secureStorage.read(key: 'saved_school_code');

      if (username == null || password == null || schoolCode == null) {
        print('❌ Missing credentials for silent login');
        return false;
      }

      print('🔄 Performing silent login for user: $username');

      // Perform login in background
      final response = await _authService.login(username, password, schoolCode);

      if (response.success && response.rawData != null) {
        // Process the fresh login data
        await _processLoginResponse(response.rawData!);

        _isSilentLoginInProgress = false;
        notifyListeners();

        print('✅ Silent login completed - Fresh data loaded');
        return true;
      } else {
        print('❌ Silent login failed: ${response.message}');
        return false;
      }
    } catch (e) {
      print('❌ Silent login error: $e');
      return false;
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

    print('📊 Session Status:');
    print('  - Hive isLoggedIn: $isLoggedInHive');
    print('  - Prefs isLoggedIn: $isLoggedInPrefs');
    print('  - Session valid: $sessionValid');
    print('  - Has userData: ${userData != null}');
    print('  - Has token: ${token != null}');

    if ((isLoggedInHive || isLoggedInPrefs) &&
        userData != null &&
        token != null) {
      final userDataMap = _deepConvertMap(userData);

      if (userDataMap == null || !userDataMap.containsKey('data')) {
        print('❌ Invalid userData format, clearing session');
        await _clearCorruptedSession();
        return;
      }

      final userDataContent = userDataMap['data'];
      if (userDataContent == null || userDataContent is! Map<String, dynamic>) {
        print('❌ Invalid user data content, clearing session');
        await _clearCorruptedSession();
        return;
      }

      try {
        _user = User.fromJson(userDataContent);
        _token = token.toString();
        _isLoggedIn = true;

        final apiService = locator<ApiService>();
        apiService.setAuthToken(_token!);

        final settings = userBox.get('settings');
        if (settings != null) {
          _settings = _deepConvertMap(settings);
        }

        await userBox.put(
            'lastLoginTime', DateTime.now().millisecondsSinceEpoch);

        print('✅ Session restored from cache');
        print('   - User: ${_user!.name}');
        print('   - Role: ${_user!.role}');

        notifyListeners();
      } catch (e, stackTrace) {
        print('❌ Error restoring session: $e');
        print('Stack trace: $stackTrace');
        await _clearCorruptedSession();
      }
    } else {
      print('⚠️ No valid session found');
      _isLoggedIn = false;
      _user = null;
      _token = null;
      _settings = null;
      notifyListeners();
    }
  }

  /// Logout and optionally clear saved credentials
  Future<void> logout({bool clearSavedCredentials = false}) async {
    try {
      final userBox = Hive.box('userData');

      if (clearSavedCredentials) {
        // Clear saved credentials from secure storage
        await _secureStorage.delete(key: 'saved_username');
        await _secureStorage.delete(key: 'saved_password');
        await _secureStorage.delete(key: 'saved_school_code');
        print('🔐 Saved credentials cleared');
      }

      await userBox.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final apiService = locator<ApiService>();
      apiService.setAuthToken('');

      _user = null;
      _token = null;
      _isLoggedIn = false;
      _settings = null;

      print('✅ Logout successful');
      notifyListeners();
    } catch (e) {
      print('❌ Error during logout: $e');
      _user = null;
      _token = null;
      _isLoggedIn = false;
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
      _settings = null;

      print('🧹 Corrupted session cleared');
      notifyListeners();
    } catch (e) {
      print('❌ Error clearing corrupted session: $e');
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
    return [];
  }

  Map<String, dynamic> getStudentProfile() {
    final userBox = Hive.box('userData');
    final studentProfile = userBox.get('student_profile');
    if (studentProfile != null) {
      if (studentProfile is Map<String, dynamic>) return studentProfile;
      if (studentProfile is Map)
        return Map<String, dynamic>.from(studentProfile);
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
      print('♻️ Session refreshed');
    }
  }
}
