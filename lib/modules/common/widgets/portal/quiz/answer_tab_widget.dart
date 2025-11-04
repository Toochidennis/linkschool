import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/quiz/quiz_resultscreen.dart';
import 'package:linkschool/modules/providers/admin/e_learning/mark_assignment_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';

class AnswersTabWidget extends StatefulWidget {
  final String itemId;
  const AnswersTabWidget({
    super.key,
    required this.itemId,
  });

  @override
  State<AnswersTabWidget> createState() => _AnswersTabWidgetState();
}

class _AnswersTabWidgetState extends State<AnswersTabWidget> {
  String _selectedCategory = 'SUBMITTED';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final markProvider =
          Provider.of<MarkAssignmentProvider>(context, listen: false);
      markProvider.fetchQuiz(widget.itemId); // ✅ fixed case
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarkAssignmentProvider>(
      builder: (context, markProvider, _) {
        final isLoading = markProvider.isLoading;
        final error = markProvider.error;
        final quizData = markProvider.quizData; // ✅ clean access

        return Scaffold(
          body: Container(
            decoration: Constants.customBoxDecoration(context),
            child: Column(
              children: [
                _buildNavigationRow(quizData),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : error != null
                          ? Center(
                              child: Text(error,
                                  style: AppTextStyles.normal500(
                                      fontSize: 16, color: Colors.red)),
                            )
                          : _selectedCategory == 'SUBMITTED'
                              ? _buildSubmittedContent(quizData)
                              : _buildListContent(_selectedCategory, quizData),
                ),
              ],
            ),
          ),
          floatingActionButton: _selectedCategory == 'MARKED'
              ? FloatingActionButton(
                  backgroundColor: AppColors.primaryLight,
                  onPressed: () async {
                    try {
                      final provider = locator<MarkAssignmentProvider>();
                      final markedQuizzes = (quizData?['marked'] ?? []) as List;

                      for (var quiz in markedQuizzes) {
                        final contentId = quiz['id'].toString();
                        final publish = quiz['published']?.toString() ?? "";
                        print("quesssssss id $contentId");
                        print("quesssssss id $publish");

                        await provider.returnQuiz(publish, contentId);
                      }
                      CustomToaster.toastSuccess(
                          context, 'Success', 'Marks published successfully');

                      provider.fetchQuiz(widget.itemId);
                    } catch (e) {
                      CustomToaster.toastError(context, 'Error', 'Failed: $e');
                    }
                  },
                  child: const Icon(Icons.publish, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Widget _buildNavigationRow(Map<String, dynamic>? quizData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavigationContainer('SUBMITTED', quizData),
          _buildNavigationContainer('UNMARKED', quizData),
          _buildNavigationContainer('MARKED', quizData),
        ],
      ),
    );
  }

  Widget _buildNavigationContainer(
      String text, Map<String, dynamic>? quizData) {
    bool isSelected = _selectedCategory == text;
    int itemCount = _getItemCount(text, quizData);

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = text),
      child: Container(
        width: 89,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFABBFFF) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryLight : Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!isSelected && itemCount > 0)
              Positioned(
                right: 0,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmittedContent(Map<String, dynamic>? quizData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildListContent('SUBMITTED', quizData)),
      ],
    );
  }

  Widget _buildListContent(String category, Map<String, dynamic>? quizData) {
    final List quizzes = (quizData?[category.toLowerCase()] ?? []) as List;

    if (quizzes.isEmpty) {
      return Center(
          child: Text('No $category quizzes',
              style: AppTextStyles.normal500(
                  fontSize: 16, color: AppColors.backgroundDark)));
    }

    return ListView.separated(
      itemCount: quizzes.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        final studentName = quiz['student_name'] ?? '';
        final score = quiz['score']?.toString() ?? '';
        final markingScore = quiz['marking_score']?.toString() ?? '';
        final id = quiz['id']?.toString() ?? '';
        final answers = quiz['answers'] ?? [];
        final dateStr = quiz['date'];

        DateTime? date;
        try {
          date = DateTime.parse(dateStr ?? '');
        } catch (_) {}

        return GestureDetector(
          onTap: () {
            if (category == 'MARKED') {
              CustomToaster.toastInfo(
                  context, 'Info', 'This quiz has already been marked.');
              return;
            }

            final List<Student> students =
                (quizData?[category.toLowerCase()] as List).map((quiz) {
              final attempts = (quiz['answers'] as List).map((ans) {
                return QuizAttempt(
                  questionNumber:
                      int.tryParse(ans['question_id']?.toString() ?? '0') ?? 0,
                  questionText: ans['question'] ?? '',
                  userAnswer: ans['answer'] ?? '',
                  correctAnswer: ans['correct'] ?? '',
                  marks: int.tryParse(ans['marks']?.toString() ?? '0') ?? 0,
                  status: ans['status'],
                  userAnswerImageUrl: ans['user_answer_image'],
                  correctAnswerImageUrl: ans['correct_answer_image'],
                  customMarks:
                      int.tryParse(ans['custom_marks']?.toString() ?? ''),
                );
              }).toList();

              return Student(
                name: quiz['student_name'] ?? '',
                regNo: quiz['reg_no'] ?? '',
                timeTaken: quiz['time_taken']?.toString() ?? '',
                totalQuestions: attempts.length,
                overallScore: quiz['score']?.toString(),
                attempts: attempts,
              );
            }).toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizResultsScreen(
                  students: students,
                  contentId: id,
                  onGraded: () {
                    final provider = Provider.of<MarkAssignmentProvider>(
                        context,
                        listen: false);
                    provider.fetchQuiz(widget.itemId);
                  },
                ),
              ),
            ).then((_) {
              final provider =
                  Provider.of<MarkAssignmentProvider>(context, listen: false);
              provider.fetchQuiz(widget.itemId); // refresh after grading
            });
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(
                studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                style: AppTextStyles.normal500(
                    fontSize: 16, color: AppColors.backgroundLight),
              ),
            ),
            title: Text(studentName,
                style: AppTextStyles.normal600(
                    fontSize: 16, color: Colors.black87)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Score: ${score.isNotEmpty ? score : "N/A"}/${markingScore.isNotEmpty ? markingScore : "N/A"}',
                    style: AppTextStyles.normal500(
                        fontSize: 14, color: Colors.grey[600]!)),
                Text('Questions: ${answers.length} answered',
                    style: AppTextStyles.normal500(
                        fontSize: 14, color: Colors.grey[600]!)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    date != null
                        ? DateFormat('MMM dd').format(date)
                        : 'Invalid date',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(date != null ? DateFormat('HH:mm').format(date) : '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getItemCount(String category, Map<String, dynamic>? quizData) {
    return (quizData?[category.toLowerCase()] ?? []).length;
  }
}
