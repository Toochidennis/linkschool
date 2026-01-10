import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/home/dashboard_feed_service.dart';
import 'package:linkschool/modules/model/admin/home/dashboard_feed_model.dart';

/// Provider for dashboard data (overview + feeds)
class DashboardFeedProvider with ChangeNotifier {
  final DashboardFeedService _dashboardFeedService;

  DashboardFeedProvider(this._dashboardFeedService) {
    debugPrint("✅ DashboardFeedProvider created");
  }

  bool _isLoading = false;
  String? _message;
  String? _error;
  SchoolOverview? _overview;
  List<Feed> _feeds = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get message => _message;
  String? get error => _error;
  SchoolOverview? get overview => _overview;
  List<Feed> get feeds => _feeds;

  /// Fetch dashboard data (overview + feeds)
  Future<void> fetchDashboardData({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dashboardData = await _dashboardFeedService.fetchDashboardData();
      _overview = dashboardData.overview;
      _feeds = dashboardData.feeds;
      _message = "Dashboard data loaded successfully";
    } catch (e) {
      _error = "Failed to load dashboard data: $e";
      debugPrint("Dashboard fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new feed
  Future<bool> createFeed(Map<String, dynamic> newFeed) async {
    _isLoading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      await _dashboardFeedService.createFeed(newFeed);
      _message = "Feed created successfully.";
      await fetchDashboardData(refresh: true);
      return true;
    } catch (e) {
      _error = "Failed to create feed: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a feed
  Future<bool> updateFeed(
      Map<String, dynamic> updatedFeed, String feedId) async {
    _isLoading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      await _dashboardFeedService.updateFeed(feedId, updatedFeed);
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
      await _dashboardFeedService.deleteFeed(feedId);
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

  /// Add a reply to a feed
  Future<bool> addReply(int parentId, Map<String, dynamic> replyData) async {
    _isLoading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      await _dashboardFeedService.createFeed({
        ...replyData,
        'parent_id': parentId,
      });

      final parentIndex = _feeds.indexWhere((feed) => feed.id == parentId);
      if (parentIndex != -1) {
        final replyFeed = Feed.fromJson(replyData);
        _feeds[parentIndex].replies.add(replyFeed);
      }

      _message = "Reply added successfully.";
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to add reply: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetData() {
    _feeds.clear();
    _overview = null;
    _error = null;
    _message = null;
    notifyListeners();
  }
}
