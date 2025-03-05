import 'package:linkschool/modules/model/e-learning/material_model.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';

class Topic {
  final String name;
  final String? description;
  final List<Assignment> assignments;
  final List<Question> questions;
  final List<Material> materials;

  Topic(
      {required this.name,
      this.description,
      required this.assignments,
      required this.questions,
      required this.materials});
}
