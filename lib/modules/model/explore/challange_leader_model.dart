class LeaderboardEntry {
  final int id;
  final int challengeId;
  final int userId;
  final String username;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int timeTaken;
  final int attemptsCount;
  final String submittedAt;
  final int position;
  final String? location;
  final String deviceId;
  final String platform;
  final dynamic extra;
  final String createdAt;
  final String updatedAt;

  LeaderboardEntry({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.username,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeTaken,
    required this.attemptsCount,
    required this.submittedAt,
    required this.position,
    this.location,
    required this.deviceId,
    required this.platform,
    required this.extra,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json["id"],
      challengeId: json["challenge_id"],
      userId: json["user_id"],
      username: json["username"],
      score: json["score"],
      correctAnswers: json["correct_answers"],
      totalQuestions: json["total_questions"],
      timeTaken: json["time_taken"],
      attemptsCount: json["attempts_count"],
      submittedAt: json["submitted_at"],
      position: json["position"],
      location: json["location"],
      deviceId: json["device_id"] ?? "",
      platform: json["platform"] ?? "",
      extra: json["extra"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }
}

class LeaderboardResponse {
  final List<LeaderboardEntry> data;

  LeaderboardResponse({required this.data});

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    final list = json["data"] as List<dynamic>? ?? [];
    return LeaderboardResponse(
      data: list.map((e) => LeaderboardEntry.fromJson(e)).toList(),
    );
  }
}
