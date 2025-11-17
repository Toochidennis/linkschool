import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/home/student_metrics.dart';
import 'package:linkschool/modules/services/admin/home/student_metrics.dart';


class StudentMetricsProvider extends ChangeNotifier {
  final StudentMetricsService _metricsService;

  StudentMetricsProvider({required StudentMetricsService metricsService})
      : _metricsService = metricsService;

  StudentStatsResponse? metrics;
  bool isLoading = false;
  String? errorMessage;

  /// Fetch metrics from API
  Future<void> loadMetrics() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      metrics = await _metricsService.fetchMetrics();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  /// Refresh
  Future<void> refreshMetrics() async {
    await loadMetrics();
  }

  /// Helpers to make UI code cleaner
  int get totalStudents => metrics?.response.totalStudents ?? 0;
  int get maleStudents => metrics?.response.maleStudents ?? 0;
  int get femaleStudents => metrics?.response.femaleStudents ?? 0;

  List<ChartData> get charts => metrics?.response.charts ?? [];
  List<LevelModel> get levels => metrics?.response.levels ?? [];
}
