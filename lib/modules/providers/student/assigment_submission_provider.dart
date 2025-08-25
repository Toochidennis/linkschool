import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/student/assignment_submissions_model.dart';

import '../../services/student/assignment_submission_service.dart';

class AssignmentSubmissionProvider with ChangeNotifier {
  final AssignmentSubmissionService _assignmentSubmissionService;
  bool isLoading = false;
  String? message;
  String? error;

  int currentPage = 1;
  bool hasNext = true;
  int limit = 10;
  AssignmentSubmissionProvider(this._assignmentSubmissionService);

  Future<void> submitassignment(AssignmentSubmission submission) async {



    isLoading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      final result = await _assignmentSubmissionService.submitAssignment(
        submission
      );

      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }
  Future<bool> createComment(Map<String, dynamic> commentData, String contentId) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      message = "Comment created successfully.";
      return true;
    } catch (e) {
      error = "Failed to create comment: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool>UpdateComment(Map<String, dynamic> commentData, String contentId) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      message = "Comment updated successfully.";
      return true;
    } catch (e) {
      error = "Failed to update comment: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

