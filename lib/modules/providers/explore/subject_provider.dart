import 'package:flutter/foundation.dart';
import '../../model/explore/home/subject_model.dart';
import '../../services/explore/subject_service.dart';


class SubjectProvider with ChangeNotifier {
  final SubjectService _subjectService = SubjectService();
  List<Subject> _subjects = [];
  bool _isLoading = false;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;

  Future<void> fetchSubjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      _subjects = await _subjectService.getAllSubject();
    } catch (error) {
      print('Error fetching subjects: $error');
    }
    _isLoading = false;
    notifyListeners();
  }
}