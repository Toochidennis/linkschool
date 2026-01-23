import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/courses/category_model.dart';
import 'package:linkschool/modules/model/explore/courses/course_model.dart';
import 'package:linkschool/modules/services/explore/courses/course_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreCourseProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Get all courses from all categories
  List<CourseModel> get allCourses {
    List<CourseModel> courses = [];
    for (var category in _categories) {
      courses.addAll(category.courses);
    }
    return courses;
  }

  // Get only available categories
  List<CategoryModel> get availableCategories {
    return _categories.where((category) => category.isAvailable).toList();
  }

  // Get only free categories
  List<CategoryModel> get freeCategories {
    return _categories.where((category) => category.isFreeCourse).toList();
  }

  // Get only paid categories
  List<CategoryModel> get paidCategories {
    return _categories.where((category) => !category.isFreeCourse).toList();
  }

  // Get category by ID
  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by short name
  CategoryModel? getCategoryByShort(String short) {
    try {
      return _categories.firstWhere((category) => category.short == short);
    } catch (e) {
      return null;
    }
  }

  // Get courses by category ID
  List<CourseModel> getCoursesByCategoryId(int categoryId) {
    final category = getCategoryById(categoryId);
    return category?.courses ?? [];
  }

  // Get a single course by ID
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

  /// Fetch categories and courses. If [profileId] and [dateOfBirth] are not
  /// provided this method will try to use any persisted values saved in
  /// SharedPreferences. When explicit values are provided they will be
  /// persisted for subsequent calls.
  Future<void> fetchCategoriesAndCourses({int? profileId, String? dateOfBirth}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();

      int? usedProfileId = profileId;
      String? usedDob = dateOfBirth;

      // If no explicit params, attempt to load persisted values
      if ((usedProfileId == null || usedDob == null)) {
        final savedId = prefs.getInt('active_profile_id');
        final savedDob = prefs.getString('active_profile_dob');
        if (savedId != null) usedProfileId ??= savedId;
        if (savedDob != null) usedDob ??= savedDob;
        if (savedId != null || savedDob != null) {
          print('🔁 Using persisted profile values: id=$usedProfileId dob=$usedDob');
        }
      } else {
        // Persist provided values for future calls
        if (profileId != null) await prefs.setInt('active_profile_id', profileId);
        if (dateOfBirth != null) await prefs.setString('active_profile_dob', dateOfBirth);
      }

      final response = await _courseService.getAllCategoriesAndCourses(profileId: usedProfileId, dateOfBirth: usedDob);
      _categories = response.categories.reversed.toList();

      // Log the fetched data for debugging
      print('✅ Fetched ${_categories.length} categories');
      for (var category in _categories) {
        print(
            '   📁 ${category.name} (${category.badgeText}): ${category.courses.length} courses');
      }
    } catch (e) {
      _errorMessage = 'Error fetching categories and courses: $e';
      // Log the error for debugging
      print('❌ Error in CourseProvider: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear any persisted profile id and birthdate
  Future<void> clearPersistedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_profile_id');
    await prefs.remove('active_profile_dob');
    print('🧹 Cleared persisted profile id/dob');
  }


  // payment service
 
}
