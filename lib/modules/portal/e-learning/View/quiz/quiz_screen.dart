
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';

class QuizScreen extends StatefulWidget {
  final Question question;

  const QuizScreen({Key? key, required this.question}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Quiz'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String result) {
              // Handle menu item selection
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'option1',
                child: Text('Option 1'),
              ),
              const PopupMenuItem<String>(
                value: 'option2',
                child: Text('Option 2'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: TabBar(
              tabs: const [
                Tab(text: 'Question'),
                Tab(text: 'Answers'),
              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildQuestionTab(),
                _buildAnswersTab(),
              ],
            ),
          ),
        ],
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
          style: AppTextStyles.normal600(fontSize: 20, color: AppColors.primaryLight),
        ),
        const Divider(color: Colors.blue),
        _buildInfoRow('Duration:', '${widget.question.duration.inMinutes} minutes'),
        const Divider(color: Colors.grey),
        _buildInfoRow('Description:', widget.question.description),
        const Divider(color: Colors.grey),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Implement quiz taking functionality
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Take Quiz'),
        ),
      ],
    );
  }

  Widget _buildAnswersTab() {
    // Implement the Answers tab
    return const Center(child: Text('Answers tab content'));
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.normal600(fontSize: 16, color: AppColors.textGray),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.normal400(fontSize: 16, color: AppColors.backgroundDark),
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}