import 'dart:convert';

class ExamModel {
  final String id;
  final String title;
  final String description;
  final String courseName;
  final String courseId;
  final String? body;
  final String? url;

  ExamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseName,
    required this.courseId,
    this.body,
    this.url,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: _safeToString(json['id']),
      title: _safeToString(json['title']),
      description: _safeToString(json['description']),
      courseName: _safeToString(json['course_name']),
      courseId: _safeToString(json['course_id']),
      body: _safeToString(json['body']),
      url: _safeToString(json['url']),
    );
  }

  // Helper method to safely convert any type to String
  static String _safeToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }
}

class QuestionModel {
  final String id;
  final String parent;
  final String content;
  final String title;
  final String type;
  final String answer;
  final String correct;
  final String questionImage;

  QuestionModel({
    required this.id,
    required this.parent,
    required this.content,
    required this.title,
    required this.type,
    required this.answer,
    required this.correct,
    required this.questionImage,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      parent: json['parent'] ?? '',
      content: json['content'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      answer: json['answer'] ?? '',
      correct: json['correct'] ?? '',
      questionImage: json['question_image'] ?? '',
    );
  }

  List<String> getOptions() {
    try {
      final List<dynamic> parsedAnswer = json.decode(answer);
      return parsedAnswer.map((option) => option['text'] as String).toList();
    } catch (e) {
      return [];
    }
  }
}
