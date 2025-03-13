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
  Student? _student;
   Map<String, dynamic>? _studentTerms;

  
  // Getters
  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get selectAll => _selectAll;
  List<int> get selectedStudentIds => _students
    .where((student) => student.isSelected)
    .map((student) => student.id)
    .toList();
  Student? get student => _student;
  Map<String, dynamic>? get studentTerms => _studentTerms;

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

  final StudentService _studentTermService = StudentService();



  Future<void> fetchStudentTerms(int studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _studentService.fetchStudentTerms(studentId);

      // Check if the response contains the expected data
      if (response.containsKey('terms') && response['terms'] != null) {
        _studentTerms = response;
      } else {
        _studentTerms = null;
        throw Exception('No terms data found in the API response');
      }
    } catch (e) {
      _studentTerms = null;
      debugPrint('Error fetching student terms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 

  Future<Student?> _getStudentDetails(int studentId) async {
    try {
      // Call the API and parse the response
      final response = await _studentService.getStudentsByClass(studentId.toString());
      return response.isNotEmpty ? response.first : null;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

}