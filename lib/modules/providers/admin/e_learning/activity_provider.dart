import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/e-learning/activity_model.dart';
import 'package:linkschool/modules/services/admin/e_learning/activity_service.dart';


class OverviewProvider with ChangeNotifier {
  final OverviewService _overviewService;

  OverviewProvider(this._overviewService);

  List<RecentQuizModel> _recentQuizzes = [];
  List<RecentActivityModel> _recentActivities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RecentQuizModel> get recentQuizzes => _recentQuizzes;
  List<RecentActivityModel> get recentActivities => _recentActivities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOverview(String term) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _overviewService.getOverview(term);
      _recentQuizzes = data['recent_quizzes'] ?? [];
      _recentActivities = data['recent_activities'] ?? [];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
