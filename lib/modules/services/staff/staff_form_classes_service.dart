import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/services/staff/settings_service.dart';
// import 'package:linkschool/services/settings_service.dart';

class StaffFormClassesServiceFixed {
  final AuthProvider authProvider;

  StaffFormClassesServiceFixed(this.authProvider);

  // Get staff's form classes (classes they are form teacher for)
  List<Map<String, dynamic>> getFormClasses() {
    return authProvider.getFormClasses();
  }

  // Get staff's teaching courses to calculate student numbers
  List<Map<String, dynamic>> getStaffCourses() {
    return authProvider.getStaffCourses();
  }

  // Get school settings from the settings service
  Map<String, dynamic> getSchoolSettings() {
    return SettingsService.getAllSettings();
  }

  // Get current year from settings
  String getCurrentYear() {
    return SettingsService.getCurrentYear();
  }

  // Get current term from settings
  int getCurrentTerm() {
    return SettingsService.getCurrentTerm();
  }

  // Get current term name
  String getCurrentTermName() {
    return SettingsService.getTermName(getCurrentTerm());
  }

  // Get database name
  String getDatabaseName() {
    return SettingsService.getDatabaseName();
  }

  // Get staff profile information
  Map<String, dynamic> getStaffProfile() {
    return authProvider.getUserProfile();
  }

  // Get all form teacher levels
  List<String> getFormTeacherLevels() {
    final formClasses = getFormClasses();
    return formClasses.map((level) => level['level_name'] as String).toList();
  }

  // Get classes for a specific level with current year and term
  List<Map<String, dynamic>> getClassesForLevel(String levelName) {
    final formClasses = getFormClasses();
    final levelData = formClasses.firstWhere(
      (level) => level['level_name'] == levelName,
      orElse: () => {},
    );

    if (levelData.isNotEmpty && levelData['classes'] != null) {
      final classes = List<Map<String, dynamic>>.from(levelData['classes']);
      
      // Add current year and term to each class
      return classes.map((classData) {
        return {
          ...classData,
          'year': getCurrentYear(),
          'term': getCurrentTerm(),
          'termName': getCurrentTermName(),
        };
      }).toList();
    }
    return [];
  }

  // Get student count for a specific class
  int getStudentCountForClass(int classId) {
    final staffCourses = getStaffCourses();

    for (var courseData in staffCourses) {
      if (courseData['class_id'] == classId) {
        List<dynamic> courses = courseData['courses'] ?? [];
        if (courses.isNotEmpty) {
          // Return the maximum student count (assuming same students across subjects)
          return courses.map((c) => c['num_of_students'] as int? ?? 0)
                        .reduce((a, b) => a > b ? a : b);
        }
      }
    }
    return 0;
  }

  // Check if staff is form teacher for any class
  bool isFormTeacher() {
    return getFormClasses().isNotEmpty;
  }

  // Get total number of form classes
  int getTotalFormClasses() {
    final formClasses = getFormClasses();
    int total = 0;
    for (var levelData in formClasses) {
      final classes = levelData['classes'] as List? ?? [];
      total += classes.length;
    }
    return total;
  }

  // Get class details by class ID with current session info
  Map<String, dynamic>? getClassDetails(int classId) {
    final formClasses = getFormClasses();

    for (var levelData in formClasses) {
      final classes = levelData['classes'] as List? ?? [];
      for (var classData in classes) {
        if (classData['class_id'] == classId) {
          return {
            'class_id': classData['class_id'],
            'class_name': classData['class_name'],
            'level_id': levelData['level_id'],
            'level_name': levelData['level_name'],
            'year': getCurrentYear(),
            'term': getCurrentTerm(),
            'termName': getCurrentTermName(),
            'db': getDatabaseName(),
          };
        }
      }
    }
    return null;
  }

  // Get all form classes with current session info
  List<Map<String, dynamic>> getFormClassesWithSessionInfo() {
    final formClasses = getFormClasses();
    final currentYear = getCurrentYear();
    final currentTerm = getCurrentTerm();
    final currentTermName = getCurrentTermName();
    final dbName = getDatabaseName();

    return formClasses.map((levelData) {
      final classes = levelData['classes'] as List? ?? [];
      final updatedClasses = classes.map((classData) {
        return {
          ...classData,
          'year': currentYear,
          'term': currentTerm,
          'termName': currentTermName,
          'db': dbName,
        };
      }).toList();

      return {
        ...levelData,
        'classes': updatedClasses,
      };
    }).toList();
  }
}


