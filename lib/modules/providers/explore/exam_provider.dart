import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/services/explore/exam_service.dart';

class ExamProvider extends ChangeNotifier {
  final ExamService _examService;

  ExamProvider({ExamService? examService})
      : _examService = examService ?? ExamService();

  ExamModel? examInfo;
  List<QuestionModel> questions = [];
  int currentQuestionIndex = 0;
  Map<int, int> userAnswers = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchExamData(
    String examType, {
    int? limit,
    bool randomizeQuestions = false,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _examService.fetchExamData(
        examType: examType,
        limit: limit,
        randomizeQuestions: randomizeQuestions,
      );

      // Debug: Print the response structure

      // Check if the API call was successful
      if (data['success'] == true) {
        // Parse exam info from the new structure
        if (data['data'] != null && data['data']['exam'] != null) {
          final examData = data['data']['exam'];

          examInfo = ExamModel.fromJson(examData);
        } else {
          throw Exception('Exam data not found in response');
        }

        // Parse questions from the new structure
        if (data['data'] != null && data['data']['questions'] != null) {
          final questionsData = data['data']['questions'];

          List<dynamic> flatQuestions = [];

          if (questionsData is Map) {
            // Handle Map structure: {"0": [{...}, {...}]}
            questionsData.forEach((key, value) {
              if (value is List) {
                flatQuestions.addAll(value);
              } else if (value is Map) {
                flatQuestions.add(value);
              }
            });
          } else if (questionsData is List && questionsData.isNotEmpty) {
            // Handle nested array structure
            for (var item in questionsData) {
              if (item is List) {
                flatQuestions.addAll(item);
              } else if (item is Map) {
                flatQuestions.add(item);
              }
            }
          }

          questions = flatQuestions
              .whereType<Map>()
              .map((q) {
                try {
                  return QuestionModel.fromJson(Map<String, dynamic>.from(q));
                } catch (e) {
                  return null;
                }
              })
              .whereType<QuestionModel>()
              .toList();

          if (randomizeQuestions &&
              questions.length > 1 &&
              data['source'] != 'local_db') {
            questions.shuffle();
          }

          // Debug: Print first question details
          if (questions.isNotEmpty) {}

          // Reset navigation state
          currentQuestionIndex = 0;
          userAnswers.clear();
        } else {
          questions = [];
        }
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      _error = "Failed to load exam data: ${e.toString()}";

      // Reset data on error
      questions = [];
      currentQuestionIndex = 0;
      userAnswers.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  QuestionModel? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }

  void selectAnswer(int questionIndex, int answerIndex) {
    userAnswers[questionIndex] = answerIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Additional helper methods
  bool get canMoveNext => currentQuestionIndex < questions.length - 1;
  bool get canMovePrevious => currentQuestionIndex > 0;
  int get totalQuestions => questions.length;
  bool isQuestionAnswered(int index) => userAnswers.containsKey(index);

  // Reset the provider state
  void reset() {
    examInfo = null;
    questions = [];
    currentQuestionIndex = 0;
    userAnswers.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
