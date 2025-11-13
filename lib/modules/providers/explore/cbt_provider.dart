import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import '../../model/explore/home/cbt_board_model.dart' as cbt_board_model;
import '../../model/explore/home/subject_model.dart';
import '../../model/explore/cbt_history_model.dart';
import '../../services/explore/cbt_service.dart';
import '../../services/cbt_history_service.dart';

class CBTProvider extends ChangeNotifier {
  final CBTService _cbtService;
  final CbtHistoryService _historyService = CbtHistoryService();
  List<cbt_board_model.CBTBoardModel> _boards = [];
  cbt_board_model.CBTBoardModel? _selectedBoard;
  bool _isLoading = false;
  String? _error;
  
  // Dashboard statistics
  int _totalTests = 0;
  int _successCount = 0;
  double _averageScore = 0.0;
  List<CbtHistoryModel> _recentHistory = [];

  CBTProvider(this._cbtService);

  List<cbt_board_model.CBTBoardModel> get boards => _boards;
  cbt_board_model.CBTBoardModel? get selectedBoard => _selectedBoard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Dashboard statistics getters
  int get totalTests => _totalTests;
  int get successCount => _successCount;
  double get averageScore => _averageScore;
  List<CbtHistoryModel> get recentHistory => _recentHistory;

  Future<void> loadBoards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _boards = await _cbtService.fetchCBTBoards();
      if (_boards.isNotEmpty && _selectedBoard == null) {
        _selectedBoard = _boards.first;
      }
      
      // Load dashboard statistics
      await loadDashboardStats();
    } catch (e) {
      _error = e.toString();
      print('Error in CBTProvider: $_error');
    }

    _isLoading = false;
    notifyListeners();
  }
  
  // Load dashboard statistics from shared preferences
  Future<void> loadDashboardStats() async {
    try {
      final stats = await _historyService.getDashboardStats();
      _totalTests = stats['totalTests'] ?? 0;
      _successCount = stats['successCount'] ?? 0;
      _averageScore = stats['averageScore'] ?? 0.0;
      _recentHistory = stats['recentHistory'] ?? [];
      
      print('🔄 CBTProvider - Stats loaded:');
      print('   Total Tests: $_totalTests');
      print('   Success Count: $_successCount');
      print('   Average Score: ${_averageScore.toStringAsFixed(1)}%');
      
      notifyListeners();
    } catch (e) {
      print('Error loading dashboard stats: $e');
    }
  }
  
  // Refresh statistics (call this after completing a test)
  Future<void> refreshStats() async {
    await loadDashboardStats();
  }

  void selectBoard(String code) {
    _selectedBoard = _boards.firstWhere(
      (board) => board.boardCode == code,
      orElse: () => _selectedBoard!,
    );
    notifyListeners();
  }

  List<String> get boardCodes => _boards
      .map((board) => board.boardCode)
      .toList();

  List<SubjectModel> get currentBoardSubjects {
    if (_selectedBoard == null) return [];

    final subjectIcons = {
      'MATHEMATICS': 'maths',
      'ENGLISH LANGUAGE': 'english',
      'ENGLISH': 'english',
     
      'PHYSICS': 'physics',
      'BIOLOGY': 'biology',
    
    
      'LITERATURE IN ENGLISH': 'english',
      'LITERATURE-I -ENGLISH 1': 'english',
      'LITERATURE': 'english',
      //'GEOGRAPHY': 'geography',
  
    
     
      
      'CIVIC EDUCATION': 'civic',
     
     
      
      // 'GENERAL': 'general',
      // 'COMPUTER': 'computer',
      // 'BIBLE QUIZ': 'bible_quiz',
      // 'HISTORY': 'history',
      // 'MUSIC': 'music',
      // 'ANIMALS': 'animals',
      // 'SPORTS': 'sports',
      // 'BASIC SCRATCH': 'scratch',
    };

    // Fallback icons for subjects without specific icons
    final fallbackIcons = [
      'physics',
      'biology',
      'english',
      'maths',
     // "civic",
      // 'sports',
      // 'animals',
      // 'bible_quiz',
      // 'scratch',
    ];

    final colors = [
      AppColors.cbtCardColor1,
      AppColors.cbtCardColor2,
      AppColors.cbtCardColor3,
      AppColors.cbtCardColor4,
      AppColors.cbtCardColor5,
    ];

    return _selectedBoard!.subjects.map((subject) {
      // Check if subject has a specific icon
      if (subjectIcons.containsKey(subject.name.toUpperCase())) {
        subject.subjectIcon = subjectIcons[subject.name.toUpperCase()];
      } else {
        // Use a hash-based approach to consistently assign a random icon
        // This ensures the same subject always gets the same icon
        final hash = subject.name.hashCode.abs();
        subject.subjectIcon = fallbackIcons[hash % fallbackIcons.length];
      }
      
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
