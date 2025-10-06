import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/home/level_class_model.dart';
import 'package:linkschool/modules/services/admin/home/assign_course_service.dart';
import 'package:linkschool/modules/services/admin/home/level_class_service.dart';



class AssignCourseProvider with ChangeNotifier {
  final AssignCourseService _assignCourseService;

  bool isLoading = false;
  String? message;
  String? error;


  AssignCourseProvider(this._assignCourseService);

  

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