import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/explore/explanation_model.dart';
//import 'package:linkschool/services/deepseek_service.dart';

class CBTStudyScreen extends StatefulWidget {
  final String subject;
  final List<String> topics;

  const CBTStudyScreen({
    Key? key,
    required this.subject,
    required this.topics,
  }) : super(key: key);

  @override
  State<CBTStudyScreen> createState() => _CBTStudyScreenState();
}

class _CBTStudyScreenState extends State<CBTStudyScreen> {
  final List<StudyQuestion> _allQuestions = [
    StudyQuestion(
      question: 'The flame used by welders in cutting metals is',
      options: [
        'butane gas flame',
        'acetylene flame',
        'Kerosene flame',
        'Oxy-acetylene flame',
      ],
      correctIndex: 1,
    ),
    StudyQuestion(
      question: 'Which gas is most commonly used in balloons?',
      options: [
        'Oxygen',
        'Nitrogen',
        'Helium',
        'Carbon dioxide',
      ],
      correctIndex: 2,
    ),
    StudyQuestion(
      question: 'What is the chemical symbol for gold?',
      options: [
        'Au',
        'Ag',
        'Gd',
        'Go',
      ],
      correctIndex: 0,
    ),
    StudyQuestion(
      question: 'Water boils at what temperature (at sea level)?',
      options: [
        '90°C',
        '100°C',
        '120°C',
        '80°C',
      ],
      correctIndex: 1,
    ),
    StudyQuestion(
      question:
          'Which vitamin is produced when the skin is exposed to sunlight?',
      options: [
        'Vitamin A',
        'Vitamin B',
        'Vitamin C',
        'Vitamin D',
      ],
      correctIndex: 3,
    ),
  ];

  late List<StudyQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedIndex;
  
  // Cache for AI-generated explanations
  Map<int, String> _explanationCache = {};

  @override
  void initState() {
    super.initState();
    _questions = List<StudyQuestion>.from(_allQuestions);
    _questions.shuffle();
    _questions = _questions.take(5).toList();
  }

  void _onAnswer(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _onNextPressed() async {
    if (_selectedIndex == null) return;

    final question = _questions[_currentIndex];
    final isCorrect = _selectedIndex == question.correctIndex;
    final selectedAnswer = question.options[_selectedIndex!];
    final correctAnswer = question.options[question.correctIndex];

    // Check if we already have explanation for this question
    String? cachedExplanation = _explanationCache[_currentIndex];

    // Show modal with loading state or cached explanation
    await _showExplanationModal(
      isCorrect: isCorrect,
      selectedAnswer: selectedAnswer,
      correctAnswer: correctAnswer,
      question: question.question,
      cachedExplanation: cachedExplanation,
    );
  }

  Future<void> _showExplanationModal({
    required bool isCorrect,
    required String selectedAnswer,
    required String correctAnswer,
    required String question,
    String? cachedExplanation,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: true,
      builder: (context) => ExplanationModal(
        isCorrect: isCorrect,
        selectedAnswer: selectedAnswer,
        correctAnswer: correctAnswer,
        question: question,
        cachedExplanation: cachedExplanation,
        onExplanationGenerated: (explanation) {
          // Cache the explanation
          _explanationCache[_currentIndex] = explanation;
        },
        onContinue: () {
          Navigator.pop(context);
          _moveToNextQuestion();
        },
      ),
    );
  }

  void _moveToNextQuestion() {
    setState(() {
      _selectedIndex = null;
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        // Quiz complete
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.subject} Study',
              style: AppTextStyles.normal600(
                fontSize: 18,
                color: AppColors.text4Light,
              ),
            ),
            Text(
              widget.topics.join(', '),
              style: AppTextStyles.normal400(
                fontSize: 12,
                color: AppColors.text7Light,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.backgroundLight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _questions.length,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.eLearningBtnColor1,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentIndex + 1}/${_questions.length}',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: AppColors.text7Light,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Question
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.eLearningBtnColor1,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_currentIndex + 1}',
                          style: AppTextStyles.normal600(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        question.question,
                        style: AppTextStyles.normal600(
                          fontSize: 16,
                          color: AppColors.text4Light,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, i) {
                    final selected = _selectedIndex == i;
                    return GestureDetector(
                      onTap: _selectedIndex == null ? () => _onAnswer(i) : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.eLearningBtnColor1.withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(
                            color: selected
                                ? AppColors.eLearningBtnColor1
                                : Colors.grey.shade300,
                            width: selected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.eLearningBtnColor1
                                        .withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selected
                                  ? AppColors.eLearningBtnColor1
                                  : Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                question.options[i],
                                style: AppTextStyles.normal500(
                                  fontSize: 15,
                                  color: selected
                                      ? AppColors.eLearningBtnColor1
                                      : AppColors.text4Light,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Navigation buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Exit',
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.text7Light,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectedIndex != null ? _onNextPressed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eLearningBtnColor1,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudyQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  StudyQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// EXPLANATION MODAL WITH AI GENERATION
class ExplanationModal extends StatefulWidget {
  final bool isCorrect;
  final String selectedAnswer;
  final String correctAnswer;
  final String question;
  final String? cachedExplanation;
  final Function(String) onExplanationGenerated;
  final VoidCallback onContinue;

  const ExplanationModal({
    Key? key,
    required this.isCorrect,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.question,
    this.cachedExplanation,
    required this.onExplanationGenerated,
    required this.onContinue,
  }) : super(key: key);

  @override
  State<ExplanationModal> createState() => _ExplanationModalState();
}

class _ExplanationModalState extends State<ExplanationModal> {
  String? _explanation;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.cachedExplanation != null) {
      _explanation = widget.cachedExplanation;
    } else {
      _fetchExplanation();
    }
  }

  Future<void> _fetchExplanation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final explanation = await DeepSeekService.getExplanation(
        question: widget.question,
        selectedAnswer: widget.selectedAnswer,
        correctAnswer: widget.correctAnswer,
        isCorrect: widget.isCorrect,
      );

      if (mounted) {
        setState(() {
          _explanation = explanation;
          _isLoading = false;
        });
        widget.onExplanationGenerated(explanation);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to generate explanation. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Container(
                    child: Row(
                      children: [
                        Icon(
                          widget.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: widget.isCorrect ? Colors.green : Colors.red,
                          size: 48,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isCorrect ? 'Excellent!' : 'Incorrect',
                                style: AppTextStyles.normal700(
                                  fontSize: 24,
                                  color: widget.isCorrect ? Colors.green : Colors.red,
                                ),
                              ),
                              Text(
                                widget.isCorrect
                                    ? 'You got it right!'
                                    : 'Let\'s learn from this',
                                style: AppTextStyles.normal500(
                                  fontSize: 14,
                                  color: AppColors.text7Light,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30,),

                  const Divider(height: 1),

                  // Content
                  SizedBox(height: 30,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Answers section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  widget.isCorrect
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 20,
                                  color: widget.isCorrect ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Answer:',
                                  style: AppTextStyles.normal600(
                                    fontSize: 14,
                                    color: AppColors.text7Light,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.selectedAnswer,
                              style: AppTextStyles.normal500(
                                fontSize: 15,
                                color: AppColors.text4Light,
                              ),
                            ),
                            if (!widget.isCorrect) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Correct Answer:',
                                    style: AppTextStyles.normal600(
                                      fontSize: 14,
                                      color: AppColors.text7Light,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.correctAnswer,
                                style: AppTextStyles.normal600(
                                  fontSize: 15,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Explanation section
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: Colors.orange, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Explanation',
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.text4Light,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Loading, error, or explanation
                      if (_isLoading)
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Generating explanation...',
                                style: AppTextStyles.normal400(
                                  fontSize: 14,
                                  color: AppColors.text7Light,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: AppTextStyles.normal400(
                                    fontSize: 14,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_explanation != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _explanation!,
                            style: AppTextStyles.normal400(
                              fontSize: 15,
                              color: AppColors.text4Light,
                             // height: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Continue button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.eLearningBtnColor1,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue Learning',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}