// lib/modules/models/exam_model.dart

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
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      courseName: json['course_name'] ?? '',
      courseId: json['course_id'] ?? '',
      body: json['body'],
      url: json['url'],
    );
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