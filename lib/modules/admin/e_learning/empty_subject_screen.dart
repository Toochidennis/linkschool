import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/add_material_screen.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/admin/e_learning/create_topic_screen.dart';
import 'package:linkschool/modules/admin/e_learning/question_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/model/e-learning/material_model.dart' as custom;
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/staff/e_learning/staff_create_syllabus_screen.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_add_material_screen.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_question_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/quiz_answer_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/staff_assignment_details_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/staff_material_details_screen.dart';

class EmptySubjectScreen extends StatefulWidget {
  final String courseTitle;
  final String? courseId;
  final String? levelId;
  final String? classId;
  final String? courseName;

  const EmptySubjectScreen({super.key, required this.courseTitle, this.courseId, this.levelId, this.classId, this.courseName});

  @override
  State<EmptySubjectScreen> createState() => _EmptySubjectScreenState();
}

class _EmptySubjectScreenState extends State<EmptySubjectScreen> {
  // final List<Map<String, dynamic>> _syllabusList = [];
  // Map<String, dynamic>? _currentSyllabus;
  late double opacity = 0.1;
  List<Topic> topics = [];
  bool _showCourseworkScreen = false;

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
        ],
        description: '',
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
        ],
        description: '',
      ),
    ];
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
        Navigator.pop(context);
        
        switch (text) {
          case 'Assignment':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminAssignmentScreen(
                    classId: widget.classId,
            courseId: widget.courseId,
            levelId: widget.levelId,
                    courseName: widget.courseName,
                  onSave: (assignment) {
                    setState(() {
                      _showCourseworkScreen = true;
                    });
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
                      classId: widget.classId,
            courseId: widget.courseId,
            levelId: widget.levelId,
                    courseName: widget.courseName,
                  onSave: (question) {
                    setState(() {
                      _showCourseworkScreen = true;
                    });
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
                    CreateTopicScreen(
                       courseId: widget.courseId,
                  levelId: widget.levelId,
                  classId: widget.classId,
                    ),
              ),
            );
            break;
          case 'Material':

          Navigator.push(context, MaterialPageRoute(builder: (_)=>AddMaterialScreen(
                 courseId: widget.courseId,
                  levelId: widget.levelId,
                  classId: widget.classId,
                  courseName: widget.courseName,
                 onSave: (material) {
                    setState(() {
                      _showCourseworkScreen = true;
                     });}
          )));
            //Navigator.push(
              //context,
             // MaterialPageRoute(builder: 
              // MaterialPageRoute(
              //   builder: (context) => StaffAddMaterialScreen(
              //     courseId: widget.courseId,
              //     levelId: widget.levelId,
              //     classId: widget.classId,
              //     courseName: widget.courseName,
                  
              //     onSave: (material) {
              //       setState(() {
              //         _showCourseworkScreen = true;
              //       });
              //     },
              //   ),
              // ),
           // );
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
              style: AppTextStyles.normal500(
                  fontSize: 16, color: AppColors.backgroundDark),
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
      body: _buildCourseworkScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptionsBottomSheet(context),
        backgroundColor: AppColors.staffBtnColor1,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCourseworkScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: Constants.customBoxDecoration(context),
      child: _showCourseworkScreen ? _buildSyllabusDetails() : _buildEmptyState(),
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
              text: 'Create content',
              onPressed: () {
                _showCreateOptionsBottomSheet(context);
              },
              backgroundColor: AppColors.eLearningBtnColor1,
              textStyle: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundLight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSyllabusDetails() {
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
                    'assets/images/admission/background_img.svg',
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
                            widget.courseTitle,
                            style: AppTextStyles.normal700(
                              fontSize: 18,
                              color: AppColors.backgroundLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Class: ${topics.isNotEmpty ? topics.first.assignments.first.selectedClass : "N/A"}',
                            style: AppTextStyles.normal500(
                              fontSize: 14,
                              color: AppColors.backgroundLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Teacher: Current Teacher',
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
}