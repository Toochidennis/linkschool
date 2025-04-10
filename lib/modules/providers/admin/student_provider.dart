import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/student_model.dart';
import 'package:linkschool/modules/services/admin/student_service.dart';
import 'package:hive/hive.dart';

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

  // Fetch attendance data
  Future<void> fetchAttendance({
    required String classId, 
    required String date, 
    required String courseId,
  }) async {
    // Implement attendance fetching logic if needed
    notifyListeners();
  }

  // Fetch local attendance data
  Future<void> fetchLocalAttendance({
    required String classId, 
    required String date, 
    required String courseId,
  }) async {
    try {
      final attendanceBox = await Hive.openBox('attendance');
      final key = '${classId}_${date}_$courseId';
      
      final localData = attendanceBox.get(key);
      if (localData is List<dynamic>) {
        _localAttendance = localData.cast<int>();
        
        // Mark students as selected based on local attendance
        for (var student in _students) {
          student.isSelected = _localAttendance.contains(student.id);
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching local attendance: $e');
    }
  }


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
    } else {
      _errorMessage = 'Failed to save attendance';
    }

    notifyListeners();
    return success;
  } catch (e) {
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
      final key = '${classId}_${date}_$courseId';
      
      await attendanceBox.put(key, studentIds);
      
      _localAttendance = studentIds;
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
}




// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/model/admin/student_model.dart';
// import 'package:linkschool/modules/services/admin/student_service.dart';
// import 'package:hive/hive.dart';

// class StudentProvider extends ChangeNotifier {
//   final StudentService _studentService;
  
//   StudentProvider(this._studentService);
  
//   List<Student> _students = [];
//   bool _isLoading = false;
//   String _errorMessage = '';
//   bool _selectAll = false;
//   Student? _student;
//   Map<String, dynamic>? _studentTerms;
//   List<int> _localAttendance = [];

//   // Getters
//   List<Student> get students => _students;
//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;
//   bool get selectAll => _selectAll;
//   List<int> get selectedStudentIds => _students
//     .where((student) => student.isSelected)
//     .map((student) => student.id)
//     .toList();
//   Student? get student => _student;
//   Map<String, dynamic>? get studentTerms => _studentTerms;

//   // Fetch students for a specific class
//   Future<void> fetchStudents(String? classId) async {
//     if (classId == null) {
//       _errorMessage = 'Class ID is missing';
//       notifyListeners();
//       return;
//     }

//     try {
//       _isLoading = true;
//       _errorMessage = '';
//       notifyListeners();

//       final fetchedStudents = await _studentService.getStudentsByClass(classId);
      
//       _students = fetchedStudents;
//       _isLoading = false;
      
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }

//   // Fetch attendance data
//   Future<void> fetchAttendance({
//     required String classId, 
//     required String date, 
//     required String courseId,
//   }) async {
//     // Implement attendance fetching logic if needed
//     notifyListeners();
//   }

//   // Fetch local attendance data
//   Future<void> fetchLocalAttendance({
//     required String classId, 
//     required String date, 
//     required String courseId,
//   }) async {
//     try {
//       final attendanceBox = await Hive.openBox('attendance');
//       final key = '${classId}_${date}_$courseId';
      
//       final localData = attendanceBox.get(key);
//       if (localData is List<int>) {
//         _localAttendance = localData;
        
//         // Mark students as selected based on local attendance
//         for (var student in _students) {
//           student.isSelected = _localAttendance.contains(student.id);
//         }
        
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint('Error fetching local attendance: $e');
//     }
//   }

//   // Save attendance
//   Future<bool> saveAttendance({
//     required String? classId, 
//     required String? courseId, 
//     required String date,
//   }) async {
//     if (classId == null || courseId == null) {
//       _errorMessage = 'Class or Course ID is missing';
//       notifyListeners();
//       return false;
//     }

//     try {
//       final success = await _studentService.saveAttendance(
//         classId: classId,
//         courseId: courseId,
//         studentIds: selectedStudentIds,
//         date: date,
//       );

//       if (success) {
//         _errorMessage = '';
//       } else {
//         _errorMessage = 'Failed to save attendance';
//       }

//       notifyListeners();
//       return success;
//     } catch (e) {
//       _errorMessage = e.toString();
//       notifyListeners();
//       return false;
//     }
//   }

//   // Save local attendance
//   Future<void> saveLocalAttendance({
//     required String classId, 
//     required String date, 
//     required String courseId, 
//     required List<int> studentIds,
//   }) async {
//     try {
//       final attendanceBox = await Hive.openBox('attendance');
//       final key = '${classId}_${date}_$courseId';
      
//       await attendanceBox.put(key, studentIds);
      
//       _localAttendance = studentIds;
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error saving local attendance: $e');
//     }
//   }

//   // Reset provider state
//   void reset() {
//     _students = [];
//     _isLoading = false;
//     _errorMessage = '';
//     _selectAll = false;
//     _localAttendance = [];
//     notifyListeners();
//   }

//   // Toggle selection for a single student
//   void toggleStudentSelection(int index) {
//     if (index < 0 || index >= _students.length) return;
    
//     _students[index] = _students[index].copyWith(
//       isSelected: !_students[index].isSelected
//     );
    
//     // Update selectAll status
//     _updateSelectAllStatus();
    
//     notifyListeners();
//   }

//   // Toggle selection for all students
//   void toggleSelectAll() {
//     _selectAll = !_selectAll;
    
//     // Update all students
//     for (int i = 0; i < _students.length; i++) {
//       _students[i] = _students[i].copyWith(isSelected: _selectAll);
//     }
    
//     notifyListeners();
//   }

//   // Check if all students are selected and update _selectAll accordingly
//   void _updateSelectAllStatus() {
//     _selectAll = _students.isNotEmpty && 
//                  _students.every((student) => student.isSelected);
//   }

//   Future<void> fetchStudentTerms(int studentId) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final response = await _studentService.fetchStudentTerms(studentId);

//       // Check if the response contains the expected data
//       if (response.containsKey('terms') && response['terms'] != null) {
//         _studentTerms = response;
//       } else {
//         _studentTerms = null;
//         throw Exception('No terms data found in the API response');
//       }
//     } catch (e) {
//       _studentTerms = null;
//       debugPrint('Error fetching student terms: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }