import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/class_course_registration_model.dart';
import 'package:linkschool/modules/services/admin/class_course_registration_api.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class ClassCourseProvider with ChangeNotifier {
  final ClassCourseApiService _apiService = locator<ClassCourseApiService>();
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  Future<void> postClassCourse(ClassCourseModel studentClass) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.postClassCourse(studentClass);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing course
  Future<void> updateCourse(ClassCourseModel studentClass) async {
    _isLoading = true;
    notifyListeners();

    // Implementation would use the ApiService to update the course
    // This is just a placeholder for the method signature

    _isLoading = false;
    notifyListeners();
  }

  // Delete a course
  Future<void> deleteCourse(String courseId) async {
    _isLoading = true;
    notifyListeners();

    // Implementation would use the ApiService to delete the course
    // This is just a placeholder for the method signature

    _isLoading = false;
    notifyListeners();
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
