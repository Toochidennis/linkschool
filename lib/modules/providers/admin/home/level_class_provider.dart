import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/home/level_class_model.dart';
import 'package:linkschool/modules/services/admin/home/level_class_service.dart';

class LevelWithClasses {
  final Levels level;
  final List<Class> classes;

  LevelWithClasses({required this.level, required this.classes});
}

class LevelClassProvider with ChangeNotifier {
  final LevelClassService _levelClassService;

  bool isLoading = false;
  String? message;
  String? error;
  List<LevelWithClasses> levelsWithClasses = [];

  LevelClassProvider(this._levelClassService);

  

  Future<bool> createLevel(Map<String, dynamic> newLevel) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _levelClassService.createLevel(newLevel);
      message = "Level created successfully.";
      await fetchLevels();
      return true;
    } catch (e) {
      error = "Failed to create level: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClass(Map<String, dynamic> newClass) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _levelClassService.createClass(newClass);
      message = "Class created successfully.";
      await fetchLevels();
      return true;
    } catch (e) {
      error = "Failed to create class: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLevel(String levelId, Map<String, dynamic> updatedLevel) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _levelClassService.updateLevel(levelId, updatedLevel);
      message = "Level updated successfully.";
      await fetchLevels();
      return true;
    } catch (e) {
      error = "Failed to update level: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClass(String className, Map<String, dynamic> updatedClass) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _levelClassService.updateClass(className, updatedClass);
      message = "Class updated successfully.";
      await fetchLevels();
      return true;
    } catch (e) {
      error = "Failed to update class: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLevel(String levelId) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _levelClassService.deleteLevel(levelId);
      message = "Level deleted successfully.";
      await fetchLevels();
      return true;
    } catch (e) {
      error = "Failed to delete level: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClass(String className) async {
    isLoading = true;
    notifyListeners();
    error = null;
    message = null;
    try {
      await _levelClassService.deleteClass(className);
      message = "Class deleted successfully.";
      await fetchLevels();
      return true;
    } catch (e) {
      error = "Failed to delete class: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLevels() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final levels = await _levelClassService.fetchLevels();
      final classes = await _levelClassService.fetchClasses();
      levelsWithClasses = levels.map((level) {
        final levelClasses = classes.where((classItem) => classItem.levelId == level.id).toList();
        return LevelWithClasses(level: level, classes: levelClasses);
      }).toList();
      print("Fetched ${levelsWithClasses.length} levels with associated classes");
    } catch (e) {
      error = "Failed to fetch levels and classes: $e";
      print("Error in provider: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}