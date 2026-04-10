import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/exam_model.dart';
import 'package:linkschool/modules/services/explore/challange/challenge_question_service.dart';

class ChallengeQuestionProvider extends ChangeNotifier {
  final ChallengeQuestionService _service;

  ChallengeQuestionProvider({ChallengeQuestionService? service})
      : _service = service ?? ChallengeQuestionService();

  ExamModel? examInfo;
  List<QuestionModel> questions = [];
  int currentQuestionIndex = 0;
  Map<int, int> userAnswers = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchChallengeQuestions({
    required int courseId,
    required int challengeId,
    int? limit,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();


      final data = await _service.fetchChallengeQuestions(
        courseId: courseId,
        challengeId: challengeId,
        limit: limit,
      );


      if (data['success'] != true) {
        throw Exception('API did not return success:true');
      }

      // -------------------------------
      // Parse questions - FIXED VERSION
      // -------------------------------
      final questionsData = data['data'];

      if (questionsData == null) {
        questions = [];
        return;
      }

      List<dynamic> flatQuestions = [];

      // Handle if data is directly a list of questions
      if (questionsData is List) {
        flatQuestions = questionsData;
      } 
      // Handle if data is a map with a 'questions' key
      else if (questionsData is Map) {
        final questionsField = questionsData['questions'];
        
        if (questionsField is List) {
          flatQuestions = questionsField;
        } else if (questionsField is Map) {
          // If questions is a map, extract all values
          questionsField.forEach((key, value) {
            if (value is List) {
              flatQuestions.addAll(value);
            } else if (value is Map) {
              flatQuestions.add(value);
            }
          });
        } else {
          // If no 'questions' key, treat the whole data as questions
          questionsData.forEach((key, value) {
            if (value is List) {
              flatQuestions.addAll(value);
            } else if (value is Map) {
              flatQuestions.add(value);
            }
          });
        }
      }


      questions = flatQuestions
          .whereType<Map>()
          .map((q) {
            try {
              // Ensure all keys are strings and normalize the data
              final normalizedQuestion = _normalizeQuestionData(Map<String, dynamic>.from(q));
              return QuestionModel.fromJson(normalizedQuestion);
            } catch (e) {
              return null;
            }
          })
          .whereType<QuestionModel>()
          .toList();


      // Debug: Print first question's correct answer format
      if (questions.isNotEmpty) {
      }

      currentQuestionIndex = 0;
      userAnswers.clear();
    } catch (e) {
      _error = "Failed To Load Challenge Questions: $e";
      questions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Normalize question data to ensure proper types
  Map<String, dynamic> _normalizeQuestionData(Map<String, dynamic> raw) {
    final normalized = Map<String, dynamic>.from(raw);
    
    // Normalize correct answer
    if (normalized['correct'] != null) {
      final correct = normalized['correct'];
      if (correct is Map) {
        final correctMap = Map<String, dynamic>.from(correct);
        
        // Ensure 'order' is an int
        if (correctMap['order'] is String) {
          correctMap['order'] = int.tryParse(correctMap['order'].toString()) ?? 0;
        }
        
        normalized['correct'] = correctMap;
      }
    }
    
    // Normalize options
    if (normalized['options'] != null && normalized['options'] is List) {
      final options = (normalized['options'] as List).map((option) {
        if (option is Map) {
          final optionMap = Map<String, dynamic>.from(option);
          
          // Ensure 'order' is an int
          if (optionMap['order'] is String) {
            optionMap['order'] = int.tryParse(optionMap['order'].toString()) ?? 0;
          }
          
          return optionMap;
        }
        return option;
      }).toList();
      
      normalized['options'] = options;
    }
    
    // Normalize IDs
    final idFields = ['question_id', 'topic_id', 'passage_id', 'instruction_id', 'explanation_id'];
    for (final field in idFields) {
      if (normalized[field] is String) {
        normalized[field] = int.tryParse(normalized[field].toString()) ?? 0;
      }
    }
    
    return normalized;
  }

  // Navigation + Answer Handling
  QuestionModel? get currentQuestion =>
      (questions.isEmpty || currentQuestionIndex >= questions.length)
          ? null
          : questions[currentQuestionIndex];

  void selectAnswer(int questionIndex, int answerIndex) {
    // Add validation
    if (questionIndex < 0 || questionIndex >= questions.length) {
      return;
    }
    
    if (answerIndex < 0) {
      return;
    }
    
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

  bool get canMoveNext => currentQuestionIndex < questions.length - 1;
  bool get canMovePrevious => currentQuestionIndex > 0;
  int get totalQuestions => questions.length;
  bool isQuestionAnswered(int index) => userAnswers.containsKey(index);

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
