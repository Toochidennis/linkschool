class CourseLeaderboardResponseModel {
  final int statusCode;
  final bool success;
  final String message;
  final CourseLeaderboardData? data;

  CourseLeaderboardResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory CourseLeaderboardResponseModel.fromJson(Map<String, dynamic> json) {
    return CourseLeaderboardResponseModel(
      statusCode: _parseInt(json['statusCode']),
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? CourseLeaderboardData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class CourseLeaderboardData {
  final List<LeaderboardEntry> leaderboard;
  final int? profilePosition;

  CourseLeaderboardData({
    required this.leaderboard,
    required this.profilePosition,
  });

  factory CourseLeaderboardData.fromJson(Map<String, dynamic> json) {
    return CourseLeaderboardData(
      leaderboard: (json['leaderboard'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(LeaderboardEntry.fromJson)
          .toList(),
      profilePosition: _parseNullableInt(json['profile_position']),
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class LeaderboardEntry {
  final int position;
  final String name;

  const LeaderboardEntry({
    required this.position,
    required this.name,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      position: _parseInt(json['position']),
      name: json['name']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
