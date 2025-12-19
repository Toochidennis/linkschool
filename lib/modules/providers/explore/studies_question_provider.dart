import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/study/studies_questions_model.dart';
import 'package:linkschool/modules/services/explore/studies_question_service.dart';

class QuestionsProvider extends ChangeNotifier {
  final QuestionsService _service;

  QuestionsResponse? questionsData;
  List<Question> allQuestions = [];
  int currentQuestionIndex = 0;
  bool loading = false;
  bool loadingMore = false;
  String? error;

  // Track which topics we're working with
  List<int> _topicIds = [];
  int _currentTopicIndex = 0;
  int? _courseId;
  int? _examTypeId;

  QuestionsProvider(this._service);

  Question? get currentQuestion {
    if (allQuestions.isEmpty || currentQuestionIndex >= allQuestions.length) {
      return null;
    }
    return allQuestions[currentQuestionIndex];
  }

  bool get hasMoreTopics => _currentTopicIndex < _topicIds.length;
  bool get isLastQuestion => currentQuestionIndex >= allQuestions.length - 1;
  int get totalQuestions => allQuestions.length;
  int get currentTopicIndex => _currentTopicIndex;
  int get totalTopics => _topicIds.length;

  /// Initialize study session with selected topics
  Future<void> initializeStudySession({
    required List<int> topicIds,
    required int? courseId,
    required int? examTypeId,
  }) async {
    _topicIds = topicIds;
    _currentTopicIndex = 0;
    _courseId = courseId;
    _examTypeId = examTypeId;
    allQuestions = [];
    currentQuestionIndex = 0;
    error = null;

    // Load questions for the first topic
    await _loadNextTopicQuestions();
  }

  /// Load questions for the current topic
  Future<void> _loadNextTopicQuestions() async {
    if (_currentTopicIndex >= _topicIds.length) {
      print('📚 All topics completed!');
      return;
    }

    final topicId = _topicIds[_currentTopicIndex];
    print('📡 Loading questions for topic $_currentTopicIndex: $topicId');

    loading = allQuestions.isEmpty;
    loadingMore = allQuestions.isNotEmpty;
    error = null;
    notifyListeners();

    try {
      questionsData = await _service.fetchQuestions(
        topicId: topicId,
        courseId: _courseId,
        examTypeId: _examTypeId,
      );

      if (questionsData != null && questionsData!.data.isNotEmpty) {
        allQuestions.addAll(questionsData!.data);
        print(
            '✅ Loaded ${questionsData!.data.length} questions. Total: ${allQuestions.length}');
      } else {
        print('⚠️ No questions found for topic $topicId');
      }

      _currentTopicIndex++;
    } catch (e) {
      error = e.toString();
      print('❌ Error loading questions: $error');
    }

    loading = false;
    loadingMore = false;
    notifyListeners();
  }

  /// Load questions for a single topic (legacy method)
  Future<void> loadQuestions(
      {required int topicId,
      required int? courseId,
      required int? examTypeId}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      questionsData = await _service.fetchQuestions(
          topicId: topicId, courseId: courseId, examTypeId: examTypeId);
      if (questionsData != null) {
        allQuestions = questionsData!.data;
        currentQuestionIndex = 0;
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  /// Move to next question, load more if needed
  Future<bool> nextQuestion() async {
    if (currentQuestionIndex < allQuestions.length - 1) {
      currentQuestionIndex++;
      notifyListeners();
      return true;
    }

    // At the end of current questions, try to load more from next topic
    if (hasMoreTopics) {
      await _loadNextTopicQuestions();
      if (currentQuestionIndex < allQuestions.length - 1) {
        currentQuestionIndex++;
        notifyListeners();
        return true;
      }
    }

    // No more questions available
    return false;
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Reset the provider state
  void reset() {
    questionsData = null;
    allQuestions = [];
    currentQuestionIndex = 0;
    _topicIds = [];
    _currentTopicIndex = 0;
    _courseId = null;
    _examTypeId = null;
    loading = false;
    loadingMore = false;
    error = null;
    notifyListeners();
  }
}
