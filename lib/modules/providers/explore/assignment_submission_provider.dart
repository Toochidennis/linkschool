import 'package:flutter/foundation.dart';
import '../../services/explore/assignment_submission_service.dart';

class AssignmentSubmissionProvider with ChangeNotifier {
  final AssignmentSubmissionService _service = AssignmentSubmissionService();
  
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, dynamic>? _submissionResult;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get submissionResult => _submissionResult;

  /// Submit assignment with quiz score and files
  Future<bool> submitAssignment({
    required String name,
    required String email,
    required String phone,
    required String quizScore,
    required List<Map<String, dynamic>> assignments,
  }) async {
    print("🚀 AssignmentSubmissionProvider: submitAssignment called");
    print("  - name: $name");
    print("  - quiz_score: $quizScore");
    print("  - assignments count: ${assignments.length}");
    
    _isSubmitting = true;
    _errorMessage = null;
    _submissionResult = null;
    notifyListeners();

    try {
      print("📞 Calling service.submitAssignment...");
      final result = await _service.submitAssignment(
        name: name,
        email: email,
        phone: phone,
        quizScore: quizScore,
        assignments: assignments,
      );

      print("✅ Service returned success: $result");
      _submissionResult = result;
      _isSubmitting = false;
      notifyListeners();
      
      return true;
    } catch (error) {
      print("❌ Provider caught error: $error");
      _errorMessage = error.toString();
      _isSubmitting = false;
      notifyListeners();
      
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset submission result
  void resetSubmission() {
    _submissionResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
