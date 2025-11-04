import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/staff/syllabus_model.dart';
import 'package:linkschool/modules/services/staff/syllabus_service.dart';

class StaffSyllabusProvider with ChangeNotifier {
  final StaffSyllabusService _staffSyllabusService;
  List<StaffSyllabusModel> _syllabusList = [];
  bool _isLoading = false;
  String _error = '';

  StaffSyllabusProvider(this._staffSyllabusService);

  List<StaffSyllabusModel> get syllabusList => _syllabusList;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchSyllabus(
      String levelId, String term, String courseId, String classId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _staffSyllabusService.getSyllabus(
          levelId, term, courseId, classId);
      _syllabusList = result;
      _error = '';
    } catch (e) {
      _error = e.toString();
      print("Fetch Error: $_error");
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
    required String classId,
    required String courseName,
    required List<ClassModel> classes,
    required String levelId,
    required String creatorId,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // StaffSyllabusModel expects int? for courseId, levelId, creatorId
      // But here, you are passing String values.
      // This will cause a type error.
      // You need to convert these String values to int? before passing.
      final newSyllabus = StaffSyllabusModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        description: description,
        authorName: authorName,
        term: term,
        levelId: int.tryParse(levelId),
        creatorId: int.tryParse(creatorId),
        classes: classes,
        courseId: int.tryParse(courseId),
        courseName: courseName,
        uploadDate: '',
      );

      await _staffSyllabusService.addSyllabus(newSyllabus);
      await fetchSyllabus(levelId, term, courseId, classId);
      print("Syllabus added and list refreshed");
    } catch (e) {
      _error = e.toString();
      print("Add Error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSyllabus({
    required String title,
    required String description,
    required String term,
    required int levelId,
    required int syllabusId,
    required List<ClassModel> classes,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Use StaffSyllabusModel, not SyllabusModel (which is from e-learning)
      final updatedSyllabus = StaffSyllabusModel(
        id: syllabusId,
        title: title,
        description: description,
        term: term,
        levelId: levelId,
        classes: classes,
        // The following fields are not provided in the update, so set to null or empty
        authorName: null,
        uploadDate: '',
        courseId: null,
        courseName: null,
        creatorId: null,
      );

      await _staffSyllabusService.UpdateSyllabus(updatedSyllabus, syllabusId);
      print("Syllabus updated and list refreshed");
    } catch (e) {
      _error = e.toString();
      print("Update Error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletesyllabus(int syllabusId, String levelId, String term,
      String courseId, String classId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _staffSyllabusService.deletesyllabus(syllabusId);
      await fetchSyllabus(levelId, term, courseId, classId);
      print("Syllabus deleted successfully");
    } catch (e) {
      _error = e.toString();
      print("Delete Error: $_error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
