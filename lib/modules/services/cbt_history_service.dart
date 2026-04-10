import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/explore/cbt_history_model.dart';

class CbtHistoryService {
  static const String _historyKey = 'cbt_test_history';
  static List<CbtHistoryModel>? _historyCache;

  // Save a test result
  Future<void> saveTestResult(CbtHistoryModel history) async {
    try {
      final List<CbtHistoryModel> historyList = await _loadHistory();

      // Create a unique key for this test combination
      final uniqueKey =
          '${history.subject}_${history.year}_${history.examId}_${history.examType}';

      // Check if this is a retake (same subject, year, examId, examType)
      final existingIndex = historyList.indexWhere((h) {
        final key = '${h.subject}_${h.year}_${h.examId}_${h.examType}';
        return key == uniqueKey;
      });

      if (existingIndex != -1) {
        // Always replace with the latest attempt so dashboard/history reflect
        // the most recent test the user actually took.
        historyList[existingIndex] = history;
      } else {
        // Add new result
        historyList.add(history);
      }

      await _persistHistory(historyList);
    } catch (e) {
      // Intentionally ignored.
    }
  }

  // Find existing test by parameters
  Future<CbtHistoryModel?> findExistingTest({
    required String subject,
    required int year,
    required String examId,
    required String examType,
  }) async {
    final history = await _loadHistory();

    try {
      return history.firstWhere((h) =>
          h.subject == subject &&
          h.year == year &&
          h.examId == examId &&
          h.examType == examType);
    } catch (e) {
      return null;
    }
  }

  // Get all test history
  Future<List<CbtHistoryModel>> getTestHistory() async {
    try {
      return List<CbtHistoryModel>.from(await _loadHistory());
    } catch (e) {
      return [];
    }
  }

  // Get total number of tests taken
  Future<int> getTotalTests() async {
    final history = await getTestHistory();
    return history.length;
  }

  // Get success count (number of tests that are fully completed)
  Future<int> getSuccessCount() async {
    final history = await _loadHistory();

    if (history.isEmpty) {
      return 0;
    }

    return history.where((h) => h.isFullyCompleted).length;
  }

  // Get average score across all unique subjects
  Future<double> getAverageScore() async {
    final history = await _loadHistory();

    if (history.isEmpty) {
      return 0.0;
    }

    // Group by subject and get the latest (best/most recent) score for each
    final Map<String, double> subjectScores = {};

    for (var test in history) {
      final key = '${test.subject}_${test.year}_${test.examType}';

      // Keep the highest score for each subject-year-examType combination
      if (!subjectScores.containsKey(key) ||
          subjectScores[key]! < test.percentage) {
        subjectScores[key] = test.percentage;
      }
    }

    if (subjectScores.isEmpty) {
      return 0.0;
    }

    final totalPercentage = subjectScores.values
        .fold<double>(0.0, (sum, percentage) => sum + percentage);

    return totalPercentage / subjectScores.length;
  }

  // Get recent test history (last N tests)
  Future<List<CbtHistoryModel>> getRecentHistory({int limit = 5}) async {
    final history = List<CbtHistoryModel>.from(await _loadHistory());

    // Sort by timestamp (most recent first)
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Return limited results
    return history.take(limit).toList();
  }

  // Get ALL incomplete tests (not limited by time)
  Future<List<CbtHistoryModel>> getAllIncompleteTests() async {
    final history = await _loadHistory();

    // Filter incomplete tests and sort by timestamp (most recent first)
    final incompleteTests = history.where((h) => !h.isFullyCompleted).toList();
    incompleteTests.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return incompleteTests;
  }

  // Get history for a specific subject
  Future<List<CbtHistoryModel>> getHistoryBySubject(String subject) async {
    final history = await getTestHistory();
    return history.where((h) => h.subject == subject).toList();
  }

  // Get history for a specific exam type
  Future<List<CbtHistoryModel>> getHistoryByExamType(String examType) async {
    final history = await getTestHistory();
    return history.where((h) => h.examType == examType).toList();
  }

  // Clear all history (optional, for testing or user preference)
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      _historyCache = [];
    } catch (e) {
      // Intentionally ignored.
    }
  }

  // Get statistics for dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    final history = await _loadHistory();
    final sortedHistory = List<CbtHistoryModel>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final bestScores = <String, double>{};

    for (final test in history) {
      final key = '${test.subject}_${test.year}_${test.examType}';
      final existingScore = bestScores[key];
      if (existingScore == null || test.percentage > existingScore) {
        bestScores[key] = test.percentage;
      }
    }

    final averageScore = bestScores.isEmpty
        ? 0.0
        : bestScores.values.fold<double>(0.0, (sum, value) => sum + value) /
            bestScores.length;

    return {
      'totalTests': history.length,
      'successCount': history.where((h) => h.isFullyCompleted).length,
      'averageScore': averageScore,
      'recentHistory': sortedHistory.take(5).toList(),
      'allIncompleteTests': sortedHistory
          .where((historyItem) => !historyItem.isFullyCompleted)
          .toList(),
    };
  }

  Future<List<CbtHistoryModel>> _loadHistory() async {
    if (_historyCache != null) {
      return _historyCache!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson == null || historyJson.isEmpty) {
        _historyCache = [];
        return _historyCache!;
      }

      final List<dynamic> jsonList = jsonDecode(historyJson);
      _historyCache =
          jsonList.map((json) => CbtHistoryModel.fromJson(json)).toList();
      return _historyCache!;
    } catch (e) {
      _historyCache = [];
      return _historyCache!;
    }
  }

  Future<void> _persistHistory(List<CbtHistoryModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((h) => h.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
    _historyCache = List<CbtHistoryModel>.from(history);
  }
}
