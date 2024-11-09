import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/admin_portal/e_learning/assignment_screen.dart';
import 'package:linkschool/modules/admin_portal/e_learning/question_screen.dart';

class Topic {
  final String name;
  final List<Assignment> assignments;
  final List<Question> questions;

  Topic({required this.name, required this.assignments, required this.questions});
}
