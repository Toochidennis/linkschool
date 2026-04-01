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

  StudentSkillBehaviorTable(
      {required this.id, required this.name, required this.skills});

  factory StudentSkillBehaviorTable.fromJson(Map<String, dynamic> json) {
    final skills = <int, String>{};

    // Debug: Print the incoming JSON to see the structure

    if (json['student_skills'] != null && json['student_skills'] is List) {
      for (var skill in json['student_skills']) {

        // Handle skill_id - it comes as String in your JSON
        final skillIdString = skill['skill_id']?.toString();
        final skillId = int.tryParse(skillIdString ?? '') ?? 0;

        // Handle value - it comes as String in your JSON
        final value = skill['value']?.toString() ?? '';

        if (skillId > 0) {
          skills[skillId] = value;
        }
      }
    }

    // Use student_id from JSON, not id
    final studentId = json['student_id'] is int
        ? json['student_id'] as int
        : int.tryParse(json['student_id']?.toString() ?? '') ?? 0;

    final studentName = json['student_name']?.toString() ?? 'Unknown';


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
    required int type,
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
          'type': type,
        },
      );


      if (response.success && response.rawData != null) {
        final responseData = response.rawData!['response'];

        if (responseData != null) {
          // Parse skills
          final skillsList = responseData['skills'] as List? ?? [];
          _skills = skillsList
              .map((skill) => SkillsBehaviorTable.fromJson(skill))
              .toList();


          // Parse students
          final studentsList = responseData['students'] as List? ?? [];
          _students = studentsList.map((student) {
            try {
              return StudentSkillBehaviorTable.fromJson(student);
            } catch (e) {
              // Return a default student to avoid breaking the UI
              return StudentSkillBehaviorTable(
                id: 0,
                name: 'Error parsing student',
                skills: {},
              );
            }
          }).toList();


          // Log detailed information for debugging
          for (var student in _students) {
          }
        } else {
          _errorMessage = 'No response data found';
        }
      } else {
        _errorMessage = response.message ?? 'Unknown error occurred';
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
    required int type,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.post(
        endpoint: 'portal/students/skill-behavior',
        body: {
          ...skillsPayload,
          'type': type,
        },
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
              type: type,
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
    required int type,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.post(
        endpoint: 'portal/students/skill-behavior',
        body: {
          ...skillsPayload,
          'type': type,
        },
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
              type: type,
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
