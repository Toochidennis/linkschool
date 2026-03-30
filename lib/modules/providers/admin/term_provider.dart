import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/term_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class TermProvider with ChangeNotifier {
  final TermService _termService = locator<TermService>();

  List<Map<String, dynamic>> _terms = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get terms => _terms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTerms(String classId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final terms = await _termService.fetchTerms(classId);

      _terms = terms;
      _error = null;
    } catch (e) {
      _error = 'Failed to load terms. Please try again.';
      _terms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

