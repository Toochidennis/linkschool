import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/home/dashboard_feed_model.dart';
import 'package:linkschool/modules/services/admin/home/all_feeds.dart';

/// Provider for paginated feeds (all feeds with pagination)
class FeedsPaginationProvider with ChangeNotifier {
  final FeedsPaginationService _feedsPaginationService;
  static const int _pageLimit = 50;

  FeedsPaginationProvider(this._feedsPaginationService);

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _message;
  String? _error;
  final List<Feed> _feeds = [];
  int _currentPage = 1;
  bool _hasNextPage = true;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get message => _message;
  String? get error => _error;
  List<Feed> get feeds => _feeds;
  bool get hasNextPage => _hasNextPage;

  /// Fetch feeds with pagination
  Future<void> fetchFeeds({bool refresh = false}) async {
    if (_isLoading || _isLoadingMore) return;

    if (refresh) {
      _currentPage = 1;
      _feeds.clear();
      _hasNextPage = true;
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }

    _error = null;
    notifyListeners();

    try {
      final response = await _feedsPaginationService.fetchFeeds(
        page: _currentPage,
        limit: _pageLimit,
      );

      if (response.isEmpty) {
        _hasNextPage = false;
      } else {
        _feeds.addAll(response);
        _currentPage++;
      }

      _message = "Feeds loaded successfully";
    } catch (e) {
      _error = "Failed to load feeds: $e";
      debugPrint("Feed fetch error: $e");
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> updateFeed(
      Map<String, dynamic> updatedFeed, String feedId) async {
    _isLoading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      await _feedsPaginationService.updateFeed(feedId, updatedFeed);
      _message = "Feed updated successfully.";

      final index = _feeds.indexWhere((feed) => feed.id.toString() == feedId);
      if (index != -1) {
        _feeds[index] = Feed.fromJson({
          ..._feeds[index].toJson(),
          ...updatedFeed,
        });
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to update feed: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a feed
  Future<bool> deleteFeed(String feedId) async {
    _isLoading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      await _feedsPaginationService.deleteFeed(feedId);
      _feeds.removeWhere((feed) => feed.id.toString() == feedId);
      _message = "Feed deleted successfully.";
      return true;
    } catch (e) {
      _error = "Failed to delete feed: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more when scrolling
  Future<void> loadMore() async {
    if (_isLoadingMore || _isLoading || !_hasNextPage) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _feedsPaginationService.fetchFeeds(
        page: _currentPage,
        limit: _pageLimit,
      );

      if (response.isEmpty) {
        _hasNextPage = false;
      } else {
        _feeds.addAll(response);
        _currentPage++;
      }
    } catch (e) {
      _error = "Failed to load feeds: $e";
      debugPrint("Feed load more error: $e");
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void reset() {
    _feeds.clear();
    _currentPage = 1;
    _hasNextPage = true;
    _error = null;
    _message = null;
    notifyListeners();
  }
}
