import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuizResultService {
  static const String _quizResultsKey = 'quiz_results';

  /// Save quiz result to SharedPreferences
  static Future<void> saveQuizResult({
    required String courseTitle,
    required String lessonTitle,
    required int totalScore,
    required int totalQuestions,
    required int correctAnswers,
    required Map<int, int> userAnswers,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingResults = await getQuizResults();

      // Create a unique key for this quiz
      final quizKey = '${courseTitle}_${lessonTitle}';

      // Create quiz result data
      final quizResult = {
        'courseTitle': courseTitle,
        'lessonTitle': lessonTitle,
        'totalScore': totalScore,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'percentage': ((correctAnswers / totalQuestions) * 100).round(),
        'userAnswers':
            userAnswers.map((key, value) => MapEntry(key.toString(), value)),
        'questions': questions,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Update or add the result
      existingResults[quizKey] = quizResult;

      // Save back to SharedPreferences
      await prefs.setString(_quizResultsKey, json.encode(existingResults));

      print('💾 Quiz result saved for: $quizKey');
      print('   - Score: $totalScore%');
      print('   - Correct: $correctAnswers/$totalQuestions');
    } catch (e) {
      print('❌ Error saving quiz result: $e');
    }
  }

  /// Get all quiz results
  static Future<Map<String, dynamic>> getQuizResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsJson = prefs.getString(_quizResultsKey);

      if (resultsJson == null || resultsJson.isEmpty) {
        return {};
      }

      final Map<String, dynamic> results = json.decode(resultsJson);
      return results;
    } catch (e) {
      print('❌ Error retrieving quiz results: $e');
      return {};
    }
  }

  /// Get specific quiz result
  static Future<Map<String, dynamic>?> getQuizResult({
    required String courseTitle,
    required String lessonTitle,
  }) async {
    try {
      final quizKey = '${courseTitle}_${lessonTitle}';
      final allResults = await getQuizResults();

      if (allResults.containsKey(quizKey)) {
        return allResults[quizKey] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print(
          '❌ Error retrieving quiz result for $courseTitle - $lessonTitle: $e');
      return null;
    }
  }

  /// Check if a quiz has been taken
  static Future<bool> hasQuizBeenTaken({
    required String courseTitle,
    required String lessonTitle,
  }) async {
    final result = await getQuizResult(
      courseTitle: courseTitle,
      lessonTitle: lessonTitle,
    );
    return result != null;
  }

  /// Get quiz score
  static Future<int> getQuizScore({
    required String courseTitle,
    required String lessonTitle,
  }) async {
    final result = await getQuizResult(
      courseTitle: courseTitle,
      lessonTitle: lessonTitle,
    );

    if (result != null) {
      return result['totalScore'] as int? ?? 0;
    }

    return 0;
  }

  /// Clear specific quiz result
  static Future<void> clearQuizResult({
    required String courseTitle,
    required String lessonTitle,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingResults = await getQuizResults();
      final quizKey = '${courseTitle}_${lessonTitle}';

      existingResults.remove(quizKey);

      await prefs.setString(_quizResultsKey, json.encode(existingResults));
      print('🗑️ Quiz result cleared for: $quizKey');
    } catch (e) {
      print('❌ Error clearing quiz result: $e');
    }
  }

  /// Clear all quiz results
  static Future<void> clearAllQuizResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_quizResultsKey);
      print('🗑️ All quiz results cleared');
    } catch (e) {
      print('❌ Error clearing all quiz results: $e');
    }
  }
}
