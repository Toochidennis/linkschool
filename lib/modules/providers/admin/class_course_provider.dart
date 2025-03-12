import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/class_course_registration_model.dart';
import 'package:linkschool/modules/services/admin/class_course_registration_api.dart';

class StudentClassCourseProvider with ChangeNotifier {
  final ClassCousreRegistrationApiService _apiService =
      ClassCousreRegistrationApiService();
  bool isLoading = false;

  Future<bool> submitStudentClass(
      StudentClassCourseRegistration studentClass) async {
    isLoading = true;
    notifyListeners();

    bool success = await _apiService.postStudentClass(studentClass);

    isLoading = false;
    notifyListeners();

    return success;
  }
}
