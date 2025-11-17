import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/home/manage_student_service.dart';
import '../../../model/admin/home/manage_student_model.dart';

class ManageStudentProvider with ChangeNotifier {
  final ManageStudentService _studentService;

  bool isLoading = false;
  bool isLoadingMore = false;
  String? message;
  String? error;
  List<Students> students = [];
  
  // Pagination fields
  int currentPage = 1;
  int totalPages = 1;
  bool hasMore = false;
  int? currentLevelId;
  int? currentClassId;
  int maleStudents = 0;
  int femaleStudents = 0;

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

  Future<bool> updateStudent(
      String studentId, Map<String, dynamic> updatedStudent) async {
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

  Future<void> fetchStudentsByLevel({
    required int levelId,
    int page = 1,
    bool append = false,
  }) async {
    if (append) {
      isLoadingMore = true;
    } else {
      isLoading = true;
      students = [];
      currentPage = 1;
    }
    error = null;
    currentLevelId = levelId;
    currentClassId = null;
    notifyListeners();

    try {
      final response = await _studentService.fetchStudentsByLevel(
        levelId: levelId,
        page: page,
        limit: 15,
      );
      
      maleStudents = response.maleStudents;
      femaleStudents = response.femaleStudents;
      
      if (append) {
        students.addAll(response.students.data);
      } else {
        students = response.students.data;
      }
      
      currentPage = response.students.meta.currentPage;
      totalPages = response.students.meta.lastPage;
      hasMore = response.students.meta.hasNext;
      
      print("Fetched ${response.students.data.length} students for level $levelId, page $page");
      print("Total students: ${response.students.meta.total}, Has more: $hasMore");
    } catch (e) {
      error = "Failed to fetch students by level: $e";
      print("Error in provider: $e");
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreStudents() async {
    if (isLoadingMore || !hasMore) return;
    
    if (currentClassId != null) {
      await fetchStudentsByClass(
        classId: currentClassId!,
        page: currentPage + 1,
        append: true,
      );
    } else if (currentLevelId != null) {
      await fetchStudentsByLevel(
        levelId: currentLevelId!,
        page: currentPage + 1,
        append: true,
      );
    }
  }

  Future<void> fetchStudentsByClass({
    required int classId,
    int page = 1,
    bool append = false,
  }) async {
    if (append) {
      isLoadingMore = true;
    } else {
      isLoading = true;
      students = [];
      currentPage = 1;
    }
    error = null;
    currentClassId = classId;
    currentLevelId = null;
    notifyListeners();

    try {
      final response = await _studentService.fetchStudentsByClass(
        classId: classId,
        page: page,
        limit: 15,
      );
      
      maleStudents = response.maleStudents;
      femaleStudents = response.femaleStudents;
      
      if (append) {
        students.addAll(response.students.data);
      } else {
        students = response.students.data;
      }
      
      currentPage = response.students.meta.currentPage;
      totalPages = response.students.meta.lastPage;
      hasMore = response.students.meta.hasNext;
      
      print("Fetched ${response.students.data.length} students for class $classId, page $page");
      print("Total students: ${response.students.meta.total}, Has more: $hasMore");
    } catch (e) {
      error = "Failed to fetch students by class: $e";
      print("Error in provider: $e");
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void resetPagination() {
    currentPage = 1;
    totalPages = 1;
    hasMore = false;
    currentLevelId = null;
    currentClassId = null;
    maleStudents = 0;
    femaleStudents = 0;
    students = [];
    notifyListeners();
  }
}
