import 'package:flutter/foundation.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import '../../model/explore/home/subject_model.dart';
import '../../services/explore/subject_service.dart';


class SubjectProvider with ChangeNotifier {
  
  List<Subject> _subjects = [];
  bool _isLoading = false;
 String _errorMessage = '';
  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;
    String get errorMessage => _errorMessage;

final SubjectService _subjectService = SubjectService();
  Future<void> fetchSubject() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _subjects = await _subjectService.getAllSubjects();
      print('Fetched News: $_subjects');
    } catch (error) {
      print('Error fetching subjects: $error');
    }
    _isLoading = false;
    notifyListeners();
  }
}