import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/staff/dashboard_model.dart';

import 'package:linkschool/modules/services/staff/staff_dashboard_service.dart';

class StaffDashboardProvider with ChangeNotifier {
  final StaffDashboardService _staffDashboardService;

  StaffDashboardProvider(this._staffDashboardService) {
    debugPrint("✅ StaffDashboardProvider initialized");
  }

  bool _isLoading = false;
  String? _message;
  String? _error;

  // New model data
  List<RecentActivity> _recentActivities = [];
  List<StafFeed> _newsFeeds = [];
  List<StafFeed> _questionFeeds = [];
  List<FormClass> _formClasses = [];
  List<AssignedCourse> _assignedCourses = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get message => _message;
  String? get error => _error;
  List<RecentActivity> get recentActivities => _recentActivities;
  List<StafFeed> get newsFeeds => _newsFeeds;
  List<StafFeed> get questionFeeds => _questionFeeds;
  List<FormClass> get formClasses => _formClasses;
  List<AssignedCourse> get assignedCourses => _assignedCourses;

  /// Fetch full dashboard data
  Future<void> fetchDashboardData({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _staffDashboardService.fetchDashboardData();
      final data = result.data;

      if (data != null) {
        _recentActivities = data.recentActivities ?? [];
        _formClasses = data.formClasses ?? [];
        _assignedCourses = data.assignedCourses ?? [];
        _newsFeeds = data.feeds?.news ?? [];
        _questionFeeds = data.feeds?.questions ?? [];
        _message = "Dashboard loaded successfully";
      }
    } catch (e) {
      _error = "Failed to load dashboard: $e";
      debugPrint("❌ Dashboard fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new feed (news/question)
  Future<bool> createFeed(Map<String, dynamic> newFeed) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _staffDashboardService.createFeed(newFeed);
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

  /// Add a reply to an existing feed
  Future<bool> addReply(int parentId, Map<String, dynamic> replyData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _staffDashboardService.createFeed({
        ...replyData,
        'parent_id': parentId,
      });

      // Try to find and attach the reply locally
      for (var feedList in [_newsFeeds, _questionFeeds]) {
        final parentIndex = feedList.indexWhere((f) => f.id == parentId);
        if (parentIndex != -1) {
          feedList[parentIndex].replies.add(StafFeed.fromJson(replyData));
          break;
        }
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

  /// Update feed content
  Future<bool> updateFeed(
      String feedId, Map<String, dynamic> updatedFeed) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _staffDashboardService.updateFeed(feedId, updatedFeed);
      _message = "Feed updated successfully.";
      await fetchDashboardData(refresh: true);
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
    notifyListeners();

    try {
      await _staffDashboardService.deleteFeed(feedId);
      _newsFeeds.removeWhere((f) => f.id.toString() == feedId);
      _questionFeeds.removeWhere((f) => f.id.toString() == feedId);
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

  /// Reset provider state
  void resetData() {
    _recentActivities.clear();
    _formClasses.clear();
    _assignedCourses.clear();
    _newsFeeds.clear();
    _questionFeeds.clear();
    _error = null;
    _message = null;
    notifyListeners();
  }
}
