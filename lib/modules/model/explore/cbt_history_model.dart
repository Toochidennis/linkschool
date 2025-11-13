class CbtHistoryModel {
  final String subject;
  final int year;
  final String examId;
  final String examType;
  final int score;
  final int totalQuestions;
  final DateTime timestamp;
  final double percentage;
  final bool isFullyCompleted; // Track if all questions were answered

  CbtHistoryModel({
    required this.subject,
    required this.year,
    required this.examId,
    required this.examType,
    required this.score,
    required this.totalQuestions,
    required this.timestamp,
    this.isFullyCompleted = false, // Default to false for backward compatibility
  }) : percentage = totalQuestions > 0 ? (score / totalQuestions * 100) : 0.0;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'year': year,
      'examId': examId,
      'examType': examType,
      'score': score,
      'totalQuestions': totalQuestions,
      'timestamp': timestamp.toIso8601String(),
      'percentage': percentage,
      'isFullyCompleted': isFullyCompleted,
    };
  }

  // Create from JSON
  factory CbtHistoryModel.fromJson(Map<String, dynamic> json) {
    return CbtHistoryModel(
      subject: json['subject'] ?? '',
      year: json['year'] ?? 0,
      examId: json['examId'] ?? '',
      examType: json['examType'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isFullyCompleted: json['isFullyCompleted'] ?? false,
    );
  }

  // Check if test was passed (e.g., 50% or above)
  bool get isPassed => percentage >= 50.0;
  
  // Check if test is successful (fully completed AND passed)
  bool get isSuccessful => isFullyCompleted && isPassed;

  // Added helper functions:
  static int _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    if (value is String) {
      final intValue = int.tryParse(value);
      if (intValue != null) return intValue;
    }
    return 0;
  }

  static bool _safeBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }
}
