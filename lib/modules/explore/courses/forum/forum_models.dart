import 'package:flutter/material.dart';

class ForumReply {
  final String id;
  final String author;
  final String avatarLabel;
  final Color avatarColor;
  final String message;
  final String? imagePath;
  final String timestamp;
  final bool isLiked;
  final int likeCount;
  final List<ForumReply> replies;

  const ForumReply({
    required this.id,
    required this.author,
    required this.avatarLabel,
    required this.avatarColor,
    required this.message,
    this.imagePath,
    required this.timestamp,
    this.isLiked = false,
    this.likeCount = 0,
    this.replies = const [],
  });

  ForumReply copyWith({
    String? id,
    String? author,
    String? avatarLabel,
    Color? avatarColor,
    String? message,
    String? imagePath,
    String? timestamp,
    bool? isLiked,
    int? likeCount,
    List<ForumReply>? replies,
  }) {
    return ForumReply(
      id: id ?? this.id,
      author: author ?? this.author,
      avatarLabel: avatarLabel ?? this.avatarLabel,
      avatarColor: avatarColor ?? this.avatarColor,
      message: message ?? this.message,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      replies: replies ?? this.replies,
    );
  }
}

class ForumTopic {
  final String id;
  final String title;
  final String author;
  final String avatarLabel;
  final Color avatarColor;
  final Color statusColor;
  final String content;
  final String dateLabel;
  final String timestamp;
  final bool isLiked;
  final int likeCount;
  final String? imageUrl;
  final List<ForumReply> replies;

  const ForumTopic({
    required this.id,
    required this.title,
    required this.author,
    required this.avatarLabel,
    required this.avatarColor,
    required this.statusColor,
    required this.content,
    required this.dateLabel,
    required this.timestamp,
    this.isLiked = false,
    this.likeCount = 0,
    this.imageUrl,
    this.replies = const [],
  });

  int get replyCount {
    var total = replies.length;
    for (final reply in replies) {
      total += reply.replies.length;
    }
    return total;
  }

  ForumTopic copyWith({
    String? id,
    String? title,
    String? author,
    String? avatarLabel,
    Color? avatarColor,
    Color? statusColor,
    String? content,
    String? dateLabel,
    String? timestamp,
    bool? isLiked,
    int? likeCount,
    String? imageUrl,
    List<ForumReply>? replies,
  }) {
    return ForumTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      avatarLabel: avatarLabel ?? this.avatarLabel,
      avatarColor: avatarColor ?? this.avatarColor,
      statusColor: statusColor ?? this.statusColor,
      content: content ?? this.content,
      dateLabel: dateLabel ?? this.dateLabel,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      imageUrl: imageUrl ?? this.imageUrl,
      replies: replies ?? this.replies,
    );
  }
}
