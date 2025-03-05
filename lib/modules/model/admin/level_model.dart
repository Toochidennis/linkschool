class Level {
  final String? id;
  final String? levelName;
  final String? schoolType;
  final String? rank;
  final String? resultTemplate;
  final String? admit;

  Level({
    this.id,
    this.levelName,
    this.schoolType,
    this.rank,
    this.resultTemplate,
    this.admit,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id']?.toString(), 
      levelName: json['level_name']?.toString(),
      schoolType: json['school_type']?.toString(),
      rank: json['rank']?.toString(),
      resultTemplate: json['result_template']?.toString(),
      admit: json['admit']?.toString(),
    );
  }
}