import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/grade_model.dart';
import 'package:linkschool/modules/services/admin/grade_service.dart';

class GradeProvider with ChangeNotifier {
  final GradeService _gradeService = GradeService();
  List<Grade> _grades = [];

  List<Grade> get grades => _grades;

  Future<void> fetchGrades() async {
    _grades = await _gradeService.getGrades();
    notifyListeners();
  }

  Future<bool> addGrade(String gradeSymbol, String start, String remark) async {
    try {
      await _gradeService.addGrade(gradeSymbol, start, remark);
      await fetchGrades();
      return true; // Success
    } catch (e) {
      return false; // Failure
    }
  }
}