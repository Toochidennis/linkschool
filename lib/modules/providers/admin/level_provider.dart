import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/admin/level_model.dart';
import 'package:linkschool/modules/services/admin/level_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class LevelProvider with ChangeNotifier {
  final LevelService _levelService = locator<LevelService>();
  List<Level> _levels = [];
  bool _isLoading = false;
  String? _error;

  List<Level> get levels => _levels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLevels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First try to load from local storage
      final userBox = Hive.box('userData');
      final localLevels = userBox.get('levels');
      
      if (localLevels != null && localLevels is List) {
        _levels = localLevels.map((level) => Level.fromJson(level)).toList();
      }

      // Then fetch from API
      _levels = await _levelService.fetchLevels();
      
      // Save to local storage
      await userBox.put('levels', _levels.map((level) => level.toJson()).toList());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Level> getLevelDetails(String levelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final level = await _levelService.getLevelDetails(levelId);
      return level;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateLevels(List<Level> newLevels) {
    _levels = newLevels;
    notifyListeners();
  }
}