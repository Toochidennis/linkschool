import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';

import '../../model/explore/home/cbt_board_model.dart';
import '../../model/explore/home/subject_model.dart';
import '../../services/explore/cbt_service.dart';


class CBTProvider extends ChangeNotifier {
  final CBTService _cbtService;
  List<CBTBoardModel> _boards = [];
  CBTBoardModel? _selectedBoard;
  bool _isLoading = false;
  String? _error;

  CBTProvider(this._cbtService);

  List<CBTBoardModel> get boards => _boards;
  CBTBoardModel? get selectedBoard => _selectedBoard;
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

  List<String> get boardCodes => 
    _boards.where((board) => board.boardCode != null)
           .map((board) => board.boardCode)
           .toList();

  List<SubjectModel> get currentBoardSubjects {
    if (_selectedBoard == null) return [];
    
    // Assign icons and colors to subjects
    final subjectIcons = {
      'MATHEMATICS': 'maths',
      'ENGLISH LANGUAGE': 'english',
      'CHEMISTRY': 'chemistry',
      'PHYSICS': 'physics',
      'BIOLOGY': 'biology',
    };

    final colors = [
      AppColors.cbtCardColor1,
      AppColors.cbtCardColor2,
      AppColors.cbtCardColor3,
      AppColors.cbtCardColor4,
      AppColors.cbtCardColor5,
    ];

    return _selectedBoard!.subjects.map((subject) {
      subject.subjectIcon = subjectIcons[subject.name.toUpperCase()] ?? 'default';
      subject.cardColor = colors[_selectedBoard!.subjects.indexOf(subject) % colors.length];
      return subject;
    }).toList();
  }
}