class Skills {
  final String id;
  final String? skillName;
  final String? type;
  final String? level;
  final String? levelName;

  Skills({
    required this.id,
    required this.skillName,
    required this.type,
    required this.level,
    this.levelName,
  });

  factory Skills.fromJson(Map<String, dynamic> json) {
    return Skills(
      id: json['id'].toString(),
      skillName: json['skill_name'],
      type: json['type']?.toString(),
      level: json['level']?.toString(),
      levelName: json['level_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill_name': skillName,
      'type': type,
      'level_id': level,
      '_db': 'aalmgzmy_linkskoo_practice',
    };
  }
}

