// question_model.dart
class QuestionModel {
  final String title;
  final String description;
  final String topic;
  final DateTime createdAt;

  QuestionModel({
    required this.title,
    required this.description,
    required this.topic,
    required this.createdAt,
  });
}
