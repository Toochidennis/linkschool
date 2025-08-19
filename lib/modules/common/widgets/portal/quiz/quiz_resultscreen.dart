import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class QuizAttempt {
  final int questionNumber;
  final String questionText;
  final String userAnswer;
  final String correctAnswer;
   int marks;
   String? status; // null means not graded yet
  final String? userAnswerImageUrl;
  final String? correctAnswerImageUrl;
  int? customMarks;

  QuizAttempt({
    required this.questionNumber,
    required this.questionText,
    required this.userAnswer,
    required this.correctAnswer,
    required this.marks,
    this.status,
    this.userAnswerImageUrl,
    this.correctAnswerImageUrl,
    this.customMarks,
  });
}

class Student {
  final String name;
  final String regNo;
  final String timeTaken;
  final int totalQuestions;
  final List<QuizAttempt> attempts;
  final String? overallScore;

  Student({
    required this.name,
    required this.regNo,
    required this.timeTaken,
    required this.totalQuestions,
    required this.attempts,
    this.overallScore,
  });
}

class QuizResultsScreen extends StatefulWidget {
  const QuizResultsScreen({Key? key}) : super(key: key);

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  late PageController _pageController;
  int currentStudentIndex = 0;
  
  
  final List<Student> students = [
    Student(
      name: "Adebayo Johnson",
      regNo: "ST2024001",
      timeTaken: "12:45",
      totalQuestions: 5,
      overallScore: "18/25",
      attempts: [
        QuizAttempt(
          questionNumber: 1,
          questionText: "What is the capital of Nigeria?",
          userAnswer: "Lagos",
          correctAnswer: "Abuja",
          marks: 5,
          status: null, // Not graded yet
        ),
        QuizAttempt(
          questionNumber: 2,
          questionText: "Calculate: 2 + 3 × 4",
          userAnswer: "14",
          correctAnswer: "14",
          marks: 5,
          status: null,
        ),
        QuizAttempt(
          questionNumber: 3,
          questionText: "Who wrote 'Things Fall Apart'?",
          userAnswer: "",
          correctAnswer: "Chinua Achebe",
          marks: 5,
          status: null,
        ),
        QuizAttempt(
          questionNumber: 6,
          questionText: "What is the smallest continent?",
          userAnswerImageUrl: "https:",
          userAnswer: "Australia",
          correctAnswer: "Australia",
          marks: 5,
          status: null,
        ),
        QuizAttempt(
          questionNumber: 4,
          questionText: "What is the largest continent?",
          userAnswer: "Asia",
          correctAnswer: "Asia",
          marks: 5,
          status: null,
        ),
        QuizAttempt(
          questionNumber: 5,
          questionText: "Name the first President of Nigeria",
          userAnswer: "Nnamdi Azikiwe",
          correctAnswer: "Nnamdi Azikiwe",
          marks: 5,
          status: null,
        ),
      ],
    ),
    Student(
      name: "Fatima Abubakar",
      regNo: "ST2024002",
      timeTaken: "15:30",
      totalQuestions: 5,
      overallScore: "22/25",
      attempts: [
        QuizAttempt(
          questionNumber: 1,
          questionText: "What is the capital of Nigeria?",
          userAnswer: "Abuja",
          correctAnswer: "Abuja",
          marks: 5,
          status: "Correct",
        ),
        QuizAttempt(
          questionNumber: 2,
          questionText: "Calculate: 2 + 3 × 4",
          userAnswer: "20",
          correctAnswer: "14",
          marks: 5,
          status: "Wrong",
        ),
        QuizAttempt(
          questionNumber: 3,
          questionText: "Who wrote 'Things Fall Apart'?",
          userAnswer: "Chinua Achebe",
          correctAnswer: "Chinua Achebe",
          marks: 5,
          status: "Correct",
        ),
        QuizAttempt(
          questionNumber: 4,
          questionText: "What is the largest continent?",
          userAnswer: "Africa",
          correctAnswer: "Asia",
          marks: 5,
          status: "Wrong",
        ),
        QuizAttempt(
          questionNumber: 5,
          questionText: "Name the first President of Nigeria",
          userAnswer: "Nnamdi Azikiwe",
          correctAnswer: "Nnamdi Azikiwe",
          marks: 5,
          status: "Correct",
        ),
      ],
    ),
    Student(
      name: "Chinedu Okafor",
      regNo: "ST2024003",
      timeTaken: "18:22",
      totalQuestions: 5,
      overallScore: "15/25",
      attempts: [
        QuizAttempt(
          questionNumber: 1,
          questionText: "What is the capital of Nigeria?",
          userAnswer: "Kano",
          correctAnswer: "Abuja",
          marks: 5,
          status: "Wrong",
        ),
        QuizAttempt(
          questionNumber: 2,
          questionText: "Calculate: 2 + 3 × 4",
          userAnswer: "14",
          correctAnswer: "14",
          marks: 5,
          status: "Correct",
        ),
        QuizAttempt(
          questionNumber: 3,
          questionText: "Who wrote 'Things Fall Apart'?",
          userAnswer: "",
          correctAnswer: "Chinua Achebe",
          marks: 5,
          status: "No answer",
        ),
        QuizAttempt(
          questionNumber: 4,
          questionText: "What is the largest continent?",
          userAnswer: "Asia",
          correctAnswer: "Asia",
          marks: 5,
          status: "Correct",
        ),
        QuizAttempt(
          questionNumber: 5,
          questionText: "Name the first President of Nigeria",
          userAnswer: "Tafawa Balewa",
          correctAnswer: "Nnamdi Azikiwe",
          marks: 5,
          status: "Wrong",
        ),
      ],
    ),
    Student(
      name: "Blessing Okafor",
      regNo: "ST2024004",
      timeTaken: "10:15",
      totalQuestions: 5,
      overallScore: "25/25",
      attempts: [
        QuizAttempt(
          questionNumber: 1,
          questionText: "What is the capital of Nigeria?",
          userAnswer: "Abuja",
          correctAnswer: "Abuja",
          marks: 5,
          status: "Correct",
        ),
        QuizAttempt(
          questionNumber: 2,
          questionText: "Calculate: 2 + 3 × 4",
          userAnswer: "14",
          correctAnswer: "14",
          marks: 5,
          status: "Correct",
        ),
        QuizAttempt(
          questionNumber: 3,
          questionText: "Who wrote 'Things Fall Apart'?",
          userAnswer: "Chinua Achebe",
          correctAnswer: "Chinua Achebe",
          marks: 5,
          status: "Correct",
        ),
        QuizAttempt(
          questionNumber: 4,
          questionText: "What is the largest continent?",
          userAnswer: "Asia",
          correctAnswer: "Asia",
          marks: 5,
          status: "Correct",
        ),
        QuizAttempt(
          questionNumber: 5,
          questionText: "Name the first President of Nigeria",
          userAnswer: "Nnamdi Azikiwe",
          correctAnswer: "Nnamdi Azikiwe",
          marks: 5,
          status: "Correct",
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _markQuestion(int questionIndex, String status) {
    setState(() {
      students[currentStudentIndex].attempts[questionIndex] = QuizAttempt(
        questionNumber: students[currentStudentIndex].attempts[questionIndex].questionNumber,
        questionText: students[currentStudentIndex].attempts[questionIndex].questionText,
        userAnswer: students[currentStudentIndex].attempts[questionIndex].userAnswer,
        correctAnswer: students[currentStudentIndex].attempts[questionIndex].correctAnswer,
        marks: students[currentStudentIndex].attempts[questionIndex].marks,
        status: status,
        userAnswerImageUrl: students[currentStudentIndex].attempts[questionIndex].userAnswerImageUrl,
        correctAnswerImageUrl: students[currentStudentIndex].attempts[questionIndex].correctAnswerImageUrl,
      );
    });
  }
  String _checkAnswerStatus(QuizAttempt attempt) {
    if (attempt.userAnswer.isEmpty || attempt.userAnswer.trim().isEmpty) {
      return 'No answer';
    } 

    String correctAnswer = attempt.correctAnswer.trim().toLowerCase();
    String userAnswer = attempt.userAnswer.trim().toLowerCase();

    if (userAnswer == correctAnswer) {
    
      return 'Correct';

    } else {
     
      return 'Wrong';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Correct':
        return Colors.green;
      case 'Wrong':
        return Colors.red;
      case 'No answer':
        return Colors.grey;
      default:
        return Colors.blue; // For unmarked questions
    }
  }

  void _updateMarks(int questionIndex, int marks) {
    setState(() {
      students[currentStudentIndex].attempts[questionIndex].marks = marks;
    });
  }

  void _autoGrade() {
    setState(() {
      for (var attempt in students[currentStudentIndex].attempts) {
        attempt.status = _checkAnswerStatus(attempt);
      }
    });
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'Correct':
        return Icons.check;
      case 'Wrong':
        return Icons.close;
      case 'No answer':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  int _calculateScore() {

    int score = 0;
    for (var attempt in students[currentStudentIndex].attempts) {
      if (attempt.status == 'Correct') {
        score += attempt.customMarks ?? attempt.marks;
      }
    }
    return score;
  }

  int _getTotalPossibleScore() {
    int total = 0;
    for (var attempt in students[currentStudentIndex].attempts) {
      total += attempt.marks;
    }
    return total;
  }

  int _countCorrectAnswers() {
    return students[currentStudentIndex].attempts.where((a) => a.status == 'Correct').length;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
       appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'quiz results',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
       
        backgroundColor: AppColors.backgroundLight,
      
       
      ),
      body: Container(
        color: AppColors.backgroundLight,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              currentStudentIndex = index;
            });
          },
          itemCount: students.length,
          itemBuilder: (context, index) {
            return _buildStudentQuiz(students[index]);
          },
        ),
      ),
    );
  }

  Widget _buildStudentQuiz(Student student) {
    return Column(
      children: [
        // Student header with navigation
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, ),
          child: Column(
            children: [
              // Swipe indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              // Student navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: currentStudentIndex > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: currentStudentIndex > 0 ? AppColors.paymentTxtColor1: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.paymentTxtColor1,
                        child: Text(
                          student.name.split(' ').map((e) => e[0]).join(''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                         
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: currentStudentIndex < students.length - 1
                        ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: currentStudentIndex < students.length - 1
                          ? AppColors.paymentTxtColor1
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            
            ],
          ),
        ),
        
        // Quiz content
        Expanded(
          child: SingleChildScrollView(
           
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.blue[50],
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Score: ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.paymentTxtColor1,
                            ),
                          ),
                      
                          Text(
                            '${_calculateScore()}/${_getTotalPossibleScore()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.paymentTxtColor1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Text(
                            'Questions Answered: ',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.paymentTxtColor1,
                            ),
                          ),
                          Text(
                            '${_countCorrectAnswers()} of ${student.totalQuestions} questions',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.paymentTxtColor1,
                            ),
                          ),
                        ]
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [...List.generate(student.attempts.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),

                    child: _buildQuestionCard(student.attempts[index], index),
                  );
                }),
               ] ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(Student student) {
    int correctAnswers = _countCorrectAnswers();
    int totalQuestions = student.totalQuestions;
    int score = _calculateScore();
    int totalScore = _getTotalPossibleScore();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Score',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '$correctAnswers of $totalQuestions questions',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$score/$totalScore',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      student.timeTaken,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizAttempt attempt, int index) {
    String autoStatus = _checkAnswerStatus(attempt);
  String displayStatus = attempt.status ?? autoStatus;
  Color statusColor = _getStatusColor(displayStatus);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${attempt.questionNumber}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                 
            ],
          ),
            const SizedBox(height: 12),
            Text(
              attempt.questionText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // User answer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Student answer:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Flexible(
                  child: Text(
                    attempt.userAnswer.isEmpty ? 'No answer' : attempt.userAnswer,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: attempt.userAnswer.isEmpty ? Colors.grey : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Correct answer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Correct answer:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Flexible(
                  child: Text(
                    attempt.correctAnswer,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Marking buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
  if (attempt.userAnswer == null || attempt.userAnswer.isEmpty || attempt.userAnswer == 'No an')
    _buildStatusButton(
      'No answer',
      Colors.blue,
      Icons.help_outline,
      isSelected: displayStatus == 'no answer',
      onTap: () => _markQuestion(index, 'No answer'),
    )
  else if (attempt.userAnswer == attempt.correctAnswer)
    _buildStatusButton(
      'Correct',
      Colors.green,
      Icons.check,
      isSelected: displayStatus == 'Correct',
      onTap: () => _markQuestion(index, 'Correct'),
    )
  else
    _buildStatusButton(
      'Wrong',
      Colors.red,
      Icons.close,
      isSelected: displayStatus == 'Wrong',
      onTap: () => _markQuestion(index, 'Wrong'),
    ),

         Row(
              mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 50,
                    height: 30,
                    child: TextFormField(
                      initialValue: (attempt.customMarks ?? attempt.marks).toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      isDense: true
                      ),
                      onChanged: (value) {
                        int? newMarks = int.tryParse(value);
                        if (newMarks != null) {
                          _updateMarks(index, newMarks);
                        }
                      },
                    ),
                  ),
                  Text(' marks', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),

]


            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    String text,
    Color color,
    IconData icon, {
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}