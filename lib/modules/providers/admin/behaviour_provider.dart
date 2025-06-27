import 'package:flutter/material.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/model/admin/behaviour_model.dart';
import 'package:linkschool/modules/services/admin/behaviour_service.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:linkschool/modules/providers/auth/auth_provider.dart';

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
      // Ensure token is set before making API call
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

      final response = await _skillService.addSkill(
        skillName: skillName,
        type: type,
        levelId: level,
      );

      if (response.success && context != null) {
        CustomToaster.toastSuccess(
          context,
          'Success',
          'Skill/Behaviour added successfully',
        );
      }
      await fetchSkills();
    } catch (e) {
      _error = e.toString();
      if (context != null) {
        CustomToaster.toastError(context, 'Error', _error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
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

      if (response.success && context != null) {
        CustomToaster.toastSuccess(
          context,
          'Success',
          'Skill/Behaviour updated successfully',
        );
      }
      await fetchSkills();
    } catch (e) {
      _error = e.toString();
      if (context != null) {
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
      if (context != null) {
        CustomToaster.toastError(context, 'Error', _error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/model/admin/behaviour_model.dart';
// import 'package:linkschool/modules/services/admin/behaviour_service.dart';
// import 'package:linkschool/modules/common/custom_toaster.dart';

// class SkillsProvider with ChangeNotifier {
//   final SkillService _skillService;
//   List<Skills> _skills = [];
//   bool _isLoading = false;
//   String _error = '';

//   SkillsProvider(this._skillService);

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
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> addSkill(String skillName, String type, String level, {BuildContext? context}) async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();

//     try {
//       final response = await _skillService.addSkill(
//         skillName: skillName,
//         type: type,
//         levelId: level,
//       );

//       if (response.success && context != null) {
//         CustomToaster.toastSuccess(
//           context,
//           'Success',
//           'Skill/Behaviour added successfully',
//         );
//       }
//       await fetchSkills();
//     } catch (e) {
//       _error = e.toString();
//       if (context != null) {
//         CustomToaster.toastError(context, 'Error', _error);
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> editSkill(String id, String skillName, String type, String level, {BuildContext? context}) async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();

//     try {
//       final response = await _skillService.updateSkill(
//         id: id,
//         skillName: skillName,
//         type: type,
//         levelId: level,
//       );

//       if (response.success && context != null) {
//         CustomToaster.toastSuccess(
//           context,
//           'Success',
//           'Skill/Behaviour updated successfully',
//         );
//       }
//       await fetchSkills();
//     } catch (e) {
//       _error = e.toString();
//       if (context != null) {
//         CustomToaster.toastError(context, 'Error', _error);
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> deleteSkill(String id, {BuildContext? context}) async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();

//     try {
//       await _skillService.deleteSkill(id);
//       await fetchSkills();
//     } catch (e) {
//       _error = e.toString();
//       if (context != null) {
//         CustomToaster.toastError(context, 'Error', _error);
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }