import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin_portal/e_learning/assignment_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/model/e-learning/material_model.dart' as custom;

import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/staff_portal/e_learning/staff_create_syllabus_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/sub_screens/staff_add_material_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/sub_screens/staff_assignment_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/sub_screens/staff_question_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/view/quiz_answer_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/view/staff_assignment_details_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/view/staff_material_details_screen.dart';



class StaffCourseDetailScreen extends StatefulWidget {
  final String courseTitle;

  const StaffCourseDetailScreen({super.key, required this.courseTitle});

  @override
  State<StaffCourseDetailScreen> createState() => _StaffCourseDetailScreenState();
}

class _StaffCourseDetailScreenState extends State<StaffCourseDetailScreen> {
  final List<Map<String, dynamic>> _syllabusList = [];
  late double opacity = 0.1;
  int _currentIndex = 0;
  Map<String, dynamic>? _currentSyllabus;
  List<Topic> topics = [];

  static const String _courseworkIconPath = 'assets/icons/student/coursework_icon.svg';
  static const String _forumIconPath = 'assets/icons/student/forum_icon.svg';

  @override
  void initState() {
    super.initState();
    _addDummyData();
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
        materials: [
          custom.Material(
            title: 'Importance of Time Management',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            topic: 'Punctuality',
            description: 'A comprehensive guide on time management techniques',
            selectedClass: 'Class 10A',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 1)),
            duration: const Duration(minutes: 30),
            marks: '10',
          ),
        ], description: '',
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
        materials: [
          custom.Material(
            title: 'Importance of Time Management',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            topic: 'Punctuality',
            description: 'A comprehensive guide on time management techniques',
            selectedClass: 'Class 10A',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 1)),
            duration: const Duration(minutes: 30),
            marks: '10',
          ),
        ], description: '',
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
        _currentSyllabus = result;
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
        _currentSyllabus = result;
      });
    }
  }

  void _deleteSyllabus(int index) {
    setState(() {
      _syllabusList.removeAt(index);
      if (_syllabusList.isEmpty) {
        _currentSyllabus = null;
      }
    });
  }

  void _addAssignment(Assignment assignment) {
    setState(() {
      if (topics.isEmpty) {
        _addDummyData();
      }

      Topic? existingTopic = topics.firstWhere(
        (topic) => topic.name == assignment.topic,
        orElse: () => Topic(name: assignment.topic, assignments: [], questions: [], materials: [], description: ''),
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
        _addDummyData();
      }

      Topic? existingTopic = topics.firstWhere(
        (topic) => topic.name == question.topic,
        orElse: () => Topic(name: question.topic, assignments: [], questions: [], materials: []),
      );

      if (!topics.contains(existingTopic)) {
        topics.add(existingTopic);
      }

      existingTopic.questions.add(question);

      if (_currentSyllabus != null) {
        _currentSyllabus!['questionTitle'] = question.title;
      }
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
              _buildOptionRow(context, 'Assignment', 'assets/icons/e_learning/assignment.svg'),
              _buildOptionRow(context, 'Question', 'assets/icons/e_learning/question_icon.svg'),
              _buildOptionRow(context, 'Material', 'assets/icons/e_learning/material.svg'),
              _buildOptionRow(context, 'Topic', 'assets/icons/e_learning/topic.svg'),
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
              _buildOptionRow(context, 'Reuse content', 'assets/icons/e_learning/share.svg'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionRow(BuildContext context, String text, String iconPath) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
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
                builder: (BuildContext context) => const StaffCreateSyllabusScreen(),
              ),
            );
            break;
          case 'Material':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StaffAddMaterialScreen(
                  onSave: (material) {
                    setState(() {
                      if (topics.isEmpty) {
                        topics.add(Topic(name: "Default Topic", assignments: [], questions: [], materials: []));
                      }
                      topics.first.materials.add(material);
                    });
                  },
                ),
              ),
            );
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
            Text(
              text,
              style: AppTextStyles.normal500(fontSize: 16, color: AppColors.backgroundDark),
            ),
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
              color: _currentIndex == 0 ? AppColors.eLearningBtnColor1 : Colors.grey,
            ),
            label: 'Coursework',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _forumIconPath,
              width: 24,
              height: 24,
              color: _currentIndex == 1 ? AppColors.eLearningBtnColor1 : Colors.grey,
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
      child: _currentSyllabus == null ? _buildEmptyState() : _buildForumContent(),
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

  // ======= syllabus detail ======== //

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
            if (topics.isNotEmpty && topics.first.assignments.isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffAssignmentDetailsScreen(
                        assignment: topics.first.assignments.first,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.eLearningBtnColor1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/e_learning/assignment.svg',
                          color: AppColors.eLearningBtnColor1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Assignment: ',
                                  style: AppTextStyles.normal600(
                                    fontSize: 14,
                                    color: AppColors.backgroundDark,
                                  ),
                                ),
                                Text(
                                  topics.first.assignments.first.title,
                                  style: AppTextStyles.normal400(
                                    fontSize: 14,
                                    color: AppColors.backgroundDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created on ${DateFormat('dd MMMM, yyyy').format(topics.first.assignments.first.createdAt)} · ${DateFormat('hh:mma').format(topics.first.assignments.first.createdAt).toLowerCase()}',
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
            if (topics.isNotEmpty && topics.first.questions.isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizAnswersScreen(
                        quizTitle: topics.first.questions.first.title,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.eLearningBtnColor1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/e_learning/question_icon.svg',
                          color: AppColors.eLearningBtnColor1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Quiz: ',
                                  style: AppTextStyles.normal600(
                                    fontSize: 14,
                                    color: AppColors.backgroundDark,
                                  ),
                                ),
                                Text(
                                  topics.first.questions.first.title,
                                  style: AppTextStyles.normal400(
                                    fontSize: 14,
                                    color: AppColors.backgroundDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created on ${DateFormat('dd MMMM, yyyy').format(topics.first.questions.first.createdAt)} · ${DateFormat('hh:mma').format(topics.first.questions.first.createdAt).toLowerCase()}',
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
            if (topics.isNotEmpty && topics.first.materials.isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffMaterialDetailsScreen(
                        material: topics.first.materials.first,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.eLearningBtnColor1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/e_learning/material.svg',
                          color: AppColors.eLearningBtnColor1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Material: ',
                                  style: AppTextStyles.normal600(
                                    fontSize: 14,
                                    color: AppColors.backgroundDark,
                                  ),
                                ),
                                Text(
                                  topics.first.materials.first.title,
                                  style: AppTextStyles.normal400(
                                    fontSize: 14,
                                    color: AppColors.backgroundDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created on ${DateFormat('dd MMMM, yyyy').format(topics.first.materials.first.createdAt)} · ${DateFormat('hh:mma').format(topics.first.materials.first.createdAt).toLowerCase()}',
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
            if (topics.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      topics.first.name,
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                  ),
                  _buildTopicItem(
                    'What is Punctuality?',
                    '25 June, 2015 · 08:52am',
                    Icons.help_outline,
                  ),
                  _buildTopicItem(
                    'First C.A',
                    '25 June, 2015 · 08:52am',
                    Icons.quiz_outlined,
                  ),
                  _buildTopicItem(
                    'Assignment',
                    '25 June, 2015 · 08:52am',
                    Icons.assignment_outlined,
                  ),
                  _buildTopicItem(
                    'Second C.A',
                    '25 June, 2015 · 08:52am',
                    Icons.quiz_outlined,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicItem(String title, String timestamp, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.eLearningBtnColor1,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.normal500(
                    fontSize: 14,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created on $timestamp',
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
    );
  }

  Widget _buildForumContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person_outline, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Share with your class...',
                      border: InputBorder.none,
                      hintStyle: AppTextStyles.normal400(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildForumPost(
                  title: topics.isNotEmpty
                      ? topics.first.name
                      : "What is Punctuality?",
                  date: "25 June, 2015",
                  time: "08:52am",
                  isTopicPost: true,
                ),
                ..._buildComments(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person_outline, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      hintStyle: AppTextStyles.normal400(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumPost({
    required String title,
    required String date,
    required String time,
    bool isTopicPost = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              isTopicPost
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.eLearningBtnColor1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.person_outline, color: Colors.grey),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                    Text(
                      '$date · $time',
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
        ],
      ),
    );
  }

  List<Widget> _buildComments() {
    return [
      _buildComment(
        name: "Tochukwu Dennis",
        content: "This is a mock data showing the info details of a post. This is a mock data sh",
        date: "03 Jan",
      ),
      _buildComment(
        name: "Tochukwu Dennis",
        content: "This is a mock data showing the info details of a post. This is a mock data sh",
        date: "03 Jan",
      ),
    ];
  }

  Widget _buildComment({
    required String name,
    required String content,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(48, 12, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                radius: 16,
                child: const Icon(Icons.person_outline, color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: AppColors.backgroundDark,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: AppTextStyles.normal400(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              content,
              style: AppTextStyles.normal400(
                fontSize: 14,
                color: AppColors.backgroundDark,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border, size: 16),
                  label: Text(
                    'Like',
                    style: AppTextStyles.normal400(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Reply',
                    style: AppTextStyles.normal400(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}