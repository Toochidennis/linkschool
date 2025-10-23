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
  
  Future<void> fetchExamData(String examType) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('🔄 Fetching exam data for type: $examType');
      
      final data = await _examService.fetchExamData(examType: examType);
      
      // Debug: Print the response structure
      print('📦 API Response: $data');
      
      // Check if the API call was successful
      if (data['success'] == true) {
        // Parse exam info from the new structure
        if (data.containsKey('exam')) {
          final examData = data['exam'];
          print('📊 Exam data: $examData');
          
          examInfo = ExamModel.fromJson(examData);
          print('✅ Exam info loaded: ${examInfo?.title}');
        } else {
          throw Exception('Exam data not found in response');
        }
        
        // Parse questions from the new structure
        if (data.containsKey('questions')) {
          final questionsData = data['questions'];
          print('❓ Questions data type: ${questionsData.runtimeType}');
          print('❓ Questions data: $questionsData');
          
          if (questionsData is List && questionsData.isNotEmpty) {
            questions = questionsData
                .where((q) => q is Map)
                .map((q) {
                  try {
                    return QuestionModel.fromJson(q);
                  } catch (e) {
                    print('⚠️ Error parsing question: $e');
                    print('⚠️ Question data that failed: $q');
                    return null;
                  }
                })
                .whereType<QuestionModel>() // Remove null values
                .toList();
                
            print('✅ Successfully loaded ${questions.length} questions');
            
            // Reset navigation state
            currentQuestionIndex = 0;
            userAnswers.clear();
          } else {
            print('ℹ️ No questions available or questions list is empty');
            questions = [];
          }
        } else {
          print('ℹ️ No questions key in response - this exam has no questions');
          questions = [];
        }
      } else {
        throw Exception('API returned success: false');
      }
      
    } catch (e) {
      print("💥 Provider error: $e");
      print("💥 Stack trace: ${e.toString()}");
      _error = "Failed to load exam data: ${e.toString()}";
      
      // Reset data on error
      questions = [];
      currentQuestionIndex = 0;
      userAnswers.clear();
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
  
  // Reset the provider state
  void reset() {
    examInfo = null;
    questions = [];
    currentQuestionIndex = 0;
    userAnswers.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}