import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../model/explore/home/subject_model2.dart';
import '../../services/explore/subject_service.dart';

class SubjectProvider with ChangeNotifier {
  final SubjectService _subjectService = SubjectService();
  List<SubjectModel2> _subjects = [];
  bool _isLoading = false;

  List<SubjectModel2> get subjects => _subjects;
  bool get isLoading => _isLoading;

  Future<void> fetchSubjects() async {
    // ✅ Avoid multiple unnecessary rebuilds during initState
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final apiKey = dotenv.env['API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        debugPrint('⚠️ API_KEY not found in .env file.');
      }

      _subjects = await _subjectService.getAllSubject();
      debugPrint('✅ Subjects fetched successfully: ${_subjects.length}');
    } catch (error) {
      debugPrint('❌ Error fetching subjects: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
