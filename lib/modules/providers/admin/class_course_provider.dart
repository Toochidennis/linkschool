import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/class_course_registration_model.dart';
import 'package:linkschool/modules/services/admin/class_course_registration_api.dart';

class ClassCourseProvider with ChangeNotifier {
  final ClassCourseApiService _apiService = ClassCourseApiService();
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  Future<void> postClassCourse(ClassCourseModel data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.postClassCourse(data);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/model/admin/class_course_registration_model.dart';
// import 'package:linkschool/modules/services/admin/class_course_registration_api.dart';

// class StudentClassCourseProvider with ChangeNotifier {
//   final ClassCousreRegistrationApiService _apiService =
//       ClassCousreRegistrationApiService();
//   bool isLoading = false;

//   Future<bool> submitStudentClass(
//       StudentClassCourseRegistration studentClass) async {
//     isLoading = true;
//     notifyListeners();

//     bool success = await _apiService.postStudentClass(studentClass);

//     isLoading = false;
//     notifyListeners();

//     return success;
//   }
// }
