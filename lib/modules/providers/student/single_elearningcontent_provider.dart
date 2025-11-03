

import 'package:flutter/cupertino.dart';
import 'package:linkschool/modules/model/student/single_elearningcontentmodel.dart';
import 'package:linkschool/modules/services/student/single_elearningcontentservice.dart';

import '../../services/api/service_locator.dart';

class SingleelearningcontentProvider with ChangeNotifier {
  final SingleElearningcontentservice _elearningContentService = locator<SingleElearningcontentservice>();

  late SingleElearningContentData _elearningContentData;
  bool _isLoading = false;
  String? _errorMessage;

  SingleElearningContentData get elearningcontentData => _elearningContentData;
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

  Future<SingleElearningContentData?> fetchElearningContentData( int contentid) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _elearningContentService.getElearningContentData(contentid);
      _elearningContentData = response;

      return response; // Return DashboardData directly
    } catch (e) {
      _setError('Unexpected error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

}
