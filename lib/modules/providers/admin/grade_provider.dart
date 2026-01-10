import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/grade _model.dart';
import 'package:linkschool/modules/services/admin/grade_service.dart';

class GradeProvider with ChangeNotifier {
  final GradeService _gradeService;
  List<Grade> _grades = [];
  final List<Grade> _newGrades = [];
  bool _isLoading = false;
  String _error = '';
  bool get hasNewGrades => _newGrades.isNotEmpty;

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

  Future<Grade> addGrade(
      String gradeSymbol, String start, String remark) async {
    final newGrade = Grade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      grade_Symbol: gradeSymbol,
      start: start,
      remark: remark,
    );

    _newGrades.add(newGrade);
    notifyListeners();

    return newGrade;
  }

  Future<void> saveNewGrades() async {
    if (_newGrades.isEmpty) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _gradeService.addGrades(_newGrades);
      _grades.addAll(_newGrades);
      print("new Gradesssssss added: $_grades");
      _newGrades.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGrade(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _gradeService.deleteGrades(id);
      _grades.removeWhere((grade) => grade.id == id);
      _newGrades.removeWhere((grade) => grade.id == id);
      notifyListeners();
      await fetchGrades();
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

  Future<void> updateGrade(
      String id, String gradeSymbol, String start, String remark) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final updatedGrade = Grade(
        id: id,
        grade_Symbol: gradeSymbol,
        start: start,
        remark: remark,
      );

      final index = _grades.indexWhere((grade) => grade.id == id);
      if (index != -1) {
        _grades[index] = updatedGrade;
      } else {
        final newIndex = _newGrades.indexWhere((grade) => grade.id == id);
        if (newIndex != -1) {
          _newGrades[newIndex] = updatedGrade;
        }
      }
      notifyListeners();

      await _gradeService.updateGrades(updatedGrade);
    } catch (e) {
      _error = e.toString();
      print("Update Error: $_error");
      await fetchGrades();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
