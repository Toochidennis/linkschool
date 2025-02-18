// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/assessment_screen.dart';
import 'package:linkschool/modules/admin/e_learning/question_screen.dart';

class StaffQuestionPreviewScreen extends StatefulWidget {
  final Question question;

  const StaffQuestionPreviewScreen({super.key, required this.question});

  @override
  State<StaffQuestionPreviewScreen> createState() => _StaffQuestionPreviewScreenState();
}

class _StaffQuestionPreviewScreenState extends State<StaffQuestionPreviewScreen> {
  List<Map<String, dynamic>> createdQuestions = [];
  late double opacity;
  late Question currentQuestion;
  bool showSaveButton = false;
  bool isEditing = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    currentQuestion = widget.question;
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
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Question',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
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
                onPressed: isEditing ? _saveEditedQuestion : _saveQuestions,
                text: isEditing ? 'Save' : 'Save',
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
              ...createdQuestions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return isEditing && editingIndex == index
                    ? _buildQuestionCard(question['type'], index)
                    : _buildSavedQuestionRow(question['type'], index);
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSavedQuestionRow(String questionType, int index) {
    IconData iconData =
        questionType == 'short_answer' ? Icons.short_text : Icons.list;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isEditing = true; // Set editing mode
              editingIndex = index; // Track which question is being edited
              showSaveButton = true; // Show the button in the app bar
            });
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
            trailing: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/e_learning/kebab_icon.svg',
                width: 24,
                height: 24,
              ),
              onPressed: () {
                _showKebabMenu(context, index);
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

  void _showKebabMenu(BuildContext context, int index) {
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
              setState(() {
                isEditing = true; // Set editing mode
                editingIndex = index; // Track which question is being edited
                showSaveButton = true; // Show the button in the app bar
              });
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              _deleteQuestion(index);
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
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _showKebabMenu(context, editingIndex ?? 0),
                    child: SvgPicture.asset(
                      'assets/icons/e_learning/kebab_icon.svg',
                      width: 24,
                      height: 24,
                      color: Colors.white,
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
          onSave: (Question) {},
        ),
      ),
    );

    if (result != null) {
      setState(() {
        currentQuestion = result;
      });
    }
  }

  void _deleteQuestion(int index) {
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
                setState(() {
                  createdQuestions.removeAt(index);
                });
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
              icon:
                  SvgPicture.asset('assets/icons/e_learning/preview_icon.svg'),
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
                  'assets/icons/e_learning/circle_plus_icon.svg'),
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
    Navigator.pop(context);
    setState(() {
      createdQuestions.add({
        'type': questionType,
        'widget': _buildQuestionCard(questionType, createdQuestions.length),
      });
      isEditing = true; // Set editing mode for the new question
      editingIndex = createdQuestions.length - 1; // Track the new question
      showSaveButton = true; // Show the "Save" button in the app bar
    });
  }

  void _saveQuestions() {
    setState(() {
      isEditing = false; // Exit editing mode
      editingIndex = null; // Reset the editing index
      showSaveButton = false; // Hide the button in the app bar
    });
  }

  void _saveEditedQuestion() {
    setState(() {
      isEditing = false; // Exit editing mode
      editingIndex = null; // Reset the editing index
      showSaveButton = false; // Hide the button in the app bar
    });
  }

  Widget _buildQuestionCard(String questionType, int index) {
    List<TextEditingController> optionControllers = [
      TextEditingController(),
      TextEditingController()
    ];
    TextEditingController questionController = TextEditingController();
    TextEditingController marksController = TextEditingController(text: '1');

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isEditing
                  ? AppColors.paymentTxtColor1.withOpacity(0.5)
                  : Colors.transparent,
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
                        questionType == 'short_answer'
                            ? Icons.short_text
                            : Icons.list,
                        color: AppColors.paymentTxtColor1,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        questionType == 'short_answer'
                            ? 'Short answer'
                            : 'Multiple choice',
                        style: AppTextStyles.normal600(
                            fontSize: 16, color: AppColors.textGray),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: questionController,
                      decoration: InputDecoration(
                        hintText: 'Question',
                        border: const UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showAttachmentOptions(context),
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
                    ),
                    if (questionType == 'multiple_choice')
                      Column(
                        children: [
                          ...optionControllers.asMap().entries.map((entry) =>
                              _buildOptionRow(
                                  entry.key, entry.value, setState)),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  optionControllers
                                      .add(TextEditingController());
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
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
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
                          createdQuestions.removeAt(index);
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

  Widget _buildOptionRow(
      int index, TextEditingController controller, Function setState) {
    return Row(
      children: [
        Radio(
          value: index,
          groupValue: null,
          onChanged: (value) {},
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
                // The controller will automatically update the text
              });
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showAttachmentOptions(context),
        ),
      ],
    );
  }

  void _showAttachmentOptions(BuildContext context) {
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
                  // Insert link functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload file'),
                onTap: () {
                  // Upload file functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  // Take photo functionality
                  Navigator.pop(context);
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
            Icon(icon, color: AppColors.paymentTxtColor1),
            const SizedBox(width: 16),
            Text(
              text,
              style: AppTextStyles.normal500(
                fontSize: 16,
                color: AppColors.paymentTxtColor1,
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



// // ignore_for_file: deprecated_member_use
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/e-learning/question_model.dart';
// import 'package:linkschool/modules/admin_portal/e_learning/View/question/assessment_screen.dart';
// import 'package:linkschool/modules/admin_portal/e_learning/View/quiz/quiz_screen.dart';
// import 'package:linkschool/modules/admin_portal/e_learning/question_screen.dart';


// class StaffQuestionPreviewScreen extends StatefulWidget {
//   final Question question;

//   const StaffQuestionPreviewScreen({super.key, required this.question});

//   @override
//   State<StaffQuestionPreviewScreen> createState() => _StaffQuestionPreviewScreenState();
// }

// class _StaffQuestionPreviewScreenState extends State<StaffQuestionPreviewScreen> {
//   List<Map<String, dynamic>> createdQuestions = [];
//   late double opacity;
//   late Question currentQuestion;
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
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Question',

//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.paymentTxtColor1,
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

//   Widget _buildSavedQuestionRow(String questionType, Widget questionCard) {
//     IconData iconData =
//         questionType == 'short_answer' ? Icons.short_text : Icons.list;

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
//               questionType == 'short_answer'
//                   ? 'Short answer'
//                   : 'Multiple choice',
//               style: AppTextStyles.normal500(
//                   fontSize: 16, color: AppColors.textGray),
//             ),
//             trailing: IconButton(
//               icon: SvgPicture.asset(
//                 'assets/icons/e_learning/kebab_icon.svg',
//                 width: 24,
//                 height: 24,
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
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 16,
//                   right: 8,
//                   child: GestureDetector(
//                     onTap: () => _showKebabMenu,
//                     child: SvgPicture.asset(
//                       'assets/icons/e_learning/kebab_icon.svg',
//                       width: 24,
//                       height: 24,
//                       color: Colors.white,
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
//           onSave: (Question) {},
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
//     // Implement delete functionality
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
//                 // Implement the actual deletion logic here
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pop(); // Return to the previous screen
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
//               icon:
//                   SvgPicture.asset('assets/icons/e_learning/preview_icon.svg'),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const AssessmentScreen()),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: IconButton(
//               icon: SvgPicture.asset(
//                   'assets/icons/e_learning/circle_plus_icon.svg'),
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
//               const SizedBox(height: 16), // Add spacing below the title
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
//     Navigator.pop(context);
//     setState(() {
//       createdQuestions.add({
//         'type': questionType,
//         'widget': _buildQuestionCard(questionType),
//       });
//       showSaveButton = true;
//     });
//   }

//   void _saveQuestions() {
//     setState(() {
//       List<Map<String, dynamic>> updatedQuestions = [];
//       for (var question in createdQuestions) {
//         updatedQuestions.add({
//           'type': question['type'],
//           'widget':
//               _buildSavedQuestionRow(question['type'], question['widget']),
//         });
//       }
//       createdQuestions = updatedQuestions;
//       showSaveButton = false;
//     });
//   }

//   Widget _buildQuestionCard(String questionType) {
//     bool isEditing = false;
//     List<TextEditingController> optionControllers = [
//       TextEditingController(),
//       TextEditingController()
//     ];
//     TextEditingController questionController = TextEditingController();
//     TextEditingController marksController = TextEditingController(text: '1');

//     return StatefulBuilder(
//       builder: (BuildContext context, StateSetter setState) {
//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: BorderSide(
//               color: isEditing
//                   ? AppColors.paymentTxtColor1.withOpacity(0.5)
//                   : Colors.transparent,
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
//                         questionType == 'short_answer'
//                             ? Icons.short_text
//                             : Icons.list,
//                         color: AppColors.paymentTxtColor1,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         questionType == 'short_answer'
//                             ? 'Short answer'
//                             : 'Multiple choice',
//                         style: AppTextStyles.normal600(
//                             fontSize: 16, color: AppColors.textGray),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: questionController,
//                       decoration: InputDecoration(
//                         hintText: 'Question',
//                         border: const UnderlineInputBorder(),
//                         suffixIcon: IconButton(
//                           icon: const Icon(Icons.more_vert),
//                           onPressed: () => _showAttachmentOptions(context),
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
//                     ),
//                     if (questionType == 'multiple_choice')
//                       Column(
//                         children: [
//                           ...optionControllers.asMap().entries.map((entry) =>
//                               _buildOptionRow(
//                                   entry.key, entry.value, setState)),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 16),
//                             child: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   optionControllers
//                                       .add(TextEditingController());
//                                 });
//                               },
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     'Add option',
//                                     style: AppTextStyles.normal600(
//                                       fontSize: 14,
//                                       color:
//                                           AppColors.textGray.withOpacity(0.5),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8.0),
//                           const Divider(
//                               color: Colors.grey, thickness: 0.6, height: 1),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 16.0),
//                       child: Container(
//                         width: 60,
//                         decoration: BoxDecoration(
//                           border: Border(
//                               bottom: BorderSide(color: Colors.grey[400]!)),
//                         ),
//                         child: TextField(
//                           controller: marksController,
//                           keyboardType: TextInputType.number,
//                           textAlign: TextAlign.center,
//                           decoration: const InputDecoration(
//                             border: InputBorder.none,
//                           ),
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
//                           createdQuestions.removeWhere((element) =>
//                               element == _buildQuestionCard(questionType));
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

//   Widget _buildOptionRow(
//       int index, TextEditingController controller, Function setState) {
//     return Row(
//       children: [
//         Radio(
//           value: index,
//           groupValue: null,
//           onChanged: (value) {},
//         ),
//         Expanded(
//           child: TextField(
//             controller: controller,
//             decoration: const InputDecoration(
//               hintText: 'Option',
//               border: UnderlineInputBorder(),
//             ),
//             onChanged: (value) {
//               setState(() {
//                 // The controller will automatically update the text
//               });
//             },
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.more_vert),
//           onPressed: () => _showAttachmentOptions(context),
//         ),
//       ],
//     );
//   }

//   void _showAttachmentOptions(BuildContext context) {
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
//                 onTap: () {
//                   // Insert link functionality
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.upload_file),
//                 title: const Text('Upload file'),
//                 onTap: () {
//                   // Upload file functionality
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Take photo'),
//                 onTap: () {
// // Take photo functionality
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
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
//             Icon(icon, color: AppColors.paymentTxtColor1),
//             const SizedBox(width: 16),
//             Text(
//               text,
//               style: AppTextStyles.normal500(
//                 fontSize: 16,
//                 color: AppColors.paymentTxtColor1,
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