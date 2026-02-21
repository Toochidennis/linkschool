import 'package:flutter/foundation.dart';
import '../../services/explore/lesson_attendance_service.dart';

class LessonAttendanceProvider with ChangeNotifier {
  final LessonAttendanceService _service = LessonAttendanceService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastResponse => _lastResponse;

  Future<bool> submitAttendance({
    required int lessonId,
    required Map<String, dynamic> payload,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.submitAttendance(
        lessonId: lessonId,
        payload: payload,
      );
      _lastResponse = response;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _lastResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
