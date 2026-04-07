import 'package:flutter/foundation.dart';
import '../../services/explore/lesson_detail_service.dart';
import '../../model/explore/courses/lesson_detail_model.dart';

class LessonDetailProvider with ChangeNotifier {
  final LessonDetailService _service = LessonDetailService();

  bool _isLoading = false;
  String? _errorMessage;
  LessonDetailData? _lessonDetailData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LessonDetailData? get lessonDetailData => _lessonDetailData;

  Future<bool> fetchLessonDetail({
    required int lessonId,
    required int profileId,
  }) async {

    _isLoading = true;
    _errorMessage = null;
    _lessonDetailData = null;
    notifyListeners();

    try {
      final response = await _service.fetchLessonDetail(
        lessonId: lessonId,
        profileId: profileId,
      );

      _lessonDetailData = response.data;
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

  void clearData() {
    _lessonDetailData = null;
    _errorMessage = null;
    notifyListeners();
  }
}
