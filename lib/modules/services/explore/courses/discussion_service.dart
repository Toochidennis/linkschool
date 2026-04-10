import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/model/explore/cohorts/discussion_model.dart';

class DiscussionService {


  Future<DiscussionResponseModel> fetchDiscussions({
    required String cohortId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;
        final String baseUrl =
      "${EnvConfig.apiBaseUrl}/public/learning/cohorts/$cohortId/discussions";

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: {
       // 'cohort_id': cohortId,
        'page': page.toString(),
        'per_page': perPage.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return DiscussionResponseModel.fromJson(decoded);
    } catch (e) {
      throw Exception("Error fetching discussions: $e");
    }
  }

  // fetch discussion details

  Future<DiscussionDetailResponseModel> fetchDiscussionDetail({
    required String discussionId,
    int page = 1,
    int perPage = 20,
    int? authorId,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final uri = Uri.parse(
        "${EnvConfig.apiBaseUrl}/public/learning/discussions/$discussionId/posts",
      ).replace(queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (authorId != null && authorId > 0) 'author_id': authorId.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return DiscussionDetailResponseModel.fromJson(decoded);
    } catch (e) {
      throw Exception("Error fetching discussion detail: $e");
    }
  }
// fetch post replies
  Future<DiscussionPostRepliesResponseModel> fetchPostReplies({
    required String postId,
    int page = 1,
    int perPage = 20,
    int? authorId,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final uri = Uri.parse(
        "${EnvConfig.apiBaseUrl}/public/learning/posts/$postId/replies",
      ).replace(queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (authorId != null && authorId > 0) 'author_id': authorId.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return DiscussionPostRepliesResponseModel.fromJson(decoded);
    } catch (e) {
      throw Exception("Error fetching post replies: $e");
    }
  }

  Future<DiscussionResponseModel> createDiscussion({
    required String cohortId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final uri = Uri.parse(
        "${EnvConfig.apiBaseUrl}/public/learning/cohorts/$cohortId/discussions",
      );

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: json.encode(payload),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed: ${response.body}");
      }

      final decoded = json.decode(response.body);
      return DiscussionResponseModel.fromJson(decoded);
    } catch (e) {
      throw Exception("Error creating discussion: $e");
    }
  }

  Future<bool> createDiscussionPost({
    required String cohortId,
    required String discussionId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final uri = Uri.parse(
        "${EnvConfig.apiBaseUrl}/public/learning/cohorts/$cohortId/discussions/$discussionId/posts",
      );

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: json.encode(payload),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed: ${response.body}");
      }

      return true;
    } catch (e) {
      throw Exception("Error creating discussion post: $e");
    }
  }

  Future<bool> togglePostLike({
    required String cohortId,
    required String postId,
    required int authorId,
    required bool unlike,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final action = unlike ? 'unlike' : 'like';
      final uri = Uri.parse(
        "${EnvConfig.apiBaseUrl}/public/learning/cohorts/$cohortId/posts/$postId/$action",
      );

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: json.encode({
          'author_id': authorId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed: ${response.body}");
      }

      return true;
    } catch (e) {
      throw Exception("Error toggling post like: $e");
    }
  }


   Future<bool> discussionLike({
    required String cohortId,
    required String discussionId,
    required int authorId,
    required bool unlike,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final action = unlike ? 'unlike' : 'like';
      final uri = Uri.parse(
        "${EnvConfig.apiBaseUrl}/public/learning/cohorts/$cohortId/discussions/$discussionId/$action",
      );

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: json.encode({
          'author_id': authorId,
        }),
      );


      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed: ${response.body}");
      }

      return true;
    } catch (e) {
      throw Exception("Error toggling discussion like: $e");
    }
  }

Future<bool> deleteDiscussion({
  required String cohortId,
  required String discussionId,
  required int authorId,
}) async {
  try {
    final apiKey = EnvConfig.apiKey;

    if (apiKey.isEmpty) {
      throw Exception("API KEY not found");
    }

    final uri = Uri.parse(
      '${EnvConfig.apiBaseUrl}/public/learning/cohorts/$cohortId/discussions/$discussionId',
    );


    final response = await http.delete(
      uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-API-KEY": apiKey,
      },
      body: json.encode({'author_id': authorId}),
    );

    if (response.statusCode != 200 && 
        response.statusCode != 201 && 
        response.statusCode != 204) {
      throw Exception("Failed: ${response.body}");
    }

    return true;
  } catch (e) {
    throw Exception("Error deleting discussion: $e");
  }
}

  Future<bool> updateDiscussion({
    required String cohortId,
    required String discussionId,
    required Map<String, dynamic> payload,
  }) async {
  try {
    final apiKey = EnvConfig.apiKey;

    if (apiKey.isEmpty) {
      throw Exception("API KEY not found");
    }

    final uri = Uri.parse(
      '${EnvConfig.apiBaseUrl}/public/learning/cohorts/$cohortId/discussions/$discussionId',
    );


    final response = await http.put(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-API-KEY": apiKey,
      },
      body: json.encode(payload),
    );

    if (response.statusCode != 200 && 
        response.statusCode != 201 && 
        response.statusCode != 204) {
      throw Exception("Failed: ${response.body}");
    }

    return true;
  } catch (e) {
    throw Exception("Error updating discussion: $e");
  }
}

  /// Updates a post or reply inside a discussion.
  Future<bool> updatePost({
    required String cohortId,
    required String discussionId,
    required String postId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final uri = Uri.parse(
        '${EnvConfig.apiBaseUrl}/public/learning/cohorts/$cohortId/discussions/$discussionId/posts/$postId',
      );


      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: json.encode(payload),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
  // /
        throw Exception("Failed: ${response.body}");
      }

      return true;
    } catch (e) {
      throw Exception("Error updating post: $e");
    }
  }

  /// Deletes a post or reply.
  Future<bool> deletePost({
    required String cohortId,
    required String postId,
    required int authorId,
  }) async {
    try {
      final apiKey = EnvConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception("API KEY not found");
      }

      final uri = Uri.parse(
        '${EnvConfig.apiBaseUrl}/public/learning/cohorts/$cohortId/posts/$postId',
      );


      final response = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-API-KEY": apiKey,
        },
        body: json.encode({'author_id': authorId}),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw Exception("Failed: ${response.body}");
      }

      return true;
    } catch (e) {
      throw Exception("Error deleting post: $e");
    }
  }
}

// post discussions

