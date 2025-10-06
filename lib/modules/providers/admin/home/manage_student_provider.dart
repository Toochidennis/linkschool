import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/home/manage_student_service.dart';
import '../../../model/admin/home/manage_student_model.dart';

class ManageStudentProvider with ChangeNotifier {
  final ManageStudentService _studentService;

  bool isLoading = false;
  String? message;
  String? error;
  List<Students> students = [];

  ManageStudentProvider(this._studentService);

  Future<bool> createStudent(Map<String, dynamic> newStudent) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _studentService.createStudent(newStudent);
      message = "Student created successfully.";
      await fetchStudents();
      return true;
    } catch (e) {
      error = "Failed to create student: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStudent(String studentId, Map<String, dynamic> updatedStudent) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _studentService.updateStudent(studentId, updatedStudent);
      message = "Student updated successfully.";
      await fetchStudents();
      return true;
    } catch (e) {
      error = "Failed to update student: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteStudent(String studentId) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _studentService.deleteStudent(studentId);
      message = "Student deleted successfully.";
      await fetchStudents();
      return true;
    } catch (e) {
      error = "Failed to delete student: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStudents() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      students = await _studentService.fetchStudents();
      print("Fetched ${students.length} students");
    } catch (e) {
      error = "Failed to fetch students: $e";
      print("Error in provider: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}