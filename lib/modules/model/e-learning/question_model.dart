// // question_model.dart
// class QuestionModel {
//   final String title;
//   final String description;
//   final String topic;
//   final DateTime createdAt;

//   QuestionModel({
//     required this.title,
//     required this.description,
//     required this.topic,
//     required this.createdAt,
//   });
// }


class Question {
  final String title;
  final String description;
  final String selectedClass;
  final DateTime startDate;
  final DateTime endDate;
  final String topic;
  final Duration duration;
  final String marks;
  final DateTime createdAt;

  Question({
    required this.title,
    required this.description,
    required this.selectedClass,
    required this.startDate,
    required this.endDate,
    required this.topic,
    required this.duration,
    required this.marks,

    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();
}