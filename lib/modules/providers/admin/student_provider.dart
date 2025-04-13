import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/student_model.dart';
import 'package:linkschool/modules/services/admin/student_service.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class StudentProvider extends ChangeNotifier {
  final StudentService _studentService;
  
  StudentProvider(this._studentService);
  
  List<Student> _students = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _selectAll = false;
  Student? _student;
  Map<String, dynamic>? _studentTerms;
  List<int> _localAttendance = [];
  List<int> _attendedStudentIds = [];

  // Getters
  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get selectAll => _selectAll;
  List<int> get selectedStudentIds => _students
    .where((student) => student.isSelected)
    .map((student) => student.id)
    .toList();
  List<int> get attendedStudentIds => _attendedStudentIds;
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

  // Fetch attendance data from API
Future<void> fetchAttendance({
  required String classId, 
  required String date, 
  required String courseId,
}) async {
  try {
    _isLoading = true;
    notifyListeners();
    
    final attendanceRecords = await _studentService.getClassAttendance(
      classId: classId,
      date: date,
    );
    
    _attendedStudentIds = [];
    
    // Process each attendance record
    if (attendanceRecords.isNotEmpty) {
      final firstRecord = attendanceRecords[0];
      
      if (firstRecord['register'] != null) {
        // Handle register data - it might be a List or a String
        dynamic registerData = firstRecord['register'];
        
        if (registerData is String) {
          // Try to parse if it's a string
          try {
            registerData = jsonDecode(registerData);
          } catch (e) {
            debugPrint('Error parsing register JSON: $e');
            registerData = null;
          }
        }
        
        if (registerData is List) {
          for (var student in registerData) {
            if (student is Map && student.containsKey('id')) {
              final idString = student['id'].toString();
              final studentId = int.tryParse(idString) ?? -1;
              
              if (studentId != -1 && !_attendedStudentIds.contains(studentId)) {
                _attendedStudentIds.add(studentId);
              }
            }
          }
        }
      }
    }
    
    // Update student attendance status
    for (int i = 0; i < _students.length; i++) {
      final isAttended = _attendedStudentIds.contains(_students[i].id);
      _students[i] = _students[i].copyWith(hasAttended: isAttended);
    }
    
    await saveAttendedStudents(
      classId: classId,
      date: date.split(' ')[0],
      studentIds: _attendedStudentIds,
    );
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
  }
}


Future<void> fetchCourseAttendance({
  required String classId, 
  required String date, 
  required String courseId,
}) async {
  try {
    _isLoading = true;
    notifyListeners();
    
    // Call the getCourseAttendance method from StudentService
    final attendanceRecords = await _studentService.getCourseAttendance(
      classId: classId,
      date: date,
      courseId: courseId,
    );
    
    _attendedStudentIds = [];
    
    // Process each attendance record
    if (attendanceRecords.isNotEmpty) {
      final firstRecord = attendanceRecords[0]; // Get the first record
      
      if (firstRecord['register'] != null) {
        // The register field contains a JSON string with potential leading space
        String registerStr = firstRecord['register'].toString();
        if (registerStr.startsWith(' ')) {
          registerStr = registerStr.substring(1);
        }
        
        try {
          // Parse the JSON string to get the list of attended students
          List<dynamic> registerList = jsonDecode(registerStr);
          
          for (var student in registerList) {
            if (student is Map && student.containsKey('id')) {
              // Convert string ID to int
              final idString = student['id'].toString();
              final studentId = int.tryParse(idString) ?? -1;
              
              if (studentId != -1 && !_attendedStudentIds.contains(studentId)) {
                _attendedStudentIds.add(studentId);
              }
            }
          }
        } catch (e) {
          debugPrint('Error parsing register JSON: $e');
        }
      }
    }
    
    // Update the hasAttended status for each student
    for (int i = 0; i < _students.length; i++) {
      final student = _students[i];
      final isAttended = _attendedStudentIds.contains(student.id);
      
      // Update the student using copyWith to set hasAttended
      _students[i] = student.copyWith(hasAttended: isAttended);
    }
    
    // Save the attended students locally
    await saveAttendedStudents(
      classId: classId,
      date: date.split(' ')[0], // Store with just the date part
      studentIds: _attendedStudentIds,
    );
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
  }
}

Future<bool> saveCourseAttendance({
  required String? classId, 
  required String? courseId, 
  required String date,
}) async {
  if (classId == null || courseId == null) {
    _errorMessage = 'Class or Course ID is missing';
    notifyListeners();
    return false;
  }

  try {
    _isLoading = true;
    notifyListeners();
    
    // Get selected students with their complete data (not just IDs)
    final selectedStudents = _students.where((student) => student.isSelected).toList();
    
    final success = await _studentService.saveCourseAttendance(
      classId: classId,
      courseId: courseId,
      studentIds: selectedStudentIds,
      date: date,
      selectedStudents: selectedStudents,
    );

    if (success) {
      _errorMessage = '';
      
      // Update the attended students list with newly selected students
      final updatedAttendedIds = [..._attendedStudentIds];
      
      // Add any newly selected student IDs that aren't already in the attended list
      for (final studentId in selectedStudentIds) {
        if (!updatedAttendedIds.contains(studentId)) {
          updatedAttendedIds.add(studentId);
        }
      }
      
      // Save the updated attended students list
      final dateOnly = date.split(' ')[0]; // Extract just the date part
      await saveAttendedStudents(
        classId: classId,
        date: dateOnly,
        studentIds: updatedAttendedIds,
      );
    } else {
      _errorMessage = 'Failed to save attendance';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}

  // Save attended students to local storage
  Future<void> saveAttendedStudents({
    required String classId,
    required String date,
    required List<int> studentIds,
  }) async {
    try {
      final attendanceBox = await Hive.openBox('attendance');
      final dateOnly = date.split(' ')[0]; // Extract just the date part
      final key = 'attended_${classId}_$dateOnly';
      
      await attendanceBox.put(key, studentIds);
      _attendedStudentIds = studentIds;
      
      debugPrint('Saved attended students with key: $key');
      debugPrint('Attended students: $_attendedStudentIds');
      
      // Update the hasAttended property for all students
      for (int i = 0; i < _students.length; i++) {
        final isAttended = _attendedStudentIds.contains(_students[i].id);
        _students[i] = _students[i].copyWith(hasAttended: isAttended);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving attended students: $e');
    }
  }

  // Load attended students from local storage
  Future<void> loadAttendedStudents({
    required String classId,
    required String date,
  }) async {
    try {
      final attendanceBox = await Hive.openBox('attendance');
      final dateOnly = date.split(' ')[0]; // Extract just the date part
      final key = 'attended_${classId}_$dateOnly';
      
      debugPrint("Loading attended students with key: $key");
      final localData = attendanceBox.get(key);

      if (localData is List<dynamic>) {
        _attendedStudentIds = localData.cast<int>();
        debugPrint("Loaded attended students: $_attendedStudentIds");
        
        // Update the hasAttended property for all students
        for (int i = 0; i < _students.length; i++) {
          final isAttended = _attendedStudentIds.contains(_students[i].id);
          debugPrint("Student ${_students[i].id}: ${_students[i].name} - isAttended: $isAttended");
          _students[i] = _students[i].copyWith(hasAttended: isAttended);
        }
        
        notifyListeners();
      } else {
        debugPrint("No attended students data found for key: $key");
      }
    } catch (e) {
      debugPrint("Error loading attended students: $e");
    }
  }

  // Fetch local attendance data
  Future<void> fetchLocalAttendance({
    required String classId, 
    required String date, 
    required String courseId,
  }) async {
    try {
      final attendanceBox = await Hive.openBox('attendance');
      final dateOnly = date.split(' ')[0]; // Extract just the date part 
      final key = '${classId}_${dateOnly}_$courseId';
      
      debugPrint("Fetching local attendance with key: $key");
      final localData = attendanceBox.get(key);
      
      if (localData is List<dynamic>) {
        _localAttendance = localData.cast<int>();
        debugPrint("Loaded local attendance: $_localAttendance");
        
        // Mark students as selected based on local attendance
        for (var i = 0; i < _students.length; i++) {
          final isSelected = _localAttendance.contains(_students[i].id);
          _students[i] = _students[i].copyWith(isSelected: isSelected);
        }
        
        // Update selectAll status
        _updateSelectAllStatus();
        
        notifyListeners();
      } else {
        debugPrint("No local attendance data found for key: $key");
      }
    } catch (e) {
      debugPrint('Error fetching local attendance: $e');
    }
  }

  // Save attendance to API
  Future<bool> saveAttendance({
    required String? classId, 
    required String? courseId, 
    required String date,
  }) async {
    if (classId == null || courseId == null) {
      _errorMessage = 'Class or Course ID is missing';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();
      
      // Get selected students with their complete data (not just IDs)
      final selectedStudents = _students.where((student) => student.isSelected).toList();
      
      final success = await _studentService.saveAttendance(
        classId: classId,
        courseId: courseId,
        studentIds: selectedStudentIds,
        date: date,
        selectedStudents: selectedStudents,
      );

      if (success) {
        _errorMessage = '';
        
        // Update the attended students list with newly selected students
        final updatedAttendedIds = [..._attendedStudentIds];
        
        // Add any newly selected student IDs that aren't already in the attended list
        for (final studentId in selectedStudentIds) {
          if (!updatedAttendedIds.contains(studentId)) {
            updatedAttendedIds.add(studentId);
          }
        }
        
        // Save the updated attended students list
        final dateOnly = date.split(' ')[0]; // Extract just the date part
        await saveAttendedStudents(
          classId: classId,
          date: dateOnly,
          studentIds: updatedAttendedIds,
        );
      } else {
        _errorMessage = 'Failed to save attendance';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Save local attendance
  Future<void> saveLocalAttendance({
    required String classId, 
    required String date, 
    required String courseId, 
    required List<int> studentIds,
  }) async {
    try {
      final attendanceBox = await Hive.openBox('attendance');
      final dateOnly = date.split(' ')[0]; // Extract just the date part
      final key = '${classId}_${dateOnly}_$courseId';
      
      await attendanceBox.put(key, studentIds);
      
      _localAttendance = studentIds;
      debugPrint('Saved local attendance with key: $key');
      debugPrint('Local attendance: $_localAttendance');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving local attendance: $e');
    }
  }

  // Reset provider state
  void reset() {
    _students = [];
    _isLoading = false;
    _errorMessage = '';
    _selectAll = false;
    _localAttendance = [];
    _attendedStudentIds = [];
    notifyListeners();
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
}