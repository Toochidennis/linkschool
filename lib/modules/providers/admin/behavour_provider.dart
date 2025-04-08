import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/behaviour_model.dart';
import 'package:linkschool/modules/services/admin/behaviour_service.dart';

class SkillsProvider with ChangeNotifier {
  final SkillService _skillService;
  List<Skills> _skills = [];
  bool _isLoading = false;
  String _error = '';

  SkillsProvider(this._skillService);

  List<Skills> get skills => _skills;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchSkills() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _skills = await _skillService.getSkills();
      _error = '';
    } catch (e) {
      _error = e.toString();
      print("Fetch Error: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSkill(String skillName, String type, String level) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Convert type to API format if needed
      final apiType = type == "Skills" ? "0" : "1";
      
      final newSkill = Skills(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        skillName: skillName,
        type: apiType,
        level: level,
      );

      // Send the new skill to the API
      await _skillService.addSkill(newSkill);

      // Refresh the list
      await fetchSkills();
    } catch (e) {
      _error = e.toString();
      print("Add Skill Error: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSkill(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _skillService.deleteSkill(id);
      await fetchSkills();
    } catch (e) {
      _error = e.toString();
      print("Delete Error: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void editSkillLocally(String id, String skillName, String typeDisplay, String level) {
    // Find the skill to edit
    final skillIndex = _skills.indexWhere((skill) => skill.id == id);
    if (skillIndex != -1) {
      // Convert display type back to numeric type
      final type = typeDisplay == "Skills" ? "0" : "1";
      
      // Update the skill locally
      _skills[skillIndex] = Skills(
        id: id,
        skillName: skillName,
        type: type, // Store as "0" or "1"
        level: level,
      );
      notifyListeners();
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/model/admin/behaviour_model.dart';
// import '../../services/admin/behaviour_service.dart';

// class SkillsProvider with ChangeNotifier {
//   final SkillService _skillService = SkillService();
//   List<Skills> _skills = [];
//   bool _isLoading = false;
//   String _error = '';

//   List<Skills> get skills => _skills;
//   bool get isLoading => _isLoading;
//   String get error => _error;

//   Future<void> fetchSkills() async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();

//     try {
//       _skills = await _skillService.getSkills();
//       _error = '';
//     } catch (e) {
//       _error = e.toString();
//       print("Fetch Error: $_error");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

// Future<void> addSkill(String skillName, String type, String level) async {
//   _isLoading = true;
//   _error = '';
//   notifyListeners();

//   try {
//     // Convert type to API format if needed
//     final apiType = type == "Skills" ? "0" : "1";
    
//     final newSkill = Skills(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       skillName: skillName,
//       type: apiType,
//       level: level,
//     );

//     // Send the new skill to the API
//     await _skillService.addSkill(newSkill);

//     // Refresh the list
//     await fetchSkills();
//   } catch (e) {
//     _error = e.toString();
//     print("Add Skill Error: $_error");
//   } finally {
//     _isLoading = false;
//     notifyListeners();
//   }
// }

//   Future<void> deleteSkill(String id) async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();

//     try {
//       await _skillService.deleteSkill(id);
//       await fetchSkills();
//     } catch (e) {
//       _error = e.toString();
//       print("Delete Error: $_error");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void editSkillLocally(String id, String skillName, String typeDisplay, String level) {
//     // Find the skill to edit
//     final skillIndex = _skills.indexWhere((skill) => skill.id == id);
//     if (skillIndex != -1) {
//       // Convert display type back to numeric type
//       final type = typeDisplay == "Skills" ? "0" : "1";
      
//       // Update the skill locally
//       _skills[skillIndex] = Skills(
//         id: id,
//         skillName: skillName,
//         type: type, // Store as "0" or "1"
//         level: level,
//       );
//       notifyListeners();
//     }
//   }
// }