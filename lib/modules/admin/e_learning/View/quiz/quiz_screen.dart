import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/e_learning/View/quiz/quiz_assessment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/quiz/answer_tab_widget.dart';
import '../../../../model/e-learning/question_model.dart';

// import 'package:linkschool/modules/model/e-learning/question_model.dart';

class QuizScreen extends StatefulWidget {
  final Question question;

  const QuizScreen({super.key, required this.question});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // int _selectedIndex = 0;
  late double opacity;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
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
            'Quiz',
            style: AppTextStyles.normal600(
              fontSize: 24.0,
              color: AppColors.primaryLight,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.primaryLight),
              onSelected: (String result) {
                // Handle menu item selection
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
            // Move TabBar to AppBar's bottom
            // controller: _tabController,
            tabs:  [
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
        body: Container(
          decoration: Constants.customBoxDecoration(context),
          child: TabBarView(
            // Corresponding TabBarView
            children: [
              _buildQuestionTab(),
              _buildAnswersTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoRow('Due date:', _formatDate(widget.question.endDate)),
        const Divider(color: Colors.grey),
        Text(
          widget.question.title,
          style: AppTextStyles.normal600(
              fontSize: 20, color: AppColors.primaryLight),
        ),
        const Divider(color: AppColors.eLearningBtnColor1),
        _buildInfoRow(
            'Duration:', '${widget.question.duration.inMinutes} minutes'),
        const Divider(color: Colors.grey),
        _buildInfoRow('Description:', widget.question.description),
        const Divider(color: Colors.grey),
        const SizedBox(height: 20),
        CustomLongElevatedButton(
          onPressed: () {
            // Navigate to the assessment screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizAssessmentScreen(
                  question: widget.question,
                ),
              ),
            );
          },
          backgroundColor: AppColors.eLearningBtnColor1,
          text: 'Take Quiz',
          textStyle: AppTextStyles.normal600(fontSize: 18, color: AppColors.backgroundLight),
        ),
      ],
    );
  }

Widget _buildAnswersTab() {
  return const AnswersTabWidget();
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

