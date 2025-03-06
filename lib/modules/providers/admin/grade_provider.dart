import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/grade%20_model.dart';
import 'package:linkschool/modules/services/admin/grade_service.dart';

class GradeProvider with ChangeNotifier {
  final GradeService _gradeService = GradeService();
  List<Grade> _grades = [];
  List<Grade> _newGrades = []; // List to store newly added grades
  bool _isLoading = false;
  String _error = '';

  List<Grade> get grades => [..._grades, ..._newGrades];
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchGrades() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _grades = await _gradeService.getGrades();
       _newGrades.clear(); // Clear new grades on refresh
      _error = '';
    } catch (e) {
      _error = e.toString();
      print("Fetch Error: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // This method should only add the grade locally
  Future<void> addGrade(String gradeSymbol, String start, String remark) async {
    final newGrade = Grade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      grade_Symbol: gradeSymbol,
      start: start,
      remark: remark,
    );

    _newGrades.add(newGrade);
    notifyListeners(); // UI updates immediately
  }

  Future<void> saveNewGrades() async {
    if (_newGrades.isEmpty) return; // Don't call the API if the list is empty

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _gradeService.addGrades(_newGrades);
      // _grades.addAll(_newGrades); // Add the new grades to the _grades list
       await fetchGrades();
      _newGrades.clear(); // Clear the new grades list
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
