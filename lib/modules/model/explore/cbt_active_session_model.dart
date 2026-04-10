import 'package:linkschool/modules/model/explore/home/exam_model.dart';

class CbtActiveSessionModel {
  final String examTypeId;
  final String? subjectId;
  final String? subject;
  final int? year;
  final String calledFrom;
  final int? totalDurationInSeconds;
  final int? questionLimit;
  final int remainingSeconds;
  final int currentQuestionIndex;
  final Map<int, int> userAnswers;
  final Set<int> attemptedQuestionIndexes;
  final int lastGateAtAttemptCount;
  final bool adsGatePending;
  final bool isContinueWithAds;
  final DateTime updatedAt;
  final ExamModel? examInfo;
  final List<QuestionModel> questions;

  const CbtActiveSessionModel({
    required this.examTypeId,
    this.subjectId,
    this.subject,
    this.year,
    required this.calledFrom,
    this.totalDurationInSeconds,
    this.questionLimit,
    required this.remainingSeconds,
    required this.currentQuestionIndex,
    required this.userAnswers,
    required this.attemptedQuestionIndexes,
    required this.lastGateAtAttemptCount,
    required this.adsGatePending,
    required this.isContinueWithAds,
    required this.updatedAt,
    this.examInfo,
    required this.questions,
  });

  int get totalQuestions => questions.length;
  int get answeredCount => userAnswers.length;
  double get progressPercentage {
    if (totalQuestions == 0) return 0.0;
    return (answeredCount / totalQuestions) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'examTypeId': examTypeId,
      'subjectId': subjectId,
      'subject': subject,
      'year': year,
      'calledFrom': calledFrom,
      'totalDurationInSeconds': totalDurationInSeconds,
      'questionLimit': questionLimit,
      'remainingSeconds': remainingSeconds,
      'currentQuestionIndex': currentQuestionIndex,
      'userAnswers': userAnswers.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'attemptedQuestionIndexes':
          attemptedQuestionIndexes.toList()..sort((a, b) => a.compareTo(b)),
      'lastGateAtAttemptCount': lastGateAtAttemptCount,
      'adsGatePending': adsGatePending,
      'isContinueWithAds': isContinueWithAds,
      'updatedAt': updatedAt.toIso8601String(),
      'examInfo': examInfo?.toStorageJson(),
      'questions': questions.map((question) => question.toStorageJson()).toList(),
    };
  }

  factory CbtActiveSessionModel.fromJson(Map<String, dynamic> json) {
    return CbtActiveSessionModel(
      examTypeId: json['examTypeId']?.toString() ?? '',
      subjectId: json['subjectId']?.toString(),
      subject: json['subject']?.toString(),
      year: _safeInt(json['year']),
      calledFrom: json['calledFrom']?.toString() ?? 'details',
      totalDurationInSeconds: _safeInt(json['totalDurationInSeconds']),
      questionLimit: _safeInt(json['questionLimit']),
      remainingSeconds: _safeInt(json['remainingSeconds']) ?? 0,
      currentQuestionIndex: _safeInt(json['currentQuestionIndex']) ?? 0,
      userAnswers: _parseAnswers(json['userAnswers']),
      attemptedQuestionIndexes:
          _parseAttemptedIndexes(json['attemptedQuestionIndexes']),
      lastGateAtAttemptCount: _safeInt(json['lastGateAtAttemptCount']) ?? 0,
      adsGatePending: _safeBool(json['adsGatePending']),
      isContinueWithAds: _safeBool(json['isContinueWithAds']),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      examInfo: json['examInfo'] is Map
          ? ExamModel.fromStorageJson(
              Map<String, dynamic>.from(json['examInfo'] as Map),
            )
          : null,
      questions: (json['questions'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (question) =>
                QuestionModel.fromStorageJson(Map<String, dynamic>.from(question)),
          )
          .toList(),
    );
  }

  static Map<int, int> _parseAnswers(dynamic rawAnswers) {
    if (rawAnswers is! Map) return <int, int>{};
    final parsed = <int, int>{};
    rawAnswers.forEach((key, value) {
      final parsedKey = int.tryParse(key.toString());
      final parsedValue = _safeInt(value);
      if (parsedKey != null && parsedValue != null) {
        parsed[parsedKey] = parsedValue;
      }
    });
    return parsed;
  }

  static Set<int> _parseAttemptedIndexes(dynamic rawIndexes) {
    if (rawIndexes is! List) return <int>{};
    return rawIndexes
        .map(_safeInt)
        .whereType<int>()
        .toSet();
  }

  static int? _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool _safeBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}
