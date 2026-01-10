class AssignmentModel {
  final String title;
  final String description;
  final List<Map<String, String>> attachments;
  final String topic;
  final DateTime createdAt;

  AssignmentModel({
    required this.title,
    required this.description,
    required this.topic,
    required this.attachments,
    required this.createdAt,
  });
}
