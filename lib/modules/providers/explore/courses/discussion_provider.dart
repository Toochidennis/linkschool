import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/cohorts/discussion_model.dart';
import 'package:linkschool/modules/services/explore/courses/discussion_service.dart';

class DiscussionProvider extends ChangeNotifier {
  final DiscussionService _service;

  List<DiscussionItem> _discussions = [];
  DiscussionMeta? _meta;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _currentCohortId;
  int _currentPage = 1;

  DiscussionItem? _activeDiscussion;
  List<DiscussionPost> _posts = [];
  DiscussionMeta? _postsMeta;
  bool _isDetailLoading = false;
  bool _isDetailLoadingMore = false;
  String? _detailError;
  String? _currentDiscussionId;
  int _currentPostPage = 1;
  int? _currentAuthorId;

  DiscussionPost? _activePost;
  List<DiscussionPost> _postReplies = [];
  DiscussionMeta? _postRepliesMeta;
  bool _isPostRepliesLoading = false;
  bool _isPostRepliesLoadingMore = false;
  String? _postRepliesError;
  String? _currentPostId;
  int _currentPostRepliesPage = 1;
  int? _currentPostAuthorId;

  DiscussionProvider(this._service);

  List<DiscussionItem> get discussions => List.unmodifiable(_discussions);
  DiscussionMeta? get meta => _meta;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;

  DiscussionItem? get activeDiscussion => _activeDiscussion;
  List<DiscussionPost> get posts => List.unmodifiable(_posts);
  DiscussionMeta? get postsMeta => _postsMeta;
  bool get isDetailLoading => _isDetailLoading;
  bool get isDetailLoadingMore => _isDetailLoadingMore;
  String? get detailError => _detailError;

  DiscussionPost? get activePost => _activePost;
  List<DiscussionPost> get postReplies => List.unmodifiable(_postReplies);
  DiscussionMeta? get postRepliesMeta => _postRepliesMeta;
  bool get isPostRepliesLoading => _isPostRepliesLoading;
  bool get isPostRepliesLoadingMore => _isPostRepliesLoadingMore;
  String? get postRepliesError => _postRepliesError;

  Future<void> loadDiscussions({
    required String cohortId,
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    _currentCohortId = cohortId;
    _currentPage = 1;

    try {
      final response = await _service.fetchDiscussions(
        cohortId: cohortId,
        page: _currentPage,
      );

      if (response.success) {
        _discussions = response.data?.items ?? [];
        _meta = response.data?.meta;
        _error = null;
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : "Failed to load discussions";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    final cohortId = _currentCohortId;
    if (cohortId == null) return;
    if (_meta?.hasNext != true) return;
    if (_isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _service.fetchDiscussions(
        cohortId: cohortId,
        page: nextPage,
      );

      if (response.success) {
        final items = response.data?.items ?? [];
        _discussions = [..._discussions, ...items];
        _meta = response.data?.meta;
        _currentPage = nextPage;
        _error = null;
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : "Failed to load discussions";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> createDiscussion({
    required String cohortId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _service.createDiscussion(
        cohortId: cohortId,
        payload: payload,
      );

      if (!response.success) {
        _error = response.message.isNotEmpty
            ? response.message
            : "Failed to create discussion";
        notifyListeners();
        return false;
      }

      await loadDiscussions(cohortId: cohortId, silent: true);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDiscussion({
    required String cohortId,
    required String discussionId,
    required int authorId,
  }) async {
    try {
      final ok = await _service.deleteDiscussion(
        cohortId: cohortId,
        discussionId: discussionId,
        authorId: authorId,
      );
      if (ok) {
        await loadDiscussions(cohortId: cohortId, silent: true);
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDiscussion({
    required String cohortId,
    required String discussionId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final ok = await _service.updateDiscussion(
        cohortId: cohortId,
        discussionId: discussionId,
        payload: payload,
      );
      if (ok) {
        await loadDiscussions(cohortId: cohortId, silent: true);
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost({
    required String cohortId,
    required String postId,
    required int authorId,
  }) async {
    try {
      final ok = await _service.deletePost(
        cohortId: cohortId,
        postId: postId,
        authorId: authorId,
      );
      if (ok) {
      
        await loadDiscussionDetail(
          discussionId: _currentDiscussionId ?? '',
          silent: true,
          authorId: _currentAuthorId,
        );
        if (_currentPostId != null) {
          await loadPostReplies(
            postId: _currentPostId!,
            silent: true,
            authorId: _currentPostAuthorId,
          );
        }
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePost({
    required String cohortId,
    required String discussionId,
    required String postId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final ok = await _service.updatePost(
        cohortId: cohortId,
        discussionId: discussionId,
        postId: postId,
        payload: payload,
      );
      if (ok) {
        await loadDiscussionDetail(
          discussionId: discussionId,
          silent: true,
          authorId: _currentAuthorId,
        );
        if (_currentPostId != null) {
          await loadPostReplies(
            postId: _currentPostId!,
            silent: true,
            authorId: _currentPostAuthorId,
          );
        }
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createDiscussionPost({
    required String cohortId,
    required String discussionId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final ok = await _service.createDiscussionPost(
        cohortId: cohortId,
        discussionId: discussionId,
        payload: payload,
      );
      if (ok) {
        await loadDiscussionDetail(
          discussionId: discussionId,
          silent: true,
        );
      }
      return ok;
    } catch (e) {
      _detailError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPostReply({
    required String cohortId,
    required String discussionId,
    required String postId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final ok = await _service.createDiscussionPost(
        cohortId: cohortId,
        discussionId: discussionId,
        payload: payload,
      );
      if (ok) {
        await loadPostReplies(postId: postId, silent: true);
      }
      return ok;
    } catch (e) {
      _postRepliesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadDiscussionDetail({
    required String discussionId,
    bool silent = false,
    int? authorId,
  }) async {
    if (!silent) {
      _isDetailLoading = true;
      _detailError = null;
      notifyListeners();
    }

    _currentDiscussionId = discussionId;
    _currentPostPage = 1;
    _currentAuthorId = authorId;

    try {
      final response = await _service.fetchDiscussionDetail(
        discussionId: discussionId,
        page: _currentPostPage,
        authorId: authorId,
      );

      if (response.success) {
        _activeDiscussion = response.data?.discussion;
        _posts = response.data?.posts ?? [];
        _postsMeta = response.data?.meta;
        _detailError = null;
      } else {
        _detailError = response.message.isNotEmpty
            ? response.message
            : "Failed to load discussion";
      }
    } catch (e) {
      _detailError = e.toString();
    }

    _isDetailLoading = false;
    notifyListeners();
  }

  Future<void> loadMorePosts() async {
    final discussionId = _currentDiscussionId;
    if (discussionId == null) return;
    if (_postsMeta?.hasNext != true) return;
    if (_isDetailLoadingMore) return;

    _isDetailLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPostPage + 1;
      final response = await _service.fetchDiscussionDetail(
        discussionId: discussionId,
        page: nextPage,
        authorId: _currentAuthorId,
      );

      if (response.success) {
        final items = response.data?.posts ?? [];
        _posts = [..._posts, ...items];
        _postsMeta = response.data?.meta;
        _currentPostPage = nextPage;
        _detailError = null;
      } else {
        _detailError = response.message.isNotEmpty
            ? response.message
            : "Failed to load discussion";
      }
    } catch (e) {
      _detailError = e.toString();
    }

    _isDetailLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadPostReplies({
    required String postId,
    bool silent = false,
    int? authorId,
  }) async {
    if (!silent) {
      _isPostRepliesLoading = true;
      _postRepliesError = null;
      notifyListeners();
    }

    _currentPostId = postId;
    _currentPostRepliesPage = 1;
    _currentPostAuthorId = authorId;

    try {
      final response = await _service.fetchPostReplies(
        postId: postId,
        page: _currentPostRepliesPage,
        authorId: authorId,
      );

      if (response.success) {
        _activePost = response.data?.post;
        _postReplies = response.data?.replies ?? [];
        _postRepliesMeta = response.data?.meta;
        _postRepliesError = null;
      } else {
        _postRepliesError = response.message.isNotEmpty
            ? response.message
            : "Failed to load replies";
      }
    } catch (e) {
      _postRepliesError = e.toString();
    }

    _isPostRepliesLoading = false;
    notifyListeners();
  }

  Future<void> loadMorePostReplies() async {
    final postId = _currentPostId;
    if (postId == null) return;
    if (_postRepliesMeta?.hasNext != true) return;
    if (_isPostRepliesLoadingMore) return;

    _isPostRepliesLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPostRepliesPage + 1;
      final response = await _service.fetchPostReplies(
        postId: postId,
        page: nextPage,
        authorId: _currentPostAuthorId,
      );

      if (response.success) {
        final items = response.data?.replies ?? [];
        _postReplies = [..._postReplies, ...items];
        _postRepliesMeta = response.data?.meta;
        _currentPostRepliesPage = nextPage;
        _postRepliesError = null;
      } else {
        _postRepliesError = response.message.isNotEmpty
            ? response.message
            : "Failed to load replies";
      }
    } catch (e) {
      _postRepliesError = e.toString();
    }

    _isPostRepliesLoadingMore = false;
    notifyListeners();
  }

  List<DiscussionPost> get postTree {
    return _buildPostTree(_posts);
  }

  DiscussionPost? getPostById(int postId) {
    for (final post in _posts) {
      if (post.id == postId) return post;
    }
    return null;
  }

  List<DiscussionPost> getRepliesForPost(int postId) {
    return _buildPostTree(_posts, parentId: postId);
  }

  Future<void> togglePostLike({
    required String cohortId,
    required int postId,
    required int authorId,
    required bool isLiked,
  }) async {
    bool updated = false;

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final nextLiked = !isLiked;
      final nextCount = nextLiked ? post.likesCount + 1 : post.likesCount - 1;
      _posts[index] = post.copyWith(
        isLiked: nextLiked,
        likesCount: nextCount < 0 ? 0 : nextCount,
      );
      updated = true;
    }

    final repliesIndex =
        _postReplies.indexWhere((post) => post.id == postId);
    if (repliesIndex != -1) {
      final post = _postReplies[repliesIndex];
      final nextLiked = !isLiked;
      final nextCount = nextLiked ? post.likesCount + 1 : post.likesCount - 1;
      _postReplies[repliesIndex] = post.copyWith(
        isLiked: nextLiked,
        likesCount: nextCount < 0 ? 0 : nextCount,
      );
      updated = true;
    }

    if (_activePost?.id == postId) {
      final post = _activePost!;
      final nextLiked = !isLiked;
      final nextCount = nextLiked ? post.likesCount + 1 : post.likesCount - 1;
      _activePost = post.copyWith(
        isLiked: nextLiked,
        likesCount: nextCount < 0 ? 0 : nextCount,
      );
      updated = true;
    }

    if (updated) {
      notifyListeners();
    }

    try {
      await _service.togglePostLike(
        cohortId: cohortId,
        postId: postId.toString(),
        authorId: authorId,
        unlike: isLiked,
      );
    } catch (_) {
      // Silent fail: UI already updated optimistically.
    }
  }

  void addLocalPost({
    required int discussionId,
    required String message,
    int? parentPostId,
    String? imagePath,
  }) {
    final trimmed = message.trim();
    if (trimmed.isEmpty && (imagePath == null || imagePath.isEmpty)) return;

    final newPost = DiscussionPost(
      id: DateTime.now().microsecondsSinceEpoch,
      parentPostId: parentPostId,
      discussionId: discussionId,
      authorId: 0,
      author: DiscussionAuthor(
        firstName: 'You',
        lastName: '',
        fullName: 'You',
      ),
      body: trimmed,
      images: imagePath == null || imagePath.isEmpty
          ? []
          : [
              DiscussionImage(
                fileName: imagePath.startsWith('file://')
                    ? imagePath
                    : 'file://$imagePath',
                oldFileName: imagePath,
                file: '',
                type: 'image',
              ),
            ],
      depth: parentPostId == null ? 0 : 1,
      replyCount: 0,
      likesCount: 0,
      isLiked: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    _posts = [newPost, ..._posts];
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_currentCohortId != null) {
      await loadDiscussions(cohortId: _currentCohortId!, silent: false);
    }
  }

  Future<void> refreshDetail() async {
    if (_currentDiscussionId != null) {
      await loadDiscussionDetail(
        discussionId: _currentDiscussionId!,
        silent: false,
        authorId: _currentAuthorId,
      );
    }
  }

  Future<void> refreshPostReplies() async {
    if (_currentPostId != null) {
      await loadPostReplies(
        postId: _currentPostId!,
        silent: false,
        authorId: _currentPostAuthorId,
      );
    }
  }

  void clear() {
    _discussions = [];
    _meta = null;
    _error = null;
    _currentCohortId = null;
    _currentPage = 1;

    _activeDiscussion = null;
    _posts = [];
    _postsMeta = null;
    _detailError = null;
    _currentDiscussionId = null;
    _currentPostPage = 1;
    _currentAuthorId = null;

    _activePost = null;
    _postReplies = [];
    _postRepliesMeta = null;
    _postRepliesError = null;
    _currentPostId = null;
    _currentPostRepliesPage = 1;
    _currentPostAuthorId = null;
    notifyListeners();
  }

  List<DiscussionPost> _buildPostTree(
    List<DiscussionPost> posts, {
    int? parentId,
  }) {
    final Map<int, DiscussionPost> byId = {};
    for (final post in posts) {
      byId[post.id] = post.copyWith(replies: []);
    }

    byId.forEach((id, post) {
      final parent = post.parentPostId;
      if (parent == null) return;
      if (parentId != null && parent != parentId) return;

      final parentPost = byId[parent];
      if (parentPost != null) {
        final updatedParent =
            parentPost.copyWith(replies: [...parentPost.replies, post]);
        byId[parent] = updatedParent;
      }
    });

    if (parentId != null) {
      return byId[parentId]?.replies ?? [];
    }

    final List<DiscussionPost> roots = [];
    for (final post in byId.values) {
      if (post.parentPostId == null) {
        roots.add(post);
      }
    }
    return roots;
  }
}
