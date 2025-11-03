class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<Class> classes;
  final List<Level> levels;
  final List<FormClass> formClasses; // For staff
  final List<Course> courses;
  final List<StaffCourse> staffCourses; // For staff courses
  final SchoolSettings settings;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.classes,
    required this.levels,
    required this.formClasses,
    required this.courses,
    required this.staffCourses,
    required this.settings,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] ?? {};
    final role = profile['role'] ?? '';
    
    return User(
      id: profile['staff_id']?.toString() ?? '',
      name: profile['name'] ?? '',
      email: profile['email'] ?? '',
      role: role,
      // Admin data structure
      classes: role == 'admin' 
        ? (json['classes'] as List?)?.map((classData) => Class.fromJson(classData)).toList() ?? []
        : [],
      levels: role == 'admin'
        ? (json['levels'] as List?)?.map((levelData) => Level.fromJson(levelData)).toList() ?? []
        : [],
      courses: role == 'admin'
        ? (json['courses'] as List?)?.map((courseData) => Course.fromJson(courseData)).toList() ?? []
        : [],
      // Staff data structure
      formClasses: role == 'staff'
        ? (json['form_classes'] as List?)?.map((formClassData) => FormClass.fromJson(formClassData)).toList() ?? []
        : [],
      staffCourses: role == 'staff'
        ? (json['courses'] as List?)?.map((staffCourseData) => StaffCourse.fromJson(staffCourseData)).toList() ?? []
        : [],
      settings: SchoolSettings.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': {
        'staff_id': id,
        'name': name,
        'email': email,
        'role': role,
      },
      'classes': classes.map((c) => c.toJson()).toList(),
      'levels': levels.map((l) => l.toJson()).toList(),
      'courses': courses.map((c) => c.toJson()).toList(),
      'form_classes': formClasses.map((fc) => fc.toJson()).toList(),
      'staff_courses': staffCourses.map((sc) => sc.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }
}

class Class {
  final int id;
  final String className;
  final int levelId;
  final String? formTeacher;

  Class({
    required this.id,
    required this.className,
    required this.levelId,
    this.formTeacher,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'] ?? 0,
      className: json['class_name'] ?? '',
      levelId: json['level_id'] ?? 0,
      formTeacher: json['form_teacher']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_name': className,
      'level_id': levelId,
      'form_teacher': formTeacher,
    };
  }
}

class Level {
  final int id;
  final String levelName;

  Level({
    required this.id,
    required this.levelName,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] ?? 0,
      levelName: json['level_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_name': levelName,
    };
  }
}

class Course {
  final int id;
  final String courseName;

  Course({
    required this.id,
    required this.courseName,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      courseName: json['course_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': courseName,
    };
  }
}

// New models for staff-specific data
class FormClass {
  final int levelId;
  final String levelName;
  final List<FormClassDetail> classes;

  FormClass({
    required this.levelId,
    required this.levelName,
    required this.classes,
  });

  factory FormClass.fromJson(Map<String, dynamic> json) {
    return FormClass(
      levelId: json['level_id'] ?? 0,
      levelName: json['level_name'] ?? '',
      classes: (json['classes'] as List?)
        ?.map((classData) => FormClassDetail.fromJson(classData))
        .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level_id': levelId,
      'level_name': levelName,
      'classes': classes.map((c) => c.toJson()).toList(),
    };
  }
}

class FormClassDetail {
  final int classId;
  final String className;

  FormClassDetail({
    required this.classId,
    required this.className,
  });

  factory FormClassDetail.fromJson(Map<String, dynamic> json) {
    return FormClassDetail(
      classId: json['class_id'] ?? 0,
      className: json['class_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
    };
  }
}

class StaffCourse {
  final int classId;
  final String className;
  final List<CourseDetail> courses;

  StaffCourse({
    required this.classId,
    required this.className,
    required this.courses,
  });

  factory StaffCourse.fromJson(Map<String, dynamic> json) {
    return StaffCourse(
      classId: json['class_id'] ?? 0,
      className: json['class_name'] ?? '',
      courses: (json['courses'] as List?)
        ?.map((courseData) => CourseDetail.fromJson(courseData))
        .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
      'courses': courses.map((c) => c.toJson()).toList(),
    };
  }
}

class CourseDetail {
  final int courseId;
  final String courseName;
  final int numOfStudents;

  CourseDetail({
    required this.courseId,
    required this.courseName,
    required this.numOfStudents,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      numOfStudents: json['num_of_students'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'num_of_students': numOfStudents,
    };
  }
}

class SchoolSettings {
  final String schoolName;
  final String year;
  final int term;

  SchoolSettings({
    required this.schoolName,
    required this.year,
    required this.term,
  });

  factory SchoolSettings.fromJson(Map<String, dynamic> json) {
    return SchoolSettings(
      schoolName: json['school_name'] ?? '',
      year: json['year'] ?? '',
      term: json['term'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school_name': schoolName,
      'year': year,
      'term': term,
    };
  }
}


