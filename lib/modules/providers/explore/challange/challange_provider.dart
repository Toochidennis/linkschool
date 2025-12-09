import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/explore/challange/challenge_service.dart';


class ChallengeProvider extends ChangeNotifier {
  final ChallengeService _service = ChallengeService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  dynamic _response;
  dynamic get response => _response;

  /// Create Challenge
  Future<void> createChallenge(Map<String, dynamic> payload) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
       await _service.createChallenge(payload: payload);

    //  _response = result; // If your service returns something
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
