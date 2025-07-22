
import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class SkillsBehaviorTable {
  final int id;
  final String name;

  SkillsBehaviorTable({required this.id, required this.name});

  factory SkillsBehaviorTable.fromJson(Map<String, dynamic> json) {
    return SkillsBehaviorTable(
      id: json['id'],
      name: json['skill_name'],
    );
  }
}

class StudentSkillBehaviorTable {
  final int id;
  final String name;
  final Map<int, String> skills;

  StudentSkillBehaviorTable({required this.id, required this.name, required this.skills});

  factory StudentSkillBehaviorTable.fromJson(Map<String, dynamic> json) {
    final skills = <int, String>{};
    if (json['student_skills'] != null && json['student_skills'] is List) {
      for (var skill in json['student_skills']) {
        // Parse skill_id as String and convert to int
        final skillId = int.tryParse(skill['skill_id'].toString()) ?? 0;
        skills[skillId] = skill['value']?.toString() ?? '-';
      }
    }
    return StudentSkillBehaviorTable(
      id: json['id'],
      name: json['student_name']?.toString() ?? 'Unknown',
      skills: skills,
    );
  }
}

class SkillsBehaviorTableProvider with ChangeNotifier {
  final ApiService _apiService;
  List<SkillsBehaviorTable> _skills = [];
  List<StudentSkillBehaviorTable> _students = [];
  bool _isLoading = false;
  String _errorMessage = '';

  SkillsBehaviorTableProvider(this._apiService);

  List<SkillsBehaviorTable> get skills => _skills;
  List<StudentSkillBehaviorTable> get students => _students;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchSkillsAndBehaviours({
    required String classId,
    required String levelId,
    required String term,
    required String year,
    required String db,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.get(
        endpoint: 'portal/classes/$classId/skill-behavior',
        queryParams: {
          'level_id': levelId,
          'term': term,
          'year': year,
          '_db': db,
        },
        fromJson: (json) {
          final responseData = json['response'];
          final skills = (responseData['skills'] as List? ?? [])
              .map((skill) => SkillsBehaviorTable.fromJson(skill))
              .toList();
          final students = (responseData['students'] as List? ?? [])
              .map((student) => StudentSkillBehaviorTable.fromJson(student))
              .toList();
          return {'skills': skills, 'students': students};
        },
      );

      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        _skills = data['skills'] as List<SkillsBehaviorTable>;
        _students = data['students'] as List<StudentSkillBehaviorTable>;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSkillsAndBehaviours({
    required Map<String, dynamic> skillsPayload,
    required String classId,
    required String levelId,
    required String term,
    required String year,
    required String db,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.post(
        endpoint: 'portal/students/skill-behavior',
        body: skillsPayload,
        fromJson: (json) => json,
      );

      if (response.success) {
        // Defer fetch to avoid setState during build
        await Future.microtask(() => fetchSkillsAndBehaviours(
              classId: classId,
              levelId: levelId,
              term: term,
              year: year,
              db: db,
            ));
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to save data: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}





// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';

// class SkillsBehaviorTable {
//   final int id;
//   final String name;

//   SkillsBehaviorTable({required this.id, required this.name});

//   factory SkillsBehaviorTable.fromJson(Map<String, dynamic> json) {
//     return SkillsBehaviorTable(
//       id: json['id'],
//       name: json['skill_name'],
//     );
//   }
// }

// class StudentSkillBehaviorTable {
//   final int id;
//   final String name;
//   final Map<int, String> skills;

//   StudentSkillBehaviorTable({required this.id, required this.name, required this.skills});

//   factory StudentSkillBehaviorTable.fromJson(Map<String, dynamic> json) {
//     final skills = <int, String>{};
//     if (json['student_skills'] != null && json['student_skills'] is List) {
//       for (var skill in json['student_skills']) {
//         skills[skill['skill_id']] = skill['value']?.toString() ?? '-';
//       }
//     }
//     return StudentSkillBehaviorTable(
//       id: json['id'],
//       name: json['student_name']?.toString() ?? 'Unknown',
//       skills: skills,
//     );
//   }
// }

// class SkillsBehaviorTableProvider with ChangeNotifier {
//   final ApiService _apiService;
//   List<SkillsBehaviorTable> _skills = [];
//   List<StudentSkillBehaviorTable> _students = [];
//   bool _isLoading = false;
//   String _errorMessage = '';

//   SkillsBehaviorTableProvider(this._apiService);

//   List<SkillsBehaviorTable> get skills => _skills;
//   List<StudentSkillBehaviorTable> get students => _students;
//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;

//   Future<void> fetchSkillsAndBehaviours({
//     required String classId,
//     required String levelId,
//     required String term,
//     required String year,
//     required String db,
//   }) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       final response = await _apiService.get(
//         endpoint: 'portal/classes/$classId/skill-behavior',
//         queryParams: {
//           'level_id': levelId,
//           'term': term,
//           'year': year,
//           '_db': db,
//         },
//         fromJson: (json) {
//           final responseData = json['response'];
//           final skills = (responseData['skills'] as List? ?? [])
//               .map((skill) => SkillsBehaviorTable.fromJson(skill))
//               .toList();
//           final students = (responseData['students'] as List? ?? [])
//               .map((student) => StudentSkillBehaviorTable.fromJson(student))
//               .toList();
//           return {'skills': skills, 'students': students};
//         },
//       );

//       if (response.success) {
//         final data = response.data as Map<String, dynamic>;
//         _skills = data['skills'] as List<SkillsBehaviorTable>;
//         _students = data['students'] as List<StudentSkillBehaviorTable>;
//       } else {
//         _errorMessage = response.message;
//       }
//     } catch (e) {
//       _errorMessage = 'Failed to fetch data: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> createSkillsAndBehaviours({
//     required Map<String, dynamic> skillsPayload,
//     required String classId,
//     required String levelId,
//     required String term,
//     required String year,
//     required String db,
//   }) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       final response = await _apiService.post(
//         endpoint: 'portal/students/skill-behavior',
//         body: skillsPayload,
//         fromJson: (json) => json,
//       );

//       if (response.success) {
//         // Refresh data after successful creation
//         await fetchSkillsAndBehaviours(
//           classId: classId,
//           levelId: levelId,
//           term: term,
//           year: year,
//           db: db,
//         );
//         return true;
//       } else {
//         _errorMessage = response.message;
//         return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Failed to save data: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }