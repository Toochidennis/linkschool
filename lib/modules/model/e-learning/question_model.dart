class Question {
  final int? topicId;
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
   this.topicId,
    required this.title,
    required this.description,
    required this.selectedClass,
    required this.startDate,
    required this.endDate,
    required this.topic,
    required this.duration,
    required this.marks,

    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}