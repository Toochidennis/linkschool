import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';

import '../../common/widgets/portal/attachmentItem.dart';

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
  final  List<AttachmentItem>? attachments;

  Material({
    required this.title,
    required this.description,
    required this.selectedClass,
    required this.startDate,
    required this.endDate,
    required this.topic,
    required this.duration,
    required this.marks,
    this.attachments,
    DateTime? createdAt, int? id,
   
  }) : createdAt = createdAt ?? DateTime.now();
}
