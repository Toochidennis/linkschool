import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';

class Material {
  final String title;
  final String description;
  final String selectedClass;
  final DateTime startDate;
  final DateTime endDate;
  final String topic;
  final Duration duration;
  final String marks;
  final DateTime createdAt;

  Material({
    required this.title,
    required this.description,
    required this.selectedClass,
    required this.startDate,
    required this.endDate,
    required this.topic,
    required this.duration,
    required this.marks,

    DateTime? createdAt, int? id,
      List<AttachmentItem>? attachments,
  }) : createdAt = createdAt ?? DateTime.now();
}
