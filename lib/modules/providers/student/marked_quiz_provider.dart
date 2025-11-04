import 'package:flutter/cupertino.dart';
import 'package:linkschool/modules/model/student/streams_model.dart';
import 'package:linkschool/modules/model/student/submitted_quiz_model.dart';
import 'package:linkschool/modules/services/student/marked_quiz_service.dart';

class MarkedQuizProvider with ChangeNotifier {
  final MarkedQuizService _markedQuizService;
  List<StreamsModel> streams = [];
  bool isLoading = false;
  String? message;
  String? error;

  int currentPage = 1;
  bool hasNext = true;
  int limit = 10;
  MarkedQuizProvider(this._markedQuizService);

  Future<MarkedQuizModel?> fetchMarkedQuiz(
      int contentid, int year, int term) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      final result = await _markedQuizService.getMarkedQuiz(
        term: term,
        contentid: contentid,
        year: year,
      );

      print("Quest $result");
      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
