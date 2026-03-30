import 'package:linkschool/modules/staff/e_learning/form_classes/staff_skills_behaviour_screen.dart';

class StaffBehaviourScreen extends StaffSkillsBehaviourScreen {
  const StaffBehaviourScreen({
    super.key,
    required super.classId,
    required super.levelId,
    super.term,
    super.year,
    super.db,
  }) : super(screenTitle: 'Behaviour', contentType: 1);
}
