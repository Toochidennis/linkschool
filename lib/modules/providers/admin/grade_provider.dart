import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/grade _model.dart';
import 'package:linkschool/modules/services/admin/grade_service.dart';

class GradeProvider with ChangeNotifier {
  final GradeService _gradeService;
  List<Grade> _grades = [];
  List<Grade> _newGrades = [];
  bool _isLoading = false;
  String _error = '';

  GradeProvider(this._gradeService);

  List<Grade> get grades => [..._grades, ..._newGrades];
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchGrades() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _grades = await _gradeService.getGrades();
      _newGrades.clear();
      _error = '';
    } catch (e) {
      _error = e.toString();
      print("Fetch Error: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGrade(String gradeSymbol, String start, String remark) async {
    final newGrade = Grade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      grade_Symbol: gradeSymbol,
      start: start,
      remark: remark,
    );

    _newGrades.add(newGrade);
    notifyListeners();
  }

  Future<void> saveNewGrades() async {
    if (_newGrades.isEmpty) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _gradeService.addGrades(_newGrades);
      await fetchGrades();
      _newGrades.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGrade(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    _grades.removeWhere((grade) => grade.id == id);
    _newGrades.removeWhere((grade) => grade.id == id);
    notifyListeners();

    try {
      await _gradeService.deleteGrades(id);
      await fetchGrades();
    } catch (e) {
      _error = e.toString();
      print("Delete Error: $_error");
      // Revert local deletion if API call fails
      await fetchGrades();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/model/admin/grade%20_model.dart';
// import 'package:linkschool/modules/services/admin/grade_service.dart';

// class GradeProvider with ChangeNotifier {
//   final GradeService _gradeService = GradeService();
//   List<Grade> _grades = [];
//   bool _isLoading = false;
//   String _error = '';

//   List<Grade> get grades => _grades;
//   bool get isLoading => _isLoading;
//   String get error => _error;

//   Future<void> fetchGrades() async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();

//     try {
//       _grades = await _gradeService.getGrades();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> addGrade(String gradeSymbol, String start, String remark) async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();

//     try {
//       // Add the new grade locally
//       final newGrade = Grade(
//         id: DateTime.now()
//             .millisecondsSinceEpoch
//             .toString(), // Generate a unique ID
//         grade_Symbol: gradeSymbol,
//         start: start,
//         remark: remark,
//       );
//       _grades.add(newGrade); // Add the new grade to the local list
//       notifyListeners(); // Notify listeners to update the UI

//       // Post the new grade to the API
//       await _gradeService.addGrade(gradeSymbol, start, remark);

//       // Fetch the latest grades from the API to ensure consistency
//       await fetchGrades();
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }