
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/portal/e-learning/View/view_assignment_screen.dart';
import 'package:linkschool/modules/portal/e-learning/View/question/view_question_screen.dart';
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
  late double opacity;

  @override
  void initState() {
    super.initState();
    // Removed _addDummyData() to ensure the screen starts empty.
  }

  void _addDummyData() {
    topics = [
      Topic(
        name: 'Punctuality',
        assignments: [
          Assignment(
            title: 'Assignment 1',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            topic: 'Punctuality',
            description: 'Write an essay about the importance of punctuality',
            selectedClass: 'Class 10A',
            attachments: [],
            dueDate: DateTime.now().add(const Duration(days: 7)),
            marks: '20',
          ),
          Assignment(
            title: 'Assignment 2',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            topic: 'Punctuality',
            description: 'Create a presentation on time management techniques',
            selectedClass: 'Class 10B',
            attachments: [],
            dueDate: DateTime.now().add(const Duration(days: 10)),
            marks: '30',
          ),
        ],
        questions: [
          Question(
            title: 'Question 1',
            createdAt: DateTime.now().subtract(const Duration(days: 4)),
            topic: 'Punctuality',
            description: 'What are the benefits of being punctual?',
            selectedClass: 'Class 10A',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 1)),
            duration: const Duration(minutes: 30),
            marks: '10',
          ),
          Question(
            title: 'Question 2',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            topic: 'Punctuality',
            description: 'How can you improve your time management skills?',
            selectedClass: 'Class 10B',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 1)),
            duration: const Duration(minutes: 45),
            marks: '15',
          ),
        ],
      ),
      Topic(
        name: 'Time Management',
        assignments: [
          Assignment(
            title: 'Assignment 3',
            createdAt: DateTime.now().subtract(const Duration(days: 6)),
            topic: 'Time Management',
            description: 'Create a weekly schedule to improve time management',
            selectedClass: 'Class 11A',
            attachments: [],
            dueDate: DateTime.now().add(const Duration(days: 5)),
            marks: '25',
          ),
        ],
        questions: [
          Question(
            title: 'Question 3',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            topic: 'Time Management',
            description: 'What are the key principles of effective time management?',
            selectedClass: 'Class 11A',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 1)),
            duration: const Duration(minutes: 20),
            marks: '20',
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

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
        decoration: Constants.customBoxDecoration(context),
        child: topics.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  return _buildTopicSection(topics[index]);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nothing has been created for this subject',
              style: AppTextStyles.normal500(
                fontSize: 16.0,
                color: AppColors.backgroundDark,
              ),
            ),
            const SizedBox(height: 20),
            CustomMediumElevatedButton(
              text: 'Create content',
              onPressed: () => _showCreateOptionsBottomSheet(context),
              backgroundColor: AppColors.eLearningBtnColor1,
              textStyle: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundLight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            )
          ],
        ),
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
              fontSize: 20.0,
              color: AppColors.primaryLight,
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.primaryLight),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            color: AppColors.backgroundDark.withOpacity(0.2),
            thickness: 1,
          ),
        ),
        ...topic.assignments.map((assignment) => _buildContentItem(
              'Assignment',
              'Assignment',
              assignment.createdAt,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewAssignmentScreen(assignment: assignment),
                  ),
                );
              },
            )),
        ...topic.questions.map((question) => _buildContentItem(
              'Question',
              'Question',
              question.createdAt,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewQuestionScreen(question: question),
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
            ? 'assets/icons/e_learning/circle-assignment.svg'
            : 'assets/icons/e_learning/circle-question.svg',
        width: 36,
        height: 36,
      ),
      title: Text(
        title,
        style: AppTextStyles.normal600(
          fontSize: 18.0,
          color: AppColors.backgroundDark,
        ),
      ),
      subtitle: Text(
        'Created on ${_formatDate(createdAt)}',
        style: AppTextStyles.normal600(
          fontSize: 14.0,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: AppColors.primaryLight),
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

  void _addAssignment(Assignment assignment) {
    setState(() {
      if (topics.isEmpty) {
        _addDummyData(); // Add dummy data if the list is empty when the first assignment is added.
      }

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
      if (topics.isEmpty) {
        _addDummyData(); // Add dummy data if the list is empty when the first question is added.
      }

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
          Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) => const CreateTopicScreen(),),);
          break;
        case 'Material':
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMaterialScreen()));
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
}
