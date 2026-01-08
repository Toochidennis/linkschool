import 'package:flutter/material.dart';
import 'quiz_summary_screen.dart';

class QuizScreen extends StatefulWidget {
  final String courseTitle;
  final String lessonTitle;

  const QuizScreen({
    Key? key,
    required this.courseTitle,
    required this.lessonTitle,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {}; // questionIndex -> selectedOptionIndex

  // Static quiz questions
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the primary purpose of AI in storytelling?',
      'options': [
        'To replace human creativity',
        'To enhance and assist creative processes',
        'To write stories automatically',
        'To eliminate the need for writers',
      ],
      'correctAnswer': 1,
    },
    {
      'question':
          'Which of the following is a key benefit of using AI tools in script development?',
      'options': [
        'It makes scripts shorter',
        'It speeds up the brainstorming process',
        'It removes all errors',
        'It writes the entire script',
      ],
      'correctAnswer': 1,
    },
    {
      'question': 'What is visual storytelling primarily focused on?',
      'options': [
        'Using only text to tell stories',
        'Conveying narratives through images and visuals',
        'Writing detailed descriptions',
        'Creating audio content',
      ],
      'correctAnswer': 1,
    },
    {
      'question':
          'In editing and presentation, what is the most important aspect?',
      'options': [
        'Using expensive software',
        'Making the story longer',
        'Clear communication of your message',
        'Adding many special effects',
      ],
      'correctAnswer': 2,
    },
    {
      'question': 'What does "iterative process" mean in creative work?',
      'options': [
        'Doing something once and finishing',
        'Repeatedly refining and improving your work',
        'Working very slowly',
        'Avoiding changes',
      ],
      'correctAnswer': 1,
    },
    {
      'question': 'Which element is crucial for effective storytelling?',
      'options': [
        'Using complex vocabulary',
        'Having a clear narrative structure',
        'Making it as long as possible',
        'Avoiding conflict in the story',
      ],
      'correctAnswer': 1,
    },
    {
      'question': 'What is the role of a script in storytelling?',
      'options': [
        'To confuse the audience',
        'To provide a blueprint for the narrative',
        'To make the story complicated',
        'To replace visual elements',
      ],
      'correctAnswer': 1,
    },
    {
      'question': 'How can AI assist in the creative process?',
      'options': [
        'By doing all the work',
        'By providing suggestions and alternatives',
        'By limiting creativity',
        'By making decisions for you',
      ],
      'correctAnswer': 1,
    },
    {
      'question': 'What is the purpose of a presentation showcase?',
      'options': [
        'To hide your work',
        'To demonstrate and share your creative work',
        'To criticize others',
        'To avoid feedback',
      ],
      'correctAnswer': 1,
    },
    {
      'question':
          'What is the most important skill in AI-assisted storytelling?',
      'options': [
        'Typing speed',
        'Critical thinking and creativity',
        'Memorization',
        'Following instructions exactly',
      ],
      'correctAnswer': 1,
    },
  ];

  void _selectAnswer(int optionIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = optionIndex;
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _submitQuiz() {
    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }

    final score = ((correctAnswers / _questions.length) * 100).round();

    // Navigate to summary screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSummaryScreen(
          totalScore: score,
          totalQuestions: _questions.length,
          questions: _questions,
          userAnswers: _selectedAnswers,
          courseTitle: widget.courseTitle,
          lessonTitle: widget.lessonTitle,
          onRetake: () {
            Navigator.pop(context); // Close summary
            setState(() {
              _currentQuestionIndex = 0;
              _selectedAnswers.clear();
            });
          },
          onClose: () {
            Navigator.pop(context); // Close summary
            Navigator.pop(context); // Close quiz screen
          },
        ),
      ),
    ).then((_) {
      // When returning from summary, close the quiz screen
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final selectedAnswer = _selectedAnswers[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Quiz?'),
                content:
                    const Text('Your progress will be lost if you exit now.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close quiz screen
                    },
                    child: const Text(
                      'Exit',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${((_currentQuestionIndex + 1) / _questions.length * 100).round()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6366F1),
                  ),
                  minHeight: 6,
                ),
              ],
            ),
          ),

          // Question and options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Text(
                    currentQuestion['question'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...List.generate(
                    (currentQuestion['options'] as List).length,
                    (index) {
                      final isSelected = selectedAnswer == index;
                      return GestureDetector(
                        onTap: () => _selectAnswer(index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6366F1).withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6366F1)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF6366F1)
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6366F1)
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  currentQuestion['options'][index] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                // Previous button
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                if (_currentQuestionIndex > 0) const SizedBox(width: 12),

                // Next/Submit button
                Expanded(
                  flex: _currentQuestionIndex == 0 ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: selectedAnswer != null
                        ? (isLastQuestion ? _submitQuiz : _nextQuestion)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isLastQuestion ? 'Submit' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
