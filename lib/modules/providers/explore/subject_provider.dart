import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/services/explore/subject_service.dart';

import '../../model/explore/home/subject_model2.dart';

class SubjectProvider with ChangeNotifier {
  final SubjectService _subjectService = SubjectService();
  List<SubjectModel2> _subjects = [];
  bool _isLoading = false;

  List<SubjectModel2> get subjects => _subjects;
  bool get isLoading => _isLoading;
  // String get errorMessage => _errorMessage;

  // final SubjectService _subjectService = SubjectService();
  Future<void> fetchSubject() async {
    _isLoading = true;
    // _errorMessage = '';
    notifyListeners();

    try {
      _subjects = await _subjectService.getAllSubject();
      print('Fetched News: $_subjects');
    } catch (error) {
      print('Error fetching subjects: $error');
    }

    _isLoading = false;
    notifyListeners();
  }
}
