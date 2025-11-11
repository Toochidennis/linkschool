import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import '../../model/explore/home/cbt_board_model.dart' as cbt_board_model;
import '../../model/explore/home/subject_model.dart';
import '../../services/explore/cbt_service.dart';

class CBTProvider extends ChangeNotifier {
  final CBTService _cbtService;
  List<cbt_board_model.CBTBoardModel> _boards = [];
  cbt_board_model.CBTBoardModel? _selectedBoard;
  bool _isLoading = false;
  String? _error;

  CBTProvider(this._cbtService);

  List<cbt_board_model.CBTBoardModel> get boards => _boards;
  cbt_board_model.CBTBoardModel? get selectedBoard => _selectedBoard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBoards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _boards = await _cbtService.fetchCBTBoards();
      if (_boards.isNotEmpty && _selectedBoard == null) {
        _selectedBoard = _boards.first;
      }
    } catch (e) {
      _error = e.toString();
      print('Error in CBTProvider: $_error');
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectBoard(String code) {
    _selectedBoard = _boards.firstWhere(
      (board) => board.boardCode == code,
      orElse: () => _selectedBoard!,
    );
    notifyListeners();
  }

  List<String> get boardCodes => _boards
      .where((board) => board.boardCode != null)
      .map((board) => board.boardCode)
      .toList();

  List<SubjectModel> get currentBoardSubjects {
    if (_selectedBoard == null) return [];

    final subjectIcons = {
      'MATHEMATICS': 'maths',
      'ENGLISH LANGUAGE': 'english',
      'CHEMISTRY': 'chemistry',
      'PHYSICS': 'physics',
      'BIOLOGY': 'biology',
      'GOVERNMENT': 'government',
      'ECONOMICS': 'economics',
      'LITERATURE IN ENGLISH': 'literature',
      'GEOGRAPHY': 'geography',
      'ACCOUNTING': 'accounting',
      'C. R. S': 'crs',
      'COMMERCE': 'commerce',
      'AGRICULTURAL SCIENCE': 'agriculture',
      'CHRISTIAN RELIGIOUS STUDIES (CRS)': 'crs',
      'FINANCIAL ACCOUNTING': 'accounting',
      'BUSINESS EDUCATION': 'business',
      'CIVIC EDUCATION': 'civic',
      'HOME ECONOMICS': 'home_economics',
      'SOCIAL STUDIES': 'social_studies',
      'VERBAL APTITUDE': 'verbal_aptitude',
      'QUANTITATIVE REASONING': 'quantitative_reasoning',
      'GENERAL': 'general',
      'COMPUTER': 'computer',
      'BIBLE QUIZ': 'bible_quiz',
      'HISTORY': 'history',
      'MUSIC': 'music',
      'ANIMALS': 'animals',
      'SPORTS': 'sports',
      'BASIC SCRATCH': 'scratch',
    };

    final colors = [
      AppColors.cbtCardColor1,
      AppColors.cbtCardColor2,
      AppColors.cbtCardColor3,
      AppColors.cbtCardColor4,
      AppColors.cbtCardColor5,
    ];

    return _selectedBoard!.subjects.map((subject) {
      subject.subjectIcon =
          subjectIcons[subject.name.toUpperCase()] ?? 'default';
      subject.cardColor =
          colors[_selectedBoard!.subjects.indexOf(subject) % colors.length];
      return subject;
    }).toList();
  }

  List<String> getYearsForSubject(String subjectName) {
    final subject = currentBoardSubjects.firstWhere(
      (subject) => subject.name == subjectName,
      orElse: () => SubjectModel(
        id: '', // Add this line to provide the required 'id' parameter
        name: subjectName,
        years: [],
      ),
    );
    return subject.years?.map((year) => year.year).toList() ?? [];
  }

  // Get all YearModel objects for a subject (includes both year and exam_id)
  List<YearModel> getYearModelsForSubject(String subjectName) {
    final subject = currentBoardSubjects.firstWhere(
      (subject) => subject.name == subjectName,
      orElse: () => SubjectModel(
        id: '',
        name: subjectName,
        years: [],
      ),
    );
    debugPrint('Year models for $subjectName: ${subject.years?.map((y) => y.year).join(', ')}');
    return subject.years ?? [];
  }

  // Get the specific exam_id for a subject and year combination
  String? getExamIdForYear(String subjectName, String year) {
    final subject = currentBoardSubjects.firstWhere(
      (subject) => subject.name == subjectName,
      orElse: () => SubjectModel(
        id: '',
        name: subjectName,
        years: [],
      ),
    );

    print('Finding exam ID for Subject: $subjectName, Year: $year');
    print('Available years for $subjectName: ${subject.years?.map((y) => y.id).join(', ')}');
    
    final yearModel = subject.years?.firstWhere(
      (y) => y.year == year,
      orElse: () => YearModel(id: '', year: ''),
    );

  
    
    return yearModel?.id.isNotEmpty == true ? yearModel!.id : null;
  }
  

  List<String> getOtherSubjects(String currentSubject) {
    return currentBoardSubjects
        .where((subject) => subject.name != currentSubject)
        .map((subject) => subject.name)
        .toList();
  }

  String getSubjectIcon(String subjectName) {
    final subject = currentBoardSubjects.firstWhere(
      (subject) => subject.name == subjectName,
      orElse: () => SubjectModel(
        id: '', // Add this line to provide the required 'id' parameter
        name: subjectName,
        subjectIcon: 'default',
      ),
    );
    return subject.subjectIcon ?? 'default';
  }

  Color getSubjectColor(String subjectName) {
    final subject = currentBoardSubjects.firstWhere(
      (subject) => subject.name == subjectName,
      orElse: () => SubjectModel(
        id: '', // Add this line to provide the required 'id' parameter
        name: subjectName,
        cardColor: AppColors.cbtCardColor1,
      ),
    );
    return subject.cardColor ?? AppColors.cbtCardColor1;
  }
}
