import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/courses/lesson_model.dart';
import 'package:linkschool/modules/services/explore/courses/lessons_service.dart';

class LessonProvider extends ChangeNotifier {
  final LessonService _lessonService;
  
  List<LessonModel> _lessons = [];
  List<ResourceModel> _resources = [];
  NextCourseModel? _nextCourse;
  bool _isLoading = false;
  String? _error;
  String? _currentCategoryId;
  String? _currentCourseId;
  String? _currentCohortId;
  int? _currentProfileId;

  LessonProvider(this._lessonService);

  // Getters
  List<LessonModel> get lessons => _lessons;
  List<ResourceModel> get resources => _resources;
  NextCourseModel? get nextCourse => _nextCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCategoryId => _currentCategoryId;
  String? get currentCourseId => _currentCourseId;
  String? get currentCohortId => _currentCohortId;
  int? get currentProfileId => _currentProfileId;

  // Get lesson by id
  LessonModel? getLessonById(int id) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get resources for a specific lesson
  List<ResourceModel> getResourcesForLesson(int lessonId) {
    return _resources.where((resource) => resource.lessonId == lessonId).toList();
  }

  // Get lessons by course - since all lessons are for current course, return all
  List<LessonModel> getLessonsByCourse(int courseId) {
    return _lessons;
  }

  // Load lessons with optional filters
  Future<void> loadLessons({
    String? categoryId,
    String? courseId,
    required String cohortId,
    required int profileId,
  }) async {
    _isLoading = true;
    _error = null;
    _currentCategoryId = categoryId;
    _currentCourseId = courseId;
    _currentCohortId = cohortId;
    _currentProfileId = profileId;
    notifyListeners();

    if (profileId <= 0) {
      _error = 'Profile ID is required to load lessons';
      print('❌ $_error');
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await _lessonService.fetchLessons(
        cohortId: cohortId,
        profileId: profileId.toString(),
      );

      if (response.success) {
        _lessons = response.lessons;
        _resources = response.resources;
        _nextCourse = response.nextCourse;
        
        print('✅ Lessons loaded successfully:');
        print('   Total lessons: ${_lessons.length}');
        print('   Total resources: ${_resources.length}');
      } else {
        _error = response.message;
        print('❌ Failed to load lessons: ${response.message}');
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error in LessonProvider: $_error');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh lessons (reload with current filters)
  Future<void> refreshLessons() async {
    if (_currentCohortId != null && _currentProfileId != null) {
      await loadLessons(
        categoryId: _currentCategoryId,
        courseId: _currentCourseId,
        cohortId: _currentCohortId!,
        profileId: _currentProfileId!,
      );
    }
  }

  // Clear all lessons
  void clearLessons() {
    _lessons = [];
    _resources = [];
    _nextCourse = null;
    _currentCategoryId = null;
    _currentCourseId = null;
    _currentCohortId = null;
    _currentProfileId = null;
    _error = null;
    notifyListeners();
  }

  // Get unique course names - since no courseName, return empty
  List<String> get uniqueCourseNames => [];

  // Get lessons count by course - since no courseName, return empty
  Map<String, int> get lessonsCountByCourse => {};

  // Check if a lesson has video
  bool hasVideo(int lessonId) {
    final lesson = getLessonById(lessonId);
    return lesson?.videoUrl.isNotEmpty ?? false;
  }

  // Check if a lesson has material - not in new data
  bool hasMaterial(int lessonId) {
    return false;
  }

  // Check if a lesson has assignment - not in new data
  bool hasAssignment(int lessonId) {
    return false;
  }

  // Check if a lesson has quiz - not in new data
  bool hasQuiz(int lessonId) {
    return false;
  }

  // Get upcoming lessons - no date in new data
  List<LessonModel> get upcomingLessons => [];

  // Get past lessons - no date in new data
  List<LessonModel> get pastLessons => [];
}
