class CbtDiscussionComment {
  final int id;
  final int updateId;
  final int userId;
  final String username;
  final String body;
  final String createdAt;

  const CbtDiscussionComment({
    required this.id,
    required this.updateId,
    required this.userId,
    required this.username,
    required this.body,
    required this.createdAt,
  });

  factory CbtDiscussionComment.fromJson(Map<String, dynamic> json) {
    return CbtDiscussionComment(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}')!,
      updateId: json['update_id'] is int
          ? json['update_id'] as int
          : int.tryParse('${json['update_id']}')!,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse('${json['user_id']}')!,
      username: json['username'] is String ? json['username'] as String : '',
      body: json['body'] is String ? json['body'] as String : '',
      createdAt:
          json['created_at'] is String ? json['created_at'] as String : '',
    );
  }
}
