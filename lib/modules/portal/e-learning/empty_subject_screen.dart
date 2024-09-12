import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/e-learning/View/view_assignment_screen.dart';
import 'package:linkschool/modules/portal/e-learning/View/view_question_screen.dart';
import 'package:linkschool/modules/portal/e-learning/add_material_screen.dart';
import 'package:linkschool/modules/portal/e-learning/assignment_screen.dart';
import 'package:linkschool/modules/portal/e-learning/create_topic_screen.dart';
import 'package:linkschool/modules/portal/e-learning/question_screen.dart';


class EmptySubjectScreen extends StatefulWidget {
  final String title;
  final String selectedSubject;

  const EmptySubjectScreen({
    Key? key,
    required this.title,
    required this.selectedSubject,
  }) : super(key: key);

  @override
  _EmptySubjectScreenState createState() => _EmptySubjectScreenState();
}

class _EmptySubjectScreenState extends State<EmptySubjectScreen> {
  List<Topic> topics = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
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
          widget.selectedSubject,
          style: AppTextStyles.normal600(
              fontSize: 24.0, color: AppColors.primaryLight),
        ),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: topics.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                return _buildTopicSection(topics[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Nothing has been created for this subject',
            style: AppTextStyles.normal500(
                fontSize: 16.0, color: AppColors.backgroundDark),
          ),
          const SizedBox(height: 20),
          CustomMediumElevatedButton(
            text: 'Create content',
            onPressed: () => _showCreateOptionsBottomSheet(context),
            backgroundColor: AppColors.eLearningBtnColor1,
            textStyle: AppTextStyles.normal600(
                fontSize: 16, color: AppColors.backgroundLight),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          )
        ],
      ),
    );
  }

  Widget _buildTopicSection(Topic topic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            topic.name,
            style: AppTextStyles.normal600(
                fontSize: 18.0, color: AppColors.backgroundDark),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.primaryLight),
            onSelected: (String result) {
              if (result == 'edit') {
                // Implement edit functionality
              } else if (result == 'delete') {
                // Implement delete functionality
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
        ),
        ...topic.assignments.map((assignment) => _buildContentItem(
              assignment.title,
              'Assignment',
              assignment.createdAt,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewAssignmentScreen(assignment: assignment),
                  ),
                );
              },
            )),
        ...topic.questions.map((question) => _buildContentItem(
              question.title,
              'Question',
              question.createdAt,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewQuestionScreen(question: question),
                  ),
                );
              },
            )),
      ],
    );
  }

  Widget _buildContentItem(
      String title, String type, DateTime createdAt, VoidCallback onTap) {
    return ListTile(
      leading: SvgPicture.asset(
        type == 'Assignment'
            ? 'assets/icons/e_learning/assignment.svg'
            : 'assets/icons/e_learning/question_icon.svg',
        width: 24,
        height: 24,
      ),
      title: Text(title),
      subtitle: Text(
        'Created on ${_formatDate(createdAt)}',
        style: AppTextStyles.normal400(
            fontSize: 12.0, color: Colors.grey.shade600),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: AppColors.primaryLight),
        onSelected: (String result) {
          if (result == 'edit') {
            // Implement edit functionality
          } else if (result == 'delete') {
            // Implement delete functionality
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
      onTap: onTap,
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

  void _showCreateOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What do you want to create?',
                style: AppTextStyles.normal600(
                    fontSize: 18.0, color: AppColors.backgroundDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildOptionRow(context, 'Assignment',
                  'assets/icons/e_learning/assignment.svg'),
              _buildOptionRow(context, 'Question',
                  'assets/icons/e_learning/question_icon.svg'),
              _buildOptionRow(
                  context, 'Material', 'assets/icons/e_learning/material.svg'),
              _buildOptionRow(
                  context, 'Topic', 'assets/icons/e_learning/topic.svg'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              _buildOptionRow(
                  context, 'Reuse content', 'assets/icons/e_learning/share.svg'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionRow(BuildContext context, String text, String iconPath) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close the bottom sheet
        // Navigate to the appropriate screen based on the selected text option
        switch (text) {
          case 'Assignment':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssignmentScreen(
                  onSave: (assignment) {
                    _addAssignment(assignment);
                  },
                ),
              ),
            );
            break;
          case 'Question':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionScreen(
                  onSave: (question) {
                    _addQuestion(question);
                  },
                ),
              ),
            );
            break;
        case 'Topic':
          Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) => CreateTopicScreen(),),);
          break;
        case 'Material':
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddMaterialScreen()));
          break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SvgPicture.asset(iconPath, width: 24, height: 24),
            const SizedBox(width: 16),
            Text(text,
                style: AppTextStyles.normal500(
                    fontSize: 16, color: AppColors.backgroundDark)),
          ],
        ),
      ),
    );
  }

  void _addAssignment(Assignment assignment) {
    setState(() {
      Topic? existingTopic = topics.firstWhere(
        (topic) => topic.name == assignment.topic,
        orElse: () => Topic(name: assignment.topic, assignments: [], questions: []),
      );

      if (!topics.contains(existingTopic)) {
        topics.add(existingTopic);
      }

      existingTopic.assignments.add(assignment);
    });
  }

  void _addQuestion(Question question) {
    setState(() {
      Topic? existingTopic = topics.firstWhere(
        (topic) => topic.name == question.topic,
        orElse: () => Topic(name: question.topic, assignments: [], questions: []),
      );

      if (!topics.contains(existingTopic)) {
        topics.add(existingTopic);
      }

      existingTopic.questions.add(question);
    });
  }
}

class Topic {
  final String name;
  final List<Assignment> assignments;
  final List<Question> questions;

  Topic({required this.name, required this.assignments, required this.questions});
}

