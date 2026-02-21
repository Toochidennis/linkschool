import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/cbt_plan_model.dart';
import 'package:linkschool/modules/services/cbt_plan_service.dart';

class CbtPlanProvider extends ChangeNotifier {
  final CbtPlanService _service = CbtPlanService();
  bool _isLoading = false;
  String? _errorMessage;
  List<CbtPlanModel> _plans = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CbtPlanModel> get plans => _plans;

  Future<void> fetchPlans({bool force = false}) async {
    if (_isLoading) return;
    if (_plans.isNotEmpty && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plans = await _service.fetchPlans();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
