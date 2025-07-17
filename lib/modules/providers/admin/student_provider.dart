import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/student_model.dart';
import 'package:linkschool/modules/services/admin/student_service.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class StudentProvider extends ChangeNotifier {
  final StudentService _studentService;

  StudentProvider(this._studentService);

  List<Student> _students = [];
  List<Student> _allStudents = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _selectAll = false;
  Student? _student;
  Map<String, dynamic>? _studentTerms;
  List<int> _localAttendance = [];
  List<int> _attendedStudentIds = [];
  int? _currentAttendanceId;
  bool _hasExistingAttendance = false;
  Map<String, dynamic>? _studentTermResult;
  List<Map<String, dynamic>>? _annualResults;

  List<Student> get students => _students;
  List<Student> get allStudents => _allStudents;
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
  int? get currentAttendanceId => _currentAttendanceId;
  bool get hasExistingAttendance => _hasExistingAttendance;
  Map<String, dynamic>? get studentTermResult => _studentTermResult;
  List<Map<String, dynamic>>? get annualResults => _annualResults;

  Future<bool> updateAttendance({required int attendanceId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final studentsToMark = _students.where((s) => s.isMarkedPresent).toList();
      final studentIdsToMark = studentsToMark.map((s) => s.id).toList();

      final success = await _studentService.updateAttendance(
        attendanceId: attendanceId,
        studentIds: studentIdsToMark,
        selectedStudents: studentsToMark,
      );

      if (success) {
        _errorMessage = '';
        _attendedStudentIds = studentIdsToMark;
        for (int i = 0; i < _students.length; i++) {
          final isAttended = _attendedStudentIds.contains(_students[i].id);
          _students[i] = _students[i].copyWith(
            hasAttended: isAttended,
            isSelected: false,
          );
        }
        _selectAll = false;
      } else {
        _errorMessage = 'Failed to update attendance';
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

  Future<void> fetchStudents(String? classId, {String? courseId}) async {
    if (classId == null) {
      _errorMessage = 'Class ID is missing';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = '';
      _students = []; // Clear existing students
      notifyListeners();

      final fetchedStudents = courseId != null
          ? await _studentService.getStudentsByCourse(courseId, classId)
          : await _studentService.getStudentsByClass(classId);

      _students = fetchedStudents;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchAllStudents() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final fetchedStudents = await _studentService.getAllStudents();
      _allStudents = fetchedStudents;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchStudentResultTerms(int studentId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final fetchedTerms = await _studentService.getStudentResultTerms(studentId);
      _studentTerms = fetchedTerms;
      _student = _allStudents.firstWhere(
        (student) => student.id == studentId,
        orElse: () => _students.firstWhere(
          (student) => student.id == studentId,
          orElse: () => throw Exception('Student not found'),
        ),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchAttendance({
    required String classId,
    required String date,
    required String courseId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = ''; // Clear any previous errors
      notifyListeners();

      final attendanceRecords = await _studentService.getClassAttendance(
        classId: classId,
        date: date,
      );

      _attendedStudentIds = [];
      _currentAttendanceId = null;
      _hasExistingAttendance = false;

      if (attendanceRecords.isNotEmpty) {
        final firstRecord = attendanceRecords[0];
        if (firstRecord.containsKey('id')) {
          _currentAttendanceId = firstRecord['id'] is int
              ? firstRecord['id']
              : int.tryParse(firstRecord['id'].toString());
          _hasExistingAttendance = _currentAttendanceId != null;
        }

        if (firstRecord['students'] != null) {
          final students = firstRecord['students'];
          if (students is List) {
            for (var student in students) {
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
      } else {
        debugPrint('No existing attendance records found for class $classId on $date');
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
      debugPrint('Error in fetchAttendance: $e');
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
      _errorMessage = ''; // Clear any previous errors
      notifyListeners();

      final attendanceRecords = await _studentService.getCourseAttendance(
        classId: classId,
        date: date,
        courseId: courseId,
      );

      _attendedStudentIds = [];
      _currentAttendanceId = null;
      _hasExistingAttendance = false;

      if (attendanceRecords.isNotEmpty) {
        final firstRecord = attendanceRecords[0];
        if (firstRecord.containsKey('id')) {
          _currentAttendanceId = firstRecord['id'] is int
              ? firstRecord['id']
              : int.tryParse(firstRecord['id'].toString());
          _hasExistingAttendance = _currentAttendanceId != null;
        }

        if (firstRecord['students'] != null) {
          final students = firstRecord['students'];
          if (students is List) {
            for (var student in students) {
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
      } else {
        debugPrint('No existing attendance records found for course $courseId on $date');
      }

      // Update student attendance status
      for (int i = 0; i < _students.length; i++) {
        final student = _students[i];
        final isAttended = _attendedStudentIds.contains(student.id);
        _students[i] = student.copyWith(hasAttended: isAttended);
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
      debugPrint('Error in fetchCourseAttendance: $e');
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
        final updatedAttendedIds = [..._attendedStudentIds];
        for (final studentId in selectedStudentIds) {
          if (!updatedAttendedIds.contains(studentId)) {
            updatedAttendedIds.add(studentId);
          }
        }

        final dateOnly = date.split(' ')[0];
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

  Future<void> saveAttendedStudents({
    required String classId,
    required String date,
    required List<int> studentIds,
  }) async {
    try {
      final attendanceBox = await Hive.openBox('attendance');
      final dateOnly = date.split(' ')[0];
      final key = 'attended_${classId}_$dateOnly';
      await attendanceBox.put(key, studentIds);
      _attendedStudentIds = studentIds;
      debugPrint('Saved attended students with key: $key');
      debugPrint('Attended students: $_attendedStudentIds');

      for (int i = 0; i < _students.length; i++) {
        final isAttended = _attendedStudentIds.contains(_students[i].id);
        _students[i] = _students[i].copyWith(hasAttended: isAttended);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving attended students: $e');
    }
  }

  Future<void> loadAttendedStudents({
    required String classId,
    required String date,
  }) async {
    try {
      final attendanceBox = await Hive.openBox('attendance');
      final dateOnly = date.split(' ')[0];
      final key = 'attended_${classId}_$dateOnly';
      debugPrint("Loading attended students with key: $key");

      final localData = attendanceBox.get(key);
      if (localData is List<dynamic>) {
        _attendedStudentIds = localData.cast<int>();
        debugPrint("Loaded attended students: $_attendedStudentIds");

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

  Future<void> fetchLocalAttendance({
    required String classId,
    required String date,
    required String courseId,
  }) async {
    try {
      final attendanceBox = await Hive.openBox('attendance');
      final dateOnly = date.split(' ')[0];
      final key = '${classId}_${dateOnly}_$courseId';
      debugPrint("Fetching local attendance with key: $key");

      final localData = attendanceBox.get(key);
      if (localData is List<dynamic>) {
        _localAttendance = localData.cast<int>();
        debugPrint("Loaded local attendance: $_localAttendance");

        for (var i = 0; i < _students.length; i++) {
          final isSelected = _localAttendance.contains(_students[i].id);
          _students[i] = _students[i].copyWith(isSelected: isSelected);
        }
        _updateSelectAllStatus();
        notifyListeners();
      } else {
        debugPrint("No local attendance data found for key: $key");
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
      _isLoading = true;
      notifyListeners();

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
        final updatedAttendedIds = [..._attendedStudentIds];
        for (final studentId in selectedStudentIds) {
          if (!updatedAttendedIds.contains(studentId)) {
            updatedAttendedIds.add(studentId);
          }
        }

        final dateOnly = date.split(' ')[0];
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

  Future<void> saveLocalAttendance({
    required String classId,
    required String date,
    required String courseId,
    required List<int> studentIds,
  }) async {
    try {
      final attendanceBox = await Hive.openBox('attendance');
      final dateOnly = date.split(' ')[0];
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

  Future<void> fetchAnnualResults({
    required int studentId,
    required String classId,
    required String levelId,
    required String year,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      debugPrint('Fetching annual results with params: '
          'studentId=$studentId, classId=$classId, levelId=$levelId, year=$year');
      notifyListeners();

      final result = await _studentService.getStudentAnnualResults(
        studentId: studentId,
        classId: classId,
        levelId: levelId,
        year: year,
      );

      debugPrint('Received annual results: $result');
      _annualResults = result;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error fetching annual results: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    }
  }

  void reset() {
    _students = [];
    _isLoading = false;
    _errorMessage = '';
    _selectAll = false;
    _localAttendance = [];
    _attendedStudentIds = [];
    _currentAttendanceId = null;
    _hasExistingAttendance = false;
    _annualResults = null;
    notifyListeners();
  }

  void toggleStudentSelection(int index) {
    if (index < 0 || index >= _students.length) return;

    _students[index] = _students[index].copyWith(
      isSelected: !_students[index].isSelected,
    );
    _updateSelectAllStatus();
    notifyListeners();
  }

  void toggleSelectAll() {
    _selectAll = !_selectAll;
    for (int i = 0; i < _students.length; i++) {
      _students[i] = _students[i].copyWith(
        isSelected: _selectAll,
        hasAttended: _selectAll ? _students[i].hasAttended : false,
      );
    }
    notifyListeners();
  }

  void _updateSelectAllStatus() {
    _selectAll = _students.isNotEmpty &&
        _students.every((student) => student.isSelected);
  }

  Future<void> fetchStudentTermResults({
    required int studentId,
    required int termId,
    required String classId,
    required String year,
    required String levelId,
  }) async {
    try {
      // Validate parameters
      if (classId.isEmpty || levelId.isEmpty || year.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Invalid parameters: classId, levelId, or year is empty';
        debugPrint(_errorMessage);
        notifyListeners();
        return;
      }

      _isLoading = true;
      _errorMessage = '';
      debugPrint('Fetching term results with params: '
          'studentId=$studentId, termId=$termId, classId=$classId, '
          'year=$year, levelId=$levelId');
      notifyListeners();

      final result = await _studentService.getStudentTermResults(
        studentId: studentId,
        termId: termId,
        classId: classId,
        year: year,
        levelId: levelId,
      );

      debugPrint('Received term results: $result');
      _studentTermResult = result;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error fetching term results: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    }
  }
}





// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/model/admin/student_model.dart';
// import 'package:linkschool/modules/services/admin/student_service.dart';
// import 'package:hive/hive.dart';
// import 'dart:convert';

// class StudentProvider extends ChangeNotifier {
//   final StudentService _studentService;

//   StudentProvider(this._studentService);

//   List<Student> _students = [];
//   List<Student> _allStudents = [];
//   bool _isLoading = false;
//   String _errorMessage = '';
//   bool _selectAll = false;
//   Student? _student;
//   Map<String, dynamic>? _studentTerms;
//   List<int> _localAttendance = [];
//   List<int> _attendedStudentIds = [];
//   int? _currentAttendanceId;
//   bool _hasExistingAttendance = false;
//   Map<String, dynamic>? _studentTermResult;
//   List<Map<String, dynamic>>? _annualResults;

//   List<Student> get students => _students;
//   List<Student> get allStudents => _allStudents;
//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;
//   bool get selectAll => _selectAll;
//   List<int> get selectedStudentIds => _students
//       .where((student) => student.isSelected)
//       .map((student) => student.id)
//       .toList();
//   List<int> get attendedStudentIds => _attendedStudentIds;
//   Student? get student => _student;
//   Map<String, dynamic>? get studentTerms => _studentTerms;
//   int? get currentAttendanceId => _currentAttendanceId;
//   bool get hasExistingAttendance => _hasExistingAttendance;
//   Map<String, dynamic>? get studentTermResult => _studentTermResult;
//   List<Map<String, dynamic>>? get annualResults => _annualResults;

//   Future<bool> updateAttendance({required int attendanceId}) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final studentsToMark = _students.where((s) => s.isMarkedPresent).toList();
//       final studentIdsToMark = studentsToMark.map((s) => s.id).toList();

//       final success = await _studentService.updateAttendance(
//         attendanceId: attendanceId,
//         studentIds: studentIdsToMark,
//         selectedStudents: studentsToMark,
//       );

//       if (success) {
//         _errorMessage = '';
//         _attendedStudentIds = studentIdsToMark;

//         for (int i = 0; i < _students.length; i++) {
//           final isAttended = _attendedStudentIds.contains(_students[i].id);
//           _students[i] = _students[i].copyWith(
//             hasAttended: isAttended,
//             isSelected: false,
//           );
//         }

//         _selectAll = false;
//       } else {
//         _errorMessage = 'Failed to update attendance';
//       }

//       _isLoading = false;
//       notifyListeners();
//       return success;
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> fetchStudents(String? classId, {String? courseId}) async {
//     if (classId == null) {
//       _errorMessage = 'Class ID is missing';
//       notifyListeners();
//       return;
//     }

//     try {
//       _isLoading = true;
//       _errorMessage = '';
//       _students = []; // Clear existing students
//       notifyListeners();

//       final fetchedStudents = courseId != null
//           ? await _studentService.getStudentsByCourse(courseId, classId)
//           : await _studentService.getStudentsByClass(classId);

//       _students = fetchedStudents;
//       _isLoading = false;

//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> fetchAllStudents() async {
//     try {
//       _isLoading = true;
//       _errorMessage = '';
//       notifyListeners();

//       final fetchedStudents = await _studentService.getAllStudents();

//       _allStudents = fetchedStudents;
//       _isLoading = false;

//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> fetchStudentResultTerms(int studentId) async {
//     try {
//       _isLoading = true;
//       _errorMessage = '';
//       notifyListeners();

//       final fetchedTerms = await _studentService.getStudentResultTerms(studentId);

//       _studentTerms = fetchedTerms;

//       _student = _allStudents.firstWhere(
//         (student) => student.id == studentId,
//         orElse: () => _students.firstWhere(
//           (student) => student.id == studentId,
//           orElse: () => throw Exception('Student not found'),
//         ),
//       );

//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> fetchAttendance({
//     required String classId,
//     required String date,
//     required String courseId,
//   }) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final attendanceRecords = await _studentService.getClassAttendance(
//         classId: classId,
//         date: date,
//       );

//       _attendedStudentIds = [];
//       _currentAttendanceId = null;
//       _hasExistingAttendance = false;

//       if (attendanceRecords.isNotEmpty) {
//         final firstRecord = attendanceRecords[0];

//         if (firstRecord.containsKey('id')) {
//           _currentAttendanceId = firstRecord['id'] is int
//               ? firstRecord['id']
//               : int.tryParse(firstRecord['id'].toString());
//           _hasExistingAttendance = _currentAttendanceId != null;
//         }

//         if (firstRecord['register'] != null) {
//           dynamic registerData = firstRecord['register'];

//           if (registerData is String) {
//             try {
//               registerData = jsonDecode(registerData);
//             } catch (e) {
//               debugPrint('Error parsing register JSON: $e');
//               registerData = null;
//             }
//           }

//           if (registerData is List) {
//             for (var student in registerData) {
//               if (student is Map && student.containsKey('id')) {
//                 final idString = student['id'].toString();
//                 final studentId = int.tryParse(idString) ?? -1;

//                 if (studentId != -1 && !_attendedStudentIds.contains(studentId)) {
//                   _attendedStudentIds.add(studentId);
//                 }
//               }
//             }
//           }
//         }
//       }

//       for (int i = 0; i < _students.length; i++) {
//         final isAttended = _attendedStudentIds.contains(_students[i].id);
//         _students[i] = _students[i].copyWith(hasAttended: isAttended);
//       }

//       await saveAttendedStudents(
//         classId: classId,
//         date: date.split(' ')[0],
//         studentIds: _attendedStudentIds,
//       );

//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }

//   Future<void> fetchCourseAttendance({
//     required String classId,
//     required String date,
//     required String courseId,
//   }) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final attendanceRecords = await _studentService.getCourseAttendance(
//         classId: classId,
//         date: date,
//         courseId: courseId,
//       );

//       _attendedStudentIds = [];
//       _currentAttendanceId = null;
//       _hasExistingAttendance = false;

//       if (attendanceRecords.isNotEmpty) {
//         final firstRecord = attendanceRecords[0];

//         if (firstRecord.containsKey('id')) {
//           _currentAttendanceId = firstRecord['id'] is int
//               ? firstRecord['id']
//               : int.tryParse(firstRecord['id'].toString());
//           _hasExistingAttendance = _currentAttendanceId != null;
//         }

//         if (firstRecord['register'] != null) {
//           String registerStr = firstRecord['register'].toString();
//           if (registerStr.startsWith(' ')) {
//             registerStr = registerStr.substring(1);
//           }

//           try {
//             List<dynamic> registerList = jsonDecode(registerStr);

//             for (var student in registerList) {
//               if (student is Map && student.containsKey('id')) {
//                 final idString = student['id'].toString();
//                 final studentId = int.tryParse(idString) ?? -1;

//                 if (studentId != -1 && !_attendedStudentIds.contains(studentId)) {
//                   _attendedStudentIds.add(studentId);
//                 }
//               }
//             }
//           } catch (e) {
//             debugPrint('Error parsing register JSON: $e');
//           }
//         }
//       }

//       for (int i = 0; i < _students.length; i++) {
//         final student = _students[i];
//         final isAttended = _attendedStudentIds.contains(student.id);
//         _students[i] = student.copyWith(hasAttended: isAttended);
//       }

//       await saveAttendedStudents(
//         classId: classId,
//         date: date.split(' ')[0],
//         studentIds: _attendedStudentIds,
//       );

//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }

//   Future<bool> saveCourseAttendance({
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
//       _isLoading = true;
//       notifyListeners();

//       final selectedStudents = _students.where((student) => student.isSelected).toList();

//       final success = await _studentService.saveCourseAttendance(
//         classId: classId,
//         courseId: courseId,
//         studentIds: selectedStudentIds,
//         date: date,
//         selectedStudents: selectedStudents,
//       );

//       if (success) {
//         _errorMessage = '';

//         final updatedAttendedIds = [..._attendedStudentIds];

//         for (final studentId in selectedStudentIds) {
//           if (!updatedAttendedIds.contains(studentId)) {
//             updatedAttendedIds.add(studentId);
//           }
//         }

//         final dateOnly = date.split(' ')[0];
//         await saveAttendedStudents(
//           classId: classId,
//           date: dateOnly,
//           studentIds: updatedAttendedIds,
//         );
//       } else {
//         _errorMessage = 'Failed to save attendance';
//       }

//       _isLoading = false;
//       notifyListeners();
//       return success;
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> saveAttendedStudents({
//     required String classId,
//     required String date,
//     required List<int> studentIds,
//   }) async {
//     try {
//       final attendanceBox = await Hive.openBox('attendance');
//       final dateOnly = date.split(' ')[0];
//       final key = 'attended_${classId}_$dateOnly';

//       await attendanceBox.put(key, studentIds);
//       _attendedStudentIds = studentIds;

//       debugPrint('Saved attended students with key: $key');
//       debugPrint('Attended students: $_attendedStudentIds');

//       for (int i = 0; i < _students.length; i++) {
//         final isAttended = _attendedStudentIds.contains(_students[i].id);
//         _students[i] = _students[i].copyWith(hasAttended: isAttended);
//       }

//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error saving attended students: $e');
//     }
//   }

//   Future<void> loadAttendedStudents({
//     required String classId,
//     required String date,
//   }) async {
//     try {
//       final attendanceBox = await Hive.openBox('attendance');
//       final dateOnly = date.split(' ')[0];
//       final key = 'attended_${classId}_$dateOnly';

//       debugPrint("Loading attended students with key: $key");
//       final localData = attendanceBox.get(key);

//       if (localData is List<dynamic>) {
//         _attendedStudentIds = localData.cast<int>();
//         debugPrint("Loaded attended students: $_attendedStudentIds");

//         for (int i = 0; i < _students.length; i++) {
//           final isAttended = _attendedStudentIds.contains(_students[i].id);
//           debugPrint("Student ${_students[i].id}: ${_students[i].name} - isAttended: $isAttended");
//           _students[i] = _students[i].copyWith(hasAttended: isAttended);
//         }

//         notifyListeners();
//       } else {
//         debugPrint("No attended students data found for key: $key");
//       }
//     } catch (e) {
//       debugPrint("Error loading attended students: $e");
//     }
//   }

//   Future<void> fetchLocalAttendance({
//     required String classId,
//     required String date,
//     required String courseId,
//   }) async {
//     try {
//       final attendanceBox = await Hive.openBox('attendance');
//       final dateOnly = date.split(' ')[0];
//       final key = '${classId}_${dateOnly}_$courseId';

//       debugPrint("Fetching local attendance with key: $key");
//       final localData = attendanceBox.get(key);

//       if (localData is List<dynamic>) {
//         _localAttendance = localData.cast<int>();
//         debugPrint("Loaded local attendance: $_localAttendance");

//         for (var i = 0; i < _students.length; i++) {
//           final isSelected = _localAttendance.contains(_students[i].id);
//           _students[i] = _students[i].copyWith(isSelected: isSelected);
//         }

//         _updateSelectAllStatus();

//         notifyListeners();
//       } else {
//         debugPrint("No local attendance data found for key: $key");
//       }
//     } catch (e) {
//       debugPrint('Error fetching local attendance: $e');
//     }
//   }

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
//       _isLoading = true;
//       notifyListeners();

//       final selectedStudents = _students.where((student) => student.isSelected).toList();

//       final success = await _studentService.saveAttendance(
//         classId: classId,
//         courseId: courseId,
//         studentIds: selectedStudentIds,
//         date: date,
//         selectedStudents: selectedStudents,
//       );

//       if (success) {
//         _errorMessage = '';

//         final updatedAttendedIds = [..._attendedStudentIds];

//         for (final studentId in selectedStudentIds) {
//           if (!updatedAttendedIds.contains(studentId)) {
//             updatedAttendedIds.add(studentId);
//           }
//         }

//         final dateOnly = date.split(' ')[0];
//         await saveAttendedStudents(
//           classId: classId,
//           date: dateOnly,
//           studentIds: updatedAttendedIds,
//         );
//       } else {
//         _errorMessage = 'Failed to save attendance';
//       }

//       _isLoading = false;
//       notifyListeners();
//       return success;
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> saveLocalAttendance({
//     required String classId,
//     required String date,
//     required String courseId,
//     required List<int> studentIds,
//   }) async {
//     try {
//       final attendanceBox = await Hive.openBox('attendance');
//       final dateOnly = date.split(' ')[0];
//       final key = '${classId}_${dateOnly}_$courseId';

//       await attendanceBox.put(key, studentIds);

//       _localAttendance = studentIds;
//       debugPrint('Saved local attendance with key: $key');
//       debugPrint('Local attendance: $_localAttendance');

//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error saving local attendance: $e');
//     }
//   }

//   Future<void> fetchAnnualResults({
//     required int studentId,
//     required String classId,
//     required String levelId,
//     required String year,
//   }) async {
//     try {
//       _isLoading = true;
//       _errorMessage = '';
//       debugPrint('Fetching annual results with params: '
//           'studentId=$studentId, classId=$classId, levelId=$levelId, year=$year');
//       notifyListeners();

//       final result = await _studentService.getStudentAnnualResults(
//         studentId: studentId,
//         classId: classId,
//         levelId: levelId,
//         year: year,
//       );

//       debugPrint('Received annual results: $result');
//       _annualResults = result;
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = 'Error fetching annual results: $e';
//       debugPrint(_errorMessage);
//       notifyListeners();
//     }
//   }

//   void reset() {
//     _students = [];
//     _isLoading = false;
//     _errorMessage = '';
//     _selectAll = false;
//     _localAttendance = [];
//     _attendedStudentIds = [];
//     _currentAttendanceId = null;
//     _hasExistingAttendance = false;
//     _annualResults = null;
//     notifyListeners();
//   }

//   void toggleStudentSelection(int index) {
//     if (index < 0 || index >= _students.length) return;

//     _students[index] = _students[index].copyWith(
//       isSelected: !_students[index].isSelected,
//     );

//     _updateSelectAllStatus();

//     notifyListeners();
//   }

//   void toggleSelectAll() {
//     _selectAll = !_selectAll;

//     for (int i = 0; i < _students.length; i++) {
//       _students[i] = _students[i].copyWith(
//         isSelected: _selectAll,
//         hasAttended: _selectAll ? _students[i].hasAttended : false,
//       );
//     }

//     notifyListeners();
//   }

//   void _updateSelectAllStatus() {
//     _selectAll = _students.isNotEmpty &&
//         _students.every((student) => student.isSelected);
//   }

//   Future<void> fetchStudentTermResults({
//     required int studentId,
//     required int termId,
//     required String classId,
//     required String year,
//     required String levelId,
//   }) async {
//     try {
//       // Validate parameters
//       if (classId.isEmpty || levelId.isEmpty || year.isEmpty) {
//         _isLoading = false;
//         _errorMessage = 'Invalid parameters: classId, levelId, or year is empty';
//         debugPrint(_errorMessage);
//         notifyListeners();
//         return;
//       }

//       _isLoading = true;
//       _errorMessage = '';
//       debugPrint('Fetching term results with params: '
//           'studentId=$studentId, termId=$termId, classId=$classId, '
//           'year=$year, levelId=$levelId');
//       notifyListeners();

//       final result = await _studentService.getStudentTermResults(
//         studentId: studentId,
//         termId: termId,
//         classId: classId,
//         year: year,
//         levelId: levelId,
//       );

//       debugPrint('Received term results: $result');
//       _studentTermResult = result;
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = 'Error fetching term results: $e';
//       debugPrint(_errorMessage);
//       notifyListeners();
//     }
//   }
// }