import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/e-learning/quiz_model.dart';
import 'package:linkschool/modules/services/admin/e_learning/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService _quizService;
  bool isLoading = false;
  String? error;
  String? message;
  ContentResponse? contentResponse; // Store fetched content
  final bool _isLoadingContent = false;

  // Add this flag

  QuizProvider(this._quizService);

  Future<void> addTest(Map<String, dynamic> quizPayload) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      await _quizService.addTest(quizPayload);
      message = 'Test added successfully';
    } catch (e) {
      print('Error adding test: $e');
      error = e.toString();
      message = 'Failed to add test: $error';
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTest(Map<String, dynamic> quizPayload) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      await _quizService.updateTest(quizPayload);
      message = 'Test updated successfully';
    } catch (e) {
      print('Error updating test: $e');
      error = e.toString();
      message = 'Failed to update test: $error';
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> DeleteQuiz(int id) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      await _quizService.DeleteQuiz(id);
      message = 'quiz deleted successfully';
    } catch (e) {
      print('Error deleting quiz: $e');
      error = e.toString();
      message = 'Failed to delete quiz: $error';
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
