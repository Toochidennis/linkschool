import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/courses/lesson_model.dart';
import 'package:linkschool/modules/services/explore/courses/lessons_service.dart';

class LessonProvider extends ChangeNotifier {
  final LessonService _lessonService;
  
  List<LessonModel> _lessons = [];
  List<ResourceModel> _resources = [];
  bool _isLoading = false;
  String? _error;
  String? _currentCategoryId;
  String? _currentCourseId;

  LessonProvider(this._lessonService);

  // Getters
  List<LessonModel> get lessons => _lessons;
  List<ResourceModel> get resources => _resources;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCategoryId => _currentCategoryId;
  String? get currentCourseId => _currentCourseId;

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

  // Get lessons by course
  List<LessonModel> getLessonsByCourse(int courseId) {
    return _lessons.where((lesson) => lesson.courseId == courseId).toList();
  }

  // Load lessons with optional filters
  Future<void> loadLessons({
    String? categoryId,
    String? courseId,
  }) async {
    _isLoading = true;
    _error = null;
    _currentCategoryId = categoryId;
    _currentCourseId = courseId;
    notifyListeners();

    try {
      final response = await _lessonService.fetchLessons(
        categoryId: categoryId,
        courseId: courseId,
      );

      if (response.success) {
        _lessons = response.lessons;
        _resources = response.resources;
        
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
    await loadLessons(
      categoryId: _currentCategoryId,
      courseId: _currentCourseId,
    );
  }

  // Clear all lessons
  void clearLessons() {
    _lessons = [];
    _resources = [];
    _currentCategoryId = null;
    _currentCourseId = null;
    _error = null;
    notifyListeners();
  }

  // Get unique course names
  List<String> get uniqueCourseNames {
    final courseNames = _lessons.map((lesson) => lesson.courseName).toSet().toList();
    return courseNames;
  }

  // Get lessons count by course
  Map<String, int> get lessonsCountByCourse {
    final Map<String, int> counts = {};
    for (var lesson in _lessons) {
      counts[lesson.courseName] = (counts[lesson.courseName] ?? 0) + 1;
    }
    return counts;
  }

  // Check if a lesson has video
  bool hasVideo(int lessonId) {
    final lesson = getLessonById(lessonId);
    return lesson?.videoUrl.isNotEmpty ?? false;
  }

  // Check if a lesson has material
  bool hasMaterial(int lessonId) {
    final lesson = getLessonById(lessonId);
    return lesson?.materialUrl.isNotEmpty ?? false;
  }

  // Check if a lesson has assignment
  bool hasAssignment(int lessonId) {
    final lesson = getLessonById(lessonId);
    return lesson?.assignmentUrl.isNotEmpty ?? false;
  }

  // Check if a lesson has quiz
  bool hasQuiz(int lessonId) {
    final lesson = getLessonById(lessonId);
    return lesson?.hasQuiz == 1;
  }

  // Get upcoming lessons (lessons with future dates)
  List<LessonModel> get upcomingLessons {
    final now = DateTime.now();
    return _lessons.where((lesson) {
      try {
        final lessonDate = DateTime.parse(lesson.date);
        return lessonDate.isAfter(now);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get past lessons
  List<LessonModel> get pastLessons {
    final now = DateTime.now();
    return _lessons.where((lesson) {
      try {
        final lessonDate = DateTime.parse(lesson.date);
        return lessonDate.isBefore(now);
      } catch (e) {
        return false;
      }
    }).toList();
  }
}