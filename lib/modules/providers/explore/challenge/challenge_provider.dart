import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/challange_modal.dart';
import 'package:linkschool/modules/providers/explore/exam_provider.dart';
import 'package:linkschool/modules/services/explore/challange/challenge_service.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
//import 'package:linkschool/modules/providers/exam_provider.dart'; // <-- IMPORTANT

class ChallengeProvider extends ChangeNotifier {
  final ChallengeService _challengeService;
  final ExamProvider _examProvider; // <-- ADD THIS (not required in constructor)

  ChallengeProvider(
    this._challengeService, [
    ExamProvider? examProvider,
  ]) : _examProvider = examProvider ?? ExamProvider();

  ChallengeData? _challengeData;
  bool _loading = false;
  String? _error;

  // Optional preview exam data (NOT REQUIRED anywhere)
  ExamModel? _previewExam;
  List<QuestionModel> _previewQuestions = [];

  ExamModel? get previewExam => _previewExam;
  List<QuestionModel> get previewQuestions => _previewQuestions;

  // Expose categories
  List<ChallengeModel> get recommended => _challengeData?.recommended ?? [];
  List<ChallengeModel> get personal => _challengeData?.personal ?? [];
  List<ChallengeModel> get active => _challengeData?.active ?? [];
  List<ChallengeModel> get upcoming => _challengeData?.upcoming ?? [];

  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadChallenges(int authorId, int examTypeId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final challengeResponse =
          await _challengeService.fetchChallenges(authorId: authorId, examTypeId: examTypeId);

      final data = challengeResponse.data;

      _challengeData = ChallengeData(
        recommended: data.recommended,
        personal: data.personal,
        active: data.active,
        upcoming: data.upcoming,
      );

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // ---------------------------------------
  // 🔥 NEW: PREVIEW CHALLENGE EXAM
  // ---------------------------------------
  Future<void> previewChallengeExam(String examType, {int? limit}) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      // fetch from ExamProvider, NOT from service
      await _examProvider.fetchExamData(examType, limit: limit);

      _previewExam = _examProvider.examInfo;
      _previewQuestions = _examProvider.questions;

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // ---------------------------------------
  // CREATE CHALLENGE
  // ---------------------------------------
  Future<void> createChallenge(Map<String, dynamic> payload) async {
    try {
      await _challengeService.createChallenge(payload: payload);

      final authorId = payload["author_id"] is int
          ? payload["author_id"]
          : int.parse(payload["author_id"].toString());

      final examTypeId = payload["exam_type_id"] is int
          ? payload["exam_type_id"]
          : int.parse(payload["exam_type_id"].toString());

      await loadChallenges(authorId, examTypeId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ---------------------------------------
  // UPDATE CHALLENGE
  // ---------------------------------------
  Future<void> updateChallenges({
    required authorId,
    required Map<String, dynamic> payload,
    required challengeId,
  }) async {
    try {
      await _challengeService.updateChallenge(
        challengeId: challengeId,
        payload: payload,
      );

      await loadChallenges(authorId, payload["exam_type_id"]);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ---------------------------------------
  // DELETE CHALLENGE
  // ---------------------------------------
  Future<void> deleteChallenge({
    required int challengeId,
    required int authorId,
    required int examTypeId,
  }) async {
    try {
      await _challengeService.deleteChallenge(
        challengeId: challengeId,
        authorId: authorId,
      );

      await loadChallenges(authorId, examTypeId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // update challenge status
    Future<void> updateChallengeStatus({
    required int challengeId, required String status}) async {
    try {
      await _challengeService.updateChallengeStatus(
        challengeId: challengeId,
       status: status,
      );

    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update challenge status locally without reloading
  void updateChallengeStatusLocally(int challengeId, String newStatus) {
    if (_challengeData == null) return;

    // Helper function to update status in a list
    void updateInList(List<ChallengeModel> list) {
      final index = list.indexWhere((c) => c.id == challengeId.toString());
      if (index != -1) {
        list[index] = list[index].copyWith(status: newStatus);
      }
    }

    // Update in all categories
    updateInList(_challengeData!.recommended);
    updateInList(_challengeData!.personal);
    updateInList(_challengeData!.active);
    updateInList(_challengeData!.upcoming);

    notifyListeners();
  }
}
