import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/courses/category_model.dart';
import 'package:linkschool/modules/model/explore/courses/course_model.dart';
import 'package:linkschool/modules/services/explore/courses/course_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreCourseProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime? _lastFetchTime;
  int? _lastProfileId;
  String? _lastDateOfBirth;

  // Cache duration - adjust as needed (5 minutes is reasonable)
  final Duration _cacheDuration = const Duration(minutes: 5);

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<CourseModel> get allCourses {
    List<CourseModel> courses = [];
    for (var category in _categories) {
      courses.addAll(category.courses);
    }
    return courses;
  }

  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  List<CourseModel> getCoursesByCategoryId(int categoryId) {
    final category = getCategoryById(categoryId);
    return category?.courses ?? [];
  }

  CourseModel? getCourseById(int id) {
    for (var category in _categories) {
      try {
        return category.courses.firstWhere((course) => course.id == id);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  final CourseService _courseService = CourseService();

  /// Check if cached data is still valid
  bool _isCacheValid(int? profileId, String? dateOfBirth) {
    if (_categories.isEmpty) return false;
    if (_lastFetchTime == null) return false;
    
    // Check if cache has expired
    if (DateTime.now().difference(_lastFetchTime!) > _cacheDuration) {
      return false;
    }
    
    // Check if profile parameters have changed
    if (_lastProfileId != profileId || _lastDateOfBirth != dateOfBirth) {
      return false;
    }
    
    return true;
  }

  Future<void> fetchCategoriesAndCourses({
    int? profileId,
    String? dateOfBirth,
    bool showLoading = true,
    bool forceRefresh = false,
  }) async {
    // Check if we can use cached data
    if (!forceRefresh && _isCacheValid(profileId, dateOfBirth)) {
      debugPrint('✅ Using cached course data (${_categories.length} categories)');
      return;
    }

    if (showLoading) {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();

      int? usedProfileId = profileId;
      String? usedDob = dateOfBirth;

      final savedId = prefs.getInt('active_profile_id');
      final savedDob = prefs.getString('active_profile_dob');

      usedProfileId ??= savedId;
      usedDob ??= savedDob;

      if (profileId != null) await prefs.setInt('active_profile_id', profileId);
      if (dateOfBirth != null) await prefs.setString('active_profile_dob', dateOfBirth);

      debugPrint('🔄 Fetching fresh course data from server...');
      final response = await _courseService.getAllCategoriesAndCourses(
        profileId: usedProfileId,
        dateOfBirth: usedDob,
      );
      
      _categories = response.categories.reversed.toList();
      _lastFetchTime = DateTime.now();
      _lastProfileId = usedProfileId;
      _lastDateOfBirth = usedDob;
      _errorMessage = '';
      
      debugPrint('✅ Successfully fetched ${_categories.length} categories');
    } catch (e) {
      _errorMessage = 'Error fetching categories and courses: $e';
      debugPrint('❌ Error fetching courses: $e');
    } finally {
      if (showLoading) {
        _isLoading = false;
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  /// Force refresh data (for pull-to-refresh)
  Future<void> refresh({
    int? profileId,
    String? dateOfBirth,
  }) async {
    debugPrint('🔄 Force refreshing course data...');
    return fetchCategoriesAndCourses(
      profileId: profileId,
      dateOfBirth: dateOfBirth,
      showLoading: true,
      forceRefresh: true,
    );
  }

  /// Clear cache and force next fetch
  void invalidateCache() {
    _lastFetchTime = null;
    _lastProfileId = null;
    _lastDateOfBirth = null;
    debugPrint('🗑️ Cache invalidated');
  }

  Future<void> clearPersistedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_profile_id');
    await prefs.remove('active_profile_dob');
    invalidateCache(); // Also clear cache when clearing profile
  }

  /// Update cache duration if needed
  void setCacheDuration(Duration duration) {
    // You can make _cacheDuration non-final and update it if needed
  }
}