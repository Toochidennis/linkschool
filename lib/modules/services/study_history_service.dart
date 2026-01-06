import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../explore/cbt/study_progress_dashboard.dart';

class StudyHistoryService {
  static const String _studyHistoryKey = 'study_history';

  // Save a study session result
  Future<void> saveStudySession(StudySessionStats sessionStats) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing study history
      final List<StudySessionStats> historyList = await getStudyHistory();

      // Add new session
      historyList.add(sessionStats);

      // Convert to JSON and save
      final jsonList =
          historyList.map((session) => _sessionToJson(session)).toList();
      await prefs.setString(_studyHistoryKey, jsonEncode(jsonList));

      print('💾 Study session saved. Total sessions: ${historyList.length}');
    } catch (e) {
      print('❌ Error saving study session: $e');
    }
  }

  // Get all study history
  Future<List<StudySessionStats>> getStudyHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_studyHistoryKey);

      if (jsonString == null || jsonString.isEmpty) {
        print('📖 No study history found');
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final history = jsonList.map((json) => _sessionFromJson(json)).toList();

      print('📖 Retrieved ${history.length} study sessions');
      return history;
    } catch (e) {
      print('❌ Error retrieving study history: $e');
      return [];
    }
  }

  // Clear all study history
  Future<void> clearStudyHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_studyHistoryKey);
      print('🗑️ Study history cleared');
    } catch (e) {
      print('❌ Error clearing study history: $e');
    }
  }

  // Convert StudySessionStats to JSON
  Map<String, dynamic> _sessionToJson(StudySessionStats session) {
    return {
      'subject': session.subject,
      'topicProgressList': session.topicProgressList
          .map((topic) => {
                'topicName': topic.topicName,
                'topicId': topic.topicId,
                'questionsAnswered': topic.questionsAnswered,
                'correctAnswers': topic.correctAnswers,
                'wrongAnswers': topic.wrongAnswers,
                'timeSpent': topic.timeSpent.inSeconds,
              })
          .toList(),
      'totalTimeSpent': session.totalTimeSpent.inSeconds,
      'sessionDate': session.sessionDate.toIso8601String(),
    };
  }

  // Convert JSON to StudySessionStats
  StudySessionStats _sessionFromJson(Map<String, dynamic> json) {
    return StudySessionStats(
      subject: json['subject'] ?? '',
      topicProgressList:
          (json['topicProgressList'] as List<dynamic>?)?.map((topicJson) {
                return TopicProgress(
                  topicName: topicJson['topicName'] ?? '',
                  topicId: topicJson['topicId'] ?? 0,
                  questionsAnswered: topicJson['questionsAnswered'] ?? 0,
                  correctAnswers: topicJson['correctAnswers'] ?? 0,
                  wrongAnswers: topicJson['wrongAnswers'] ?? 0,
                  timeSpent: Duration(seconds: topicJson['timeSpent'] ?? 0),
                );
              }).toList() ??
              [],
      totalTimeSpent: Duration(seconds: json['totalTimeSpent'] ?? 0),
      sessionDate: DateTime.parse(
          json['sessionDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}
