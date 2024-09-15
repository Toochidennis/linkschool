// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/e-learning/View/question/question_editor_screen.dart';
import 'package:linkschool/modules/portal/e-learning/question_screen.dart';

class ViewQuestionScreen extends StatefulWidget {
  final Question question;

  const ViewQuestionScreen({Key? key, required this.question}) : super(key: key);

  @override
  State<ViewQuestionScreen> createState() => _ViewQuestionScreenState();
}

class _ViewQuestionScreenState extends State<ViewQuestionScreen> {
  List<Widget> createdQuestions = [];
    late double opacity;

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
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        SvgPicture.asset(
                          'assets/images/e-learning/question_bg2.svg',
                          fit: BoxFit.contain,
                          width: constraints.maxWidth,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoSection(
                                value: widget.question.title,
                                style: AppTextStyles.normal600(fontSize: 20, color: AppColors.backgroundLight),
                              ),
                              _buildInfoSection(
                                label: 'Instruction : ',
                                value: widget.question.description,
                                style: AppTextStyles.normal400(fontSize: 16, color: AppColors.backgroundLight),
                              ),
                              _buildInfoSection(
                                value: _formatDuration(widget.question.duration),
                                style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundLight),
                                icon: 'assets/icons/e_learning/stopwatch_icon.svg',
                              ),
                              _buildInfoSection(
                                value: widget.question.selectedClass,
                                style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundLight),
                                icon: 'assets/icons/e_learning/class_icon.svg',
                              ),
                              _buildInfoSection(
                                label: 'Due : ',
                                value: _formatDate(widget.question.endDate),
                                style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                ...createdQuestions,
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showQuestionTypeOverlay(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryLight),
                ),
                child: const Text('+ Question'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Implement preview functionality
                },
                icon: const Icon(Icons.preview),
                label: const Text('Preview'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryLight),
                ),
              ),
            ),
          ],
        ),
      ),
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

  void _showQuestionTypeOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuestionTypeOption(
                icon: Icons.short_text,
                text: 'Short answer',
                onTap: () => _navigateToQuestionScreen('short_answer'),
              ),
              _buildQuestionTypeOption(
                icon: Icons.list,
                text: 'Multiple choice',
                onTap: () => _navigateToQuestionScreen('multiple_choice'),
              ),
              _buildQuestionTypeOption(
                icon: Icons.view_agenda,
                text: 'Section',
                onTap: () => _navigateToQuestionScreen('section'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToQuestionScreen(String questionType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => QuestionEditorScreen(questionType: questionType),
      ),
    );
    if (result != null) {
      setState(() {
        createdQuestions.add(_buildCreatedQuestionWidget(result as Map<String, dynamic>));
      });
    }
  }

Widget _buildCreatedQuestionWidget(Map<String, dynamic> questionData) {
  return Column(
    children: [
      ListTile(
        leading: SvgPicture.asset(
          questionData['type'] == 'short_answer'
              ? 'assets/icons/e_learning/short_answer_icon.svg'
              : 'assets/icons/e_learning/multiple_choice_icon.svg',
          width: 24,
          height: 24,
        ),
        title: Text(
          questionData['type'] == 'short_answer' ? 'Show answer' : 'Multiple choice',
          style: AppTextStyles.normal500(fontSize: 16, color: AppColors.textGray),
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'preview',
              child: Row(
                children: [
                  Icon(Icons.preview),
                  SizedBox(width: 8),
                  Text('Preview'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            // Handle menu item selection
          },
        ),
      ),
      const Divider(), 
    ],
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

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)}, ${date.year} ${_formatTime(date)}';
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}${date.hour >= 12 ? 'pm' : 'am'}';
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }
}
