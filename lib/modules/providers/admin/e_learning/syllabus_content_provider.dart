import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_content_service.dart';
// import 'package:linkschool/modules/services/admin/e_learning/syllabus_content_service.dart';

class SyllabusContentProvider with ChangeNotifier {
  final SyllabusContentService _syllabusContentService;

  List<Map<String, dynamic>> _contents = [];
  bool _isLoading = false;
  String _error = '';

  SyllabusContentProvider(this._syllabusContentService);

  List<Map<String, dynamic>> get contents => _contents;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchSyllabusContents(int syllabusId, String dbName) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response =
          await _syllabusContentService.getSyllabusContents(syllabusId, dbName);

      if (response.success && response.rawData != null) {
        final responseData = response.rawData!['response'];
        if (responseData is List) {
          _contents = List<Map<String, dynamic>>.from(responseData);
        } else {
          _contents = [];
        }
        _error = '';
      } else {
        _error = response.message;
        _contents = [];
      }
    } catch (e) {
      _error = 'Failed to fetch syllabus contents: $e';
      _contents = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearContents() {
    _contents = [];
    _error = '';
    notifyListeners();
  }
}
