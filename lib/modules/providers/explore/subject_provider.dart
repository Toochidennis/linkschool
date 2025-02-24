import 'package:flutter/foundation.dart';

import '../../model/explore/home/subject_model2.dart';
import '../../services/explore/subject_service.dart';



class SubjectProvider with ChangeNotifier {
  final SubjectService _subjectService = SubjectService();
  List<SubjectModel2> _subjects = [];
  bool _isLoading = false;

  List<SubjectModel2> get subjects => _subjects;
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