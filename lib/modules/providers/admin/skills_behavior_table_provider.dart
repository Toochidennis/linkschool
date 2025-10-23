
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
    
    // Debug: Print the incoming JSON to see the structure
    debugPrint('Student JSON: $json');
    
    if (json['student_skills'] != null && json['student_skills'] is List) {
      for (var skill in json['student_skills']) {
        debugPrint('Skill data: $skill');
        
        // Handle skill_id - it comes as String in your JSON
        final skillIdString = skill['skill_id']?.toString();
        final skillId = int.tryParse(skillIdString ?? '') ?? 0;
        
        // Handle value - it comes as String in your JSON
        final value = skill['value']?.toString() ?? '';
        
        if (skillId > 0) {
          skills[skillId] = value;
          debugPrint('Added skill: id=$skillId, value=$value');
        }
      }
    }
    
    // Use student_id from JSON, not id
    final studentId = json['student_id'] is int 
        ? json['student_id'] as int
        : int.tryParse(json['student_id']?.toString() ?? '') ?? 0;
    
    final studentName = json['student_name']?.toString() ?? 'Unknown';
    
    debugPrint('Created student: id=$studentId, name=$studentName, skills=$skills');
    
    return StudentSkillBehaviorTable(
      id: studentId, // Use student_id from JSON
      name: studentName,
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
    debugPrint('Fetching skills and behaviors for class: $classId, level: $levelId');
    
    final response = await _apiService.get(
      endpoint: 'portal/classes/$classId/skill-behavior',
      queryParams: {
        'level_id': levelId,
        'term': term,
        'year': year,
        '_db': db,
      },
    );

    debugPrint('Raw API response: ${response.rawData}');
    debugPrint('Response success: ${response.success}');

    if (response.success && response.rawData != null) {
      final responseData = response.rawData!['response'];
      
      if (responseData != null) {
        // Parse skills
        final skillsList = responseData['skills'] as List? ?? [];
        _skills = skillsList.map((skill) => SkillsBehaviorTable.fromJson(skill)).toList();
        
        debugPrint('Parsed ${_skills.length} skills');
        
        // Parse students
        final studentsList = responseData['students'] as List? ?? [];
        _students = studentsList.map((student) {
          try {
            return StudentSkillBehaviorTable.fromJson(student);
          } catch (e) {
            debugPrint('Error parsing student: $e, student data: $student');
            // Return a default student to avoid breaking the UI
            return StudentSkillBehaviorTable(
              id: 0,
              name: 'Error parsing student',
              skills: {},
            );
          }
        }).toList();
        
        debugPrint('Parsed ${_students.length} students');
        
        // Log detailed information for debugging
        for (var student in _students) {
          debugPrint('Student: ${student.name} (ID: ${student.id}), Skills: ${student.skills}');
        }
      } else {
        _errorMessage = 'No response data found';
        debugPrint(_errorMessage);
      }
    } else {
      _errorMessage = response.message ?? 'Unknown error occurred';
      debugPrint('API error: $_errorMessage');
    }
  } catch (e) {
    _errorMessage = 'Failed to fetch data: $e';
    debugPrint('Exception: $_errorMessage');
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

  Future<bool> updateSkillsAndBehaviours({
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
      _errorMessage = 'Failed to update data: $e';
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