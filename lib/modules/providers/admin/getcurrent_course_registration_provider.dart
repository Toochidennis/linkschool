import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/getcurrent_registration_model.dart';
import 'package:linkschool/modules/services/admin/getcurrentcourse_registeration_service.dart';

class getCurrentCourseRegistrationProvider with ChangeNotifier {
  final GetcurrentcourseRegisterationService _service =
      GetcurrentcourseRegisterationService();
  GetCurrentCourseRegistrationModel? _currentRegistration;
  bool _isLoading = false;

  GetCurrentCourseRegistrationModel? get currentRegistration =>
      _currentRegistration;
  bool get isLoading => _isLoading;

  // Fetch current course registration
  Future<void> fetchCurrentCourseRegistration(
      student_Id, classID, term, Year) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentRegistration = await _service.getCurrentCourseRegistration(
          student_Id, classID, term, Year); // Fixed method call
    } catch (e) {
      // Handle error
      print("Error fetching course registration: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Post current course registration
  // Future<void> postCurrentCourseRegistration(
  //     GetCurrentCourseRegistrationModel registration) async {
  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     await _service.postCurrentCourseRegistration(registration);
  //   } catch (e) {
  //     // Handle error
  //     print("Error posting course registration: $e");
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
