import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/home/add_course_model.dart';
import 'package:linkschool/modules/services/admin/home/assign_course_service.dart';

class AssignCourseProvider with ChangeNotifier {
  final AssignCourseService _assignCourseService;

  bool isLoading = false;
  String? message;
  String? error;

  AssignCourseProvider(this._assignCourseService);

        List<CourseAssignment> _assignments = [];
  List<CourseAssignment> get assignments => _assignments;

  Future<void> loadCourseAssignments(int staffId, String term, String year) async {
    isLoading = true;
    notifyListeners();

    try {
      final response =
          await _assignCourseService.fetchCourseAssignments(staffId,  year,term);
      _assignments = response.response;
    } catch (e) {
      debugPrint("Failed to load course assignments: $e");
      print("llcourse assignments: $_assignments");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> AssignCourse(Map<String, dynamic> AssignedCourse) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _assignCourseService.Assigncourse(AssignedCourse);
      message = "Level created successfully.";
      return true;
    } catch (e) {
      error = "Failed to create level: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
