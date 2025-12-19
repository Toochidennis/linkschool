class SubjectTopicsModel {
  final List<String> topics;

  SubjectTopicsModel({required this.topics});

  factory SubjectTopicsModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] as List<dynamic>? ?? [];
    return SubjectTopicsModel(
      topics: data.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "topics": topics,
    };
  }
}
