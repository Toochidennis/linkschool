import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/getcurrent_registration_model.dart';
import 'package:linkschool/modules/services/admin/getcurrentcourse_registeration_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class getCurrentCourseRegistrationProvider with ChangeNotifier {
  final GetcurrentcourseRegisterationService _currentregistrationservice =
      locator<GetcurrentcourseRegisterationService>();
  List<CurrentCourseRegistrationModel> _currentRegistration = [];
  bool _isLoading = false;

  List<CurrentCourseRegistrationModel> get currentRegistration =>
      _currentRegistration;
  bool get isLoading => _isLoading;

  // Fetch current course registration
  Future<void> fetchCurrentCourseRegistration(
      studentId, classID, term, Year) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _currentregistrationservice.getCurrentCourseRegistration(
          studentId, classID, term, Year); 
          
        if(response.success && response.data != null){
          _currentRegistration = response.data!;
        }else{
          _currentRegistration =[];
          debugPrint('No Current course Found');
        }// Fixed method call
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
