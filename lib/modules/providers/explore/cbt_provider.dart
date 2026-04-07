import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import '../../model/explore/home/cbt_board_model.dart' as cbt_board_model;
import '../../model/explore/home/subject_model.dart';
import '../../model/explore/cbt_history_model.dart';
import '../../services/explore/cbt_service.dart';
import '../../services/cbt_history_service.dart';
import 'package:linkschool/modules/services/network/connectivity_service.dart';

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

  // Get the most recent incomplete test
  CbtHistoryModel? get incompleteTest {
    try {
      return _recentHistory.firstWhere(
        (test) => !test.isFullyCompleted,
      );
    } catch (e) {
      return null;
    }
  }

  // Get ALL incomplete tests
  List<CbtHistoryModel> get incompleteTests {
    return _recentHistory.where((test) => !test.isFullyCompleted).toList();
  }

  // ─────────────────────────────────────────
  // ✅ UPDATED loadBoards — DB first, network fallback
  // ─────────────────────────────────────────
  Future<void> loadBoards() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Read DB-backed boards first. The service only touches network when the
      // local SQLite cache is empty or explicitly bypassed.
      _boards = await _cbtService.fetchCBTBoards();

      if (_boards.isNotEmpty) {
        if (_selectedBoard == null) {
          _selectedBoard = _boards.first;
        } else {
          final selectedCode = _selectedBoard!.boardCode;
          _selectedBoard = _boards.firstWhere(
            (board) => board.boardCode == selectedCode,
            orElse: () => _boards.first,
          );
        }
      }

      // Load dashboard statistics
      await loadDashboardStats();

      if (_boards.isEmpty) {
        final isOnline = await ConnectivityService.isOnline();
        _error = isOnline
            ? 'No CBT data available yet. Please try again.'
            : 'No internet connection. Connect and try again.';
      }
    } catch (e) {
      // Last resort — try forcing network even if we thought we were offline
      try {
        _boards = await _cbtService.fetchCBTBoards(forceNetwork: true);
        if (_boards.isNotEmpty) {
          if (_selectedBoard == null) {
            _selectedBoard = _boards.first;
          } else {
            final selectedCode = _selectedBoard!.boardCode;
            _selectedBoard = _boards.firstWhere(
              (board) => board.boardCode == selectedCode,
              orElse: () => _boards.first,
            );
          }
        }
        await loadDashboardStats();
        _error = null;
      } catch (e2) {
        final isOnline = await ConnectivityService.isOnline();
        _error = isOnline
            ? 'Network error. Please try again.'
            : 'No internet connection. Connect and try again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────
  // Load dashboard statistics — UNCHANGED
  // ─────────────────────────────────────────
  Future<void> loadDashboardStats() async {
    try {
      final stats = await _historyService.getDashboardStats();
      _totalTests = stats['totalTests'] ?? 0;
      _successCount = stats['successCount'] ?? 0;
      _averageScore = stats['averageScore'] ?? 0.0;
      _recentHistory = stats['recentHistory'] ?? [];

      final allIncompleteTests =
          stats['allIncompleteTests'] as List<CbtHistoryModel>? ?? [];
      if (allIncompleteTests.isNotEmpty) {
        _recentHistory.insertAll(0, allIncompleteTests);
        final seen = <String>{};
        _recentHistory = _recentHistory.where((test) {
          final key = '${test.subject}_${test.year}_${test.examId}';
          return seen.add(key);
        }).toList();
      }

      notifyListeners();
    } catch (e) {
      // Intentionally ignored.
    }
  }

  // Refresh statistics — UNCHANGED
  Future<void> refreshStats() async {
    await loadDashboardStats();
  }

  // selectBoard — UNCHANGED
  void selectBoard(String code) {
    _selectedBoard = _boards.firstWhere(
      (board) => board.boardCode == code,
      orElse: () => _selectedBoard!,
    );
    notifyListeners();
  }

  // boardCodes — UNCHANGED
  List<String> get boardCodes =>
      _boards.map((board) => board.boardCode).toList();

  // currentBoardSubjects — UNCHANGED
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
      'CIVIC EDUCATION': 'civic',
    };

    final fallbackIcons = [
      'physics',
      'biology',
      'english',
      'maths',
    ];

    final colors = [
      AppColors.cbtCardColor1,
      AppColors.cbtCardColor2,
      AppColors.cbtCardColor3,
      AppColors.cbtCardColor4,
      AppColors.cbtCardColor5,
    ];

    final subjects = List<SubjectModel>.from(_selectedBoard!.subjects);

    for (var i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      if (subjectIcons.containsKey(subject.name.toUpperCase())) {
        subject.subjectIcon = subjectIcons[subject.name.toUpperCase()];
      } else {
        final hash = subject.name.hashCode.abs();
        subject.subjectIcon = fallbackIcons[hash % fallbackIcons.length];
      }

      subject.cardColor = colors[i % colors.length];
    }

    subjects.sort((a, b) {
      final priorityCompare =
          _subjectPriority(a.name).compareTo(_subjectPriority(b.name));
      if (priorityCompare != 0) return priorityCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return subjects;
  }

  int _subjectPriority(String subjectName) {
    final normalized = subjectName.trim().toUpperCase();
    if (normalized == 'ENGLISH LANGUAGE' || normalized == 'ENGLISH') {
      return 0;
    }
    if (normalized == 'MATHEMATICS' || normalized == 'GENERAL MATHEMATICS') {
      return 1;
    }
    return 10;
  }

  // getYearsForSubject — UNCHANGED
  List<String> getYearsForSubject(String subjectName) {
    final subject = currentBoardSubjects.firstWhere(
      (subject) => subject.name == subjectName,
      orElse: () => SubjectModel(id: '', name: subjectName, years: []),
    );
    return subject.years?.map((year) => year.year).toList() ?? [];
  }

  // getYearModelsForSubject — UNCHANGED
  List<YearModel> getYearModelsForSubject(String subjectName) {
    final subject = currentBoardSubjects.firstWhere(
      (subject) => subject.name == subjectName,
      orElse: () => SubjectModel(id: '', name: subjectName, years: []),
    );
    return subject.years ?? [];
  }

  // getExamIdForYear — UNCHANGED
  String? getExamIdForYear(String subjectName, String year) {
    final subject = currentBoardSubjects.firstWhere(
      (subject) => subject.name == subjectName,
      orElse: () => SubjectModel(id: '', name: subjectName, years: []),
    );

    final yearModel = subject.years?.firstWhere(
      (y) => y.year == year,
      orElse: () => YearModel(id: '', year: ''),
    );

    return yearModel?.id.isNotEmpty == true ? yearModel!.id : null;
  }

  // getOtherSubjects — UNCHANGED
  List<String> getOtherSubjects(String currentSubject) {
    return currentBoardSubjects
        .where((subject) => subject.name != currentSubject)
        .map((subject) => subject.name)
        .toList();
  }

  // getSubjectIcon — UNCHANGED
  String getSubjectIcon(String subjectName) {
    final subject = currentBoardSubjects.firstWhere(
      (subject) => subject.name == subjectName,
      orElse: () =>
          SubjectModel(id: '', name: subjectName, subjectIcon: 'default'),
    );
    return subject.subjectIcon ?? 'default';
  }

  // getSubjectColor — UNCHANGED
  Color getSubjectColor(String subjectName) {
    final subject = currentBoardSubjects.firstWhere(
      (subject) => subject.name == subjectName,
      orElse: () => SubjectModel(
          id: '', name: subjectName, cardColor: AppColors.cbtCardColor1),
    );
    return subject.cardColor ?? AppColors.cbtCardColor1;
  }
}
