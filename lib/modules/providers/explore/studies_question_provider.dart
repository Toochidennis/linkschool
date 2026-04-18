import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study/models/study_session_stats.dart';
import 'package:linkschool/modules/model/explore/study/studies_questions_model.dart';
import 'package:linkschool/modules/services/explore/offline_game_question_service.dart';
import 'package:linkschool/modules/services/explore/studies_question_service.dart';

class QuestionsProvider extends ChangeNotifier {
  static const int studyQuestionLimit = 100;

  final QuestionsService _service;
  final OfflineGameQuestionService _offlineGameService =
      OfflineGameQuestionService();

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
  bool _isOfflineStudySession = false;

  // Study session tracking
  final Map<int, Map<String, dynamic>> _topicStats = {};
  final Map<int, DateTime> _topicStartTimes = {};
  final Map<int, int> _correctAnswersPerTopic = {};
  final Map<int, int> _wrongAnswersPerTopic = {};
  final Map<int, int> _questionsAnsweredPerTopic = {};
  DateTime? _sessionStartTime;
  List<String> _topicNames = [];

  QuestionsProvider(this._service);

  Question? get currentQuestion {
    if (allQuestions.isEmpty || currentQuestionIndex >= allQuestions.length) {
      return null;
    }
    return allQuestions[currentQuestionIndex];
  }

  bool get hasMoreTopics =>
      !_isOfflineStudySession && _currentTopicIndex < _topicIds.length;
  bool get isLastQuestion => currentQuestionIndex >= allQuestions.length - 1;
  int get totalQuestions => allQuestions.length;
  int get currentTopicIndex => _isOfflineStudySession ? 0 : _currentTopicIndex;
  int get totalTopics => _topicIds.length;

  Future<void> initializeOfflineSession({
    required int courseId,
    required int examTypeId,
    int questionLimit = OfflineGameQuestionService.defaultQuestionLimit,
  }) async {
    _topicIds = [];
    _currentTopicIndex = 0;
    _courseId = courseId;
    _examTypeId = examTypeId;
    _topicNames = [];
    allQuestions = [];
    currentQuestionIndex = 0;
    loading = true;
    loadingMore = false;
    error = null;
    _sessionStartTime = DateTime.now();
    _topicStats.clear();
    _topicStartTimes.clear();
    _correctAnswersPerTopic.clear();
    _wrongAnswersPerTopic.clear();
    _questionsAnsweredPerTopic.clear();
    notifyListeners();

    try {
      questionsData = await _offlineGameService.fetchQuestions(
        courseId: courseId,
        examTypeId: examTypeId,
        limit: questionLimit,
      );
      allQuestions = questionsData?.data ?? [];
    } catch (e) {
      error = e.toString();
      allQuestions = [];
    }

    loading = false;
    notifyListeners();
  }

  Future<void> reloadOfflineSession({
    required int courseId,
    required int examTypeId,
    int questionLimit = OfflineGameQuestionService.defaultQuestionLimit,
    int startIndex = 0,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      questionsData = await _offlineGameService.fetchQuestions(
        courseId: courseId,
        examTypeId: examTypeId,
        limit: questionLimit,
      );
      allQuestions = questionsData?.data ?? [];
      if (allQuestions.isEmpty) {
        currentQuestionIndex = 0;
      } else {
        currentQuestionIndex = startIndex.clamp(0, allQuestions.length - 1);
      }
    } catch (e) {
      error = e.toString();
      allQuestions = [];
      currentQuestionIndex = 0;
    }

    loading = false;
    notifyListeners();
  }

  /// Initialize study session with selected topics
  Future<void> initializeStudySession({
    required String subjectName,
    required List<int> topicIds,
    required int? courseId,
    required int? examTypeId,
    List<String>? topicNames,
  }) async {
    final studyTopicId = courseId ?? 0;

    _isOfflineStudySession = true;
    _topicIds = [studyTopicId];
    _currentTopicIndex = 0;
    _courseId = courseId;
    _examTypeId = examTypeId;
    _topicNames = [subjectName];
    allQuestions = [];
    currentQuestionIndex = 0;
    loading = true;
    loadingMore = false;
    error = null;
    questionsData = null;

    // Initialize session tracking
    _sessionStartTime = DateTime.now();
    _topicStats.clear();
    _topicStartTimes.clear();
    _correctAnswersPerTopic.clear();
    _wrongAnswersPerTopic.clear();
    _questionsAnsweredPerTopic.clear();

    _topicStartTimes[studyTopicId] = DateTime.now();
    _correctAnswersPerTopic[studyTopicId] = 0;
    _wrongAnswersPerTopic[studyTopicId] = 0;
    _questionsAnsweredPerTopic[studyTopicId] = 0;
    notifyListeners();

    try {
      questionsData = await _offlineGameService.fetchQuestions(
        courseId: courseId ?? 0,
        examTypeId: examTypeId ?? 0,
        limit: studyQuestionLimit,
      );
      allQuestions = questionsData?.data ?? [];
      _currentTopicIndex = _topicIds.length;
    } catch (e) {
      error = e.toString();
      allQuestions = [];
    }

    loading = false;
    notifyListeners();
  }

  /// Load questions for the current topic
  Future<void> _loadNextTopicQuestions() async {
    _isOfflineStudySession = false;

    if (_currentTopicIndex >= _topicIds.length) {
      return;
    }

    final topicId = _topicIds[_currentTopicIndex];

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
      } else {}

      _currentTopicIndex++;
    } catch (e) {
      error = e.toString();
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
    _isOfflineStudySession = false;
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

  /// Record an answer for the current question
  void recordAnswer({
    required int questionId,
    required bool isCorrect,
  }) {
    if (currentQuestion == null) return;

    final topicId = _isOfflineStudySession
        ? (_topicIds.isNotEmpty ? _topicIds.first : null)
        : _findTopicForQuestion(currentQuestionIndex);
    if (topicId == null) return;

    // Update stats for this topic
    _questionsAnsweredPerTopic[topicId] =
        (_questionsAnsweredPerTopic[topicId] ?? 0) + 1;

    if (isCorrect) {
      _correctAnswersPerTopic[topicId] =
          (_correctAnswersPerTopic[topicId] ?? 0) + 1;
    } else {
      _wrongAnswersPerTopic[topicId] =
          (_wrongAnswersPerTopic[topicId] ?? 0) + 1;
    }
  }

  /// Find which topic a question belongs to
  int? _findTopicForQuestion(int questionIndex) {
    if (_isOfflineStudySession) {
      return _topicIds.isNotEmpty ? _topicIds.first : null;
    }

    if (_topicIds.isEmpty ||
        questionIndex < 0 ||
        questionIndex >= allQuestions.length) {
      return null;
    }

    // Calculate which topic based on question distribution
    // For now, we'll use a simple approach based on current topic index
    if (_currentTopicIndex > 0 && _currentTopicIndex <= _topicIds.length) {
      return _topicIds[_currentTopicIndex - 1];
    }

    return _topicIds.isNotEmpty ? _topicIds[0] : null;
  }

  /// Generate study session statistics
  StudySessionStats generateSessionStats(String subject) {
    final List<TopicProgress> topicProgressList = [];

    for (int i = 0; i < _topicIds.length; i++) {
      final topicId = _topicIds[i];
      final topicName =
          i < _topicNames.length ? _topicNames[i] : 'Topic ${i + 1}';

      final questionsAnswered = _questionsAnsweredPerTopic[topicId] ?? 0;
      final correctAnswers = _correctAnswersPerTopic[topicId] ?? 0;
      final wrongAnswers = _wrongAnswersPerTopic[topicId] ?? 0;

      // Calculate time spent on this topic
      final startTime = _topicStartTimes[topicId];
      final timeSpent = startTime != null
          ? DateTime.now().difference(startTime)
          : Duration.zero;

      if (questionsAnswered > 0) {
        topicProgressList.add(
          TopicProgress(
            topicName: topicName,
            topicId: topicId,
            questionsAnswered: questionsAnswered,
            correctAnswers: correctAnswers,
            wrongAnswers: wrongAnswers,
            timeSpent: timeSpent,
          ),
        );
      }
    }

    final totalTimeSpent = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;

    return StudySessionStats(
      subject: subject,
      topicProgressList: topicProgressList,
      totalTimeSpent: totalTimeSpent,
      sessionDate: DateTime.now(),
    );
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
    _isOfflineStudySession = false;
    loading = false;
    loadingMore = false;
    error = null;

    // Reset tracking
    _topicStats.clear();
    _topicStartTimes.clear();
    _correctAnswersPerTopic.clear();
    _wrongAnswersPerTopic.clear();
    _questionsAnsweredPerTopic.clear();
    _sessionStartTime = null;
    _topicNames.clear();

    notifyListeners();
  }
}
