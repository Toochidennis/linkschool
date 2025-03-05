import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/grade%20_model.dart';
import 'package:linkschool/modules/services/admin/grade_service.dart';

class GradeProvider with ChangeNotifier {
  final GradeService _gradeService = GradeService();
  List<Grade> _grades = [];
  bool _isLoading = false;
  String _error = '';

  List<Grade> get grades => _grades;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchGrades() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _grades = await _gradeService.getGrades();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGrade(String gradeSymbol, String start, String remark) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Add the new grade locally
      final newGrade = Grade(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(), // Generate a unique ID
        grade_Symbol: gradeSymbol,
        start: start,
        remark: remark,
      );
      _grades.add(newGrade); // Add the new grade to the local list
      notifyListeners(); // Notify listeners to update the UI

      // Post the new grade to the API
      await _gradeService.addGrade(gradeSymbol, start, remark);

      // Fetch the latest grades from the API to ensure consistency
      await fetchGrades();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}


// Future<void> addGrade(String gradeSymbol, String start, String remark, String text) async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();

//     try {
//       await _gradeService.addGrade(gradeSymbol, start, remark);
//       await fetchGrades();
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//     }
//   }