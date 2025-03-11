import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/course_registration_model.dart';
import 'package:linkschool/modules/services/admin/course_registration_service.dart';


class CourseRegistrationProvider with ChangeNotifier {
  final CourseRegistrationService _courseRegistrationService =
      CourseRegistrationService();

  List<CourseRegistrationModel> _registeredCourses = [];
  bool _isLoading = false;

  List<CourseRegistrationModel> get registeredCourses => _registeredCourses;
  bool get isLoading => _isLoading;

  //  Fetch registered courses (Fixed)
  Future<void> fetchRegisteredCourses(
      String classId, String term, String year) async {
    _isLoading = true;
    notifyListeners();

    _registeredCourses = await _courseRegistrationService
        .fetchRegisteredCourses(classId, term, year);
    print("$_registeredCourses");
    _isLoading = false; 
    notifyListeners();
  }

  //  Register a new course
  Future<void> registerCourse(CourseRegistrationModel course) async {
    _isLoading = true;
    notifyListeners();

    bool success = await _courseRegistrationService.registerCourse(course);

    if (success) {
      _registeredCourses.add(course);
    }

    _isLoading = false;
    notifyListeners();
  }
}