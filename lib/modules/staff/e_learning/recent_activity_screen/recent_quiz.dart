import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/assessment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/quiz/answer_tab_widget.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_sylabus_content.dart';
import 'package:linkschool/modules/providers/admin/e_learning/single_content_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/model/e-learning/single_content_model.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/staff/e_learning/view/staffview_question.dart';
import 'package:provider/provider.dart';

class StaffRecentQuiz extends StatefulWidget {
  final String quizId;
  final String levelId;
  final String syllabusId;
  final String courseId;
  final String courseName;

  const StaffRecentQuiz({
    super.key,
    required this.quizId,
    required this.levelId,
    required this.syllabusId,
    required this.courseId,
    required this.courseName,
  });

  @override
  _StaffRecentQuizState createState() => _StaffRecentQuizState();
}

class _StaffRecentQuizState extends State<StaffRecentQuiz> {
  late double opacity;
  AssessmentContentItem? quizData;
  bool isLoading = true;
  String? errorMessage;

  // Formatted data for other screens
  List<Map<String, dynamic>>? questions;
  List<Map<String, dynamic>>? correctAnswers;
  Question? questionModel;
  Map<String, dynamic>? questiondata;
  List<Map<String, String>>? classIds;

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    try {
      final singleContentProvider =
          Provider.of<SingleContentProvider>(context, listen: false);
      print('Fetching quiz for ID: ${widget.quizId}');

      final content =
          await singleContentProvider.fetchQuiz(int.parse(widget.quizId));

      if (content == null) {
        setState(() {
          isLoading = false;
          errorMessage =
              singleContentProvider.errorMessage ?? 'Failed to load quiz';
        });
        print('Error: ${singleContentProvider.errorMessage}');
        CustomToaster.toastError(context, 'Error', errorMessage!);
        return;
      }

      setState(() {
        quizData = content;
        _prepareFormattedData();
        isLoading = false;
        errorMessage = null;
      });

      print('Fetched quiz: ${quizData?.title}');
      print('Questions count: ${questions?.length ?? 0}');
      print('Correct answers count: ${correctAnswers?.length ?? 0}');
    } catch (e, stackTrace) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching quiz: $e';
      });
      print('Error fetching quiz: $e\nStackTrace: $stackTrace');
      CustomToaster.toastError(context, 'Error', errorMessage!);
    }
  }

  void _prepareFormattedData() {
    if (quizData == null) return;

    questions = quizData!.questions.map((q) {
      return {
        'question_id': q.questionId,
        'question_text': q.questionText,
        'question_type': q.questionType,
        'question_grade': q.questionGrade,
        'question_files': q.questionFiles.map((f) => f.toJson()).toList(),
        'options': q.options
            .map((opt) => {
                  'text': opt.text,
                  'order': opt.order,
                  'option_files':
                      opt.optionFiles.map((f) => f.toJson()).toList(),
                })
            .toList(),
        // 👇 include correct in the same structure you handle in _initializeQuestions
        'correct': {
          'text': q.correct.text,
          'order': q.correct.order,
        },
      };
    }).toList();

    // Correct answers list (if you still want a flat structure for AssessmentScreen)
    correctAnswers = quizData!.questions
        .map((q) => {
              'question_id': q.questionId.toString(),
              'correct_answer': q.correct.text,
              'correct_order': q.correct.order,
            })
        .toList();

    // Build Question model for edit screen
    questionModel = Question(
      id: quizData!.id ?? 0,
      title: quizData!.title,
      description: quizData!.description,
      selectedClass: quizData!.classes.map((c) => c.name).join(', '),
      endDate: quizData!.endDate != null
          ? DateTime.tryParse(quizData!.endDate!) ?? DateTime.now()
          : DateTime.now(),
      startDate: quizData!.startDate != null
          ? DateTime.tryParse(quizData!.startDate!) ?? DateTime.now()
          : DateTime.now(),
      topic: quizData!.topic ?? 'No Topic',
      duration: quizData!.duration != null
          ? Duration(minutes: int.tryParse(quizData!.duration.toString()) ?? 0)
          : Duration.zero,
      marks: quizData!.grade ?? '0',
      topicId: quizData!.topicId,
    );

    questiondata = {
      'id': quizData!.id,
      'title': quizData!.title,
      'description': quizData!.description,
      'duration': quizData!.duration,
      'marks': 0,
      'start_date': quizData!.startDate,
      'end_date': quizData!.endDate,
      'type': quizData!.type,
      'rank': quizData!.rank,
      'topic_id': quizData!.topicId,
      'topic': quizData!.topic,
      'date_posted': quizData!.datePosted,
      'course_name': widget.courseName,
      'course_id': widget.courseId,
      'level_id': widget.levelId,
      'syllabus_id': widget.syllabusId,
      'term': quizData!.id ?? 1,
      'classes': quizData!.classes.map((c) => c.id).toList(),
    };

    classIds = quizData!.classes
        .map((c) => {
              'id': c.id,
              'name': c.name,
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              print("Popping back to dashboard...");
              //Navigator.pop(context);

              Navigator.of(context).pop();
            },
            icon: Image.asset(
              'assets/icons/arrow_back.png',
              color: AppColors.primaryLight,
              width: 34.0,
              height: 34.0,
            ),
          ),
          title: Text(
            'Quiz',
            style: AppTextStyles.normal600(
              fontSize: 24.0,
              color: AppColors.primaryLight,
            ),
          ),
          actions: [
            if (!isLoading && errorMessage == null)
              PopupMenuButton<String>(
                icon:
                    const Icon(Icons.more_vert, color: AppColors.primaryLight),
                onSelected: (String result) {
                  switch (result) {
                    case 'edit':
                      _navigateToEditScreen();
                      break;
                    case 'delete':
                      _deleteQuiz();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
          ],
          backgroundColor: AppColors.backgroundLight,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: opacity,
                    child: Image.asset(
                      'assets/images/background.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Questions',
                  style: AppTextStyles.normal600(
                      fontSize: 18, color: AppColors.primaryLight),
                ),
              ),
              Tab(
                child: Text(
                  'Answers',
                  style: AppTextStyles.normal600(
                      fontSize: 18, color: AppColors.primaryLight),
                ),
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            _fetchQuizData();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: Constants.customBoxDecoration(context),
                    child: TabBarView(
                      children: [
                        _buildQuestionTab(),
                        _buildAnswersTab(),
                      ],
                    ),
                  ),
      ),
    );
  }

  void _navigateToEditScreen() {
    if (questionModel == null || questions == null || classIds == null) {
      CustomToaster.toastError(
          context, 'Error', 'Quiz data not available for editing');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffViewQuestionScreen(
          question: questionModel!,
          questiondata: questiondata ?? {},
          class_ids: classIds!,
          syllabusClasses: quizData!.classes.map((c) => c.name).join(', '),
          questions: questions!,
          editMode: true,
        ),
      ),
    ).then((_) {
      // Refresh data when returning from edit screen
      _fetchQuizData();
    });
  }

  Future<void> _deleteQuiz() async {
    try {
      final provider = locator<DeleteSyllabusProvider>();
      await provider.DeleteQuiz(widget.quizId.toString());
      CustomToaster.toastSuccess(
          context, 'Success', 'Quiz deleted successfully');
      Navigator.of(context).pop();
    } catch (e) {
      print('Error deleting quiz: $e');
      CustomToaster.toastError(context, 'Error', 'Failed to delete quiz: $e');
    }
  }

  Widget _buildQuestionTab() {
    if (quizData == null) {
      return const Center(child: Text('No quiz data available'));
    }

    final endDate = quizData!.endDate != null
        ? DateTime.tryParse(quizData!.endDate!)
        : null;

    final duration = quizData!.duration != null
        ? Duration(minutes: int.tryParse(quizData!.duration.toString()) ?? 0)
        : Duration.zero;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoRow(
            'Due:', endDate != null ? _formatDate(endDate) : 'No due date'),
        const Divider(color: Colors.grey),
        Text(
          quizData!.title,
          style: AppTextStyles.normal600(
              fontSize: 20, color: AppColors.primaryLight),
        ),
        const Divider(color: AppColors.eLearningBtnColor1),
        _buildInfoRow('Duration:', '${duration.inMinutes} minutes'),
        const Divider(color: Colors.grey),
        _buildInfoRow(
            'Description:',
            quizData!.description.isNotEmpty
                ? quizData!.description
                : 'No Description'),
        const Divider(color: Colors.grey),
        const SizedBox(height: 20),
        CustomLongElevatedButton(
          onPressed: () {
            if (questions == null || correctAnswers == null) {
              CustomToaster.toastError(
                  context, 'Error', 'Quiz questions not loaded properly');
              return;
            }

            print("Navigating to AssessmentScreen with:");
            print("Questions: ${questions!.length}");
            print("Correct Answers: ${correctAnswers!.length}");
            print("Quiz duration: $duration");
            print(
                "Sample question: ${questions!.isNotEmpty ? questions!.first : 'None'}");
            print(
                "Sample correct answer: ${correctAnswers!.isNotEmpty ? correctAnswers!.first : 'None'}");

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssessmentScreen(
                  title: quizData!.title,
                  duration: duration,
                  questions: questions!,
                  mark: quizData!.grade,
                  correctAnswer: correctAnswers!,
                ),
              ),
            );
          },
          backgroundColor: AppColors.eLearningBtnColor1,
          text: 'Take Quiz',
          textStyle: AppTextStyles.normal600(
              fontSize: 18, color: AppColors.backgroundLight),
        ),
      ],
    );
  }

  Widget _buildAnswersTab() {
    return AnswersTabWidget(
      itemId: widget.quizId.toString(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.normal600(
                fontSize: 16, color: AppColors.textGray),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.normal400(
                  fontSize: 16, color: AppColors.backgroundDark),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)} ${date.year} ${_formatTime(date)}';
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
