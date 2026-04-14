import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class CbtUpdatesService {
  final ApiService _apiService = locator<ApiService>();

  Future<ApiResponse<Map<String, dynamic>>> fetchUpdates({
    int page = 1,
    int perPage = 25,
  }) {
    return _apiService.get<Map<String, dynamic>>(
      endpoint: 'public/cbt-updates',
      queryParams: {
        'page': page,
        'limit': perPage,
      },
      addDatabaseParam: false,
      fromJson: (json) => json,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> fetchUpdateById(int id) {
    return _apiService.get<Map<String, dynamic>>(
      endpoint: 'public/cbt-updates/$id',
      addDatabaseParam: false,
      fromJson: (json) => json,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> fetchComments(
    int updateId, {
    int page = 1,
    int limit = 20,
  }) {
    return _apiService.get<Map<String, dynamic>>(
      endpoint: 'public/cbt-updates/$updateId/comments',
      queryParams: {
        'page': page,
        'limit': limit,
      },
      addDatabaseParam: false,
      fromJson: (json) => json,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> postComment(
    int updateId, {
    required String body,
    required String userId,
    required String username,
  }) {
    final payload = {
      'user_id': userId,
      'username': username,
      'body': body,
    };
    debugPrint('[postComment] POST public/cbt-updates/$updateId/comments');
    debugPrint('[postComment] body: $payload');
    return _apiService.post<Map<String, dynamic>>(
      endpoint: 'public/cbt-updates/$updateId/comments',
      body: payload,
      addDatabaseParam: false,
      fromJson: (json) => json,
    );
  }
}
