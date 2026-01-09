class LevelModel {
  final int id;
  final String name;
  final int rank;

  LevelModel({
    required this.id,
    required this.name,
    required this.rank,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      rank: json['rank'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rank': rank,
    };
  }
}
