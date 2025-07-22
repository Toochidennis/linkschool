import 'package:linkschool/modules/auth/provider/auth_provider.dart';

class StaffDataService {
  final AuthProvider authProvider;

  StaffDataService(this.authProvider);

  // Get staff profile information
  Map<String, dynamic> getStaffProfile() {
    return authProvider.getUserProfile();
  }

  // Get staff's form classes (classes they are form teacher for)
  List<Map<String, dynamic>> getFormClasses() {
    return authProvider.getFormClasses();
  }

  // Get staff's teaching courses
  List<Map<String, dynamic>> getTeachingCourses() {
    return authProvider.getStaffCourses();
  }

  // Get school settings
  Map<String, dynamic> getSchoolSettings() {
    return authProvider.getSettings();
  }

  // Get all classes the staff teaches (from courses data)
  List<String> getTeachingClassNames() {
    final courses = getTeachingCourses();
    return courses.map((course) => course['class_name'] as String).toSet().toList();
  }

  // Get subjects for a specific class
  List<Map<String, dynamic>> getSubjectsForClass(String className) {
    final courses = getTeachingCourses();
    final classData = courses.firstWhere(
      (course) => course['class_name'] == className,
      orElse: () => {},
    );
    
    if (classData.isNotEmpty && classData['courses'] != null) {
      return List<Map<String, dynamic>>.from(classData['courses']);
    }
    return [];
  }

  // Get total number of students for a subject
  int getTotalStudentsForSubject(String subjectName) {
    final courses = getTeachingCourses();
    int totalStudents = 0;
    
    for (var classData in courses) {
      final subjects = classData['courses'] as List? ?? [];
      for (var subject in subjects) {
        if (subject['course_name'] == subjectName) {
          totalStudents += (subject['num_of_students'] as int? ?? 0);
        }
      }
    }
    
    return totalStudents;
  }

  // Check if staff is form teacher for any class
  bool isFormTeacher() {
    return getFormClasses().isNotEmpty;
  }

  // Get form teacher classes
  List<String> getFormTeacherClasses() {
    final formClasses = getFormClasses();
    List<String> classNames = [];
    
    for (var levelData in formClasses) {
      final classes = levelData['classes'] as List? ?? [];
      for (var classData in classes) {
        classNames.add(classData['class_name'] as String);
      }
    }
    
    return classNames;
  }
}
