import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/class_model.dart';
import 'package:linkschool/modules/services/admin/class_service.dart';


class ClassProvider with ChangeNotifier {
  List<Class> _classes = [];
  List<Class> get classes => _classes;

  Future<void> fetchClasses(String levelId) async {
    final ClassService classService = ClassService();
    _classes = await classService.fetchClasses(levelId);
    notifyListeners();
  }
}