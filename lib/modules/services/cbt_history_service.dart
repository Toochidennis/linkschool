import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/explore/cbt_history_model.dart';

class CbtHistoryService {
  static const String _historyKey = 'cbt_test_history';

  // Save a test result
  Future<void> saveTestResult(CbtHistoryModel history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing history
      final List<CbtHistoryModel> historyList = await getTestHistory();
      
      // Check if this is a retake (same subject, year, examId, examType)
      final existingIndex = historyList.indexWhere((h) =>
        h.subject == history.subject &&
        h.year == history.year &&
        h.examId == history.examId &&
        h.examType == history.examType
      );
      
      if (existingIndex != -1) {
        // Update existing test
        historyList[existingIndex] = history;
        print('Updated existing test result');
      } else {
        // Add new result
        historyList.add(history);
        print('Added new test result');
      }
      
      // Convert to JSON and save
      final jsonList = historyList.map((h) => h.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
      
      print('Test result saved successfully');
    } catch (e) {
      print('Error saving test result: $e');
    }
  }
  
  // Find existing test by parameters
  Future<CbtHistoryModel?> findExistingTest({
    required String subject,
    required int year,
    required String examId,
    required String examType,
  }) async {
    final history = await getTestHistory();
    
    try {
      return history.firstWhere((h) =>
        h.subject == subject &&
        h.year == year &&
        h.examId == examId &&
        h.examType == examType
      );
    } catch (e) {
      return null;
    }
  }

  // Get all test history
  Future<List<CbtHistoryModel>> getTestHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(historyJson);
      return jsonList.map((json) => CbtHistoryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading test history: $e');
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
    final history = await getTestHistory();
    
    if (history.isEmpty) {
      print('📊 Completed Count: No history found, returning 0');
      return 0;
    }
    
    // Count all tests that were fully completed (regardless of pass/fail)
    final completedTests = history.where((h) => h.isFullyCompleted).toList();
    
    print('📊 Completed Count Calculation:');
    print('   Total tests: ${history.length}');
    print('   Completed tests: ${completedTests.length}');
    
    for (var test in history) {
      final status = test.isFullyCompleted 
          ? (test.isPassed ? '✓ Completed & Passed' : '✓ Completed but Failed')
          : '⊘ Incomplete';
      print('   $status: ${test.subject} (${test.year}): ${test.percentage.toStringAsFixed(1)}%');
    }
    
    return completedTests.length;
  }

  // Get average score across all unique subjects
  Future<double> getAverageScore() async {
    final history = await getTestHistory();
    
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
    
    final totalPercentage = subjectScores.values.fold<double>(
      0.0, 
      (sum, percentage) => sum + percentage
    );
    
    return totalPercentage / subjectScores.length;
  }

  // Get recent test history (last N tests)
  Future<List<CbtHistoryModel>> getRecentHistory({int limit = 5}) async {
    final history = await getTestHistory();
    
    // Sort by timestamp (most recent first)
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Return limited results
    return history.take(limit).toList();
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
      print('Test history cleared');
    } catch (e) {
      print('Error clearing test history: $e');
    }
  }

  // Get statistics for dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    final totalTests = await getTotalTests();
    final successCount = await getSuccessCount();
    final averageScore = await getAverageScore();
    final recentHistory = await getRecentHistory(limit: 3);
    
    print('📊 Dashboard Stats:');
    print('   Total Tests: $totalTests');
    print('   Success Count: $successCount');
    print('   Average Score: ${averageScore.toStringAsFixed(1)}%');
    print('   Recent History: ${recentHistory.length} items');
    
    return {
      'totalTests': totalTests,
      'successCount': successCount,
      'averageScore': averageScore,
      'recentHistory': recentHistory,
    };
  }
}
