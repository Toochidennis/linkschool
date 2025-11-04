import 'package:flutter/cupertino.dart';

import '../../model/student/student_result_model.dart';
import '../../services/student/student_result_service.dart';

class StudentResultProvider with ChangeNotifier {
  final StudentResultService _studentResultService;
  bool isLoading = false;
  String? message;
  String? error;

  int currentPage = 1;
  bool hasNext = true;
  int limit = 10;
  StudentResultProvider(this._studentResultService);

  Future<StudentResultModel?> fetchStudentResult(
      int levelid, int classid, String year, int term) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      final result = await _studentResultService.getStudentResult(
        term: term,
        levelid: levelid,
        classid: classid,
        year: year,
      );

      print("Quest $result");
      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
