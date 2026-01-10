import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/course_registration_model.dart';
import 'package:linkschool/modules/services/admin/course_registration_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class CourseRegistrationProvider with ChangeNotifier {
  final CourseRegistrationService _courseRegistrationService =
      locator<CourseRegistrationService>();
  List<CourseRegistrationModel> _registeredCourses = [];
  bool _isLoading = false;

  List<CourseRegistrationModel> get registeredCourses => _registeredCourses;
  bool get isLoading => _isLoading;

  Future<void> fetchRegisteredCourses(
      String classId, String term, String year) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _courseRegistrationService.fetchRegisteredCourses(
          classId, term, year);

      if (response.success && response.data != null) {
        _registeredCourses = response.data!;
      } else {
        _registeredCourses = [];
        debugPrint('No registered students found or ${response.message}');
      }
    } catch (e) {
      _registeredCourses = [];
      debugPrint('Error fetching registered students: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<int>> fetchStudentRegisteredCourses({
    required int studentId,
    required String classId,
    required String year,
    required String term,
    required String dbName,
  }) async {
    try {
      final response =
          await _courseRegistrationService.fetchStudentRegisteredCourses(
        studentId: studentId,
        classId: classId,
        year: year,
        term: term,
        dbName: dbName,
      );

      if (response.success && response.rawData != null) {
        final List<dynamic> coursesJson = response.rawData!['data'] ?? [];
        final courseIds = coursesJson
            .map<int>((json) => (json['id'] as num).toInt())
            .toList();
        print('Fetched course IDs: $courseIds');
        return courseIds;
      }

      print('No registered courses found for student $studentId');
      return [];
    } catch (e) {
      print('Error fetching student registered courses: ${e.toString()}');
      return [];
    }
  }

  Future<bool> registerCourse(CourseRegistrationModel course,
      {Map<String, dynamic>? payload}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _courseRegistrationService.registerCourse(
        course,
        payload: payload,
      );

      if (response.success) {
        int index = _registeredCourses
            .indexWhere((s) => s.studentId == course.studentId);
        if (index != -1) {
          var updatedStudent = CourseRegistrationModel(
            studentId: course.studentId,
            studentName: course.studentName,
            courseCount: course.courseCount,
            classId: course.classId,
            term: course.term,
            year: course.year,
          );
          _registeredCourses[index] = updatedStudent;
        }
        debugPrint('Course registered successfully');
        return true;
      } else {
        debugPrint('Failed to register course: ${response.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Error registering course: ${e.toString()}');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
