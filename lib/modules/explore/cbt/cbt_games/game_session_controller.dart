import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/explore/study/studies_questions_model.dart';
import 'package:linkschool/modules/services/explore/offline_game_question_service.dart';

class GameSessionController extends ChangeNotifier {
  GameSessionController({
    required int courseId,
    required int examTypeId,
    required int questionLimit,
    OfflineGameQuestionService? service,
  })  : _courseId = courseId,
        _examTypeId = examTypeId,
        _questionLimit = questionLimit,
        _service = service ?? OfflineGameQuestionService();

  final int _courseId;
  final int _examTypeId;
  final int _questionLimit;
  final OfflineGameQuestionService _service;

  List<Question> _questions = const [];
  int _currentQuestionIndex = 0;
  bool _loading = false;
  String? _error;

  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get loading => _loading;
  String? get error => _error;
  int get totalQuestions => _questions.length;

  Question? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  Future<void> initialize() async {
    await _loadBatch(startIndex: 0);
  }

  Future<void> reload({required int startIndex}) async {
    await _loadBatch(startIndex: startIndex);
  }

  Future<bool> nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex += 1;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _loadBatch({required int startIndex}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.fetchQuestions(
        courseId: _courseId,
        examTypeId: _examTypeId,
        limit: _questionLimit,
      );
      _questions = response.data;
      _currentQuestionIndex =
          _questions.isEmpty ? 0 : startIndex.clamp(0, _questions.length - 1);
    } catch (e) {
      _error = e.toString();
      _questions = const [];
      _currentQuestionIndex = 0;
    }

    _loading = false;
    notifyListeners();
  }
}
