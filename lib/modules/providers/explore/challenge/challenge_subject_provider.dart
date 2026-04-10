import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/challange_subject_model.dart';
import 'package:linkschool/modules/services/explore/challange/challenge_subject_service.dart';

class ChallengeSubjectProvider extends ChangeNotifier {
  final ChallengeSubjectService _service;

  ChallengeSubjectProvider(this._service);

  List<ChallengeCourseModel> subjects = [];
  bool isLoading = false;
  String? error;

  int? _loadedExamTypeId;

  Future<void> loadChallengeSubjects(
    int examTypeId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _loadedExamTypeId == examTypeId &&
        subjects.isNotEmpty) {
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      subjects = await _service.fetchChallengeSubjects(examTypeId);
      _loadedExamTypeId = examTypeId;
    } catch (e) {
      error = e.toString();
      subjects = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    subjects = [];
    error = null;
    isLoading = false;
    _loadedExamTypeId = null;
    notifyListeners();
  }
}
