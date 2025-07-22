class Class {
  final String classId;
  final String className;
  final String levelId;

  Class({
    required this.classId,
    required this.className,
    required this.levelId,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      classId: json['class_id'],
      className: json['class_name'],
      levelId: json['level_id'],
    );
  }
}