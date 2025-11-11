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
  final List<Map<String, dynamic>>? options;
  final Map<String, dynamic>? correctAnswer;

  QuestionModel({
    required this.id,
    required this.parent,
    required this.content,
    required this.title,
    required this.type,
    required this.answer,
    required this.correct,
    required this.questionImage,
    this.options,
    this.correctAnswer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // Handle both old format and new CBT API format
    if (json.containsKey('question_id')) {
      // New CBT API format
      final optionsList = json['options'] as List<dynamic>?;
      
      return QuestionModel(
        id: json['question_id']?.toString() ?? '',
        parent: json['question_grade']?.toString() ?? '',
        content: json['question_text']?.toString() ?? '',
        title: '',
        type: json['question_type']?.toString() ?? 'multiple_choice',
        answer: json['options'] != null ? jsonEncode(json['options']) : '',
        correct: json['correct']?['order']?.toString() ?? '',
        questionImage: '',
        options: optionsList?.map((o) => Map<String, dynamic>.from(o as Map)).toList(),
        correctAnswer: json['correct'] != null ? Map<String, dynamic>.from(json['correct'] as Map) : null,
      );
    } else {
      // Old format
      return QuestionModel(
        id: json['id'] ?? '',
        parent: json['parent'] ?? '',
        content: json['content'] ?? '',
        title: json['title'] ?? '',
        type: json['type'] ?? '',
        answer: json['answer'] ?? '',
        correct: json['correct'] ?? '',
        questionImage: json['question_image'] ?? '',
        options: null,
        correctAnswer: null,
      );
    }
  }

  List<String> getOptions() {
    try {
      // If we have the new format options, use them
      if (options != null && options!.isNotEmpty) {
        return options!
            .map((option) => option['text']?.toString() ?? '')
            .toList();
      }
      
      // Otherwise try to parse the old format
      final List<dynamic> parsedAnswer = json.decode(answer);
      return parsedAnswer.map((option) => option['text'] as String).toList();
    } catch (e) {
      print('⚠️ Error parsing options: $e');
      return [];
    }
  }
  
  int? getCorrectAnswerIndex() {
    if (correctAnswer != null) {
      return correctAnswer!['order'] as int?;
    }
    // Try to parse from correct field for old format
    return int.tryParse(correct);
  }
}
