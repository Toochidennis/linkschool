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

  // Fetch registered courses
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
        // If the API call was successful but returned no data
        _registeredCourses = [];
        debugPrint('No courses found or ${response.message}');
      }
    } catch (e) {
      _registeredCourses = [];
      debugPrint('Error fetching courses: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register a new course
  Future<void> registerCourse(CourseRegistrationModel course) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _courseRegistrationService.registerCourse(course);

      if (response.success && response.data == true) {
        // Add the newly registered course to the list
        _registeredCourses.add(course);
        debugPrint('Course registered successfully');
      } else {
        debugPrint('Failed to register course: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error registering course: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing course
  Future<void> updateCourse(CourseRegistrationModel course) async {
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
// import 'package:linkschool/modules/model/admin/course_registration_model.dart';
// import 'package:linkschool/modules/services/admin/course_registration_service.dart';

// class CourseRegistrationProvider with ChangeNotifier {
//   final CourseRegistrationService _courseRegistrationService =
//       CourseRegistrationService();

//   List<CourseRegistrationModel> _registeredCourses = [];
//   bool _isLoading = false;

//   List<CourseRegistrationModel> get registeredCourses => _registeredCourses;
//   bool get isLoading => _isLoading;

//   //  Fetch registered courses (Fixed)
//   Future<void> fetchRegisteredCourses(String classId, String term, String year) async {
//   _isLoading = true;
//   notifyListeners();

//   try {
//     _registeredCourses = await _courseRegistrationService.fetchRegisteredCourses(classId, term, year);
//   } catch (e) {
//     print("Error fetching registered courses: $e");
//   } finally {
//     _isLoading = false;
//     notifyListeners(); // Ensures UI updates after loading
//   }
// }

//   //  Register a new course
//   Future<void> registerCourse(CourseRegistrationModel course) async {
//     _isLoading = true;
//     notifyListeners();

//     bool success = await _courseRegistrationService.registerCourse(course);

//     if (success) {
//       _registeredCourses.add(course);
//     }

//     _isLoading = false;
//     notifyListeners();
//   }
// }
