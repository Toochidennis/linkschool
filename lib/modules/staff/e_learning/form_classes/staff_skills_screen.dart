import 'package:linkschool/modules/staff/e_learning/form_classes/staff_skills_behaviour_screen.dart';

class StaffSkillsScreen extends StaffSkillsBehaviourScreen {
  const StaffSkillsScreen({
    super.key,
    required super.classId,
    required super.levelId,
    super.term,
    super.year,
    super.db,
  }) : super(screenTitle: 'Skills', contentType: 0);
}
