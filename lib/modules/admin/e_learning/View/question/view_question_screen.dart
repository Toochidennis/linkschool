import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/preview_assessment.dart';
import 'package:linkschool/modules/admin/e_learning/View/quiz/quiz_screen.dart';
import 'package:linkschool/modules/admin/e_learning/question_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/providers/admin/e_learning/delete_question.dart';
import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:linkschool/modules/staff/e_learning/form_classes/edit_staff_skill_behaviour_screen.dart';
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
  final VoidCallback? onSaveFlag;
  final VoidCallback? onCreation;
  final String? source;
  const ViewQuestionScreen(
      {super.key,
      required this.question,
      this.class_ids,
      required this.questiondata,
      this.syllabusClasses,
      this.questions,
      this.editMode = false,
      this.onSaveFlag,
      this.onCreation,
      this.source});

  @override
  State<ViewQuestionScreen> createState() => _ViewQuestionScreenState();
}

class _ViewQuestionScreenState extends State<ViewQuestionScreen> {
  List<Map<String, dynamic>> createdQuestions = [];
  late double opacity;
  late Question currentQuestion;
  int? _selectedTopicId;
  bool showSaveButton = false;
  bool _isSaving = false;
  String? creatorName;
  String? creatorRole;
  int? creatorId;

  @override
  void initState() {
    super.initState();
    currentQuestion = widget.question;

    if (widget.questions != null) {
      createdQuestions = widget.questions!;
      showSaveButton = true;
      // Print the IDs of each question in widget.questions
      for (var q in widget.questions!) {
        print("Question ID: ${q['question_id']}");
      }
    }
    _initializeQuestions();
    if (widget.editMode) {
      showSaveButton = true;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
      if (storedUserData != null) {
        final processedData = storedUserData is String
            ? json.decode(storedUserData)
            : storedUserData as Map<String, dynamic>;
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final profile = data['profile'] ?? {};
        final settings = data['settings'] ?? {};

        setState(() {
          creatorId = profile['staff_id'] as int?;
          creatorRole = profile['role']?.toString();
          creatorName = profile['name']?.toString();
          final academicYear = settings['year']?.toString();
          final academicTerm = settings['term'] as int?;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

 void _initializeQuestions() {
  if (widget.questions == null || widget.questions!.isEmpty) return;

  createdQuestions = widget.questions!.map((q) {
    final questionType = q['question_type'] ?? q['type'] ?? 'short_answer';
    final questionText = q['question_text'] ?? q['title'] ?? '';
    final id = q['question_id']?.toString() ?? '';
    print('SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS$id');
    final grade =
        q['question_grade']?.toString() ?? q['grade']?.toString() ?? '1';

    // Initialize controllers
    final questionController = TextEditingController(text: questionText);
    final marksController = TextEditingController(text: grade);

    // Handle options for multiple choice
    List<TextEditingController> optionControllers = [];
    List<int> correctOptions = [];
    TextEditingController? correctAnswerController;
    List<Map<String, dynamic>> optionsData = [];

    if (questionType == 'multiple_choice') {
      final options = (q['options'] is List) ? q['options'] as List : [];

      // Initialize options data and controllers
      for (int i = 0; i < options.length; i++) {
        final opt = options[i];
        final optText =
            (opt is Map && opt['text'] != null) ? opt['text'].toString() : '';

        optionControllers.add(TextEditingController(text: optText));

        // Handle option files - FIXED
        Map<String, dynamic>? optionFile;
        if (opt is Map &&
            opt['option_files'] is List &&
            (opt['option_files'] as List).isNotEmpty) {
          final file = (opt['option_files'] as List).first;
          if (file is Map) {
            // Try to get file content first
            String? fileContent = file['file']?.toString();
            
            // If file is empty, use file_name instead
            if (fileContent == null || fileContent.isEmpty) {
              fileContent = file['file_name']?.toString();
            }
            
            if (fileContent != null && fileContent.isNotEmpty) {
              optionFile = {
                'file_name': file['file_name']?.toString() ?? '',
                'base64': fileContent, // This now contains either base64 or file path
              };
            }
          }
        }

        optionsData.add({
          'order': i,
          'text': optText,
          'options_file': optionFile,
        });
      }

      // Handle correct answer for multiple choice
      final correct = q['correct'];
      if (correct is Map && correct['order'] != null) {
        final correctOrder = correct['order'] is int
            ? correct['order']
            : int.tryParse(correct['order'].toString()) ?? -1;
        if (correctOrder >= 0 && correctOrder < optionControllers.length) {
          correctOptions.add(correctOrder);
        }
      }
    } else {
      // Handle correct answer for short answer
      final correct = q['correct'];
      if (correct is Map && correct['text'] != null) {
        correctAnswerController =
            TextEditingController(text: correct['text'].toString());
      } else {
        correctAnswerController = TextEditingController();
      }
    }

    // Handle question files - FIXED
    final questionFiles =
        (q['question_files'] is List) ? q['question_files'] as List : [];
    String? imagePath;
    String? imageName;
    if (questionFiles.isNotEmpty && questionFiles.first is Map) {
      final file = questionFiles.first;
      
      // Try to get file content first
      String? fileContent = file['file']?.toString();
      
      // If file is empty, use file_name instead
      if (fileContent == null || fileContent.isEmpty) {
        fileContent = file['file_name']?.toString();
      }
      
      if (fileContent != null && fileContent.isNotEmpty) {
        imagePath = fileContent;
        imageName = file['file_name']?.toString() ?? 'question_image.jpg';
      }
    }

    // Build the question card widget
    final questionCardWidget = _buildQuestionCard(
      questionType,
      questionController,
      marksController,
      optionControllers,
      correctOptions,
      correctAnswerController,
      false,
    );
    print('Questions ID: $id, Type: $questionType, Text: $questionText');
    print('Question image path: $imagePath'); // Debug log

    return {
      'type': questionType,
      'title': questionText,
      'grade': grade,
      'topic': q['topic'] ?? currentQuestion.topic,
      'options': optionsData,
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
      'widget': questionCardWidget,
    };
  }).toList();
}

  @override
  void dispose() {
    for (var question in createdQuestions) {
      final questionController =
          question['questionController'] as TextEditingController?;
      final marksController =
          question['marksController'] as TextEditingController?;
      final optionControllers =
          question['optionControllers'] as List<TextEditingController>?;
      final correctAnswerController =
          question['correctAnswerController'] as TextEditingController?;

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
            if (widget.source == 'empty_subject') {
              Navigator.of(context)
                  .popUntil(ModalRoute.withName('/empty_subject'));
            } else {
              Navigator.of(context).pop();
            }
            // Navigator.of(context)
            //     .popUntil(ModalRoute.withName('/empty_subject'));
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
                isLoading: _isSaving,
              ),
            )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildQuestionBackground(),
              if (createdQuestions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/e-learning/Student stress-amico.svg',
                          width: 280,
                          height: 280,
                          placeholderBuilder: (context) => Image.asset(
                            'assets/images/e-learning/Student stress-amico.svg',
                            width: 150,
                            height: 150,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Questions Available',
                          style: AppTextStyles.normal600(
                            fontSize: 18,
                            color: AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                )
              else
                ...createdQuestions.map((question) => question['widget']),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Future<void> _saveQuestions() async {
    final validationErrors = _validateQuestions();

    if (validationErrors.isNotEmpty) {
      final errorMessage = validationErrors.join('\n');
      CustomToaster.toastError(context, "Validation Error", errorMessage);
      return;
    }

    // Update createdQuestions with the latest data from controllers

    setState(() {
      List<Map<String, dynamic>> updatedQuestions = [];
      for (var question in createdQuestions) {
        final questionType = question['type'];
        final questionId = question['question_id'] ?? 0;
        final questionController =
            question['questionController'] as TextEditingController;
        final marksController =
            question['marksController'] as TextEditingController;
        final optionControllers =
            question['optionControllers'] as List<TextEditingController>;
        final correctOptions = question['correctOptions'] as List<int>;
        final imagePath = question['imagePath'] as String?;
        final correctAnswerController =
            question['correctAnswerController'] as TextEditingController?;

        updatedQuestions.add({
          'type': questionType,
          'title': questionController.text,
          'grade': marksController.text.isNotEmpty ? marksController.text : '1',
          'topic': currentQuestion.topic,
          'question_id': questionId ?? 0,
          'options': questionType == 'multiple_choice'
              ? optionControllers
                  .asMap()
                  .entries
                  .map((e) => {
                        'order': e.key,
                        'text': e.value.text,
                        'options_file': question['options'][e.key]
                            ['options_file'],
                      })
                  .toList()
              : [],
          'correct': questionType == 'multiple_choice'
              ? correctOptions
                  .map((i) => {
                        'order': i,
                        'text': optionControllers[i].text,
                      })
                  .toList()
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
    if (widget.questiondata['creator_name'] == null ||
        widget.questiondata['creator_id'] == null) {
      await _loadUserData();
      creatorName = creatorName ?? 'Unknown';
      creatorId = creatorId;
    } else {
      creatorName = widget.questiondata['creator_name'];
      creatorId = widget.questiondata['creator_id'];
    }
    var classId = widget.class_ids ?? [];
    if (classId == null || classId.isEmpty) {
      classId = widget.questiondata['classes'] ?? [];
    } else {
      classId = widget.class_ids;
    }

    final assessment = {
      'setting': {
        'title': widget.questiondata['title'],
        'description': widget.questiondata['description'],
        'classes': widget.class_ids ?? [],
        "course_name": widget.questiondata['course_name'],
        "level_id": widget.questiondata['level_id'],
        "duration": currentQuestion.duration.inMinutes,
        'start_date': widget.questiondata['start_date'],
        'end_date': widget.questiondata['end_date'],
        'topic': widget.questiondata['topic'],
        "creator_id": creatorId,
        'creator_name': creatorName,
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
            Map<String, dynamic>? optionFile = opt['options_file'];

            return {
              'order': opt['order'],
              'text': opt['text'] ?? '',
              'option_files': optionFile != null
                  ? [
                      {
                        'file_name': optionFile['file_name'] ?? '',
                        'old_file_name': '',
                        'type': 'image',
                        'file': optionFile['base64'] ?? '',
                      }
                    ]
                  : [],
            };
          }).toList();
        }

        // Fixed: Proper correct answer handling
        dynamic correct = {};
        if (q['correct'] is List && (q['correct'] as List).isNotEmpty) {
          correct = (q['correct'] as List).first;
        } else if (q['correct'] is Map) {
          correct = q['correct'];
        }

        return {
          'question_text': q['title'] ?? '',
          'question_grade': q['grade'] ?? '1',
          'question_type': q['type'],
          'question_files': q['imagePath'] != null
              ? [
                  {
                    'file_name': q['imageName'] ?? '',
                    'old_file_name': "",
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
    final Updatedassessment = {
      'setting': {
        "id": widget.question.id,
        'title': widget.questiondata['title'],
        'description': widget.questiondata['description'],
        'classes': widget.class_ids ?? [],
        "course_name": widget.questiondata['course_name'],
        "level_id": widget.questiondata['level_id'],
        "duration": currentQuestion.duration.inMinutes,
        'start_date': widget.questiondata['start_date'],
        'end_date': widget.questiondata['end_date'],
        'topic': widget.questiondata['topic'],
        "creator_id": creatorId,
        'creator_name': creatorName,
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
            Map<String, dynamic>? optionFile = opt['options_file'];

            return {
              'order': opt['order'],
              'text': opt['text'] ?? '',
              'option_files': optionFile != null
                  ? [
                      {
                        'file_name': optionFile['file_name'] ?? '',
                        'old_file_name': '',
                        'type': 'image',
                        'file': optionFile['base64'] ?? '',
                      }
                    ]
                  : [],
            };
          }).toList();
        }

        // Handle correct answer
        dynamic correct = {};
        if (q['correct'] is List && (q['correct'] as List).isNotEmpty) {
          correct = (q['correct'] as List).first;
        } else if (q['correct'] is Map) {
          correct = q['correct'];
        }

        return {
          'question_id': q['question_id'] ?? "0", // Ensure this is included
          'question_text': q['title'] ?? '',
          'question_grade': q['grade'] ?? '',
          'question_type': q['type'],
          'question_files': q['imagePath'] != null
              ? [
                  {
                    'file_name': q['imageName'] ?? '',
                    'old_file_name': "",
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

    setState(() {
      _isSaving = true;
    });

    try {
      // Debug: Print the assessment to check the structure
      print('Assessment JSON: ${jsonEncode(assessment)}');
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      print('Updating existing quiz with ID: ${widget.question.id}');
      if (widget.editMode == true) {
        print('Updated assessment: ${jsonEncode(Updatedassessment)}');

        await quizProvider.updateTest(Updatedassessment);
        widget.onCreation?.call();
        CustomToaster.toastSuccess(
            context, "Success", "Questions updated successfully");
      } else {
        await quizProvider.addTest(assessment);
        widget.onCreation?.call();
        CustomToaster.toastSuccess(
            context, "Success", "Questions saved successfully");
      }
      setState(() {
        showSaveButton = false;
      });
      print('Quiz posted!');
      if (mounted) {
        widget.onSaveFlag?.call();
        widget.onCreation?.call();

        if (widget.source == 'empty_subject') {
          Navigator.of(context).popUntil(ModalRoute.withName('/empty_subject'));
        } else if (widget.source == 'elearning_dashboard') {
          Navigator.of(context).popUntil(ModalRoute.withName('/recent_quiz'));
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print('Error posting quiz: $e');
      CustomToaster.toastError(context, "Error", "Error saving questions: $e");
      print('Error posting quiz: $assessment');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildSavedQuestionRow(String questionType, String questionText,
      String marks, List<Map<String, dynamic>> options) {
    IconData iconData =
        questionType == 'short_answer' ? Icons.short_text : Icons.list;

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
              questionType == 'short_answer'
                  ? 'Short answer'
                  : 'Multiple choice',
              style: AppTextStyles.normal500(
                  fontSize: 16, color: AppColors.textGray),
            ),
            subtitle: Text(
              questionText.isEmpty ? 'Untitled Question' : questionText,
              style: AppTextStyles.normal400(
                  fontSize: 1, color: AppColors.textGray),
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
              onPressed: () async {
                await _SaveToPrefs();

                print('Created Questions: $createdQuestions');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreviewAssessment(
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

  List<String> _validateQuestions() {
    List<String> invalidQuestions = [];

    for (int i = 0; i < createdQuestions.length; i++) {
      final question = createdQuestions[i];
      final questionType = question['type'];
      final questionText = question['questionController'].text;
      final displayNumber = i + 1;

      // Check if question text is empty
      if (questionText.trim().isEmpty) {
        invalidQuestions.add('Question $displayNumber: Question text is empty');
        continue;
      }

      if (questionType == 'multiple_choice') {
        final optionControllers =
            question['optionControllers'] as List<TextEditingController>;
        final correctOptions = question['correctOptions'] as List<int>;

        // Check if any options are empty
        bool hasEmptyOptions = false;
        for (int j = 0; j < optionControllers.length; j++) {
          if (optionControllers[j].text.trim().isEmpty) {
            hasEmptyOptions = true;
            break;
          }
        }

        if (hasEmptyOptions) {
          invalidQuestions
              .add('Question $displayNumber: Some options are empty');
        }

        // Check if correct option is selected
        if (correctOptions.isEmpty) {
          invalidQuestions
              .add('Question $displayNumber: No correct answer selected');
        } else {
          // Validate that the selected correct option index is valid
          final selectedOption = correctOptions.first;
          if (selectedOption < 0 ||
              selectedOption >= optionControllers.length) {
            invalidQuestions.add(
                'Question $displayNumber: Invalid correct answer selection');
          } else if (optionControllers[selectedOption].text.trim().isEmpty) {
            invalidQuestions.add(
                'Question $displayNumber: Selected correct answer is empty');
          }
        }
      } else if (questionType == 'short_answer') {
        final correctAnswerController =
            question['correctAnswerController'] as TextEditingController?;

        // Check if correct answer is provided
        if (correctAnswerController == null ||
            correctAnswerController.text.trim().isEmpty) {
          invalidQuestions
              .add('Question $displayNumber: Correct answer is empty');
        }
      }
    }

    return invalidQuestions;
  }

  // Updated _SaveToPrefs method in ViewQuestionScreen
// Fixed _SaveToPrefs method in ViewQuestionScreen
  Future<void> _SaveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // Convert questions to a format suitable for SharedPreferences
      List<Map<String, dynamic>> questionsForPreview =
          createdQuestions.map((q) {
        final questionController =
            q['questionController'] as TextEditingController;
        final marksController = q['marksController'] as TextEditingController;
        final optionControllers =
            q['optionControllers'] as List<TextEditingController>;
        final correctOptions = q['correctOptions'] as List<int>;
        final correctAnswerController =
            q['correctAnswerController'] as TextEditingController?;

        // Handle options for multiple choice with better validation
        List<Map<String, dynamic>> options = [];
        if (q['type'] == 'multiple_choice' && q['options'] != null) {
          final originalOptions = q['options'] as List;

          // Ensure we have the same number of options as controllers
          int optionCount = optionControllers.length;
          for (int i = 0; i < optionCount; i++) {
            Map<String, dynamic>? optionFile;

            // Safely get option file if it exists
            if (i < originalOptions.length &&
                originalOptions[i]['options_file'] != null) {
              final origFile = originalOptions[i]['options_file'];
              optionFile = {
                'file_name': origFile['file_name'] ?? '',
                'base64': origFile['base64'] ?? '',
              };
            }

            options.add({
              'order': i,
              'text':
                  i < optionControllers.length ? optionControllers[i].text : '',
              'option_files': optionFile != null
                  ? [
                      {
                        'file_name': optionFile['file_name'],
                        'old_file_name': '',
                        'type': 'image',
                        'file': _ensureProperBase64Format(optionFile['base64']),
                      }
                    ]
                  : [],
            });
          }
        }

        // Handle correct answer with better validation
        dynamic correct = {};
        if (q['type'] == 'multiple_choice') {
          if (correctOptions.isNotEmpty &&
              correctOptions.first < optionControllers.length) {
            correct = {
              'order': correctOptions.first,
              'text': optionControllers[correctOptions.first].text,
            };
          } else {
            // Fallback to first option if no valid selection
            correct = {
              'order': 0,
              'text':
                  optionControllers.isNotEmpty ? optionControllers[0].text : '',
            };
          }
        } else {
          // Short answer
          correct = {
            'order': 0,
            'text': correctAnswerController?.text ?? '',
          };
        }

        // Handle question image with proper validation
        List<Map<String, dynamic>> questionFiles = [];
        if (q['imagePath'] != null && q['imagePath'].toString().isNotEmpty) {
          questionFiles.add({
            'file_name': q['imageName'] ?? 'question_image.jpg',
            'old_file_name': '',
            'type': 'image',
            'file': _ensureProperBase64Format(q['imagePath'].toString()),
          });
        }

        return {
          'question_id':
              q['question_id']?.toString() ?? '0', // Include question_id
          'question_text': questionController.text.trim(),
          'question_grade':
              marksController.text.isNotEmpty ? marksController.text : '1',
          'question_type': q['type'],
          'question_files': questionFiles,
          'options': options,
          'correct': correct,
          'topic': q['topic'] ?? currentQuestion.topic ?? 'General',
        };
      }).toList();

      // Validate that we have questions to save
      if (questionsForPreview.isEmpty) {
        print('WARNING: No questions to save for preview');
        CustomToaster.toastError(
            context, "Error", "No questions available for preview");
        return;
      }

      // Debug: Print questions being saved
      print('=== SAVING QUESTIONS FOR PREVIEW ===');
      print('Saving ${questionsForPreview.length} questions');
      for (int i = 0; i < questionsForPreview.length; i++) {
        final q = questionsForPreview[i];
        print('Question $i:');
        print('  - ID: ${q['question_id']}');
        print('  - Text: "${q['question_text']}"');
        print('  - Type: ${q['question_type']}');
        print('  - Grade: ${q['question_grade']}');
        print('  - Has image: ${q['question_files'].isNotEmpty}');
        print('  - Options count: ${q['options'].length}');
        print('  - Correct: ${q['correct']}');
      }

      // Save questions to SharedPreferences
      String questionsJson = jsonEncode(questionsForPreview);
      await prefs.setString('preview_questions', questionsJson);

      // Save additional metadata
      await prefs.setString('preview_title',
          widget.questiondata['title']?.toString() ?? 'Assessment Preview');
      await prefs.setString(
          'preview_duration', currentQuestion.duration.inSeconds.toString());
      await prefs.setBool('is_edit_mode', widget.editMode);

      print(
          '✓ Questions saved successfully. JSON length: ${questionsJson.length}');
      print('✓ Title saved: ${widget.questiondata['title']}');
      print('✓ Duration saved: ${currentQuestion.duration.inSeconds} seconds');
    } catch (e, stackTrace) {
      print('ERROR saving questions to SharedPreferences: $e');
      print('Stack trace: $stackTrace');
      CustomToaster.toastError(
          context, "Error", "Failed to save questions for preview: $e");
      return;
    }
  }

// Helper method to ensure proper base64 format
  String _ensureProperBase64Format(String? imageData) {
    if (imageData == null || imageData.isEmpty) return '';

    // If already has data URL prefix, return as is
    if (imageData.startsWith('data:')) {
      return imageData;
    }

    // If it looks like base64, add proper prefix
    if (_isBase64String(imageData)) {
      return 'data:image/jpeg;base64,$imageData';
    }

    // Otherwise return as is (might be a file path)
    return imageData;
  }

// Helper method to check if string is valid base64
  bool _isBase64String(String str) {
    try {
      // Remove any whitespace
      str = str.replaceAll(RegExp(r'\s+'), '');
      // Check if it's valid base64
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
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
    final correctAnswerController =
        questionType == 'short_answer' ? TextEditingController() : null;

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
            ? optionControllers
                .asMap()
                .entries
                .map((e) => {
                      'order': e.key,
                      'text': e.value.text,
                      'options_file': null,
                    })
                .toList()
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
        int index = createdQuestions
            .indexWhere((q) => q['questionController'] == questionController);
        final questionId =
            index != -1 ? createdQuestions[index]['question_id'] : '';
        String? imageName =
            index != -1 ? createdQuestions[index]['imageName'] : null;
        String? imagePath =
            index != -1 ? createdQuestions[index]['imagePath'] : null;

        void collapseAllOtherCards(int currentIndex) {
          for (int i = 0; i < createdQuestions.length; i++) {
            if (i != currentIndex &&
                createdQuestions[i]['isExpanded'] == true) {
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

        Widget collapsedView() {
          return GestureDetector(
            onTap: () {
              setState(() {
                collapseAllOtherCards(index);
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
                          questionType == 'short_answer'
                              ? Icons.short_text
                              : Icons.list,
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          questionType == 'short_answer'
                              ? 'Short answer'
                              : 'Multiple choice',
                          style: AppTextStyles.normal500(
                              fontSize: 16, color: AppColors.textGray),
                        ),
                        const Spacer(),
                        Icon(Icons.expand_more, color: AppColors.textGray),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 15),
                    child: Text(
                      (questionController.text.isEmpty
                          ? 'Untitled Question'
                          : questionController.text[0].toUpperCase() +
                              questionController.text.substring(1)),
                      style: AppTextStyles.normal400(
                          fontSize: 14, color: AppColors.textGray),
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
                        questionType == 'short_answer'
                            ? Icons.short_text
                            : Icons.list,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          questionType == 'short_answer'
                              ? 'Short answer'
                              : 'Multiple choice',
                          style: AppTextStyles.normal600(
                              fontSize: 16, color: AppColors.textGray),
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
                              // Update widget without resetting image data
                              createdQuestions[index]['widget'] =
                                  _buildQuestionCard(
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
                            _showAttachmentOptions(context,
                                index: index, isQuestion: true);
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
                            createdQuestions[index]['widget'] =
                                _buildQuestionCard(
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
                  if (imagePath != null && imagePath.isNotEmpty) ...[
  const SizedBox(height: 8),
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Container(
          constraints: const BoxConstraints(
              maxHeight: 100, maxWidth: 200),
          child: _buildQuestionImageWidget(imagePath),
        ),
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
                    if (questionType == 'short_answer' &&
                        correctAnswerController != null) ...[
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
                          ...optionControllers.asMap().entries.map((entry) {
                            final optionIndex = entry.key;
                            final controller = entry.value;
                            final hasImage = index != -1 &&
                                createdQuestions[index]['options'][optionIndex]
                                        ['options_file'] !=
                                    null;

                            return _buildOptionRow(
                              optionIndex,
                              controller,
                              setState,
                              () async {
                                final imageData =
                                    await _pickImageWithFilePicker();
                                if (imageData != null && index != -1) {
                                  setState(() {
                                    createdQuestions[index]['options']
                                        [optionIndex]['options_file'] = {
                                      'file_name': imageData['file_name'],
                                      'base64': imageData['base64'],
                                    };
                                    controller.text = imageData['file_name'];
                                  });
                                }
                              },
                              () {
                                setState(() {
                                  correctOptions.clear();
                                  correctOptions.add(optionIndex);
                                  if (index != -1) {
                                    createdQuestions[index]['correctOptions'] =
                                        correctOptions;
                                    createdQuestions[index]['correct'] =
                                        correctOptions
                                            .map((i) => {
                                                  'order': i,
                                                  'text':
                                                      optionControllers[i].text,
                                                })
                                            .toList();
                                  }
                                });
                              },
                              correctOptions.contains(optionIndex),
                              hasImage,
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  optionControllers
                                      .add(TextEditingController());
                                  if (index != -1) {
                                    createdQuestions[index]['options'].add({
                                      'order': optionControllers.length - 1,
                                      'text': '',
                                      'options_file': null,
                                    });
                                    createdQuestions[index]
                                            ['optionControllers'] =
                                        optionControllers;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Add option',
                                    style: AppTextStyles.normal600(
                                      fontSize: 14,
                                      color:
                                          AppColors.textGray.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Divider(
                              color: Colors.grey, thickness: 0.6, height: 1),
                        ],
                      ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey[400]!)),
                        ),
                        child: TextField(
                          controller: marksController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
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
                          const SnackBar(
                            content: Text('Question copied'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () {
                        _showDeleteQuestionDialog(context, index);
                      },
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
              color: isEditing
                  ? AppColors.primaryLight.withOpacity(0.5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: isExpanded ? expandedView() : collapsedView(),
        );
      },
    );
  }

  Widget _buildQuestionImageWidget(String imagePath) {
  // Check if it's base64 data
  if (imagePath.startsWith('data:')) {
    final base64String = imagePath.split(',').last;
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Text(
          'Error loading image',
          style: TextStyle(fontSize: 14, color: Colors.red),
        );
      },
    );
  } 
  // Check if it's plain base64 (without data: prefix)
  else if (_isBase64String(imagePath)) {
    return Image.memory(
      base64Decode(imagePath),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Text(
          'Error loading image',
          style: TextStyle(fontSize: 14, color: Colors.red),
        );
      },
    );
  }
  // Otherwise treat as network URL
  else {
    return Image.network(
      'https://linkskool.net/$imagePath',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Text(
          'Error loading image',
          style: TextStyle(fontSize: 14, color: Colors.red),
        );
      },
    );
  }
}

  void _duplicateQuestion(int questionIndex) {
    if (questionIndex < 0 || questionIndex >= createdQuestions.length) return;

    final originalQuestion = createdQuestions[questionIndex];

    // Create new controllers with the same values
    final questionController = TextEditingController(
        text: originalQuestion['questionController'].text);
    final marksController =
        TextEditingController(text: originalQuestion['marksController'].text);

    // Handle option controllers
    final optionControllers =
        (originalQuestion['optionControllers'] as List<TextEditingController>)
            .map((c) => TextEditingController(text: c.text))
            .toList();

    // Handle correct answer controller if exists
    final correctAnswerController =
        originalQuestion['correctAnswerController'] != null
            ? TextEditingController(
                text: originalQuestion['correctAnswerController'].text)
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
      CustomToaster.toastError(context, "Error", "invalid question index");
      return;
    }

    final settingId = widget.question.id.toString();
    final id = createdQuestions[questionIndex]['question_id']?.toString();
    final provider = locator<DeleteQuestionProvider>();

    try {
      setState(() {
        final questionToDelete = createdQuestions[questionIndex];

        // Dispose controllers
        final questionController =
            questionToDelete['questionController'] as TextEditingController;
        final marksController =
            questionToDelete['marksController'] as TextEditingController;
        final optionControllers = questionToDelete['optionControllers']
            as List<TextEditingController>;
        final correctAnswerController =
            questionToDelete['correctAnswerController']
                as TextEditingController?;

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
      print('Deleting question with ID: $id and setting ID: $settingId');
      await provider.deleteQuestion(id!, settingId);
      CustomToaster.toastSuccess(
          context, "Success", "Questions deleted successfully");

      // Navigate back if no questions remain
      if (createdQuestions.isEmpty) {
        Navigator.of(context).popUntil(ModalRoute.withName('/empty_subject'));
      }
    } catch (e) {
      CustomToaster.toastError(
          context, "Error", " Error deleting questions: $e");
    }
  }

 Widget _buildOptionRow(
  int index,
  TextEditingController controller,
  Function setState,
  VoidCallback onImagePick,
  VoidCallback onSelectCorrect,
  bool isCorrect,
  bool hasImage,
) {
  return StatefulBuilder(
    builder: (context, localSetState) {
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
                hintText: hasImage ? 'Image uploaded' : 'Option',
                border: const UnderlineInputBorder(),
                hintStyle: TextStyle(
                  color: hasImage ? Colors.grey : null,
                ),
              ),
              onChanged: (value) {
                // Only update the specific option, don't rebuild the entire card
                int qIndex = createdQuestions.indexWhere(
                    (q) => q['optionControllers'].contains(controller));
                if (qIndex != -1) {
                  if (createdQuestions[qIndex]['options'].length <= index) {
                    while (createdQuestions[qIndex]['options'].length <= index) {
                      createdQuestions[qIndex]['options'].add({
                        'order': createdQuestions[qIndex]['options'].length,
                        'text': '',
                        'options_file': null,
                      });
                    }
                  }
                  createdQuestions[qIndex]['options'][index]['text'] = value;
                }
              },
            ),
          ),
          _buildOptionKebabButton(
            context,
            createdQuestions.indexWhere((q) => q['optionControllers'].contains(controller)),
            index,
            localSetState, // Use localSetState instead of the parent setState
          ),
        ],
      );
    },
  );
}

  Widget _buildOptionKebabButton(BuildContext context, int questionIndex,
      int optionIndex, Function setState) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String value) {
        switch (value) {
          case 'attachment':
            _showAttachmentOptions(context,
                index: questionIndex,
                optionIndex: optionIndex,
                isQuestion: false);
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

  void _showAttachmentOptions(BuildContext context,
      {required int index, int? optionIndex, required bool isQuestion}) {
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
                        createdQuestions[index]['imagePath'] =
                            imageData['base64'];
                        createdQuestions[index]['imageName'] =
                            imageData['file_name'];
                      } else if (optionIndex != null) {
                        createdQuestions[index]['options'][optionIndex]
                            ['options_file'] = {
                          'file_name': imageData['file_name'],
                          'base64': imageData['base64'],
                        };
                        (createdQuestions[index]['optionControllers']
                                as List<TextEditingController>)[optionIndex]
                            .text = imageData['file_name'];
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
                        createdQuestions[index]['imagePath'] =
                            imageData['base64'];
                        createdQuestions[index]['imageName'] =
                            imageData['file_name'];
                      } else if (optionIndex != null) {
                        createdQuestions[index]['options'][optionIndex]
                            ['options_file'] = {
                          'file_name': imageData['file_name'],
                          'base64': imageData['base64'],
                        };
                        (createdQuestions[index]['optionControllers']
                                as List<TextEditingController>)[optionIndex]
                            .text = imageData['file_name'];
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
      final optionControllers =
          question['optionControllers'] as List<TextEditingController>;
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
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
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

  void _performOptionDeletion(
      int questionIndex, int optionIndex, Function setState) {
    setState(() {
      final question = createdQuestions[questionIndex];
      final optionControllers =
          question['optionControllers'] as List<TextEditingController>;
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
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
