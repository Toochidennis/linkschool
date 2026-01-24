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

  Future<void> fetchCategoriesAndCourses({int? profileId, String? dateOfBirth}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();

      int? usedProfileId = profileId;
      String? usedDob = dateOfBirth;

      if ((usedProfileId == null || usedDob == null)) {
        final savedId = prefs.getInt('active_profile_id');
        final savedDob = prefs.getString('active_profile_dob');
        if (savedId != null) usedProfileId ??= savedId;
        if (savedDob != null) usedDob ??= savedDob;
      } else {
        if (profileId != null) await prefs.setInt('active_profile_id', profileId);
        if (dateOfBirth != null) await prefs.setString('active_profile_dob', dateOfBirth);
      }

      final response = await _courseService.getAllCategoriesAndCourses(
        profileId: usedProfileId,
        dateOfBirth: usedDob,
      );
      _categories = response.categories.reversed.toList();
    } catch (e) {
      _errorMessage = 'Error fetching categories and courses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearPersistedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_profile_id');
    await prefs.remove('active_profile_dob');
  }
}
