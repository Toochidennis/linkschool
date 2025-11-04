import 'package:linkschool/modules/services/admin/e_learning/marking_service.dart';
import 'package:flutter/material.dart';

class MarkAssignmentProvider extends ChangeNotifier {
  final MarkingService _markingService;

  MarkAssignmentProvider(this._markingService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Assignment data
  Map<String, dynamic>? _assignmentData;
  Map<String, dynamic>? get assignmentData => _assignmentData;

  // Quiz data
  Map<String, dynamic>? _quizData;
  Map<String, dynamic>? get quizData => _quizData;

  String? _error;
  String? get error => _error;

  // ---------------- ASSIGNMENTS ----------------
  Future<void> fetchAssignment(String itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _markingService.getAssignment(itemId);
      _assignmentData = data;
    } catch (e) {
      _error = e.toString();
      _assignmentData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _assignmentData = null;
    _quizData = null;
    _error = null;
    notifyListeners();
  }

  Future<void> markAssignment(String itemId, String score) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _markingService.markAssignment(itemId, score);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> returnAssignment(String publish, String contentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _markingService.returnAssignment(publish, contentId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- QUIZZES ----------------
  Future<void> fetchQuiz(String itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _markingService.getQuiz(itemId);
      _quizData = {
        'submitted': data['submitted'] ?? [],
        'unmarked': data['unmarked'] ?? [],
        'marked': data['marked'] ?? [],
      };
    } catch (e) {
      _error = e.toString();
      _quizData = {
        'submitted': [],
        'unmarked': [],
        'marked': [],
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markQuiz(String itemId, String score) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _markingService.markQuiz(itemId, score);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> returnQuiz(String publish, String contentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _markingService.returnQuiz(publish, contentId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// import 'package:linkschool/modules/services/admin/e_learning/marking_service.dart';
// import 'package:flutter/material.dart';

// class MarkAssignmentProvider extends ChangeNotifier {
//   final MarkingService _markingService;

//   MarkAssignmentProvider(this._markingService);

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Map<String, dynamic>? _assignmentData;
//   Map<String, dynamic>? get assignmentData => _assignmentData;

//   String? _error;
//   String? get error => _error;

//   Future<void> fetchAssignment(String itemId) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final data = await _markingService.getAssignment(itemId);
//       _assignmentData = data;
//     } catch (e) {
//       _error = e.toString();
//       _assignmentData = null;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void clear() {
//     _assignmentData = null;
//     _error = null;
//     notifyListeners();
//   }

//   Future<void> markAssignment(String itemId, String score) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await _markingService.markAssignment(itemId, score);
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> returnAssignment(String publish, String contentId) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await _markingService.returnAssignment(publish,contentId);
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> fetchQuiz(String itemId) async {
//   _isLoading = true;
//   _error = null;
//   notifyListeners();

//   try {
//     // call your service
//     final data = await _markingService.getQuiz(itemId);

//     // update local state with the response from service
//     _quizData = {
//       'submitted': data['submitted'] ?? [],
//       'unmarked': data['unmarked'] ?? [],
//       'marked': data['marked'] ?? [],
//     };
//   } catch (e) {
//     _error = e.toString();
//     _quizData = {
//       'submitted': [],
//       'unmarked': [],
//       'marked': [],
//     };
//   } finally {
//     _isLoading = false;
//     notifyListeners();
//   }
// }

// }
