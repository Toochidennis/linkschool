import 'package:flutter/foundation.dart';

import '../../model/explore/home/subject_model2.dart';
import '../../model/explore/home/level_model.dart';
import '../../model/explore/videos/dashboard_video_model.dart';
import '../../services/explore/subject_service.dart';

class SubjectProvider with ChangeNotifier {
  final SubjectService _subjectService = SubjectService();
  List<SubjectModel2> _subjects = [];
  List<LevelModel> _levels = [];
  DashboardDataModel? _dashboardData;
  bool _isLoading = false;
  bool _isLoadingLevels = false;
  bool _isLoadingDashboard = false;

  List<SubjectModel2> get subjects => _subjects;
  List<LevelModel> get levels => _levels;
  DashboardDataModel? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  bool get isLoadingLevels => _isLoadingLevels;
  bool get isLoadingDashboard => _isLoadingDashboard;

  Future<void> fetchSubjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      _subjects = await _subjectService.getAllSubjects();
    } catch (error) {
      print('Error fetching subjects: $error');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLevels() async {
    _isLoadingLevels = true;
    notifyListeners();

    try {
      _levels = await _subjectService.getAllLevels();
    } catch (error) {
      print('Error fetching levels: $error');
    }

    _isLoadingLevels = false;
    notifyListeners();
  }

  Future<void> fetchDashboardData(int levelId) async {
    _isLoadingDashboard = true;
    notifyListeners();

    try {
      final response = await _subjectService.getDashboardData(levelId);
      _dashboardData = response.data;
    } catch (error) {
      print('Error fetching dashboard data: $error');
      _dashboardData = null;
    }

    _isLoadingDashboard = false;
    notifyListeners();
  }
}
