import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/e-learning/comment_model.dart';
import 'package:linkschool/modules/services/admin/e_learning/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _commentService;
  List<Comment> comments = [];

  bool isLoading = false;
  String? message;
  String? error;

  int currentPage = 1;
  bool hasNext = true;
  int limit = 10;
  CommentProvider(this._commentService);

  Future<void> fetchComments(String contentId, {bool loadMore = false}) async {
    if (!hasNext && loadMore) return;

    if (!loadMore) {
      currentPage = 1;
      comments.clear();
    }

    isLoading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      final result = await _commentService.getComments(
        contentId: contentId,
        page: currentPage,
        limit: limit,
      );
      final newComments = result['comments'] as List<Comment>;
      final meta = result['meta'] as Map<String, dynamic>;

      comments.addAll(newComments);
      currentPage = meta['current_page'] + 1;
      hasNext = meta['has_next'] ?? false;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createComment(
      Map<String, dynamic> commentData, String contentId) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _commentService.CreateComments(commentData, contentId);
      message = "Comment created successfully.";
      return true;
    } catch (e) {
      error = "Failed to create comment: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> UpdateComment(
      Map<String, dynamic> commentData, String contentId) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _commentService.updateComment(commentData, contentId);
      message = "Comment updated successfully.";
      return true;
    } catch (e) {
      error = "Failed to update comment: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> DeleteComment(String commentId) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _commentService.deleteComment(commentId);
      comments.removeWhere((c) => c.id.toString() == commentId);
      message = "Comment updated successfully.";
      return true;
    } catch (e) {
      error = "Failed to update comment: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
