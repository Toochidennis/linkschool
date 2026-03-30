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
    } catch (e) {
      _error = e.toString();
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
    } catch (e) {
      _error = e.toString();
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
    } catch (e) {
      _error = e.toString();
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
    } catch (e) {
      _error = e.toString();
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
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}

