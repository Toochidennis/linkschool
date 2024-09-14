import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/e-learning/question_screen.dart';

class ViewQuestionScreen extends StatefulWidget {
  final Question question;

  const ViewQuestionScreen({Key? key, required this.question}) : super(key: key);

  @override
  State<ViewQuestionScreen> createState() => _ViewQuestionScreenState();
}

class _ViewQuestionScreenState extends State<ViewQuestionScreen> {
  @override
  Widget build(BuildContext context) {
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
          'View Question',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Stack(
        children: [
          // SVG Background with question details
          SvgPicture.asset(
            'assets/images/e-learning/question_bg2.svg',
            fit: BoxFit.contain,
            width: double.infinity,
            height: 400,
          ),
         
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Title', widget.question.title),
                  _buildInfoSection('Description', widget.question.description),
                  _buildInfoSection('Class', widget.question.selectedClass),
                  _buildInfoSection('Marks', widget.question.marks),
                  _buildInfoSection('Due Date', _formatDate(widget.question.endDate)),
                  _buildInfoSection('Duration', _formatDuration(widget.question.duration)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showQuestionTypeOverlay(context),
                child: const Text('+ Question'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryLight),
                ),
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

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.normal600(
              fontSize: 18.0,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: AppTextStyles.normal500(
              fontSize: 16.0,
              color: AppColors.backgroundDark,
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
                onTap: () => Navigator.pushNamed(context, '/short-answer-question'),
              ),
              _buildQuestionTypeOption(
                icon: Icons.list,
                text: 'Multiple choice',
                onTap: () => Navigator.pushNamed(context, '/multiple-choice-question'),
              ),
              _buildQuestionTypeOption(
                icon: Icons.view_agenda,
                text: 'Section',
                onTap: () => Navigator.pushNamed(context, '/section-question'),
              ),
            ],
          ),
        );
      },
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
          color: const Color(0xFFF8F8F8),
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
                color: AppColors.backgroundDark,
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