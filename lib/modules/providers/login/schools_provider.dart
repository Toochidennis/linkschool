import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/Login/schools_model.dart';
import 'package:linkschool/modules/services/login/schools_service.dart';

class SchoolProvider with ChangeNotifier {
  final SchoolService _schoolService = SchoolService();

  List<School> _schools = [];
  List<School> get schools => _schools;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchSchools() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schools = await _schoolService.fetchSchools();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<School> searchSchools(String query) {
    if (query.isEmpty) return _schools;
    return _schools
        .where((school) =>
            school.schoolName.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
  }
}
