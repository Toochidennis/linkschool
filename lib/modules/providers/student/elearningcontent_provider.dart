

import 'package:flutter/cupertino.dart';
import 'package:linkschool/modules/model/student/elearningcontent_model.dart';
import 'package:linkschool/modules/services/student/elearningcontent_service.dart';

import '../../model/student/dashboard_model.dart';
import '../../services/api/service_locator.dart';
import '../../services/student/student_dasboard_service.dart';

class ElearningContentProvider with ChangeNotifier {
  final ElearningContentService _elearningContentService = locator<ElearningContentService>();

  late List<ElearningContentData> _elearningContentData;
  bool _isLoading = false;
  String? _errorMessage;

  List<ElearningContentData> get elearningcontentData => _elearningContentData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<List<ElearningContentData>?> fetchElearningContentData( int syllabusid) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _elearningContentService.getElearningContentData(syllabusid);
      _elearningContentData = response;
      print("This is the response ${_elearningContentData}");

      return response; // Return DashboardData directly
    } catch (e) {
      _setError('Unexpected error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

}
