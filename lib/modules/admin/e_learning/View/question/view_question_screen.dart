import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/assessment_screen.dart';
import 'package:linkschool/modules/admin/e_learning/View/quiz/quiz_screen.dart';
import 'package:linkschool/modules/admin/e_learning/empty_subject_screen.dart';
import 'package:linkschool/modules/admin/e_learning/question_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_question.dart';
import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/staff/e_learning/form_classes/edit_staff_skill_behaviour_screen.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewQuestionScreen extends StatefulWidget {
  final Question question;
  final Map<String, dynamic> questiondata;
  final dynamic class_ids;
  final syllabusClasses;
  final List<Map<String, dynamic>>? questions;
  final bool editMode;
  const ViewQuestionScreen({
    super.key,
    required this.question,
    this.class_ids,
    required this.questiondata,
    this.syllabusClasses,
    this.questions,
    this.editMode = false,
  });

  @override
  State<ViewQuestionScreen> createState() => _ViewQuestionScreenState();
}

class _ViewQuestionScreenState extends State<ViewQuestionScreen> {
  List<Map<String, dynamic>> createdQuestions = [];
  late double opacity;
  late Question currentQuestion;
  int? _selectedTopicId;
  bool showSaveButton = false;

  @override
  void initState() {
    super.initState();
    currentQuestion = widget.question;

  if (widget.questions != null) {
    createdQuestions = widget.questions!;
     showSaveButton = true; 
  }
 _initializeQuestions();
    if (widget.editMode) {
      showSaveButton = true; 
    }
  }


void _initializeQuestions() {
  if (widget.questions == null || widget.questions!.isEmpty) return;

  createdQuestions = widget.questions!.map((q) {
    final questionType = q['question_type'] ?? q['type'] ?? 'short_answer';
    final questionText = q['question_text'] ?? q['title'] ?? '';
    final grade = q['question_grade']?.toString() ?? q['grade']?.toString() ?? '1';
    final id =q['question_id']?.toString();
    // Initialize controllers
    final questionController = TextEditingController(text: questionText);
    final marksController = TextEditingController(text: grade);

    // Handle options for multiple choice
    List<TextEditingController> optionControllers = [];
    List<int> correctOptions = [];
    TextEditingController? correctAnswerController;

    if (questionType == 'multiple_choice') {
      final options = (q['options'] is List) ? q['options'] as List : [];
      optionControllers = options.map<TextEditingController>((opt) {
        return TextEditingController(text: (opt is Map && opt['text'] != null) ? opt['text'].toString() : '');
      }).toList();

      final correct = (q['correct'] is List) ? q['correct'] as List : [];
      correctOptions = correct.map<int>((c) {
        if (c is Map && c['order'] != null) {
          return c['order'] is int ? c['order'] : int.tryParse(c['order'].toString()) ?? 0;
        }
        return 0;
      }).toList();
    } else {
      if (q['correct'] is List && (q['correct'] as List).isNotEmpty) {
        final firstCorrect = (q['correct'] as List).first;
        correctAnswerController = TextEditingController(
          text: (firstCorrect is Map && firstCorrect['text'] != null)
              ? firstCorrect['text'].toString()
              : '',
        );
      } else if (q['correct'] is Map && q['correct']?['text'] != null) {
        correctAnswerController = TextEditingController(
          text: q['correct']['text'].toString(),
        );
      } else {
        correctAnswerController = TextEditingController();
      }
    }

    // Handle files
    final questionFiles = (q['question_files'] is List) ? q['question_files'] as List : [];
    String? imagePath;
    String? imageName;

    if (questionFiles.isNotEmpty && questionFiles.first is Map) {
      imagePath = questionFiles.first['file']?.toString();
      imageName = questionFiles.first['file_name']?.toString();
    }

    // Defensive: always provide a Widget for 'widget' key to avoid null Widget exception
    final questionCardWidget = _buildQuestionCard(
      questionType,
      questionController,
      marksController,
      optionControllers,
      correctOptions,
      correctAnswerController,
      false,
    );

    return {
      'type': questionType,
      'title': questionText,
      'grade': grade,
      'topic': q['topic'] ?? currentQuestion.topic,
      'options': q['options'] ?? [],
      'correct': q['correct'] ?? [],
      'imagePath': imagePath,
      'imageName': imageName,
      'question_id': id,
      'questionController': questionController,
      'marksController': marksController,
      'optionControllers': optionControllers,
      'correctOptions': correctOptions,
      'correctAnswerController': correctAnswerController,
      'isExpanded': false,
      'widget': questionCardWidget, // Always provide a Widget
    };
  }).toList();
}

  

    @override
  void dispose() {

    for (var question in createdQuestions) {
      final questionController = question['questionController'] as TextEditingController?;
      final marksController = question['marksController'] as TextEditingController?;
      final optionControllers = question['optionControllers'] as List<TextEditingController>?;
      final correctAnswerController = question['correctAnswerController'] as TextEditingController?;
      
      questionController?.dispose();
      marksController?.dispose();
      correctAnswerController?.dispose();
      
      if (optionControllers != null) {
        for (var controller in optionControllers) {
          controller.dispose();
        }
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context)
                .popUntil(ModalRoute.withName('/empty_subject'));
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Question',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
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
        actions: [
          if (showSaveButton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CustomSaveElevatedButton(
                onPressed: _saveQuestions,
                text: 'Save',
              ),
            ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildQuestionBackground(),
              ...createdQuestions.map((question) => question['widget']),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

 Future<void> _saveQuestions() async {
  setState(() {
    List<Map<String, dynamic>> updatedQuestions = [];
    for (var question in createdQuestions) {
      final questionType = question['type'];
      final questionController = question['questionController'] as TextEditingController;
      final marksController = question['marksController'] as TextEditingController;
      final optionControllers = question['optionControllers'] as List<TextEditingController>;
      final correctOptions = question['correctOptions'] as List<int>;
      final imagePath = question['imagePath'] as String?;
      final correctAnswerController = question['correctAnswerController'] as TextEditingController?;

      updatedQuestions.add({
        'type': questionType,
        'title': questionController.text,
        'grade': marksController.text.isNotEmpty ? marksController.text : '1',
        'topic': currentQuestion.topic,
        'options': questionType == 'multiple_choice'
            ? optionControllers.asMap().entries.map((e) => {
                  'order': e.key,
                  'text': e.value.text,
                  'options_file': question['options'][e.key]['options_file'],
                }).toList()
            : [],
        'correct': questionType == 'multiple_choice'
            ? correctOptions.map((i) => {
                  'order': i,
                  'text': optionControllers[i].text,
                }).toList()
            : [
                {'order': 0, 'text': correctAnswerController?.text ?? ''}
              ],
        'imagePath': imagePath,
        'imageName': question['imageName'],
        'questionController': questionController,
        'marksController': marksController,
        'optionControllers': optionControllers,
        'correctOptions': correctOptions,
        'correctAnswerController': correctAnswerController,
        'isExpanded': question['isExpanded'] ?? false,
        'widget': _buildQuestionCard(
          questionType,
          questionController,
          marksController,
          optionControllers,
          correctOptions,
          correctAnswerController,
          question['isExpanded'] ?? false,
        ),
      });
    }
    createdQuestions = updatedQuestions;
  });

  final quizProvider = Provider.of<QuizProvider>(context, listen: false);

  // Convert Duration to total seconds for serialization
  final durationInSeconds = currentQuestion.duration.inSeconds;

  final assessment = {
    'setting': {
      'title': widget.questiondata['title'],
      'description': widget.questiondata['description'],
      'classes': widget.class_ids,
      "course_name": widget.questiondata['course_name'],
      "level_id": widget.questiondata['level_id'],
      'duration': durationInSeconds, // Use the converted value
      'start_date': widget.questiondata['start_date'],
      'end_date': widget.questiondata['end_date'],
      'topic': widget.questiondata['topic'] ,
      "creator_id": widget.questiondata['creator_id'],
      'creator_name': widget.questiondata['creator_name'],
      'course_id': widget.questiondata['course_id'],
      "term": widget.questiondata['term'],
      'marks': widget.questiondata['marks'],
      'syllabus_id': widget.questiondata['syllabus_id'],
      'topic_id': widget.questiondata['topic_id'],
    },
    'questions': createdQuestions.map((q) {
      List<Map<String, dynamic>> options = [];
      if (q['options'] != null) {
        options = (q['options'] as List).map<Map<String, dynamic>>((opt) {
          return {
            'order': opt['order'],
            'text': opt['text'],
            'option_files': opt['options_file'] != null
                ? [{
                    'file_name': opt['options_file']['file_name'],
                    'old_file_name': opt['options_file']['file_name'],
                    'type': 'image',
                    'file': opt['options_file']['base64'],
                  }]
                : [],
          };
        }).toList();
      }

      dynamic correct;
      if (q['correct'] is List && (q['correct'] as List).isNotEmpty) {
        correct = (q['correct'] as List).first;
      } else if (q['correct'] is Map) {
        correct = q['correct'];
      } else {
        correct = {};
      }

      return {
        'question_text': q['title'],
        'question_grade': q['grade'],
        'question_type': q['type'],
        'question_files': q['imagePath'] != null
            ? [
                {
                  'file_name': q['imageName'] ?? 'question_${q['type']}_${createdQuestions.indexOf(q)}.jpg',
                  'old_file_name': q['imageName'] ?? 'question_${q['type']}_${createdQuestions.indexOf(q)}.jpg',
                  'type': 'image',
                  'file': q['imagePath'],
                }
              ]
            : [],
        'options': options,
        'correct': correct,
      };
    }).toList(),
  };

  try {
    await quizProvider.addTest(assessment);
    setState(() {
      showSaveButton = false; 
    });
    print('Quiz posted!');
    if (mounted) {
      CustomToaster.toastSuccess(context, "Success", "Questions saved successfully");
      Navigator.of(context)
                .popUntil(ModalRoute.withName('/empty_subject'));
    }
  } catch (e) {
    print('Error posting quiz: $e');
    CustomToaster.toastError(context, "Error", "Error saving questions: $e");
  }
}



  Widget _buildSavedQuestionRow(
      String questionType, String questionText, String marks, List<Map<String, dynamic>> options) {
    IconData iconData = questionType == 'short_answer' ? Icons.short_text : Icons.list;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuizScreen(question: currentQuestion)),
            );
          },
          child: ListTile(
            leading: Icon(iconData),
            title: Text(
              questionType == 'short_answer' ? 'Short answer' : 'Multiple choice',
              style: AppTextStyles.normal500(fontSize: 16, color: AppColors.textGray),
            ),
            subtitle: Text(
              questionText.isEmpty ? 'Untitled Question' : questionText,
              style: AppTextStyles.normal400(fontSize: 14, color: AppColors.textGray),
            ),
            trailing: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/e_learning/kebab_icon.svg',
                width: 24,
                height: 24,
                placeholderBuilder: (context) => Image.asset(
                  'assets/icons/e_learning/kebab_icon.png',
                  width: 24,
                  height: 24,
                ),
              ),
              onPressed: () {
                _showKebabMenu(context);
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: Colors.grey),
        ),
      ],
    );
  }

  void _showKebabMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              _editQuestion();
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              _deleteQuestion();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBackground() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => _editQuestion(),
          child: Container(
            width: constraints.maxWidth,
            height: 164,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      child: SvgPicture.asset(
                        'assets/images/e-learning/question_bg2.svg',
                        fit: BoxFit.cover,
                        width: constraints.maxWidth,
                        height: 164,
                        placeholderBuilder: (context) => Image.asset(
                          'assets/images/e-learning/question_bg2.png',
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: 164,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _showKebabMenu(context),
                    child: SvgPicture.asset(
                      'assets/icons/e_learning/kebab_icon.svg',
                      width: 24,
                      height: 24,
                      color: Colors.white,
                      placeholderBuilder: (context) => Image.asset(
                        'assets/icons/e_learning/kebab_icon.png',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(
                        value: currentQuestion.title,
                        style: AppTextStyles.normal600(
                            fontSize: 20, color: AppColors.backgroundLight),
                      ),
                      const SizedBox(height: 16.0),
                      _buildInfoSection(
                        value: currentQuestion.description,
                        style: AppTextStyles.normal400(
                            fontSize: 16, color: AppColors.backgroundLight),
                      ),
                      const Divider(color: Colors.white, height: 1),
                      const SizedBox(height: 16.0),
                      _buildInfoSection(
                        value: _formatDuration(currentQuestion.duration),
                        style: AppTextStyles.normal600(
                            fontSize: 16, color: AppColors.backgroundLight),
                        icon: 'assets/icons/e_learning/stopwatch_icon.svg',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editQuestion() async {
    final result = await Navigator.push<Question>(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(
          question: currentQuestion,
          isEditing: true,
          onSave: (Question question) {},
          syllabusId: widget.questiondata['syllabus_id'],
          courseId: widget.questiondata['course_id'],
          classId: widget.questiondata['class_id'],
          courseName: widget.questiondata['course_name'],
          levelId: widget.questiondata['level_id'],
            questions: widget.questions, 
        ),
      ),

    );
  print('result: $result');
    if (result != null) {
      setState(() {
        currentQuestion = result;
      });
    }
  }

  void _deleteQuestion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Question'),
          content: const Text('Are you sure you want to delete this question?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/e_learning/preview_icon.svg',
                placeholderBuilder: (context) => Image.asset(
                  'assets/icons/e_learning/preview_icon.png',
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AssessmentScreen(
                            timer: currentQuestion.duration,
                          )),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/e_learning/circle_plus_icon.svg',
                placeholderBuilder: (context) => Image.asset(
                  'assets/icons/e_learning/circle_plus_icon.png',
                ),
              ),
              onPressed: () => _showQuestionTypeOverlay(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestionTypeOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Select Question Type',
                  style: AppTextStyles.normal600(
                    fontSize: 18,
                    color: AppColors.textGray,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildQuestionTypeOption(
                icon: Icons.short_text,
                text: 'Short answer',
                onTap: () => _addQuestion('short_answer'),
              ),
              _buildQuestionTypeOption(
                icon: Icons.list,
                text: 'Multiple choice',
                onTap: () => _addQuestion('multiple_choice'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addQuestion(String questionType) {
    final questionController = TextEditingController();
    final marksController = TextEditingController(text: '1');
    final optionControllers = questionType == 'multiple_choice'
        ? [TextEditingController(), TextEditingController()]
        : <TextEditingController>[];
    final correctOptions = <int>[];
    final correctAnswerController = questionType == 'short_answer' ? TextEditingController() : null;

    Navigator.pop(context);
    setState(() {
      // Collapse all existing questions
      for (var question in createdQuestions) {
        question['isExpanded'] = false;
        question['widget'] = _buildQuestionCard(
          question['type'],
          question['questionController'],
          question['marksController'],
          question['optionControllers'],
          question['correctOptions'],
          question['correctAnswerController'],
          false,
        );
      }

      // Add new question (expanded)
      createdQuestions.add({
        'type': questionType,
        'title': '',
        'grade': '1',
        'topic': currentQuestion.topic,
        'options': questionType == 'multiple_choice'
            ? optionControllers.asMap().entries.map((e) => {
                  'order': e.key,
                  'text': e.value.text,
                  'options_file': null,
                }).toList()
            : [],
        'correct': [],
        'imagePath': null,
        'imageName': null,
        'questionController': questionController,
        'marksController': marksController,
        'optionControllers': optionControllers,
        'correctOptions': correctOptions,
        'correctAnswerController': correctAnswerController,
        'isExpanded': true,
        'widget': _buildQuestionCard(
          questionType,
          questionController,
          marksController,
          optionControllers,
          correctOptions,
          correctAnswerController,
          true,
        ),
      });
      showSaveButton = true;
    });
  }

  Widget _buildQuestionCard(
    String questionType,
    TextEditingController questionController,
    TextEditingController marksController,
    List<TextEditingController> optionControllers,
    List<int> correctOptions,
    TextEditingController? correctAnswerController,
    bool isExpanded,
  ) {
    bool isEditing = false;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        int index = createdQuestions.indexWhere((q) => q['questionController'] == questionController);
        String? imageName = index != -1 ? createdQuestions[index]['imageName'] : null;

      void _collapseAllOtherCards(int currentIndex) {
  for (int i = 0; i < createdQuestions.length; i++) {
    if (i != currentIndex && createdQuestions[i]['isExpanded'] == true) {
      createdQuestions[i]['isExpanded'] = false;
      createdQuestions[i]['widget'] = _buildQuestionCard(
        createdQuestions[i]['type'],
        createdQuestions[i]['questionController'],
        createdQuestions[i]['marksController'],
        createdQuestions[i]['optionControllers'],
        createdQuestions[i]['correctOptions'],
        createdQuestions[i]['correctAnswerController'],
        false,
      );
    }
  }
}

// Update the collapsedView() method in _buildQuestionCard
Widget collapsedView() {
  return GestureDetector(
    onTap: () {
      setState(() {
      
        _collapseAllOtherCards(index);
        isExpanded = true;
        if (index != -1) {
          createdQuestions[index]['isExpanded'] = true;
          createdQuestions[index]['widget'] = _buildQuestionCard(
            questionType,
            questionController,
            marksController,
            optionControllers,
            correctOptions,
            correctAnswerController,
            true,
          );
        }
      });
    },
    child: Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            height: 50,
            color: AppColors.textGray.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  questionType == 'short_answer' ? Icons.short_text : Icons.list,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 8),
                Text(
                  questionType == 'short_answer' ? 'Short answer' : 'Multiple choice',
                  style: AppTextStyles.normal500(fontSize: 16, color: AppColors.textGray),
                ),
                const Spacer(),
                Icon(Icons.expand_more, color: AppColors.textGray),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, top: 15),
            child: Text(
              (questionController.text.isEmpty ? 'Untitled Question' : questionController.text),
              style: AppTextStyles.normal400(fontSize: 14, color: AppColors.textGray),
            ),
          ),
        ], 
      ),
    ),
  );
}

        Widget expandedView() {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: const Color.fromRGBO(235, 235, 235, 1),
                  child: Row(
                    children: [
                      Icon(
                        questionType == 'short_answer' ? Icons.short_text : Icons.list,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          questionType == 'short_answer' ? 'Short answer' : 'Multiple choice',
                          style: AppTextStyles.normal600(fontSize: 16, color: AppColors.textGray),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.textGray,
                        ),
                        onPressed: () {
                          setState(() {
                            isExpanded = false;
                            if (index != -1) {
                              createdQuestions[index]['isExpanded'] = false;
                              createdQuestions[index]['widget'] = _buildQuestionCard(
                                questionType,
                                questionController,
                                marksController,
                                optionControllers,
                                correctOptions,
                                correctAnswerController,
                                false,
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: questionController,
                      decoration: InputDecoration(
                        hintText: 'Question',
                        border: const UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            setState(() {
                              isExpanded = true;
                              if (index != -1) {
                                createdQuestions[index]['isExpanded'] = true;
                              }
                            });
                            _showAttachmentOptions(context, index: index, isQuestion: true);
                          },
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isEditing = true;
                          isExpanded = true;
                          if (index != -1) {
                            createdQuestions[index]['isExpanded'] = true;
                          }
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          isEditing = false;
                          isExpanded = false;
                          if (index != -1) {
                            createdQuestions[index]['isExpanded'] = false;
                            createdQuestions[index]['widget'] = _buildQuestionCard(
                              questionType,
                              questionController,
                              marksController,
                              optionControllers,
                              correctOptions,
                              correctAnswerController,
                              false,
                            );
                          }
                        });
                      },
                      onChanged: (value) {
                        if (index != -1) {
                          setState(() {
                            createdQuestions[index]['title'] = value;
                          });
                        }
                      },
                    ),
                    if (imageName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ' ${imageName}.',
                            style: AppTextStyles.normal400(fontSize: 14, color: AppColors.textGray),
                          ),

                           TextButton(
                        onPressed: () {
                          if (index != -1) {
                            setState(() {
                              createdQuestions[index]['imagePath'] = null;
                              createdQuestions[index]['imageName'] = null;
                            });
                          }
                        },
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                        ],
                      ),
                    
                     
                    ],
                    if (questionType == 'short_answer' && correctAnswerController != null) ...[
          
                      TextField(
                        controller: correctAnswerController,
                        decoration: const InputDecoration(
                          hintText: 'Correct Answer',
                          border: UnderlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (index != -1) {
                            setState(() {
                              createdQuestions[index]['correct'] = [
                                {'order': 0, 'text': value}
                              ];
                            });
                          }
                        },
                      ),
                    ],
                    if (questionType == 'multiple_choice')
                      Column(
                        children: [
                          ...optionControllers.asMap().entries.map((entry) => _buildOptionRow(
                                entry.key,
                                entry.value,
                                setState,
                                () async {
                                  final imageData = await _pickImageWithFilePicker();
                                  if (imageData != null && index != -1) {
                                    setState(() {
                                      createdQuestions[index]['options'][entry.key]['options_file'] = {
                                        'file_name': imageData['file_name'],
                                        'base64': imageData['base64'],
                                      };
                                      entry.value.text = imageData['file_name'];
                                    });
                                  }
                                },
                                () {
                                  setState(() {
                                    correctOptions.clear();
                                    correctOptions.add(entry.key);
                                    if (index != -1) {
                                      createdQuestions[index]['correctOptions'] = correctOptions;
                                      createdQuestions[index]['correct'] = correctOptions
                                          .map((i) => {
                                                'order': i,
                                                'text': optionControllers[i].text,
                                              })
                                          .toList();
                                    }
                                  });
                                },
                                correctOptions.contains(entry.key),
                                createdQuestions[index]['options'][entry.key]['options_file'] != null,
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  optionControllers.add(TextEditingController());
                                  if (index != -1) {
                                    createdQuestions[index]['options'].add({
                                      'order': optionControllers.length - 1,
                                      'text': '',
                                      'options_file': null,
                                    });
                                    createdQuestions[index]['optionControllers'] = optionControllers;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Add option',
                                    style: AppTextStyles.normal600(
                                      fontSize: 14,
                                      color: AppColors.textGray.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Divider(color: Colors.grey, thickness: 0.6, height: 1),
                        ],
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[400]!)),
                        ),
                        child: TextField(
                          controller: marksController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text('marks'),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.grey),
                      onPressed: () {
                        _duplicateQuestion(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Question copied')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: (){
                        _showDeleteQuestionDialog(context, index);
                      }
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isEditing ? AppColors.primaryLight.withOpacity(0.5) : Colors.transparent,
              width: 1,
            ),
          ),
          child: isExpanded ? expandedView() : collapsedView(),
        );
      },
    );
  }

  void _duplicateQuestion(int questionIndex) {
  if (questionIndex < 0 || questionIndex >= createdQuestions.length) return;

  final originalQuestion = createdQuestions[questionIndex];
  
  // Create new controllers with the same values
  final questionController = TextEditingController(text: originalQuestion['questionController'].text);
  final marksController = TextEditingController(text: originalQuestion['marksController'].text);
  
  // Handle option controllers
  final optionControllers = (originalQuestion['optionControllers'] as List<TextEditingController>)
      .map((c) => TextEditingController(text: c.text))
      .toList();
  
  // Handle correct answer controller if exists
  final correctAnswerController = originalQuestion['correctAnswerController'] != null
      ? TextEditingController(text: originalQuestion['correctAnswerController'].text)
      : null;
  
  // Copy the correct options
  final correctOptions = List<int>.from(originalQuestion['correctOptions']);
  
  // Copy image data if exists
  final imagePath = originalQuestion['imagePath'];
  final imageName = originalQuestion['imageName'];
  
  // Copy options data
  final options = (originalQuestion['options'] as List).map((opt) {
    return {
      'order': opt['order'],
      'text': opt['text'],
      'options_file': opt['options_file'] != null 
          ? Map<String, dynamic>.from(opt['options_file'])
          : null,
    };
  }).toList();
  
  setState(() {
    createdQuestions.add({
      'type': originalQuestion['type'],
      'title': '${originalQuestion['title']} (Copy)',
      'grade': originalQuestion['grade'],
      'topic': originalQuestion['topic'],
      'options': options,
      'correct': List<Map<String, dynamic>>.from(originalQuestion['correct']),
      'imagePath': imagePath,
      'imageName': imageName,
      'questionController': questionController,
      'marksController': marksController,
      'optionControllers': optionControllers,
      'correctOptions': correctOptions,
      'correctAnswerController': correctAnswerController,
      'isExpanded': true,
      'widget': _buildQuestionCard(
        originalQuestion['type'],
        questionController,
        marksController,
        optionControllers,
        correctOptions,
        correctAnswerController,
        true,
      ),
    });
    
    // Show save button since we've added a new question
    showSaveButton = true;
  });
}

  

 Future<Map<String, dynamic>?> _pickImageWithFilePicker() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );
  
  if (result != null) {
    PlatformFile file = result.files.first;
    String fileName = file.name; // This preserves the original filename
    
    if (file.bytes != null) {
      String base64String = base64Encode(file.bytes!);
      return {'file_name': fileName, 'base64': base64String};
    } else if (file.path != null) {
      final fileBytes = await File(file.path!).readAsBytes();
      String base64String = base64Encode(fileBytes);
      return {'file_name': fileName, 'base64': base64String};
    }
  }
  return null;
}




void _showDeleteQuestionDialog(BuildContext context, int questionIndex) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteQuestionFromList(questionIndex);
            },
          ),
        ],
      );
    },
  );
}

void _deleteQuestionFromList(int questionIndex) async {
    if (questionIndex < 0 || questionIndex >= createdQuestions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid question index')),
      );
      return;
    }

    final settingId = widget.question.id.toString();
    final  id =  createdQuestions[questionIndex]['question_id']?.toString(); 
    final provider = locator<DeleteQuestionProvider>();

    try {
   
      await provider.deleteQuestion(id!, settingId);
      setState(() {
        final questionToDelete = createdQuestions[questionIndex];

        // Dispose controllers
        final questionController = questionToDelete['questionController'] as TextEditingController;
        final marksController = questionToDelete['marksController'] as TextEditingController;
        final optionControllers = questionToDelete['optionControllers'] as List<TextEditingController>;
        final correctAnswerController = questionToDelete['correctAnswerController'] as TextEditingController?;

        questionController.dispose();
        marksController.dispose();
        correctAnswerController?.dispose();
        for (var controller in optionControllers) {
          controller.dispose();
        }

        // Remove the question
        createdQuestions.removeAt(questionIndex);

        // Update save button visibility
        showSaveButton = createdQuestions.isNotEmpty;
      });
             CustomToaster.toastSuccess(context, "Success", "Questions deleted successfully");
      

      // Navigate back if no questions remain
      if (createdQuestions.isEmpty) {
        Navigator.of(context).popUntil(ModalRoute.withName('/empty_subject'));
      }
    } catch (e) {
    
      CustomToaster.toastSuccess(context, "Success", "Questions deleted successfully");
    }
  }
Widget _buildOptionRow(
    int index,
    TextEditingController controller,
    Function setState,
    VoidCallback onImagePick,
    VoidCallback onSelectCorrect,
    bool isCorrect,
    bool hasImage) {
  return Row(
    children: [
      Radio<bool>(
        value: true,
        groupValue: isCorrect,
        onChanged: (value) => onSelectCorrect(),
      ),
      Expanded(
        child: TextField(
          controller: controller,
          enabled: !hasImage,
          decoration: InputDecoration(
            hintText: 'Option',
            border: const UnderlineInputBorder(),
            hintStyle: TextStyle(
              color: hasImage ? Colors.grey : null,
            ),
          ),
          onChanged: (value) {
            setState(() {
              int qIndex = createdQuestions.indexWhere((q) => q['optionControllers'].contains(controller));
              if (qIndex != -1) {
                createdQuestions[qIndex]['options'][index]['text'] = value;
              }
            });
          },
        ),
      ),
   
      _buildOptionKebabButton(context, 
        createdQuestions.indexWhere((q) => q['optionControllers'].contains(controller)), 
        index, 
        setState
      ),
    ],
  );
}

Widget _buildOptionKebabButton(BuildContext context, int questionIndex, int optionIndex, Function setState) {
  return PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert),
    onSelected: (String value) {
      switch (value) {
        case 'attachment':
          _showAttachmentOptions(context, index: questionIndex, optionIndex: optionIndex, isQuestion: false);
          break;
        case 'delete':
          _deleteOption(questionIndex, optionIndex, setState);
          break;
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(
        value: 'attachment',
        child: ListTile(
          leading: Icon(Icons.attach_file),
          title: Text('Add attachment'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem<String>(
        value: 'delete',
        child: ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: Text('Delete', style: TextStyle(color: Colors.red)),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ],
  );
}
  void _showAttachmentOptions(BuildContext context, {required int index, int? optionIndex, required bool isQuestion}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Upload image'),
                onTap: () async {
                  Navigator.pop(context);
                  final imageData = await _pickImageWithFilePicker();
                  if (imageData != null && index != -1) {
                    setState(() {
                      createdQuestions[index]['isExpanded'] = true;
                      createdQuestions[index]['widget'] = _buildQuestionCard(
                        createdQuestions[index]['type'],
                        createdQuestions[index]['questionController'],
                        createdQuestions[index]['marksController'],
                        createdQuestions[index]['optionControllers'],
                        createdQuestions[index]['correctOptions'],
                        createdQuestions[index]['correctAnswerController'],
                        true,
                      );
                      if (isQuestion) {
                        createdQuestions[index]['imagePath'] = imageData['base64'];
                        createdQuestions[index]['imageName'] = imageData['file_name'];
                        (createdQuestions[index]['questionController'] as TextEditingController).clear();
                      } else if (optionIndex != null) {
                        createdQuestions[index]['options'][optionIndex]['options_file'] = {
                          'file_name': imageData['file_name'],
                          'base64': imageData['base64'],
                        };
                        (createdQuestions[index]['optionControllers'] as List<TextEditingController>)[optionIndex].text = imageData['file_name'];
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final imageData = await _pickImageWithFilePicker();
                  if (imageData != null && index != -1) {
                    setState(() {
                      createdQuestions[index]['isExpanded'] = true;
                      createdQuestions[index]['widget'] = _buildQuestionCard(
                        createdQuestions[index]['type'],
                        createdQuestions[index]['questionController'],
                        createdQuestions[index]['marksController'],
                        createdQuestions[index]['optionControllers'],
                        createdQuestions[index]['correctOptions'],
                        createdQuestions[index]['correctAnswerController'],
                        true,
                      );
                      if (isQuestion) {
                        createdQuestions[index]['imagePath'] = imageData['base64'];
                        createdQuestions[index]['imageName'] = imageData['file_name'];
                        (createdQuestions[index]['questionController'] as TextEditingController).clear();
                      } else if (optionIndex != null) {
                        createdQuestions[index]['options'][optionIndex]['options_file'] = {
                          'file_name': imageData['file_name'],
                          'base64': imageData['base64'],
                        };
                        (createdQuestions[index]['optionControllers'] as List<TextEditingController>)[optionIndex].text = imageData['file_name'];
                      }
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }



// Add this method to handle option deletion:
void _deleteOption(int questionIndex, int optionIndex, Function setState) {
  if (questionIndex >= 0 && questionIndex < createdQuestions.length) {
    final question = createdQuestions[questionIndex];
    final optionControllers = question['optionControllers'] as List<TextEditingController>;
    final correctOptions = question['correctOptions'] as List<int>;
    
 
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Option'),
          content: const Text('Are you sure you want to delete this option?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _performOptionDeletion(questionIndex, optionIndex, setState);
              },
            ),
          ],
        );
      },
    );
  }
}


void _performOptionDeletion(int questionIndex, int optionIndex, Function setState) {
  setState(() {
    final question = createdQuestions[questionIndex];
    final optionControllers = question['optionControllers'] as List<TextEditingController>;
    final correctOptions = question['correctOptions'] as List<int>;
    final options = question['options'] as List<Map<String, dynamic>>;
    
    // Dispose the controller for the option being deleted
    optionControllers[optionIndex].dispose();
    
    // Remove the option controller
    optionControllers.removeAt(optionIndex);
    
    // Remove the option data
    options.removeAt(optionIndex);
    
    // Update correct options indices
    List<int> updatedCorrectOptions = [];
    for (int correctIndex in correctOptions) {
      if (correctIndex < optionIndex) {
        // Index stays the same
        updatedCorrectOptions.add(correctIndex);
      } else if (correctIndex > optionIndex) {
        // Index decreases by 1
        updatedCorrectOptions.add(correctIndex - 1);
      }
      // If correctIndex == optionIndex, we don't add it (it's deleted)
    }
    
    // Update the options order
    for (int i = 0; i < options.length; i++) {
      options[i]['order'] = i;
    }
    
    // Update the question data
    createdQuestions[questionIndex]['optionControllers'] = optionControllers;
    createdQuestions[questionIndex]['correctOptions'] = updatedCorrectOptions;
    createdQuestions[questionIndex]['options'] = options;
    createdQuestions[questionIndex]['correct'] = updatedCorrectOptions
        .map((i) => {
              'order': i,
              'text': optionControllers[i].text,
            })
        .toList();
    
    // Rebuild the widget
    createdQuestions[questionIndex]['widget'] = _buildQuestionCard(
      createdQuestions[questionIndex]['type'],
      createdQuestions[questionIndex]['questionController'],
      createdQuestions[questionIndex]['marksController'],
      createdQuestions[questionIndex]['optionControllers'],
      createdQuestions[questionIndex]['correctOptions'],
      createdQuestions[questionIndex]['correctAnswerController'],
      createdQuestions[questionIndex]['isExpanded'] ?? false,
    );
  });
  
}

  Future<Map<String, dynamic>?> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;
      if (file.bytes != null) {
        String base64String = base64Encode(file.bytes!);
        return {'file_name': fileName, 'base64': base64String};
      } else if (file.path != null) {
        final fileBytes = await File(file.path!).readAsBytes();
        String base64String = base64Encode(fileBytes);
        return {'file_name': fileName, 'base64': base64String};
      }
    }
    return null;
  }


  Widget _buildInfoSection({
    String? label,
    required String value,
    required TextStyle style,
    String? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                color: style.color,
                placeholderBuilder: (context) => Image.asset(
                  icon.replaceFirst('.svg', '.png'),
                  width: 20,
                  height: 20,
                  color: style.color,
                ),
              ),
            ),
          if (label != null)
            Text(
              label,
              style: style,
            ),
          Expanded(
            child: Text(
              value,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
  

  Widget _buildQuestionTypeOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(248, 248, 248, 1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryLight),
            const SizedBox(width: 16),
            Text(
              text,
              style: AppTextStyles.normal500(
                fontSize: 16,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  
  if (hours == 0) {
    return '${minutes}min';
  } else if (minutes == 0) {
    return '${hours}h';
  } else {
    return '${hours}h ${minutes}min';
  }
}
}

class AttachmentItem {
  final String content;
  final String iconPath;
  final String? base64Content;

  AttachmentItem({
    required this.content,
    required this.iconPath,
    this.base64Content,
  });
}


// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:linkschool/modules/admin/e_learning/View/question/assessment_screen.dart';
// import 'package:linkschool/modules/admin/e_learning/View/quiz/quiz_screen.dart';
// import 'package:linkschool/modules/admin/e_learning/empty_subject_screen.dart';
// import 'package:linkschool/modules/admin/e_learning/question_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/e-learning/question_model.dart';
// import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ViewQuestionScreen extends StatefulWidget {
//   final Question question;
//   final Map<String, dynamic> questiondata;
//   final dynamic class_ids;
//   final syllabusClasses;
//   const ViewQuestionScreen({
//     super.key,
//     required this.question,
//     this.class_ids,
//     required this.questiondata,
//     this.syllabusClasses,
//   });

//   @override
//   State<ViewQuestionScreen> createState() => _ViewQuestionScreenState();
// }

// class _ViewQuestionScreenState extends State<ViewQuestionScreen> {
//   List<Map<String, dynamic>> createdQuestions = [];
//   late double opacity;
//   late Question currentQuestion;
//   int? _selectedTopicId;
//   bool showSaveButton = false;

//   @override
//   void initState() {
//     super.initState();
//     currentQuestion = widget.question;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context)
//                 .popUntil(ModalRoute.withName('/empty_subject'));
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.primaryLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Question',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.primaryLight,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//         actions: [
//           if (showSaveButton)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: CustomSaveElevatedButton(
//                 onPressed: _saveQuestions,
//                 text: 'Save',
//               ),
//             ),
//         ],
//       ),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         decoration: Constants.customBoxDecoration(context),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildQuestionBackground(),
//               ...createdQuestions.map((question) => question['widget']),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavigation(),
//     );
//   }

//   Future<void> _saveQuestions() async {
//     setState(() {
//       List<Map<String, dynamic>> updatedQuestions = [];
//       for (var question in createdQuestions) {
//         final questionType = question['type'];
//         final questionController = question['questionController'] as TextEditingController;
//         final marksController = question['marksController'] as TextEditingController;
//         final optionControllers = question['optionControllers'] as List<TextEditingController>;
//         final correctOptions = question['correctOptions'] as List<int>;
//         final imagePath = question['imagePath'] as String?;
//         final correctAnswerController = question['correctAnswerController'] as TextEditingController?;

//         updatedQuestions.add({
//           'type': questionType,
//           'title': questionController.text,
//           'grade': marksController.text.isNotEmpty ? marksController.text : '1',
//           'topic': currentQuestion.topic,
//           'options': questionType == 'multiple_choice'
//               ? optionControllers.asMap().entries.map((e) => {
//                     'order': e.key,
//                     'text': e.value.text,
//                     'options_file': question['options'][e.key]['options_file'],
//                   }).toList()
//               : [],
//           'correct': questionType == 'multiple_choice'
//               ? correctOptions.map((i) => {
//                     'order': i,
//                     'text': optionControllers[i].text,
//                   }).toList()
//               : [
//                   {'order': 0, 'text': correctAnswerController?.text ?? ''}
//                 ],
//           'imagePath': imagePath,
//           'imageName': question['imageName'],
//           'questionController': questionController,
//           'marksController': marksController,
//           'optionControllers': optionControllers,
//           'correctOptions': correctOptions,
//           'correctAnswerController': correctAnswerController,
//           'widget': _buildQuestionCard(
//             questionType,
//             questionController,
//             marksController,
//             optionControllers,
//             correctOptions,
//             correctAnswerController,
//           ),
//         });
//       }
//       createdQuestions = updatedQuestions;
//       showSaveButton = false;
//     });

//     final quizProvider = Provider.of<QuizProvider>(context, listen: false);

//     final assessment = {
//       'setting': {
//         'title': widget.questiondata['title'],
//         'description': widget.questiondata['description'],
//         'classes': widget.class_ids,
//         "course_name": widget.questiondata['course_name'],
//         "level_id": widget.questiondata['level_id'],
//         'duration': int.tryParse(widget.questiondata['duration'] ?? '0') ?? 0,
//         'start_date': widget.questiondata['start_date'],
//         'end_date': widget.questiondata['end_date'],
//         'topic': widget.questiondata['topic'],
//         "creator_id": widget.questiondata['creator_id'],
//         'creator_name': widget.questiondata['creator_name'],
//         'course_id': widget.questiondata['course_id'],
//         "term": widget.questiondata['term'],
//         'marks': widget.questiondata['marks'],
//         'syllabus_id': widget.questiondata['syllabus_id'],
//         'topic_id': widget.questiondata['topic_id'],
//       },
//       'questions': createdQuestions.map((q) {
//         List<Map<String, dynamic>> options = [];
//         if (q['options'] != null) {
//           options = (q['options'] as List).map<Map<String, dynamic>>((opt) {
//             return {
//               'order': opt['order'],
//               'text': opt['text'],
//               'option_files': opt['options_file'] != null
//                   ? [{
//                       'file_name': opt['options_file']['file_name'],
//                       'old_file_name': opt['options_file']['file_name'],
//                       'type': 'image',
//                       'file': opt['options_file']['base64'],
//                     }]
//                   : [],
//             };
//           }).toList();
//         }

//         dynamic correct;
//         if (q['correct'] is List && (q['correct'] as List).isNotEmpty) {
//           correct = (q['correct'] as List).first;
//         } else if (q['correct'] is Map) {
//           correct = q['correct'];
//         } else {
//           correct = {};
//         }

//         return {
//           'question_text': q['title'],
//           'question_grade': q['grade'],
//           'question_type': q['type'],
//           'question_files': q['imagePath'] != null
//               ? [
//                   {
//                     'file_name': q['imageName'] ?? 'question_${q['type']}_${createdQuestions.indexOf(q)}.jpg',
//                     'old_file_name': q['imageName'] ?? 'question_${q['type']}_${createdQuestions.indexOf(q)}.jpg',
//                     'type': 'image',
//                     'file': q['imagePath'],
//                   }
//                 ]
//               : [],
//           'options': options,
//           'correct': correct,
//         };
//       }).toList(),
//     };

//     try {
//       await quizProvider.addTest(assessment);
//       print('Quiz posted!');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Questions saved successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error posting quiz: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(quizProvider.message ?? 'Error saving questions: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Widget _buildSavedQuestionRow(
//       String questionType, String questionText, String marks, List<Map<String, dynamic>> options) {
//     IconData iconData = questionType == 'short_answer' ? Icons.short_text : Icons.list;

//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => QuizScreen(question: currentQuestion)),
//             );
//           },
//           child: ListTile(
//             leading: Icon(iconData),
//             title: Text(
//               questionType == 'short_answer' ? 'Short answer' : 'Multiple choice',
//               style: AppTextStyles.normal500(fontSize: 16, color: AppColors.textGray),
//             ),
//             subtitle: Text(
//               questionText.isEmpty ? 'Untitled Question' : questionText,
//               style: AppTextStyles.normal400(fontSize: 14, color: AppColors.textGray),
//             ),
//             trailing: IconButton(
//               icon: SvgPicture.asset(
//                 'assets/icons/e_learning/kebab_icon.svg',
//                 width: 24,
//                 height: 24,
//                 placeholderBuilder: (context) => Image.asset(
//                   'assets/icons/e_learning/kebab_icon.png',
//                   width: 24,
//                   height: 24,
//                 ),
//               ),
//               onPressed: () {
//                 _showKebabMenu(context);
//               },
//             ),
//           ),
//         ),
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.0),
//           child: Divider(color: Colors.grey),
//         ),
//       ],
//     );
//   }

//   void _showKebabMenu(BuildContext context) {
//     showMenu(
//       context: context,
//       position: const RelativeRect.fromLTRB(100, 100, 0, 0),
//       items: [
//         PopupMenuItem(
//           child: ListTile(
//             leading: const Icon(Icons.edit),
//             title: const Text('Edit'),
//             onTap: () {
//               Navigator.pop(context);
//               _editQuestion();
//             },
//           ),
//         ),
//         PopupMenuItem(
//           child: ListTile(
//             leading: const Icon(Icons.delete),
//             title: const Text('Delete'),
//             onTap: () {
//               Navigator.pop(context);
//               _deleteQuestion();
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuestionBackground() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return GestureDetector(
//           onTap: () => _editQuestion(),
//           child: Container(
//             width: constraints.maxWidth,
//             height: 164,
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             child: Stack(
//               children: [
//                 Positioned.fill(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: OverflowBox(
//                       maxWidth: double.infinity,
//                       child: SvgPicture.asset(
//                         'assets/images/e-learning/question_bg2.svg',
//                         fit: BoxFit.cover,
//                         width: constraints.maxWidth,
//                         height: 164,
//                         placeholderBuilder: (context) => Image.asset(
//                           'assets/images/e-learning/question_bg2.png',
//                           fit: BoxFit.cover,
//                           width: constraints.maxWidth,
//                           height: 164,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 16,
//                   right: 8,
//                   child: GestureDetector(
//                     onTap: () => _showKebabMenu(context),
//                     child: SvgPicture.asset(
//                       'assets/icons/e_learning/kebab_icon.svg',
//                       width: 24,
//                       height: 24,
//                       color: Colors.white,
//                       placeholderBuilder: (context) => Image.asset(
//                         'assets/icons/e_learning/kebab_icon.png',
//                         width: 24,
//                         height: 24,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildInfoSection(
//                         value: currentQuestion.title,
//                         style: AppTextStyles.normal600(
//                             fontSize: 20, color: AppColors.backgroundLight),
//                       ),
//                       const SizedBox(height: 16.0),
//                       _buildInfoSection(
//                         value: currentQuestion.description,
//                         style: AppTextStyles.normal400(
//                             fontSize: 16, color: AppColors.backgroundLight),
//                       ),
//                       const Divider(color: Colors.white, height: 1),
//                       const SizedBox(height: 16.0),
//                       _buildInfoSection(
//                         value: _formatDuration(currentQuestion.duration),
//                         style: AppTextStyles.normal600(
//                             fontSize: 16, color: AppColors.backgroundLight),
//                         icon: 'assets/icons/e_learning/stopwatch_icon.svg',
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _editQuestion() async {
//     final result = await Navigator.push<Question>(
//       context,
//       MaterialPageRoute(
//         builder: (context) => QuestionScreen(
//           question: currentQuestion,
//           isEditing: true,
//           onSave: (Question question) {},
//         ),
//       ),
//     );

//     if (result != null) {
//       setState(() {
//         currentQuestion = result;
//       });
//     }
//   }

//   void _deleteQuestion() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Question'),
//           content: const Text('Are you sure you want to delete this question?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Delete'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildBottomNavigation() {
//     return Container(
//       height: 65,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: IconButton(
//               icon: SvgPicture.asset(
//                 'assets/icons/e_learning/preview_icon.svg',
//                 placeholderBuilder: (context) => Image.asset(
//                   'assets/icons/e_learning/preview_icon.png',
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => AssessmentScreen(
//                             timer: currentQuestion.duration,
//                           )),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: IconButton(
//               icon: SvgPicture.asset(
//                 'assets/icons/e_learning/circle_plus_icon.svg',
//                 placeholderBuilder: (context) => Image.asset(
//                   'assets/icons/e_learning/circle_plus_icon.png',
//                 ),
//               ),
//               onPressed: () => _showQuestionTypeOverlay(context),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showQuestionTypeOverlay(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Center(
//                 child: Text(
//                   'Select Question Type',
//                   style: AppTextStyles.normal600(
//                     fontSize: 18,
//                     color: AppColors.textGray,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               _buildQuestionTypeOption(
//                 icon: Icons.short_text,
//                 text: 'Short answer',
//                 onTap: () => _addQuestion('short_answer'),
//               ),
//               _buildQuestionTypeOption(
//                 icon: Icons.list,
//                 text: 'Multiple choice',
//                 onTap: () => _addQuestion('multiple_choice'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _addQuestion(String questionType) {
//     final questionController = TextEditingController();
//     final marksController = TextEditingController(text: '1');
//     final optionControllers = questionType == 'multiple_choice'
//         ? [TextEditingController(), TextEditingController()]
//         : <TextEditingController>[];
//     final correctOptions = <int>[];
//     final correctAnswerController = questionType == 'short_answer' ? TextEditingController() : null;

//     Navigator.pop(context);
//     setState(() {
//       createdQuestions.add({
//         'type': questionType,
//         'title': '',
//         'grade': '1',
//         'topic': currentQuestion.topic,
//         'options': questionType == 'multiple_choice'
//             ? optionControllers.asMap().entries.map((e) => {
//                   'order': e.key,
//                   'text': e.value.text,
//                   'options_file': null,
//                 }).toList()
//             : [],
//         'correct': [],
//         'imagePath': null,
//         'imageName': null,
//         'questionController': questionController,
//         'marksController': marksController,
//         'optionControllers': optionControllers,
//         'correctOptions': correctOptions,
//         'correctAnswerController': correctAnswerController,
//         'widget': _buildQuestionCard(
//           questionType,
//           questionController,
//           marksController,
//           optionControllers,
//           correctOptions,
//           correctAnswerController,
//         ),
//       });
//       showSaveButton = true;
//     });
//   }

//   Widget _buildQuestionCard(
//     String questionType,
//     TextEditingController questionController,
//     TextEditingController marksController,
//     List<TextEditingController> optionControllers,
//     List<int> correctOptions,
//     TextEditingController? correctAnswerController,
//   ) {
//     bool isEditing = false;

//     return StatefulBuilder(
//       builder: (BuildContext context, StateSetter setState) {
//         int index = createdQuestions.indexWhere((q) => q['questionController'] == questionController);
//         String? imagePath = index != -1 ? createdQuestions[index]['imagePath'] : null;
//         String? imageName = index != -1 ? createdQuestions[index]['imageName'] : null;

//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: BorderSide(
//               color: isEditing ? AppColors.primaryLight.withOpacity(0.5) : Colors.transparent,
//               width: 1,
//             ),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   color: const Color.fromRGBO(235, 235, 235, 1),
//                   child: Row(
//                     children: [
//                       Icon(
//                         questionType == 'short_answer' ? Icons.short_text : Icons.list,
//                         color: AppColors.primaryLight,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         questionType == 'short_answer' ? 'Short answer' : 'Multiple choice',
//                         style: AppTextStyles.normal600(fontSize: 16, color: AppColors.textGray),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextField(
//                       controller: questionController,
//                       decoration: InputDecoration(
//                         hintText: 'Question',
//                         border: const UnderlineInputBorder(),
//                         suffixIcon: IconButton(
//                           icon: const Icon(Icons.more_vert),
//                           onPressed: () => _showAttachmentOptions(context, index: index, isQuestion: true),
//                         ),
//                       ),
//                       onTap: () {
//                         setState(() {
//                           isEditing = true;
//                         });
//                       },
//                       onEditingComplete: () {
//                         setState(() {
//                           isEditing = false;
//                         });
//                       },
//                       onChanged: (value) {
//                         if (index != -1) {
//                           setState(() {
//                             createdQuestions[index]['title'] = value;
//                           });
//                         }
//                       },
//                     ),
//                     if (imageName != null) ...[
//                       const SizedBox(height: 8),
//                       Text(
//                         'Attached image: $imageName',
//                         style: AppTextStyles.normal400(fontSize: 14, color: AppColors.textGray),
//                       ),
//                       const SizedBox(height: 8),
//                       TextButton(
//                         onPressed: () {
//                           if (index != -1) {
//                             setState(() {
//                               createdQuestions[index]['imagePath'] = null;
//                               createdQuestions[index]['imageName'] = null;
//                             });
//                           }
//                         },
//                         child: Text(
//                           'Remove Image',
//                           style: AppTextStyles.normal600(fontSize: 14.0, color: Colors.red),
//                         ),
//                       ),
//                     ],
//                     if (questionType == 'short_answer' && correctAnswerController != null) ...[
//                       const SizedBox(height: 16),
//                       TextField(
//                         controller: correctAnswerController,
//                         decoration: const InputDecoration(
//                           hintText: 'Correct Answer',
//                           border: UnderlineInputBorder(),
//                         ),
//                         onChanged: (value) {
//                           if (index != -1) {
//                             setState(() {
//                               createdQuestions[index]['correct'] = [
//                                 {'order': 0, 'text': value}
//                               ];
//                             });
//                           }
//                         },
//                       ),
//                     ],
//                     if (questionType == 'multiple_choice')
//                       Column(
//                         children: [
//                           ...optionControllers.asMap().entries.map((entry) => _buildOptionRow(
//                                 entry.key,
//                                 entry.value,
//                                 setState,
//                                 () async {
//                                   final imageData = await _pickImage(context, ImageSource.gallery);
//                                   if (imageData != null && index != -1) {
//                                     setState(() {
//                                       createdQuestions[index]['options'][entry.key]['options_file'] = {
//                                         'file_name': imageData['file_name'],
//                                         'base64': imageData['base64'],
//                                       };
//                                       entry.value.text = imageData['file_name'];
//                                     });
//                                   }
//                                 },
//                                 () {
//                                   setState(() {
//                                     correctOptions.clear();
//                                     correctOptions.add(entry.key);
//                                     if (index != -1) {
//                                       createdQuestions[index]['correctOptions'] = correctOptions;
//                                       createdQuestions[index]['correct'] = correctOptions
//                                           .map((i) => {
//                                                 'order': i,
//                                                 'text': optionControllers[i].text,
//                                               })
//                                           .toList();
//                                     }
//                                   });
//                                 },
//                                 correctOptions.contains(entry.key),
//                                 createdQuestions[index]['options'][entry.key]['options_file'] != null,
//                               )),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 16),
//                             child: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   optionControllers.add(TextEditingController());
//                                   if (index != -1) {
//                                     createdQuestions[index]['options'].add({
//                                       'order': optionControllers.length - 1,
//                                       'text': '',
//                                       'options_file': null,
//                                     });
//                                     createdQuestions[index]['optionControllers'] = optionControllers;
//                                   }
//                                 });
//                               },
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     'Add option',
//                                     style: AppTextStyles.normal600(
//                                       fontSize: 14,
//                                       color: AppColors.textGray.withOpacity(0.5),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8.0),
//                           const Divider(color: Colors.grey, thickness: 0.6, height: 1),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 16.0),
//                       child: Container(
//                         width: 60,
//                         decoration: BoxDecoration(
//                           border: Border(bottom: BorderSide(color: Colors.grey[400]!)),
//                         ),
//                         child: TextField(
//                           controller: marksController,
//                           keyboardType: TextInputType.number,
//                           textAlign: TextAlign.center,
//                           decoration: const InputDecoration(border: InputBorder.none),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     const Padding(
//                       padding: EdgeInsets.only(top: 16.0),
//                       child: Text('marks'),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.copy, color: Colors.grey),
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Question copied')),
//                         );
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.grey),
//                       onPressed: () {
//                         setState(() {
//                           if (index != -1) {
//                             createdQuestions.removeAt(index);
//                             questionController.dispose();
//                             marksController.dispose();
//                             correctAnswerController?.dispose();
//                             for (var controller in optionControllers) {
//                               controller.dispose();
//                             }
//                           }
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<Map<String, dynamic>?> _pickImage(BuildContext context, ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
//     if (pickedFile != null) {
//       final file = File(pickedFile.path);
//       final bytes = await file.readAsBytes();
//       final base64String = base64Encode(bytes);
//       return {
//         'file_name': pickedFile.name,
//         'base64': base64String,
//       };
//     }
//     return null;
//   }

//   Widget _buildOptionRow(
//       int index,
//       TextEditingController controller,
//       Function setState,
//       VoidCallback onImagePick,
//       VoidCallback onSelectCorrect,
//       bool isCorrect,
//       bool hasImage) {
//     return Row(
//       children: [
//         Radio<bool>(
//           value: true,
//           groupValue: isCorrect,
//           onChanged: (value) => onSelectCorrect(),
//         ),
//         Expanded(
//           child: TextField(
//             controller: controller,
//             enabled: !hasImage,
//             decoration: InputDecoration(
//               hintText: 'Option',
//               border: const UnderlineInputBorder(),
//               hintStyle: TextStyle(
//                 color: hasImage ? Colors.grey : null,
//               ),
//             ),
//             onChanged: (value) {
//               setState(() {
//                 int qIndex = createdQuestions.indexWhere((q) => q['optionControllers'].contains(controller));
//                 if (qIndex != -1) {
//                   createdQuestions[qIndex]['options'][index]['text'] = value;
//                 }
//               });
//             },
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.more_vert),
//           onPressed: () {
//             int qIndex = createdQuestions.indexWhere((q) => q['optionControllers'].contains(controller));
//             if (qIndex != -1) {
//               _showAttachmentOptions(context, index: qIndex, optionIndex: index, isQuestion: false);
//             }
//           },
//         ),
//       ],
//     );
//   }

//   void _showAttachmentOptions(BuildContext context, {required int index, int? optionIndex, required bool isQuestion}) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.link),
//                 title: const Text('Insert link'),
//                 onTap: () => _showInsertLinkDialog(context, index: index, optionIndex: optionIndex, isQuestion: isQuestion),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.image),
//                 title: const Text('Upload image'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final imageData = await _pickImage(context, ImageSource.gallery);
//                   if (imageData != null && index != -1) {
//                     setState(() {
//                       if (isQuestion) {
//                         createdQuestions[index]['imagePath'] = imageData['base64'];
//                         createdQuestions[index]['imageName'] = imageData['file_name'];
//                         (createdQuestions[index]['questionController'] as TextEditingController).clear();
//                       } else if (optionIndex != null) {
//                         createdQuestions[index]['options'][optionIndex]['options_file'] = {
//                           'file_name': imageData['file_name'],
//                           'base64': imageData['base64'],
//                         };
//                         (createdQuestions[index]['optionControllers'] as List<TextEditingController>)[optionIndex].text = imageData['file_name'];
//                       }
//                     });
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Take photo'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final imageData = await _pickImage(context, ImageSource.camera);
//                   if (imageData != null && index != -1) {
//                     setState(() {
//                       if (isQuestion) {
//                         createdQuestions[index]['imagePath'] = imageData['base64'];
//                         createdQuestions[index]['imageName'] = imageData['file_name'];
//                         (createdQuestions[index]['questionController'] as TextEditingController).clear();
//                       } else if (optionIndex != null) {
//                         createdQuestions[index]['options'][optionIndex]['options_file'] = {
//                           'file_name': imageData['file_name'],
//                           'base64': imageData['base64'],
//                         };
//                         (createdQuestions[index]['optionControllers'] as List<TextEditingController>)[optionIndex].text = imageData['file_name'];
//                       }
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<Map<String, dynamic>?> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       PlatformFile file = result.files.first;
//       String fileName = file.name;
//       if (file.bytes != null) {
//         String base64String = base64Encode(file.bytes!);
//         return {'file_name': fileName, 'base64': base64String};
//       } else if (file.path != null) {
//         final fileBytes = await File(file.path!).readAsBytes();
//         String base64String = base64Encode(fileBytes);
//         return {'file_name': fileName, 'base64': base64String};
//       }
//     }
//     return null;
//   }

//   void _showInsertLinkDialog(BuildContext context, {required int index, int? optionIndex, required bool isQuestion}) {
//     TextEditingController linkController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Insert Link'),
//           content: TextField(
//             controller: linkController,
//             decoration: const InputDecoration(hintText: 'Enter link here (https://...)'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 final link = linkController.text.trim();
//                 if (link.isNotEmpty && index != -1) {
//                   setState(() {
//                     if (isQuestion) {
//                       createdQuestions[index]['link'] = link;
//                     } else if (optionIndex != null) {
//                       createdQuestions[index]['options'][optionIndex]['link'] = link;
//                     }
//                   });
//                 }
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildInfoSection({
//     String? label,
//     required String value,
//     required TextStyle style,
//     String? icon,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         children: [
//           if (icon != null)
//             Padding(
//               padding: const EdgeInsets.only(right: 8.0),
//               child: SvgPicture.asset(
//                 icon,
//                 width: 20,
//                 height: 20,
//                 color: style.color,
//                 placeholderBuilder: (context) => Image.asset(
//                   icon.replaceFirst('.svg', '.png'),
//                   width: 20,
//                   height: 20,
//                   color: style.color,
//                 ),
//               ),
//             ),
//           if (label != null)
//             Text(
//               label,
//               style: style,
//             ),
//           Expanded(
//             child: Text(
//               value,
//               style: style,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuestionTypeOption({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         margin: const EdgeInsets.only(bottom: 8),
//         decoration: BoxDecoration(
//           color: const Color.fromRGBO(248, 248, 248, 1),
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: AppColors.primaryLight),
//             const SizedBox(width: 16),
//             Text(
//               text,
//               style: AppTextStyles.normal500(
//                 fontSize: 16,
//                 color: AppColors.primaryLight,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDuration(Duration duration) {
//     return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
//   }
// }

// class AttachmentItem {
//   final String content;
//   final String iconPath;
//   final String? base64Content;

//   AttachmentItem({
//     required this.content,
//     required this.iconPath,
//     this.base64Content,
//   });
// }