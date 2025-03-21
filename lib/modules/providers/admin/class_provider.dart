import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/class_model.dart';
import 'package:linkschool/modules/services/admin/class_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class ClassProvider with ChangeNotifier {
  final ClassService _classService = locator<ClassService>();
  List<Class> _classes = [];
  bool _isLoading = false;
  String _error = '';

  List<Class> get classes => _classes;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchClasses(String levelId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _classes = await _classService.fetchClasses(levelId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/model/admin/class_model.dart';
// import 'package:linkschool/modules/services/admin/class_service.dart';


// class ClassProvider with ChangeNotifier {
//   List<Class> _classes = [];
//   List<Class> get classes => _classes;

//   Future<void> fetchClasses(String levelId) async {
//     final ClassService classService = ClassService();
//     _classes = await classService.fetchClasses(levelId);
//     notifyListeners();
//   }
// }