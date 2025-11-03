import 'package:flutter/material.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/model/admin/behaviour_model.dart';
import 'package:linkschool/modules/services/admin/behaviour_service.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';

class SkillsProvider with ChangeNotifier {
  final SkillService _skillService;
  List<Skills> _skills = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedLevel = '0'; // Default to '0' for all levels

  SkillsProvider(this._skillService);

  List<Skills> get skills {
    // Filter skills based on selected level
    if (_selectedLevel == '0') {
      return _skills; // Return all skills for 'General (All level)'
    }
    return _skills.where((skill) => skill.level == _selectedLevel).toList();
  }
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedLevel => _selectedLevel;

  void setSelectedLevel(String level) {
    _selectedLevel = level;
    notifyListeners();
  }

  Future<void> fetchSkills() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final authProvider = locator<AuthProvider>();
      if (authProvider.token != null) {
        locator<ApiService>().setAuthToken(authProvider.token!);
      } else {
        throw Exception('Authentication token is missing');
      }
      
      _skills = await _skillService.getSkills();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSkill(String skillName, String type, String level, {BuildContext? context}) async {
    try {
      final authProvider = locator<AuthProvider>();
      if (authProvider.token != null) {
        locator<ApiService>().setAuthToken(authProvider.token!);
      } else {
        throw Exception('Authentication token is missing');
      }

      final response = await _skillService.addSkill(
        skillName: skillName,
        type: type,
        levelId: level,
      );

      if (response.success) {
        // Show success message only if context is still valid
        if (context != null && context.mounted) {
          CustomToaster.toastSuccess(
            context,
            'Success',
            'Skill/Behaviour added successfully',
          );
        }
        // Refresh skills after successful addition
        await fetchSkills();
      } else {
        throw Exception(response.message ?? 'Failed to add skill');
      }
    } catch (e) {
      _error = e.toString();
      // Only show error if context is still valid
      if (context != null && context.mounted) {
        CustomToaster.toastError(context, 'Error', _error);
      }
    }
  }

  Future<void> editSkill(String id, String skillName, String type, String level, {BuildContext? context}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final authProvider = locator<AuthProvider>();
      if (authProvider.token != null) {
        locator<ApiService>().setAuthToken(authProvider.token!);
      } else {
        throw Exception('Authentication token is missing');
      }

      final response = await _skillService.updateSkill(
        id: id,
        skillName: skillName,
        type: type,
        levelId: level,
      );

      if (response.success && context != null && context.mounted) {
        CustomToaster.toastSuccess(
          context,
          'Success',
          'Skill/Behaviour updated successfully',
        );
      }
      await fetchSkills();
    } catch (e) {
      _error = e.toString();
      if (context != null && context.mounted) {
        CustomToaster.toastError(context, 'Error', _error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSkill(String id, {BuildContext? context}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final authProvider = locator<AuthProvider>();
      if (authProvider.token != null) {
        locator<ApiService>().setAuthToken(authProvider.token!);
      } else {
        throw Exception('Authentication token is missing');
      }

      await _skillService.deleteSkill(id);
      await fetchSkills();
    } catch (e) {
      _error = e.toString();
      if (context != null && context.mounted) {
        CustomToaster.toastError(context, 'Error', _error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}



