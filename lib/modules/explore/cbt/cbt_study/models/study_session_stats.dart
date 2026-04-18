class TopicProgress {
  final String topicName;
  final int topicId;
  final int questionsAnswered;
  final int correctAnswers;
  final int wrongAnswers;
  final Duration timeSpent;

  const TopicProgress({
    required this.topicName,
    required this.topicId,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeSpent,
  });

  double get accuracyPercentage {
    if (questionsAnswered == 0) return 0.0;
    return (correctAnswers / questionsAnswered) * 100;
  }

  double get accuracy => accuracyPercentage;

  String get formattedTime {
    final minutes = timeSpent.inMinutes;
    final seconds = timeSpent.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

class StudySessionStats {
  final String subject;
  final List<TopicProgress> topicProgressList;
  final Duration totalTimeSpent;
  final DateTime sessionDate;

  const StudySessionStats({
    required this.subject,
    required this.topicProgressList,
    required this.totalTimeSpent,
    required this.sessionDate,
  });

  int get totalQuestionsAnswered =>
      topicProgressList.fold(0, (sum, topic) => sum + topic.questionsAnswered);

  int get totalCorrectAnswers =>
      topicProgressList.fold(0, (sum, topic) => sum + topic.correctAnswers);

  int get totalWrongAnswers =>
      topicProgressList.fold(0, (sum, topic) => sum + topic.wrongAnswers);

  int get topicsStudied => topicProgressList.length;

  double get overallAccuracy {
    if (totalQuestionsAnswered == 0) return 0.0;
    return (totalCorrectAnswers / totalQuestionsAnswered) * 100;
  }

  String get formattedTotalTime {
    final hours = totalTimeSpent.inHours;
    final minutes = totalTimeSpent.inMinutes % 60;
    final seconds = totalTimeSpent.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }
}

class StudyDashboardStats {
  final List<StudySessionStats> sessions;

  const StudyDashboardStats({required this.sessions});

  factory StudyDashboardStats.empty() =>
      const StudyDashboardStats(sessions: []);

  int get sessionsCount => sessions.length;

  int get subjectsStudied => sessions
      .map((session) => _normalizeSubject(session.subject))
      .where((subject) => subject.isNotEmpty)
      .toSet()
      .length;

  Duration get totalTimeSpent => sessions.fold(
        Duration.zero,
        (total, session) => total + session.totalTimeSpent,
      );

  int get totalQuestionsAnswered => sessions.fold(
        0,
        (total, session) => total + session.totalQuestionsAnswered,
      );

  int get totalCorrectAnswers => sessions.fold(
        0,
        (total, session) => total + session.totalCorrectAnswers,
      );

  int get totalWrongAnswers => sessions.fold(
        0,
        (total, session) => total + session.totalWrongAnswers,
      );

  int get totalTopicsStudied => sessions.fold(
        0,
        (total, session) => total + session.topicsStudied,
      );

  double get averageAccuracy {
    if (totalQuestionsAnswered == 0) return 0.0;
    return (totalCorrectAnswers / totalQuestionsAnswered) * 100;
  }

  List<StudySessionStats> get recentSessions {
    final sortedSessions = [...sessions]
      ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
    return sortedSessions.take(3).toList(growable: false);
  }

  Map<String, List<StudySessionStats>> get sessionsBySubject {
    final result = <String, List<StudySessionStats>>{};

    for (final session in sessions) {
      final key = _normalizeSubject(session.subject);
      if (key.isEmpty) continue;
      result.putIfAbsent(key, () => <StudySessionStats>[]).add(session);
    }

    return Map<String, List<StudySessionStats>>.unmodifiable(result);
  }
}

String normalizeStudySubject(String subject) => _normalizeSubject(subject);

String _normalizeSubject(String subject) => subject.trim().toUpperCase();
