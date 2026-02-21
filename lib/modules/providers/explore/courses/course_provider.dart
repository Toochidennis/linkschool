import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/courses/category_model.dart';
import 'package:linkschool/modules/model/explore/courses/course_model.dart';
import 'package:linkschool/modules/services/explore/courses/course_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkschool/modules/services/network/connectivity_service.dart';
import 'package:linkschool/modules/services/explore/cache/explore_dashboard_cache.dart';

class ExploreCourseProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime? _lastFetchTime;
  int? _lastProfileId;
  String? _lastDateOfBirth;
  static const String _lastCacheKeyPref = 'courses_last_cache_key';

  // Cache duration - dashboard cache is persisted for 24 hours
  final Duration _cacheDuration = const Duration(hours: 24);

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

      // If we already have valid in-memory cache, return early.
      if (!forceRefresh && _isCacheValid(usedProfileId, usedDob)) {
        debugPrint('✅ Using cached course data (${_categories.length} categories)');
        return;
      }

      // Explicitly load persisted cache first (cold start / empty state).
      if (!forceRefresh && _categories.isEmpty) {
        try {
          final cachedResponse = await _courseService.getAllCategoriesAndCourses(
            profileId: usedProfileId,
            dateOfBirth: usedDob,
            allowNetwork: false,
          );
          _categories = cachedResponse.categories.reversed.toList();
          _lastFetchTime = DateTime.now();
          _lastProfileId = usedProfileId;
          _lastDateOfBirth = usedDob;
          _errorMessage = 'You are offline. Showing saved courses.';
          notifyListeners();
        } catch (_) {
          // If key-specific cache misses, try last known cache key.
          final lastKey = prefs.getString(_lastCacheKeyPref);
          if (lastKey != null && lastKey.isNotEmpty) {
            final loaded = await _loadCachedByKey(lastKey);
            if (loaded) {
              _errorMessage = 'You are offline. Showing saved courses.';
              notifyListeners();
            }
          }
        }
      }

      final isOnline = await ConnectivityService.isOnline();
      if (!isOnline && _categories.isNotEmpty) {
        _isLoading = false;
        _errorMessage = 'You are offline. Showing saved courses.';
        notifyListeners();
        return;
      }

      final response = await _courseService.getAllCategoriesAndCourses(
        profileId: usedProfileId,
        dateOfBirth: usedDob,
        allowNetwork: isOnline,
      );
      
      _categories = response.categories.reversed.toList();
      _lastFetchTime = DateTime.now();
      _lastProfileId = usedProfileId;
      _lastDateOfBirth = usedDob;
      final cacheKey = ExploreDashboardCache.coursesKey(
        profileId: usedProfileId,
        dateOfBirth: usedDob,
      );
      await prefs.setString(_lastCacheKeyPref, cacheKey);
      _errorMessage = isOnline
          ? ''
          : 'You are offline. Showing saved courses.';
      
      debugPrint('✅ Successfully fetched ${_categories.length} categories');
    } catch (e) {
      final isOnline = await ConnectivityService.isOnline();
      _errorMessage = isOnline
          ? 'Network error. Please try again.'
          : 'No internet connection. Connect and try again.';
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

  Future<bool> _loadCachedByKey(String key) async {
    try {
      final cached = await ExploreDashboardCache.load(key);
      if (cached?.data is Map<String, dynamic>) {
        final response = CourseResponse.fromJson(
          Map<String, dynamic>.from(cached!.data),
        );
        _categories = response.categories.reversed.toList();
        _lastFetchTime = DateTime.now();
        _lastProfileId = null;
        _lastDateOfBirth = null;
        debugPrint('✅ Loaded courses from fallback cache key: $key');
        return true;
      }
    } catch (e) {
      debugPrint('❌ Failed to load fallback cache key: $e');
    }
    return false;
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
