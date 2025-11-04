import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/e_learning/delete_syllabus_content.dart';

class DeleteSyllabusProvider with ChangeNotifier {
  final DeleteSyllabusService _deleteSyllabusService;

  bool _isloading = false;
  String _error = '';
  DeleteSyllabusProvider(this._deleteSyllabusService);

  Future<void> deleteAssignment(String id) async {
    _isloading = true;
    _error = '';
    notifyListeners();
    try {
      await _deleteSyllabusService.DeleteAssignment(id);
      print("Assignment Deleted successfully");
    } catch (e) {
      _error = e.toString();
      print("Delete error: $_error");
      rethrow;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> DeleteQuiz(String id) async {
    _isloading = true;
    _error = '';
    notifyListeners();
    try {
      await _deleteSyllabusService.DeleteQuiz(id);
      print("Quiz Deleted successfully");
    } catch (e) {
      _error = e.toString();
      print("Delete error: $_error");
      rethrow;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMaterial(String id) async {
    _isloading = true;
    _error = '';
    notifyListeners();
    try {
      await _deleteSyllabusService.DeleteMaterial(id);
      print("Material Deleted successfully");
    } catch (e) {
      _error = e.toString();
      print("Delete error: $_error");
      rethrow;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> DeleteTopic(String id) async {
    _isloading = true;
    _error = '';
    notifyListeners();
    try {
      await _deleteSyllabusService.DeleteTopic(id);
      print("topic Deleted successfully");
    } catch (e) {
      _error = e.toString();
      print("Delete error: $_error");
      rethrow;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> deletesyllabus(int syllabusId) async {
    _isloading = true;
    _error = '';
    notifyListeners();

    try {
      await _deleteSyllabusService.deletesyllabus(syllabusId);
      print("Syllabus Deleted successfully");
    } catch (e) {
      _error = e.toString();
      print("Delete Error: $_error");
      rethrow;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}
