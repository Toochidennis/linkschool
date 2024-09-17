import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/portal/e-learning/View/question/assessment_screen.dart';

class ViewQuestionScreen extends StatefulWidget {
  final Question question;

  const ViewQuestionScreen({Key? key, required this.question})
      : super(key: key);

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildQuestionBackground(),
              ...createdQuestions,
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildQuestionBackground() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: 135,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    child: SvgPicture.asset(
                      'assets/images/e-learning/question_bg2.svg',
                      fit: BoxFit.cover,
                      width: constraints.maxWidth,
                      height: 135,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: SvgPicture.asset(
                  'assets/icons/kebab_icon.svg',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(
                      value: widget.question.title,
                      style: AppTextStyles.normal600(
                          fontSize: 20, color: AppColors.backgroundLight),
                    ),
                    const Divider(color: Colors.white, height: 1),
                    _buildInfoSection(
                      label: 'Instruction',
                      value: widget.question.description,
                      style: AppTextStyles.normal400(
                          fontSize: 16, color: AppColors.backgroundLight),
                    ),
                    _buildInfoSection(
                      value: _formatDuration(widget.question.duration),
                      style: AppTextStyles.normal600(
                          fontSize: 16, color: AppColors.backgroundLight),
                      icon: 'assets/icons/e_learning/stopwatch_icon.svg',
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
          IconButton(
            icon: SvgPicture.asset('assets/icons/e_learning/preview_icon.svg'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AssessmentScreen()),
              );
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
                'assets/icons/e_learning/circle_plus_icon.svg'),
            onPressed: () => _showQuestionTypeOverlay(context),
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
      createdQuestions.add(_buildQuestionCard(questionType));
    });
  }

  Widget _buildQuestionCard(String questionType) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.blue.withOpacity(0.5), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFFF6F6F6),
            child: Row(
              children: [
                SvgPicture.asset(
                  questionType == 'short_answer'
                      ? 'assets/icons/short_answer_icon.svg'
                      : 'assets/icons/multiple_choice_icon.svg',
                  width: 24,
                  height: 24,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Question',
                    border: const UnderlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showAttachmentOptions(context),
                    ),
                  ),
                ),
                if (questionType == 'multiple_choice')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: InkWell(
                      onTap: () {
                        // Add option functionality
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Add option',
                            style: AppTextStyles.normal600(
                                fontSize: 14, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: const TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('marks'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.grey),
                  onPressed: () {
                    // Copy question functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {
                    // Delete question functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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
