import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/e-learning/syllabus_model.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_service.dart';

class SyllabusProvider with ChangeNotifier {
  final SyllabusService _syllabusService;
  List<SyllabusModel> _syllabusList = [];
  bool _isLoading = false;
  String _error = '';

  SyllabusProvider(this._syllabusService);

  List<SyllabusModel> get syllabusList => _syllabusList;
  bool get isLoading => _isLoading;
  String get error => _error;

 Future<void> fetchSyllabus(String levelId, String term) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _syllabusList = await _syllabusService.getSyllabus(levelId, term);
      _error = '';
    } catch (e) {
      _error = e.toString();
      print("Fetch Error: $_error");
      // Re-throw to let the UI handle it if needed
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSyllabus({
    required String title,
    required String description,
    required String authorName,
    required String term,
    required String courseId,
    required String courseName,
  required List<ClassModel> classes,
    required String levelId,
    required String creatorId,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newSyllabus = SyllabusModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        description: description,
        authorName: authorName,
        term: term,
        levelId:levelId,
        creatorId:creatorId,
        classes:classes,
        courseId: courseId,
         courseName:courseName, uploadDate: '',
      );

      await _syllabusService.addSyllabus(newSyllabus);
      await fetchSyllabus(levelId,term); // Refresh the list from the server
      print("Syllabus added and list refreshed");
    } catch (e) {
      _error = e.toString();
      print("Adddddddddddddddddddddddddd Error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}