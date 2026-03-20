bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return fallback;
    if (normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'y') {
      return true;
    }
    if (normalized == 'false' ||
        normalized == '0' ||
        normalized == 'no' ||
        normalized == 'n') {
      return false;
    }
  }
  return fallback;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) return parsed;
    final asDouble = double.tryParse(value.trim());
    if (asDouble != null) return asDouble.toInt();
  }
  return fallback;
}

class DiscussionAuthor {
  final String firstName;
  final String lastName;
  final String fullName;

  DiscussionAuthor({
    required this.firstName,
    required this.lastName,
    required this.fullName,
  });

  factory DiscussionAuthor.fromJson(Map<String, dynamic> json) {
    return DiscussionAuthor(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }

  String get initials {
    final buffer = StringBuffer();
    if (firstName.isNotEmpty) {
      buffer.write(firstName[0]);
    }
    if (lastName.isNotEmpty) {
      buffer.write(lastName[0]);
    }
    if (buffer.isEmpty && fullName.isNotEmpty) {
      buffer.write(fullName[0]);
    }
    return buffer.toString().toUpperCase();
  }
}

class DiscussionImage {
  final String fileName;
  final String oldFileName;
  final String file;
  final String type;

  DiscussionImage({
    required this.fileName,
    required this.oldFileName,
    required this.file,
    required this.type,
  });

  factory DiscussionImage.fromJson(Map<String, dynamic> json) {
    return DiscussionImage(
      fileName: json['file_name'] ?? '',
      oldFileName: json['old_file_name'] ?? '',
      file: json['file'] ?? '',
      type: json['type'] ?? '',
    );
  }

  String get url {
    if (fileName.isEmpty) return '';
    if (fileName.startsWith('http')) return fileName;
    if (fileName.startsWith('file://')) return fileName;
    return 'https://linkskool.net/$fileName';
  }
}

class DiscussionPost {
  final int id;
  final int? parentPostId;
  final int discussionId;
  final int authorId;
  final DiscussionAuthor? author;
  final String body;
  final List<DiscussionImage> images;
  final int depth;
  final int replyCount;
  final int likesCount;
  final bool isLiked;
  final String createdAt;
  final List<DiscussionPost> replies;

  DiscussionPost({
    required this.id,
    required this.parentPostId,
    required this.discussionId,
    required this.authorId,
    required this.author,
    required this.body,
    required this.images,
    required this.depth,
    required this.replyCount,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
    this.replies = const [],
  });

  factory DiscussionPost.fromJson(Map<String, dynamic> json) {
    return DiscussionPost(
      id: _asInt(json['id']),
      parentPostId: json['parent_post_id'] == null
          ? null
          : _asInt(json['parent_post_id']),
      discussionId: _asInt(json['discussion_id']),
      authorId: _asInt(json['author_id']),
      author: json['author'] != null
          ? DiscussionAuthor.fromJson(
              Map<String, dynamic>.from(json['author']),
            )
          : null,
      body: json['body'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => DiscussionImage.fromJson(image))
              .toList() ??
          [],
      depth: _asInt(json['depth']),
      replyCount: _asInt(json['reply_count']),
      likesCount: _asInt(json['likes_count']),
      isLiked: _asBool(json['is_liked'] ?? json['isLiked']),
      createdAt: json['created_at'] ?? '',
    );
  }

  DiscussionPost copyWith({
    int? id,
    int? parentPostId,
    int? discussionId,
    int? authorId,
    DiscussionAuthor? author,
    String? body,
    List<DiscussionImage>? images,
    int? depth,
    int? replyCount,
    int? likesCount,
    bool? isLiked,
    String? createdAt,
    List<DiscussionPost>? replies,
  }) {
    return DiscussionPost(
      id: id ?? this.id,
      parentPostId: parentPostId ?? this.parentPostId,
      discussionId: discussionId ?? this.discussionId,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      body: body ?? this.body,
      images: images ?? this.images,
      depth: depth ?? this.depth,
      replyCount: replyCount ?? this.replyCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }

  String get primaryImageUrl {
    if (images.isEmpty) return '';
    return images.first.url;
  }
}

class DiscussionItem {
  final int id;
  final int cohortId;
  final int authorId;
  final DiscussionAuthor? author;
  final String title;
  final String body;
  final String createdAt;
  final List<DiscussionImage> images;
  final bool isPinned;
  final bool isLocked;
  final int postsCount;
  final int likesCount;

  DiscussionItem({
    required this.id,
    required this.cohortId,
    required this.authorId,
    required this.author,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.images,
    required this.isPinned,
    required this.isLocked,
    required this.postsCount,
    required this.likesCount,
  });

  factory DiscussionItem.fromJson(Map<String, dynamic> json) {
    return DiscussionItem(
      id: _asInt(json['id']),
      cohortId: _asInt(json['cohort_id']),
      authorId: _asInt(json['author_id']),
      author: json['author'] != null
          ? DiscussionAuthor.fromJson(
              Map<String, dynamic>.from(json['author']),
            )
          : null,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      createdAt: json['created_at'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => DiscussionImage.fromJson(image))
              .toList() ??
          [],
      isPinned: _asBool(json['is_pinned'] ?? json['isPinned']),
      isLocked: _asBool(json['is_locked'] ?? json['isLocked']),
      likesCount: _asInt(json['likes_count'] ?? json['likesCount']),
      postsCount: _asInt(json['posts_count']),
    );
  }

  String get primaryImageUrl {
    if (images.isEmpty) return '';
    return images.first.url;
  }
}

class DiscussionMeta {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final bool hasNext;
  final bool hasPrev;

  DiscussionMeta({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory DiscussionMeta.fromJson(Map<String, dynamic> json) {
    return DiscussionMeta(
      total: _asInt(json['total']),
      perPage: _asInt(json['per_page']),
      currentPage: _asInt(json['current_page']),
      lastPage: _asInt(json['last_page']),
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}

class DiscussionPayload {
  final List<DiscussionItem> items;
  final DiscussionMeta? meta;

  DiscussionPayload({
    required this.items,
    required this.meta,
  });

  factory DiscussionPayload.fromJson(Map<String, dynamic> json) {
    return DiscussionPayload(
      items: (json['data'] as List<dynamic>?)
              ?.map((item) => DiscussionItem.fromJson(item))
              .toList() ??
          [],
      meta: json['meta'] != null
          ? DiscussionMeta.fromJson(Map<String, dynamic>.from(json['meta']))
          : null,
    );
  }
}

class DiscussionResponseModel {
  final int statusCode;
  final bool success;
  final String message;
  final DiscussionPayload? data;

  DiscussionResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory DiscussionResponseModel.fromJson(Map<String, dynamic> json) {
    return DiscussionResponseModel(
      statusCode: _asInt(json['statusCode'], fallback: 200),
      success: _asBool(json['success']),
      message: json['message'] ?? '',
      data: json['data'] != null
          ? DiscussionPayload.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class DiscussionDetailPayload {
  final DiscussionItem? discussion;
  final List<DiscussionPost> posts;
  final DiscussionMeta? meta;

  DiscussionDetailPayload({
    required this.discussion,
    required this.posts,
    required this.meta,
  });

  factory DiscussionDetailPayload.fromJson(Map<String, dynamic> json) {
    return DiscussionDetailPayload(
      discussion: json['discussion'] != null
          ? DiscussionItem.fromJson(
              Map<String, dynamic>.from(json['discussion']),
            )
          : null,
      posts: (json['posts'] as List<dynamic>?)
              ?.map((item) => DiscussionPost.fromJson(item))
              .toList() ??
          [],
      meta: json['meta'] != null
          ? DiscussionMeta.fromJson(Map<String, dynamic>.from(json['meta']))
          : null,
    );
  }
}

class DiscussionDetailResponseModel {
  final int statusCode;
  final bool success;
  final String message;
  final DiscussionDetailPayload? data;

  DiscussionDetailResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory DiscussionDetailResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DiscussionDetailResponseModel(
      statusCode: _asInt(json['statusCode'], fallback: 200),
      success: _asBool(json['success']),
      message: json['message'] ?? '',
      data: json['data'] != null
          ? DiscussionDetailPayload.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
    );
  }
}

class DiscussionPostRepliesPayload {
  final DiscussionPost? post;
  final List<DiscussionPost> replies;
  final DiscussionMeta? meta;

  DiscussionPostRepliesPayload({
    required this.post,
    required this.replies,
    required this.meta,
  });

  factory DiscussionPostRepliesPayload.fromJson(Map<String, dynamic> json) {
    return DiscussionPostRepliesPayload(
      post: json['post'] != null
          ? DiscussionPost.fromJson(Map<String, dynamic>.from(json['post']))
          : null,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((item) => DiscussionPost.fromJson(item))
              .toList() ??
          [],
      meta: json['meta'] != null
          ? DiscussionMeta.fromJson(Map<String, dynamic>.from(json['meta']))
          : null,
    );
  }
}

class DiscussionPostRepliesResponseModel {
  final int statusCode;
  final bool success;
  final String message;
  final DiscussionPostRepliesPayload? data;

  DiscussionPostRepliesResponseModel({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory DiscussionPostRepliesResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DiscussionPostRepliesResponseModel(
      statusCode: _asInt(json['statusCode'], fallback: 200),
      success: _asBool(json['success']),
      message: json['message'] ?? '',
      data: json['data'] != null
          ? DiscussionPostRepliesPayload.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
    );
  }
}
