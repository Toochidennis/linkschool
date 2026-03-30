import 'dart:io';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/challange_leader_model.dart';
import 'package:linkschool/modules/services/explore/challange/challange_leader_service.dart';
import 'package:uuid/uuid.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _service;

  List<LeaderboardEntry> leaderboard = [];
  bool loading = false;
  bool submitting = false;
  String? error;
  Map<String, dynamic>? submitResponse;

  LeaderboardProvider(this._service);

  /// Submit challenge result and then load leaderboard
  Future<bool> submitChallengeResult({
    required int challengeId,
    required int userId,
    required String username,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int timeTaken,
  }) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      final resolvedUsername = username.trim().isNotEmpty ? username.trim() : 'User';

      // Generate device ID and platform
      final deviceId = const Uuid().v4();
      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : 'web';


      submitResponse = await _service.submitChallengeResult(
        challengeId: challengeId,
        userId: userId,
        username: resolvedUsername,
        score: score,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        timeTaken: timeTaken,
        deviceId: deviceId,
        platform: platform,
      );


      submitting = false;
      notifyListeners();

      return true;
    } catch (e) {
      error = e.toString();
      submitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Load leaderboard for a specific challenge
  Future<void> loadLeaderboard(int challengeId) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.fetchLeaderboard(challengeId);
      leaderboard = response.data;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}

