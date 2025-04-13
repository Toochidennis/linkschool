import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/level_model.dart';
import 'package:linkschool/modules/services/admin/level_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';


class LevelProvider with ChangeNotifier {
  final LevelService _levelService = locator<LevelService>();
  List<Level> _levels = [];
  bool _isLoading = false;
  String _error = '';

  List<Level> get levels => _levels;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchLevels() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _levels = await _levelService.fetchLevels();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}



// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/model/admin/level_model.dart';
// import 'package:linkschool/modules/services/admin/level_service.dart';


// class LevelProvider with ChangeNotifier {
//   final LevelService _levelService = LevelService();
//   List<Level> _levels = [];
//   bool _isLoading = false;

//   List<Level> get levels => _levels;
//   bool get isLoading => _isLoading;

//   Future<void> fetchLevels() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       _levels = await _levelService.fetchLevels();
//     } catch (e) {
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }




// class LevelProvider with ChangeNotifier {
//   List<Level> _levels = [];
//   List<Level> get levels => _levels;

//   Future<void> fetchLevels() async {
//     final LevelService levelService = LevelService();
//     _levels = await levelService.fetchLevels();
//     notifyListeners();
//   }
// }