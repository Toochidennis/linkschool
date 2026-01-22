import 'package:flutter/foundation.dart';
import '../../model/explore/lesson_quiz/lesson_quiz_model.dart';
import '../../services/explore/lesson_quiz_service.dart';

class LessonQuizProvider with ChangeNotifier {
  final LessonQuizService _quizService = LessonQuizService();

  List<LessonQuiz> _quizzes = [];
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionIndex -> selectedOptionIndex

  List<LessonQuiz> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, int> get selectedAnswers => _selectedAnswers;

  LessonQuiz? get currentQuestion {
    if (_currentQuestionIndex < _quizzes.length) {
      return _quizzes[_currentQuestionIndex];
    }
    return null;
  }

  bool get isLastQuestion => _currentQuestionIndex == _quizzes.length - 1;

  Future<void> loadQuizzes(int lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _quizService.fetchQuizzes(lessonId);
      _quizzes = response.data;
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(int optionIndex) {
    _selectedAnswers[_currentQuestionIndex] = optionIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _quizzes.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    notifyListeners();
  }

  int calculateScore() {
    int correctAnswers = 0;
    for (int i = 0; i < _quizzes.length; i++) {
      if (_selectedAnswers[i] == _quizzes[i].correct.order) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }

  int get totalQuestions => _quizzes.length;
}