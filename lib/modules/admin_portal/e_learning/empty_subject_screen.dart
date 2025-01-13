import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/model/e-learning/material_model.dart' as custom;
import 'package:linkschool/modules/admin_portal/e_learning/View/quiz/quiz_screen.dart';
import 'package:linkschool/modules/admin_portal/e_learning/View/view_assignment_screen.dart';
import 'package:linkschool/modules/admin_portal/e_learning/View/question/view_question_screen.dart';
import 'package:linkschool/modules/admin_portal/e_learning/add_material_screen.dart';
import 'package:linkschool/modules/admin_portal/e_learning/assignment_screen.dart';
import 'package:linkschool/modules/admin_portal/e_learning/create_topic_screen.dart';
import 'package:linkschool/modules/admin_portal/e_learning/question_screen.dart';
import 'package:linkschool/modules/staff_portal/e_learning/view/staff_material_details_screen.dart';

class EmptySubjectScreen extends StatefulWidget {
  final String title;
  final String selectedSubject;

  const EmptySubjectScreen({
    super.key,
    required this.title,
    required this.selectedSubject,
  });

  @override
  _EmptySubjectScreenState createState() => _EmptySubjectScreenState();
}

class _EmptySubjectScreenState extends State<EmptySubjectScreen> {
  List<Topic> topics = []; // Initialize as empty
  late double opacity;

  @override
  void initState() {
    super.initState();
    // Do not call _addDummyData here to ensure the empty state is shown first
  }

  void _addAssignment(Assignment assignment) {
    setState(() {
      if (topics.isEmpty) {
        // Add a default topic if the list is empty
        topics.add(Topic(
          name: 'Default Topic',
          description: 'No description',
          assignments: [],
          questions: [],
          materials: [],
        ));
      }

      // Add the assignment to the first topic (or a specific topic)
      topics.first.assignments.add(assignment);
    });
  }

  void _addQuestion(Question question) {
    setState(() {
      if (topics.isEmpty) {
        // Add a default topic if the list is empty
        topics.add(Topic(
          name: 'Default Topic',
          description: 'No description',
          assignments: [],
          questions: [],
          materials: [],
        ));
      }

      // Add the question to the first topic (or a specific topic)
      topics.first.questions.add(question);
    });
  }

  void _addMaterial(custom.Material material) {
    setState(() {
      if (topics.isEmpty) {
        // Add a default topic if the list is empty
        topics.add(Topic(
          name: 'Default Topic',
          description: 'No description',
          assignments: [],
          questions: [],
          materials: [],
        ));
      }

      // Add the material to the first topic (or a specific topic)
      topics.first.materials.add(material);
    });
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
            : _buildSyllabusDetails(),
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
              onPressed: () {
                // Open the bottom sheet with options
                _showCreateOptionsBottomSheet(context);
              },
              backgroundColor: AppColors.eLearningBtnColor1,
              textStyle: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundLight,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSyllabusDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Background Image Container
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
                    'assets/images/syllabus_background.svg', // Update with correct path
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
                            topics.isNotEmpty ? topics.first.name : 'Topic Name',
                            style: AppTextStyles.normal700(
                              fontSize: 18,
                              color: AppColors.backgroundLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Class: Class 10A', // Update with dynamic data
                            style: AppTextStyles.normal500(
                              fontSize: 14,
                              color: AppColors.backgroundLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Teacher: John Doe', // Update with dynamic data
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

            // Description Card
            if (topics.isNotEmpty && topics.first.description != null)
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
                        'topics.first.description',
                        style: AppTextStyles.normal500(
                          fontSize: 14,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Assignments
            if (topics.isNotEmpty && topics.first.assignments.isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewAssignmentScreen(
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

            // Questions
            if (topics.isNotEmpty && topics.first.questions.isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewQuestionScreen(
                        question: topics.first.questions.first,
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

            // Materials
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
          ],
        ),
      ),
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
          case 'Material':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddMaterialScreen(
                          onSave: (material) {
                            _addMaterial(material);
                          },
                        )));
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



// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/e-learning/question_model.dart';
// import 'package:linkschool/modules/model/e-learning/topic_model.dart';
// import 'package:linkschool/modules/model/e-learning/material_model.dart' as custom;
// import 'package:linkschool/modules/admin_portal/e_learning/View/view_assignment_screen.dart';
// import 'package:linkschool/modules/admin_portal/e_learning/View/question/view_question_screen.dart';
// import 'package:linkschool/modules/admin_portal/e_learning/add_material_screen.dart';
// import 'package:linkschool/modules/admin_portal/e_learning/assignment_screen.dart';
// import 'package:linkschool/modules/admin_portal/e_learning/create_topic_screen.dart';
// import 'package:linkschool/modules/admin_portal/e_learning/question_screen.dart';

// class EmptySubjectScreen extends StatefulWidget {
//   final String title;
//   final String selectedSubject;

//   const EmptySubjectScreen({
//     super.key,
//     required this.title,
//     required this.selectedSubject,
//   });

//   @override
//   _EmptySubjectScreenState createState() => _EmptySubjectScreenState();
// }

// class _EmptySubjectScreenState extends State<EmptySubjectScreen> {
//   List<Topic> topics = [];
//   late double opacity;

//   @override
//   void initState() {
//     super.initState();
//     // Removed _addDummyData() to ensure the screen starts empty.
//   }

//   void _addDummyData() {
//     topics = [
//       Topic(
//         name: 'Punctuality',
//         assignments: [
//           Assignment(
//             title: 'Assignment 1',
//             createdAt: DateTime.now().subtract(const Duration(days: 5)),
//             topic: 'Punctuality',
//             description: 'Write an essay about the importance of punctuality',
//             selectedClass: 'Class 10A',
//             attachments: [],
//             dueDate: DateTime.now().add(const Duration(days: 7)),
//             marks: '20',
//           ),
//         ],
//         questions: [
//           Question(
//             title: 'Question 1',
//             createdAt: DateTime.now().subtract(const Duration(days: 4)),
//             topic: 'Punctuality',
//             description: 'What are the benefits of being punctual?',
//             selectedClass: 'Class 10A',
//             startDate: DateTime.now(),
//             endDate: DateTime.now().add(const Duration(days: 1)),
//             duration: const Duration(minutes: 30),
//             marks: '10',
//           ),
//         ],
//         materials: [
//           custom.Material(
//             title: 'Importance of Time Management',
//             createdAt: DateTime.now().subtract(const Duration(days: 3)),
//             topic: 'Punctuality',
//             description: 'A comprehensive guide on time management techniques',
//             selectedClass: 'Class 10A',
//             startDate: DateTime.now(),
//             endDate: DateTime.now().add(const Duration(days: 1)),
//             duration: const Duration(minutes: 30),
//             marks: '10',
//           ),
//         ],
//       ),
//       Topic(
//         name: 'Time Management',
//         assignments: [
//           Assignment(
//             title: 'Assignment 3',
//             createdAt: DateTime.now().subtract(const Duration(days: 6)),
//             topic: 'Time Management',
//             description: 'Create a weekly schedule to improve time management',
//             selectedClass: 'Class 11A',
//             attachments: [],
//             dueDate: DateTime.now().add(const Duration(days: 5)),
//             marks: '25',
//           ),
//         ],
//         questions: [
//           Question(
//             title: 'Question 3',
//             createdAt: DateTime.now().subtract(const Duration(days: 1)),
//             topic: 'Time Management',
//             description:
//                 'What are the key principles of effective time management?',
//             selectedClass: 'Class 11A',
//             startDate: DateTime.now(),
//             endDate: DateTime.now().add(const Duration(days: 1)),
//             duration: const Duration(minutes: 20),
//             marks: '20',
//           ),
//         ],
//         materials: [
//           custom.Material(
//             title: 'Importance of Time Management',
//             createdAt: DateTime.now().subtract(const Duration(days: 3)),
//             topic: 'Punctuality',
//             description: 'A comprehensive guide on time management techniques',
//             selectedClass: 'Class 10A',
//             startDate: DateTime.now(),
//             endDate: DateTime.now().add(const Duration(days: 1)),
//             duration: const Duration(minutes: 30),
//             marks: '10',
//           ),
//         ],
//       ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.primaryLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           widget.selectedSubject,
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.primaryLight,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: topics.isEmpty
//             ? _buildEmptyState()
//             : ListView.builder(
//                 itemCount: topics.length,
//                 itemBuilder: (context, index) {
//                   return _buildTopicSection(topics[index]);
//                 },
//               ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       decoration: Constants.customBoxDecoration(context),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Nothing has been created for this subject',
//               style: AppTextStyles.normal500(
//                 fontSize: 16.0,
//                 color: AppColors.backgroundDark,
//               ),
//             ),
//             const SizedBox(height: 20),
//             CustomMediumElevatedButton(
//               text: 'Create content',
//               onPressed: () => _showCreateOptionsBottomSheet(context),
//               backgroundColor: AppColors.eLearningBtnColor1,
//               textStyle: AppTextStyles.normal600(
//                 fontSize: 16,
//                 color: AppColors.backgroundLight,
//               ),
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//             )
//           ],
//         ),
//       ),
//     );
//   }

// Widget _buildTopicSection(Topic topic) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ListTile(
//           title: Text(
//             topic.name,
//             style: AppTextStyles.normal600(
//               fontSize: 20.0,
//               color: AppColors.primaryLight,
//             ),
//           ),
//           trailing: PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: AppColors.primaryLight),
//             onSelected: (String result) {
//               if (result == 'edit') {
//                 // Implement edit functionality
//               } else if (result == 'delete') {
//                 // Implement delete functionality
//               }
//             },
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//               const PopupMenuItem<String>(
//                 value: 'edit',
//                 child: Text('Edit'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'delete',
//                 child: Text('Delete'),
//               ),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Divider(
//             color: AppColors.backgroundDark.withOpacity(0.2),
//             thickness: 1,
//           ),
//         ),
//         ...topic.assignments.map((assignment) => _buildContentItem(
//               'Assignment',
//               assignment.title,
//               assignment.createdAt,
//               () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ViewAssignmentScreen(assignment: assignment),
//                   ),
//                 );
//               },
//             )),
//         ...topic.questions.map((question) => _buildContentItem(
//               'Question',
//               question.title,
//               question.createdAt,
//               () {

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ViewQuestionScreen(question: question),
//                   ),
//                 );
//               },
//             )),
//       ],
//     );
//   }

//  Widget _buildContentItem(String type, String title, DateTime createdAt, VoidCallback onTap) {
//     return Column(
//       children: [
//         ListTile(
//           leading: SvgPicture.asset(
//             type == 'Assignment'
//                 ? 'assets/icons/e_learning/circle-assignment.svg'
//                 : 'assets/icons/e_learning/circle-question.svg',
//             width: 36,
//             height: 36,
//           ),
//           title: Text(
//             title,
//             style: AppTextStyles.normal600(
//               fontSize: 18.0,
//               color: AppColors.backgroundDark,
//             ),
//           ),
//           subtitle: Text(
//             'Created on ${_formatDate(createdAt)}',
//             style: AppTextStyles.normal600(
//               fontSize: 14.0,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           trailing: PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: AppColors.primaryLight),
//             onSelected: (String result) {
//               if (result == 'edit') {
//                 onTap();
//               } else if (result == 'delete') {
//                 // Implement delete functionality
//               }
//             },
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//               const PopupMenuItem<String>(
//                 value: 'edit',
//                 child: Text('Edit'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'delete',
//                 child: Text('Delete'),
//               ),
//             ],
//           ),
//           onTap: onTap,
//         ),
//         const Divider(height: 1, thickness: 1),
//       ],
//     );
//   }


//   void _addAssignment(Assignment assignment) {
//     setState(() {
//       if (topics.isEmpty) {
//         _addDummyData(); // Add dummy data if the list is empty when the first assignment is added.
//       }

//       Topic? existingTopic = topics.firstWhere(
//         (topic) => topic.name == assignment.topic,
//         orElse: () =>
//             Topic(name: assignment.topic, assignments: [], questions: [], materials: []),
//       );

//       if (!topics.contains(existingTopic)) {
//         topics.add(existingTopic);
//       }

//       existingTopic.assignments.add(assignment);
//     });
//   }

//   void _addQuestion(Question question) {
//     setState(() {
//       if (topics.isEmpty) {
//         _addDummyData(); // Add dummy data if the list is empty when the first question is added.
//       }

//       Topic? existingTopic = topics.firstWhere(
//         (topic) => topic.name == question.topic,
//         orElse: () =>
//             Topic(name: question.topic, assignments: [], questions: [], materials: []),
//       );

//       if (!topics.contains(existingTopic)) {
//         topics.add(existingTopic);
//       }

//       existingTopic.questions.add(question);
//     });
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day} ${_getMonth(date.month)}, ${date.year} ${_formatTime(date)}';
//   }

//   String _getMonth(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return months[month - 1];
//   }

//   String _formatTime(DateTime date) {
//     return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}${date.hour >= 12 ? 'pm' : 'am'}';
//   }

//   void _showCreateOptionsBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'What do you want to create?',
//                 style: AppTextStyles.normal600(
//                     fontSize: 18.0, color: AppColors.backgroundDark),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               _buildOptionRow(context, 'Assignment',
//                   'assets/icons/e_learning/assignment.svg'),
//               _buildOptionRow(context, 'Question',
//                   'assets/icons/e_learning/question_icon.svg'),
//               _buildOptionRow(
//                   context, 'Material', 'assets/icons/e_learning/material.svg'),
//               _buildOptionRow(
//                   context, 'Topic', 'assets/icons/e_learning/topic.svg'),
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10),
//                 child: Row(
//                   children: [
//                     Expanded(child: Divider()),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       child: Text('or', style: TextStyle(color: Colors.grey)),
//                     ),
//                     Expanded(child: Divider()),
//                   ],
//                 ),
//               ),
//               _buildOptionRow(context, 'Reuse content',
//                   'assets/icons/e_learning/share.svg'),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildOptionRow(BuildContext context, String text, String iconPath) {
//     return InkWell(
//       onTap: () {
//         Navigator.pop(context); // Close the bottom sheet
//         // Navigate to the appropriate screen based on the selected text option
//         switch (text) {
//           case 'Assignment':
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AssignmentScreen(
//                   onSave: (assignment) {
//                     _addAssignment(assignment);
//                   },
//                 ),
//               ),
//             );
//             break;
//           case 'Question':
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => QuestionScreen(
//                   onSave: (question) {
//                     _addQuestion(question);
//                   },
//                 ),
//               ),
//             );
//             break;
//           case 'Topic':
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 fullscreenDialog: true,
//                 builder: (BuildContext context) => const CreateTopicScreen(),
//               ),
//             );
//             break;
//           case 'Material':
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const AddMaterialScreen()));
//             break;
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         margin: const EdgeInsets.only(bottom: 8),
//         decoration: BoxDecoration(
//           color: AppColors.backgroundLight,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             SvgPicture.asset(iconPath, width: 24, height: 24),
//             const SizedBox(width: 16),
//             Text(text,
//                 style: AppTextStyles.normal500(
//                     fontSize: 16, color: AppColors.backgroundDark)),
//           ],
//         ),
//       ),
//     );
//   }
// }