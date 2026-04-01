import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/courses/course_model.dart';
import 'package:linkschool/modules/model/explore/courses/program_courses_model.dart';
import 'package:linkschool/modules/services/explore/courses/program_courses_service.dart';

class ProgramCoursesProvider with ChangeNotifier {
  final ProgramCoursesService _service;

  ProgramCoursesProvider(this._service);

  ProgramModel? _program;
  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String _errorMessage = '';

  ProgramModel? get program => _program;
  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchBySlug(String slug) async {
    final trimmedSlug = slug.trim();
    if (trimmedSlug.isEmpty) {
      _program = null;
      _courses = [];
      _errorMessage = 'Program slug is required';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = '';
      _program = null;
      _courses = [];
      notifyListeners();

      final response = await _service.fetchProgramCoursesBySlug(trimmedSlug);
      _program = response.data.program;
      _courses = response.data.courses
          .map((course) => course.toCourseModel(programId: _program?.id))
          .toList();
    } catch (e) {
      _program = null;
      _courses = [];
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _program = null;
    _courses = [];
    _errorMessage = '';
    notifyListeners();
  }
}
