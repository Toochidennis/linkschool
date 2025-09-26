import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/e-learning/comment_model.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class AdminCommentService {
 final ApiService _apiService;
 AdminCommentService(this._apiService);

 Future<Map<String, dynamic>> getComments({
    required String contentId,
    required int page,
    int limit = 10,
    String db = 'aalmgzmy_linkskoo_practice',
  }) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint: 'portal/elearning/$contentId/comments',
        queryParams: {
          '_db': db,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

     if(response.statusCode == 200) {
         final data = response.rawData?['response']['data'] as List<dynamic> ?? [];
      final meta = response.rawData?['response']['meta'] as Map<String, dynamic>;
      if (data.isNotEmpty) {
        print("Comments fetched successfully: ${data.length} comments found.");
        print("Meta data: $meta");
       return {
        'comments': data.map((json) => Comment.fromJson(json)).toList(),
        'meta': meta,
      };}
      
      }

   throw Exception("Failed to Fetch Comments: ${response.message}");
    } catch (e) {
      print("Error fetching comments: $e");
      throw Exception("Failed to Fetch Comments: $e");
    }
  }

  Future<void> CreateComments(Map<String, dynamic> commentData,String contentId) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
  
    _apiService.setAuthToken(token);

    commentData['_db'] = dbName;
    print("Request Payload: $commentData");

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint: 'portal/elearning/$contentId/comments',
        body: commentData,
      );

      print("Response Status Code: ${response.statusCode}");

      if (!response.success) {
        print("Failed to create comment");

        print("Error: ${response.message ?? 'No error message provided'}");
        SnackBar(
          content: Text("${response.message}"),
          backgroundColor: Colors.red,
        );
        throw Exception("Failed to Create Comment: ${response.message}");
      } else {
        print('Comment created successfully.');
        print('Status Code: ${response.statusCode}');
        SnackBar(
          content: Text('Comment created successfully.'),
          backgroundColor: Colors.green,
        );
        print('${response.message}');
      }
    } catch (e) {
      print("Error creating comment: $e");
      throw Exception("Failed to Create Comment: $e");
    }

  }

  Future<void> updateComment(Map<String, dynamic> UpdatedComment,String id) async {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
    _apiService.setAuthToken(token);

 UpdatedComment['_db'] = dbName;
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint: 'portal/elearning/comments/$id',
        body: UpdatedComment,
      );

      if (response.success) {
        print('Comment updated successfully.');
      } else {
        print('Failed to update comment: ${response.message}');
        throw Exception("Failed to Update Comment: ${response.message}");
      }
    } catch (e) {
      print("Error updating comment: $e");
      throw Exception("Failed to Update Comment: $e");
    }
  }


  Future<void> deleteComment(String commentId) async {
     final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    final dbName = userBox.get('_db') ?? 'aalmgzmy_linkskoo_practice';
    if (loginData == null || loginData['token'] == null) {
      throw Exception("No valid login data or token found");
    }

    final token = loginData['token'] as String;
  
    _apiService.setAuthToken(token);


     try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint: 'portal/elearning/comments/$commentId',
       body: {
        "_db":dbName,
       }
      );

      if (response.success) {
        print('Comment Deleted successfully.');
      } else {
        print('Failed to delete comment: ${response.message}');
        throw Exception("Failed to delete Comment: ${response.message}");
      }
    } catch (e) {
      print("Error delete comment: $e");
      throw Exception("Failed to delete Comment: $e");
    }
  }
}