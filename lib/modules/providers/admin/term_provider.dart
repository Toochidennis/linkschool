import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/term_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class TermProvider with ChangeNotifier {
  final TermService _termService = locator<TermService>();

  List<Map<String, dynamic>> _terms = [];
  List<Map<String, dynamic>> _chartData = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get terms => _terms;
  List<Map<String, dynamic>> get chartData => _chartData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTermsAndChartData(String classId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Fetching terms and chart data for classId: $classId');
      final result = await _termService.fetchTermsAndChartData(classId);
      print('Fetched Terms: ${result['terms']}');
      print('Fetched Chart Data: ${result['chart_data']}');

      _terms = List<Map<String, dynamic>>.from(result['terms']);
      _chartData = List<Map<String, dynamic>>.from(result['chart_data']);
      _error = null;
    } catch (e) {
      print('Error fetching terms and chart data: $e');
      _error = 'Failed to load terms. Please try again.';
      _terms = [];
      _chartData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}




// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/services/admin/term_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';

// class TermProvider with ChangeNotifier {
//   final TermService _termService = locator<TermService>();

//   List<Map<String, dynamic>> _terms = [];
//   bool _isLoading = false;
//   String? _error;

//   List<Map<String, dynamic>> get terms => _terms;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> fetchTerms(String classId) async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();

//       print('Fetching terms for classId: $classId');
//       final terms = await _termService.fetchTerms(classId);
//       print('Fetched Terms: $terms');

//       _terms = terms;
//       _error = null;
//     } catch (e) {
//       print('Error fetching terms: $e');
//       _error = 'Failed to load terms. Please try again.';
//       _terms = [];
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }