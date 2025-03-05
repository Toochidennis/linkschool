import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/services/explore/exam_service.dart';


class ExamProvider extends ChangeNotifier {
  final ExamService _examService;
  
  ExamProvider({ExamService? examService}) 
      : _examService = examService ?? ExamService();
  
  ExamModel? examInfo;
  List<QuestionModel> questions = [];
  int currentQuestionIndex = 0;
  Map<int, int> userAnswers = {};
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchExamData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final data = await _examService.fetchExamData(
        appCode: 'VDOK-124-CAUCHY',
        examId: '1',
      );
      
      // Parse exam info
      examInfo = ExamModel.fromJson(data['e']);
      
      // Parse questions
      final List<dynamic> questionsList = data['q'][0];
      questions = questionsList
          .where((q) => q['type'] == 'qo') // Filter out non-question items
          .map((q) => QuestionModel.fromJson(q))
          .toList();
          
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  QuestionModel? get currentQuestion {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }
  
  void selectAnswer(int questionIndex, int answerIndex) {
    userAnswers[questionIndex] = answerIndex;
    notifyListeners();
  }
  
  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      notifyListeners();
    }
  }
  
  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      currentQuestionIndex--;
      notifyListeners();
    }
  }
  
  // Additional helper methods
  bool get canMoveNext => currentQuestionIndex < questions.length - 1;
  bool get canMovePrevious => currentQuestionIndex > 0;
  int get totalQuestions => questions.length;
  bool isQuestionAnswered(int index) => userAnswers.containsKey(index);
}