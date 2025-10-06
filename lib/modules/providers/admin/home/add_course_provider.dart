import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/home/add_course_model.dart';
import 'package:linkschool/modules/services/admin/home/add_course_service.dart';


class CourseProvider with ChangeNotifier {
  final CourseService _courseService;
  bool isLoading = false;
  String? message;
  String? error;
  List<Courses> courses = [];

  CourseProvider(this._courseService);

  Future<bool> createCourse(Map<String, dynamic> newCourse) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _courseService.createCourse(newCourse);
      message = "Course created successfully.";
      await fetchCourses();
      return true;
    } catch (e) {
      error = "Failed to create course: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCourse(String courseId, Map<String, dynamic> updatedCourse) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _courseService.updateCourse(courseId, updatedCourse);
      message = "Course updated successfully.";
      await fetchCourses();
      return true;
    } catch (e) {
      error = "Failed to update course: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _courseService.deleteCourse(courseId);
      message = "Course deleted successfully.";
      await fetchCourses();
      return true;
    } catch (e) {
      error = "Failed to delete course: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      courses = await _courseService.fetchCourses();
      print("Fetched ${courses.length} courses");
    } catch (e) {
      error = "Failed to fetch courses: $e";
      print("Error in provider: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}