import 'package:linkschool/modules/portal/e-learning/assignment_screen.dart';
import 'package:linkschool/modules/portal/e-learning/question_screen.dart';

class Topic {
  final String name;
  final List<Assignment> assignments;
  final List<Question> questions;

  Topic({required this.name, required this.assignments, required this.questions});
}
