import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/staff/overview_model.dart';
import 'package:linkschool/modules/services/staff/overview_service.dart';

class StaffOverviewProvider with ChangeNotifier {
  final StaffOverviewService _staffOverviewService;

  StaffOverviewProvider(this._staffOverviewService);

  List<ActivityItem> _recentQuizzes = [];
  List<ActivityItem> _recentActivities = [];
  List<CourseGroup> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ActivityItem> get recentQuizzes => _recentQuizzes;
  List<ActivityItem> get recentActivities => _recentActivities;
  List<CourseGroup> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOverview(String term, String year ,String staffId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dashboardResponse = await _staffOverviewService.getOverview(term, year,staffId);
      final data = dashboardResponse.data;

      _recentQuizzes = data.recentQuizzes;
      _recentActivities = data.recentActivities;
      _courses = data.courses;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _recentQuizzes.clear();
    _recentActivities.clear();
    _courses.clear();
    _errorMessage = null;
    notifyListeners();
  }
}