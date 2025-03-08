import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/behaviour_model.dart';
import '../../services/admin/behaviour_service.dart';

class SkillsProvider with ChangeNotifier {
  final SkillService _skillService = SkillService();
  List<Skills> _skills = [];
  List<Skills> _newSkills = [];
  bool _isLoading = false;
  String _error = '';

  List<Skills> get skills => [..._skills, ..._newSkills];
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchSkills() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _skills = await _skillService.getSkills();
      _newSkills.clear();
      _error = '';
    } catch (e) {
      _error = e.toString();
      print("Fetch Error: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSkill(String skill_Name, String type, String level) async {
    final newSkill = Skills(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      skillName: skill_Name,
      type: type,
      level: level,
    );

    _newSkills.add(newSkill);
    notifyListeners();
  }

  Future<void> saveNewSkills() async {
    if (_newSkills.isEmpty) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _skillService.addSkills(_newSkills);
      await fetchSkills();
      _newSkills.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a skill
  Future<void> deleteSkill(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    // Remove the skill from both lists
    _skills.removeWhere((skill) => skill.id == id);
    _newSkills.removeWhere((skill) => skill.id == id);
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
}
