import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/courses/course_leaderboard_model.dart';
import 'package:linkschool/modules/services/explore/courses/leaderboard_service.dart';

class CourseLeaderboardProvider extends ChangeNotifier {
  final CourseLeaderboardService _service;

  CourseLeaderboardData? _leaderboardData;
  bool _isLoading = false;
  String? _error;
  String? _currentCohortId;
  int? _currentProfileId;

  CourseLeaderboardProvider(this._service);

  CourseLeaderboardData? get leaderboardData => _leaderboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LeaderboardEntry> get leaderboard =>
      _leaderboardData?.leaderboard ?? const <LeaderboardEntry>[];
  int? get profilePosition => _leaderboardData?.profilePosition;

  Future<void> loadLeaderboard({
    required String cohortId,
    required int profileId,
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    _currentCohortId = cohortId;
    _currentProfileId = profileId;

    try {
      final response = await _service.fetchLeaderboard(
        cohortId: cohortId,
        profileId: profileId,
      );

      if (response.success) {
        _leaderboardData = response.data;
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_currentCohortId == null || _currentProfileId == null) return;

    await loadLeaderboard(
      cohortId: _currentCohortId!,
      profileId: _currentProfileId!,
      silent: false,
    );
  }

  void clear() {
    _leaderboardData = null;
    _isLoading = false;
    _error = null;
    _currentCohortId = null;
    _currentProfileId = null;
    notifyListeners();
  }
}
  