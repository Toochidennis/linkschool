
// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/assessment_screen.dart';
import 'package:linkschool/modules/admin/e_learning/View/quiz/quiz_screen.dart';
import 'package:linkschool/modules/admin/e_learning/question_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ViewQuestionScreen extends StatefulWidget {
  final Question question;
  final dynamic class_ids;
  const ViewQuestionScreen({super.key, required this.question, this.class_ids});

  @override
  State<ViewQuestionScreen> createState() => _ViewQuestionScreenState();
}

class _ViewQuestionScreenState extends State<ViewQuestionScreen> {
  List<Map<String, dynamic>> createdQuestions = [];
  late double opacity;
  late Question currentQuestion;
  bool showSaveButton = false;

  @override
  void initState() {
    super.initState();
    currentQuestion = widget.question;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? questionsJson = prefs.getString('created_questions');
    if (questionsJson != null) {
      try {
        final List<dynamic> questionsData = json.decode(questionsJson);
        setState(() {
          createdQuestions = questionsData.map((q) {
            final questionController = TextEditingController(text: q['title']);
            final marksController = TextEditingController(text: q['grade'] ?? '1');
            final optionControllers = q['type'] == 'multiple_choice'
                ? (q['options'] as List).map((opt) => TextEditingController(text: opt['text'])).toList()
                : <TextEditingController>[];
            final correctOptions = q['type'] == 'multiple_choice'
                ? (q['correct'] as List).map((c) => c['order'] as int).toList()
                : <int>[];
            return {
              'type': q['type'],
              'title': q['title'] ?? '',
              'grade': q['grade'] ?? '1',
              'topic': q['topic'] ?? currentQuestion.topic,
              'options': q['type'] == 'multiple_choice'
                  ? (q['options'] as List).asMap().entries.map((e) => {
                        'order': e.key,
                        'text': e.value['text'],
                        'options_file': e.value['options_file'],
                      }).toList()
                  : [],
              'correct': q['correct'] ?? [],
              'imagePath': q['imagePath'],
              'questionController': questionController,
              'marksController': marksController,
              'optionControllers': optionControllers,
              'correctOptions': correctOptions,
              'widget': _buildSavedQuestionRow(
                q['type'],
                q['title'] ?? '',
                q['grade'] ?? '1',
                q['type'] == 'multiple_choice'
                    ? (q['options'] as List).asMap().entries.map((e) => {
                          'order': e.key,
                          'text': e.value['text'],
                          'options_file': e.value['options_file'],
                        }).toList()
                    : [],
              ),
            };
          }).toList();
        });
      } catch (e) {
        debugPrint('Error loading questions: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
              ? correctOptions.map((i) => {'order': i, 'text': optionControllers[i].text}).toList()
              : question['correct'] ?? [{'order': 0, 'text': questionController.text}],
          'imagePath': imagePath,
          'questionController': questionController,
          'marksController': marksController,
          'optionControllers': optionControllers,
          'correctOptions': correctOptions,
          'widget': _buildSavedQuestionRow(
            questionType,
            questionController.text,
            marksController.text.isNotEmpty ? marksController.text : '1',
            questionType == 'multiple_choice'
                ? optionControllers.asMap().entries.map((e) => {
                      'order': e.key,
                      'text': e.value.text,
                      'options_file': question['options'][e.key]['options_file'],
                    }).toList()
                : [],
          ),
        });
      }
      createdQuestions = updatedQuestions;
      showSaveButton = false;
    });

    final assessment = {
      'settings': {
        'title': currentQuestion.title,
        'description': currentQuestion.description,
        'class_ids':widget.class_ids,
        'selected_class': currentQuestion.selectedClass,
        'start_date': currentQuestion.startDate.toIso8601String(),
        'end_date': currentQuestion.endDate.toIso8601String(),
        'topic': currentQuestion.topic,
        'duration': currentQuestion.duration.inMinutes.toString(),
        'marks': currentQuestion.marks,
      },
      'questions': createdQuestions.map((q) {
        return {
          'type': q['type'],
          'title': q['title'],
          'grade': q['grade'],
          'topic': q['topic'],
          'file': q['imagePath'] != null
              ? [
                  {
                    'file_name': 'question_${q['type']}_${createdQuestions.indexOf(q)}.jpg',
                    'old_file': 'question_${q['type']}_${createdQuestions.indexOf(q)}.jpg',
                    'type': 'image',
                    'file': q['imagePath'],
                  }
                ]
              : [],
          'options': q['options'],
          'correct': q['correct'],
        };
      }).toList(),
    };

    print(json.encode(assessment));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('created_questions', json.encode(assessment['questions']));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Questions saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
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
        ),
      ),
    );

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
                      builder: (context) => const AssessmentScreen()),
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
              ),],
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

    Navigator.pop(context);
    setState(() {
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
        'questionController': questionController,
        'marksController': marksController,
        'optionControllers': optionControllers,
        'correctOptions': correctOptions,
        'widget': _buildQuestionCard(
          questionType,
          questionController,
          marksController,
          optionControllers,
          correctOptions,
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
  ) {
    bool isEditing = false;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        int index = createdQuestions.indexWhere((q) => q['questionController'] == questionController);
        String? imagePath = index != -1 ? createdQuestions[index]['imagePath'] : null;

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
          child: Column(
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
                      Text(
                        questionType == 'short_answer' ? 'Short answer' : 'Multiple choice',
                        style: AppTextStyles.normal600(fontSize: 16, color: AppColors.textGray),
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
                          onPressed: () => _showAttachmentOptions(context, index: index, isQuestion: true)
                              
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                      onEditingComplete: () {
                        setState(() {
                          isEditing = false;
                        });
                      },
                      onChanged: (value) {
                        if (index != -1) {
                          setState(() {
                            createdQuestions[index]['title'] = value;
                           
                            if (questionType == 'short_answer') {
                              createdQuestions[index]['correct'] = [
                                {'order': 0, 'text': value}
                              ];
                            }
                          });
                        }
                      },
                    ),
                    if (imagePath != null) ...[
                      const SizedBox(height: 8),
                      Image.memory(
                        base64Decode(imagePath),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          if (index != -1) {
                            setState(() {
                              createdQuestions[index]['imagePath'] = null;
                            });
                          }
                        },
                        child: Text(
                          'Remove Image',
                          style: AppTextStyles.normal600(fontSize: 14.0, color: Colors.red),
                        ),
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
                                  final imageData = await _pickImage(context, ImageSource.gallery);
                                  if (imageData != null && index != -1) {
                                    setState(() {
                                      createdQuestions[index]['options'][entry.key]['options_file'] = {
                                        'file_name': imageData['file_name'],
                                        'base64': imageData['base64'],
                                      };
                                    });
                                  }
                                },
                                () {
                                  setState(() {
                                    if (correctOptions.contains(entry.key)) {
                                      correctOptions.remove(entry.key);
                                    } else {
                                      correctOptions.add(entry.key);
                                    }
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Question copied')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          if (index != -1) {
                            createdQuestions.removeAt(index);
                            questionController.dispose();
                            marksController.dispose();
                            for (var controller in optionControllers) {
                              controller.dispose();
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return {
        'file_name': pickedFile.name,
        'base64': base64String,
      };
    }
    return null;
  }

  Widget _buildOptionRow(
      int index,
      TextEditingController controller,
      Function setState,
      VoidCallback onImagePick,
      VoidCallback onSelectCorrect,
      bool isCorrect) {
    return Row(
      children: [
        Checkbox(
          value: isCorrect,
          onChanged: (value) => onSelectCorrect(),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Option',
              border: UnderlineInputBorder(),
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
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            int qIndex = createdQuestions.indexWhere((q) => q['optionControllers'].contains(controller));
            if (qIndex != -1) {
              _showAttachmentOptions(context, index: qIndex, optionIndex: index, isQuestion: false);
            }
          },
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
                leading: const Icon(Icons.link),
                title: const Text('Insert link'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement link insertion logic if needed
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Upload image'),
                onTap: () async {
                  Navigator.pop(context);
                  final imageData = await _pickImage(context, ImageSource.gallery);
                  if (imageData != null && index != -1) {
                    setState(() {
                      if (isQuestion) {
                       
                          createdQuestions[index]['imagePath'] = imageData['base64'];
                     
                          (createdQuestions[index]['questionController'] as TextEditingController).clear();
                          if (createdQuestions[index]['type'] == 'short_answer') {
                            TextEditingController correctController = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Enter Correct Answer'),
                                content: TextField(
                                  controller: correctController,
                                  decoration: const InputDecoration(hintText: 'Correct answer'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            ).then((_) {
                              setState(() {
                                createdQuestions[index]['correct'] = [
                                  {'order': 0, 'text': correctController.text}
                                ];
                              });
                              correctController.dispose();
                            });
                          }
                        
                      } else if (optionIndex != null) {
                        createdQuestions[index]['options'][optionIndex]['options_file'] = {
                          'file_name': imageData['file_name'],
                          'base64': imageData['base64'],
                        };
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
                  final imageData = await _pickImage(context, ImageSource.camera);
                  if (imageData != null && index != -1) {
                    setState(() {
                      if (isQuestion) {
                     
                          createdQuestions[index]['imagePath'] = imageData['base64'];
                          createdQuestions[index]['title'] = '';
                          (createdQuestions[index]['questionController'] as TextEditingController).clear();
                          if (createdQuestions[index]['type'] == 'short_answer') {
                            TextEditingController correctController = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Enter Correct Answer'),
                                content: TextField(
                                  controller: correctController,
                                  decoration: const InputDecoration(hintText: 'Correct answer'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            ).then((_) {
                              setState(() {
                                createdQuestions[index]['correct'] = [
                                  {'order': 0, 'text': correctController.text}
                                ];
                              });
                              correctController.dispose();
                            });
                          }
                    
                      } else if (optionIndex != null) {
                        createdQuestions[index]['options'][optionIndex]['options_file'] = {
                          'file_name': imageData['file_name'],
                          'base64': imageData['base64'],
                        };
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
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }
}
