import 'package:linkschool/modules/services/admin/e_learning/delete_question.dart';

import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/e_learning/delete_question.dart';

class DeleteQuestionProvider with ChangeNotifier {
  final DeleteQuestionService _deleteQuestionService;

  bool _isLoading = false;
  String _error = '';

  DeleteQuestionProvider(this._deleteQuestionService);
  Future<void> deleteQuestion(String id, String settingId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _deleteQuestionService.deleteQuestion(id, settingId);

      print("Question deleted successfully");
    } catch (e) {
      _error = e.toString();
      print("Delete Error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
