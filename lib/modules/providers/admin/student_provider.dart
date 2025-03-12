// lib/providers/attendance_provider.dart
import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/student_model.dart';
import 'package:linkschool/modules/services/admin/student_service.dart';


class StudentProvider extends ChangeNotifier {
  final StudentService _studentService = StudentService();
  
  List<Student> _students = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _selectAll = false;
  
  // Getters
  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get selectAll => _selectAll;
  List<int> get selectedStudentIds => _students
    .where((student) => student.isSelected)
    .map((student) => student.id)
    .toList();

  // Fetch students for a specific class
  Future<void> fetchStudents(String? classId) async {
    if (classId == null) {
      _errorMessage = 'Class ID is missing';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final fetchedStudents = await _studentService.getStudentsByClass(classId);
      
      _students = fetchedStudents;
      _isLoading = false;
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Toggle selection for a single student
  void toggleStudentSelection(int index) {
    if (index < 0 || index >= _students.length) return;
    
    _students[index] = _students[index].copyWith(
      isSelected: !_students[index].isSelected
    );
    
    // Update selectAll status
    _updateSelectAllStatus();
    
    notifyListeners();
  }

  // Toggle selection for all students
  void toggleSelectAll() {
    _selectAll = !_selectAll;
    
    // Update all students
    for (int i = 0; i < _students.length; i++) {
      _students[i] = _students[i].copyWith(isSelected: _selectAll);
    }
    
    notifyListeners();
  }

  // Check if all students are selected and update _selectAll accordingly
  void _updateSelectAllStatus() {
    _selectAll = _students.isNotEmpty && 
                 _students.every((student) => student.isSelected);
  }



  // Reset state when navigating away

}