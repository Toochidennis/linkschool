import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/term_service.dart';


class TermProvider with ChangeNotifier {
  final TermService _termService = TermService();

  List<dynamic> _terms = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get terms => _terms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch terms for a specific class ID
  Future<void> fetchTerms(String classId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final terms = await _termService.fetchTerms(classId);
      setState(() {
        _terms = terms;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to update state
  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }
}