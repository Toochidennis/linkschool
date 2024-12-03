import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin_portal/e_learning/assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/staff_portal/e_learning/staff_create_syllabus_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/sub_screens/staff_add_material_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/sub_screens/staff_assignment_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/sub_screens/staff_question_screen.dart';


class StaffCourseDetailScreen extends StatefulWidget {
  final String courseTitle;

  const StaffCourseDetailScreen({super.key, required this.courseTitle});

  @override
  State<StaffCourseDetailScreen> createState() =>
      _StaffCourseDetailScreenState();
}

class _StaffCourseDetailScreenState extends State<StaffCourseDetailScreen> {
  List<Map<String, dynamic>> _syllabusList = [];
  late double opacity;
  int _currentIndex = 0; // For bottom navigation
  Map<String, dynamic>? _currentSyllabus; // To store the latest syllabus
  List<Topic> topics = [];

  static const String _courseworkIconPath =
      'assets/icons/student/coursework_icon.svg';
  static const String _forumIconPath = 'assets/icons/student/forum_icon.svg';

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
            description:
                'What are the key principles of effective time management?',
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

  void _addNewSyllabus() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => const StaffCreateSyllabusScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _syllabusList.add(result);
        _currentSyllabus = result; // Update current syllabus
      });
    }
  }

  void _editSyllabus(int index) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => StaffCreateSyllabusScreen(
          syllabusData: _syllabusList[index],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _syllabusList[index] = result;
        _currentSyllabus = result; // Update current syllabus
      });
    }
  }

  void _deleteSyllabus(int index) {
    setState(() {
      _syllabusList.removeAt(index);
      if (_syllabusList.isEmpty) {
        _currentSyllabus = null; // Reset current syllabus if list is empty
      }
    });
  }

  void _addAssignment(Assignment assignment) {
    setState(() {
      if (topics.isEmpty) {
        _addDummyData(); // Add dummy data if the list is empty when the first assignment is added.
      }

      Topic? existingTopic = topics.firstWhere(
        (topic) => topic.name == assignment.topic,
        orElse: () =>
            Topic(name: assignment.topic, assignments: [], questions: []),
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
        orElse: () =>
            Topic(name: question.topic, assignments: [], questions: []),
      );

      if (!topics.contains(existingTopic)) {
        topics.add(existingTopic);
      }

      existingTopic.questions.add(question);
    });
  }

  void _confirmDeleteSyllabus(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Syllabus',
            style: AppTextStyles.normal600(
              fontSize: 20,
              color: AppColors.backgroundDark,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this syllabus?',
            style: AppTextStyles.normal500(
              fontSize: 16,
              color: AppColors.backgroundDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'No',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteSyllabus(index);
                Navigator.of(context).pop();
              },
              child: Text(
                'Yes',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
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
              _buildOptionRow(context, 'Reuse content',
                  'assets/icons/e_learning/share.svg'),
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
                builder: (context) => StaffAssignmentScreen(
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
                builder: (context) => StaffQuestionScreen(
                  onSave: (question) {
                    _addQuestion(question);
                  },
                ),
              ),
            );
            break;
          case 'Topic':
            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (BuildContext context) =>
                    const StaffCreateSyllabusScreen(),
              ),
            );
            break;
          case 'Material':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StaffAddMaterialScreen()));
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
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildCourseworkScreen(),
          _buildForumScreen(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showCreateOptionsBottomSheet(context),
              backgroundColor: AppColors.staffBtnColor1,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.eLearningBtnColor1,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _courseworkIconPath,
              width: 24,
              height: 24,
              color: _currentIndex == 0
                  ? AppColors.eLearningBtnColor1
                  : Colors.grey,
            ),
            label: 'Coursework',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _forumIconPath,
              width: 24,
              height: 24,
              color: _currentIndex == 1
                  ? AppColors.eLearningBtnColor1
                  : Colors.grey,
            ),
            label: 'Forum',
          ),
        ],
      ),
    );
  }

  Widget _buildCourseworkScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: Constants.customBoxDecoration(context),
      child: _currentSyllabus == null
          ? _buildEmptyState()
          : _buildSyllabusDetails(),
    );
  }

Widget _buildForumScreen() {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: Constants.customBoxDecoration(context),
    child: _currentSyllabus == null 
      ? _buildEmptyState() 
      : _buildForumContent(), // Create a new method for Forum screen content
  );
}

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('No syllabus have been created'),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomMediumElevatedButton(
              text: 'Create new syllabus',
              onPressed: _addNewSyllabus,
              backgroundColor: AppColors.eLearningBtnColor1,
              textStyle: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundLight,
              ),
              padding: const EdgeInsets.all(12),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSyllabusDetails() {
    if (_currentSyllabus == null) return _buildEmptyState();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 95,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset(
                    _currentSyllabus!['backgroundImagePath'],
                    width: MediaQuery.of(context).size.width,
                    height: 95,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentSyllabus!['title'],
                            style: AppTextStyles.normal700(
                              fontSize: 18,
                              color: AppColors.backgroundLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Class: ${_currentSyllabus!['selectedClass']}',
                            style: AppTextStyles.normal500(
                              fontSize: 14,
                              color: AppColors.backgroundLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Teacher: ${_currentSyllabus!['selectedTeacher']}',
                            style: AppTextStyles.normal600(
                              fontSize: 12,
                              color: AppColors.backgroundLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_currentSyllabus!['description'] != null &&
                _currentSyllabus!['description'].isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: AppTextStyles.normal600(
                          fontSize: 16,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentSyllabus!['description'],
                        style: AppTextStyles.normal500(
                          fontSize: 14,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Assignment Row
            if (topics.isNotEmpty && topics.first.assignments.isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/e_learning/assignment.svg',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assignment',
                              style: AppTextStyles.normal600(
                                fontSize: 16,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                            Text(
                              topics.first.assignments.first.title,
                              style: AppTextStyles.normal500(
                                fontSize: 14,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created on ${DateFormat('dd MMMM, yyyy hh.mm a').format(topics.first.assignments.first.createdAt)}',
                              style: AppTextStyles.normal400(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Question Row
            if (topics.isNotEmpty && topics.first.questions.isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/e_learning/question_icon.svg',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question',
                              style: AppTextStyles.normal600(
                                fontSize: 16,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                            Text(
                              topics.first.questions.first.title,
                              style: AppTextStyles.normal500(
                                fontSize: 14,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created on ${DateFormat('dd MMMM, yyyy hh.mm a').format(topics.first.questions.first.createdAt)}',
                              style: AppTextStyles.normal400(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

Widget _buildForumContent() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 95, 
            width: MediaQuery.of(context).size.width, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent,
            ),
            child: Stack(
              fit: StackFit.expand, 
              children: [
                SvgPicture.asset(
                  _currentSyllabus!['backgroundImagePath'],
                  width: MediaQuery.of(context).size.width, 
                  height: 95, 
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentSyllabus!['title'],
                          style: AppTextStyles.normal700(
                            fontSize: 18,
                            color: AppColors.backgroundLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Class: ${_currentSyllabus!['selectedClass']}',
                          style: AppTextStyles.normal500(
                            fontSize: 14,
                            color: AppColors.backgroundLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Teacher: ${_currentSyllabus!['selectedTeacher']}',
                          style: AppTextStyles.normal600(
                            fontSize: 12,
                            color: AppColors.backgroundLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_currentSyllabus!['description'] != null && _currentSyllabus!['description'].isNotEmpty)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description:',
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentSyllabus!['description'],
                      style: AppTextStyles.normal500(
                        fontSize: 14,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // No Assignment or Question rows in Forum screen
          // Add any Forum-specific content here if needed
        ],
      ),
    ),
  );
}
}