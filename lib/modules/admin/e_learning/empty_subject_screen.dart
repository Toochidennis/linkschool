import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/View/quiz/quiz_screen.dart';
import 'package:linkschool/modules/admin/e_learning/add_material_screen.dart'
    hide AttachmentItem;
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/admin/e_learning/create_topic_screen.dart';
import 'package:linkschool/modules/admin/e_learning/question_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/model/e-learning/syllabus_content_model.dart';
import 'package:linkschool/modules/providers/admin/e_learning/assignment_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';

import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';

import 'package:linkschool/modules/staff/e_learning/view/quiz_answer_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/staff_assignment_details_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/staff_material_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/model/e-learning/material_model.dart'
    as custom;
import 'package:linkschool/modules/services/api/service_locator.dart';
import '../../common/widgets/portal/attachmentItem.dart';
import '../../model/explore/home/exam_model.dart';
import '../../providers/admin/e_learning/syllabus_content_provider.dart';

class EmptySubjectScreen extends StatefulWidget {
  final String? courseTitle;
  final String? courseId;
  final String? levelId;
  final String? classId;
  final String? courseName;
  final String? term;
  final int? syllabusId;
  final List<Map<String, dynamic>>? syllabusClasses;

  const EmptySubjectScreen({
    super.key,
    this.syllabusId,
    this.courseTitle,
    this.courseId,
    this.levelId,
    this.classId,
    this.courseName,
    this.term,
    this.syllabusClasses,
  });

  @override
  State<EmptySubjectScreen> createState() => _EmptySubjectScreenState();
}

class _EmptySubjectScreenState extends State<EmptySubjectScreen>
    with WidgetsBindingObserver {
  late double opacity = 0.1;
  List<TopicContent> _topics = [];
  List<SyllabusContentItem> _noTopicItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSyllabusContents();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSyllabusContents();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadSyllabusContents() async {
    if (widget.syllabusId == null) {
      CustomToaster.toastError(context, 'Error', 'Syllabus ID is missing');
      return;
    }

    try {
      final contentProvider = locator<SyllabusContentProvider>();

      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
      final processedData = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData;
      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      final settings = data['settings'] ?? {};
      final dbName =
          settings['db_name']?.toString() ?? 'aalmgzmy_linkskoo_practice';

      await contentProvider.fetchSyllabusContents(widget.syllabusId!, dbName);

      if (contentProvider.error.isEmpty) {
        _processContents(contentProvider.contents);
      } else {
        CustomToaster.toastError(context, 'Error', contentProvider.error);
      }
    } catch (e) {
      print('Error loading syllabus contents: $e');
      CustomToaster.toastError(
          context, 'Error', 'Failed to load syllabus contents: $e');
    }
  }

  void _processContents(List<Map<String, dynamic>> contents) {
    final topics = <TopicContent>[];
    final noTopicItems = <SyllabusContentItem>[];

    for (final content in contents) {
      if (content['type'] == 'topic') {
        final children = content['children'] as List<dynamic>? ?? [];
        final topicChildren = <SyllabusContentItem>[];
        for (final child in children) {
          if (child is Map<String, dynamic> && child.containsKey('settings')) {
            final settings = child['settings'] as Map<String, dynamic>;
            topicChildren.add(SyllabusContentItem.fromJson({
              ...settings,
              'questions': child['questions'] ?? [],
            }));
          } else {
            topicChildren.add(
                SyllabusContentItem.fromJson(child as Map<String, dynamic>));
          }
        }
        topics.add(TopicContent(
          id: content['id'],
          name: content['title'] ?? '',
          type: content['type'] ?? '',
          children: topicChildren,
        ));
      } else if (content['type'] == 'no topic') {
        final children = content['children'] as List<dynamic>? ?? [];
        for (final child in children) {
          if (child is Map<String, dynamic> && child.containsKey('settings')) {
            final settings = child['settings'] as Map<String, dynamic>;
            noTopicItems.add(SyllabusContentItem.fromJson({
              ...settings,
              'questions': child['questions'] ?? [],
            }));
          } else {
            noTopicItems.add(
                SyllabusContentItem.fromJson(child as Map<String, dynamic>));
          }
        }
      }
    }

    setState(() {
      _topics = topics;
      _noTopicItems = noTopicItems;
    });
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
                  fontSize: 18.0,
                  color: AppColors.backgroundDark,
                ),
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

  Widget _buildOptionRow(
    BuildContext context,
    String text,
    String iconPath,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        switch (text) {
          case 'Assignment':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminAssignmentScreen(
                  syllabusId: widget.syllabusId,
                  classId: widget.classId,
                  courseId: widget.courseId,
                  levelId: widget.levelId,
                  courseName: widget.courseName,
                  syllabusClasses: widget.syllabusClasses,
                  editMode: false,
                  onSave: (assignment) {
                    _loadSyllabusContents();
                  },
                ),
              ),
            );
            break;
          case 'Question':
            if (widget.syllabusId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Syllabus ID is missing'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionScreen(
                  // Use QuestionScreen instead of StaffQuestionScreen
                  classId: widget.classId,
                  syllabusId: widget.syllabusId!,
                  courseId: widget.courseId,
                  levelId: widget.levelId,
                  courseName: widget.courseName,
                  onSave: (question) {
                    _loadSyllabusContents();
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
                builder: (BuildContext context) => CreateTopicScreen(
                  syllabusId: widget.syllabusId,
                  courseId: widget.courseId,
                  levelId: widget.levelId,
                  classId: widget.classId,
                ),
              ),
            );
            break;
          case 'Material':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddMaterialScreen(
                  syllabusClasses: widget.syllabusClasses,
                  courseId: widget.courseId,
                  levelId: widget.levelId,
                  classId: widget.classId,
                  syllabusId: widget.syllabusId,
                  courseName: widget.courseName,
                  onSave: (material) {
                    _loadSyllabusContents(); // Reload content after saving
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

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return ChangeNotifierProvider.value(
      value: locator<SyllabusContentProvider>(),
      child: Scaffold(
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
            widget.courseTitle ?? 'Course',
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
                ),
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
      ),
    );
  }

  Widget _buildCourseworkScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: Constants.customBoxDecoration(context),
      child: Consumer<SyllabusContentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: _loadSyllabusContents,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_topics.isEmpty && _noTopicItems.isEmpty) {
            return _buildEmptyState();
          }

          return _buildSyllabusDetails();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('No content has been created'),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomMediumElevatedButton(
              text: 'Create content',
              onPressed: () => _showCreateOptionsBottomSheet(context),
              backgroundColor: AppColors.eLearningBtnColor1,
              textStyle: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundLight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSyllabusDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.courseTitle ?? 'Course',
                            style: AppTextStyles.normal700(
                              fontSize: 18,
                              color: AppColors.backgroundLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Class: ${_getClassNames()}',
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
            ..._noTopicItems.map(_buildContentItem),
            ..._topics.map(_buildTopicSection),
          ],
        ),
      ),
    );
  }

  String _getClassNames() {
    if (_noTopicItems.isNotEmpty && _noTopicItems.first.classes.isNotEmpty) {
      return _noTopicItems.first.classes.map((c) => c.name).join(', ');
    }
    if (_topics.isNotEmpty &&
        _topics.first.children.isNotEmpty &&
        _topics.first.children.first.classes.isNotEmpty) {
      return _topics.first.children.first.classes.map((c) => c.name).join(', ');
    }
    return 'N/A';
  }

  Widget _buildTopicSection(TopicContent topic) {
    if (topic.children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(children: [
            Text(
              topic.name,
              style: AppTextStyles.normal600(
                fontSize: 18,
                color: AppColors.backgroundDark,
              ),
            ),
            //   PopupMenuButton<String>(
            //   icon: const Icon(
            //     Icons.more_vert,
            //     color: AppColors.paymentTxtColor1,
            //   ),
            //   onSelected: (String result) {
            //     switch (result) {
            //       case 'edit':
            //         _handleEditItem(item);
            //         break;
            //       case 'delete':
            //         // Handle delete functionality
            //         //  _showDeleteConfirmation(item);
            //         break;
            //     }
            //   },
            //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            //     const PopupMenuItem<String>(
            //       value: 'edit',
            //       child: Row(
            //         children: [
            //           Icon(Icons.edit, size: 16),
            //           SizedBox(width: 8),
            //           Text('Edit'),
            //         ],
            //       ),
            //     ),
            //     const PopupMenuItem<String>(
            //       value: 'delete',
            //       child: Row(
            //         children: [
            //           Icon(Icons.delete, size: 16, color: Colors.red),
            //           SizedBox(width: 8),
            //           Text('Delete', style: TextStyle(color: Colors.red)),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),

            
          ]),
        ),
        ...topic.children.map((item) => _buildTopicItem(
              item.title,
              item.datePosted != null
                  ? _formatDate(DateTime.parse(item.datePosted!))
                  : 'No date',
              _getIconForType(item.type),
              item,
            )),
      ],
    );
  }

  Widget _buildContentItem(SyllabusContentItem item) {
    return InkWell(
      onTap: () => _navigateToDetails(item),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                _getIconPathForType(item.type),
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
                        '${_getTypeDisplayName(item.type)}: ',
                        style: AppTextStyles.normal600(
                          fontSize: 14,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.normal400(
                            fontSize: 14,
                            color: AppColors.backgroundDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.datePosted != null
                        ? 'Created on ${_formatDate(DateTime.parse(item.datePosted!))}'
                        : 'No date available',
                    style: AppTextStyles.normal400(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.paymentTxtColor1,
              ),
              onSelected: (String result) {
                switch (result) {
                  case 'edit':
                    _handleEditItem(item);
                    break;
                  case 'delete':
                    _showDeleteConfirmationDialog(item);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicItem(
      String title, String timestamp, IconData icon, SyllabusContentItem item) {
    return InkWell(
      onTap: () => _navigateToDetails(item),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.paymentTxtColor1,
              ),
              onSelected: (String result) {
                switch (result) {
                  case 'edit':
                    _handleEditItem(item);
                    break;
                  case 'delete':
                    _showDeleteConfirmationDialog(item);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleEditItem(SyllabusContentItem item) {
        final attachments = item.contentFiles.map((file) {
      return AttachmentItem(
        fileName: file.fileName,
        iconPath: (file.type == 'image' || file.type == 'photo')
            ? 'assets/icons/e_learning/material.svg'
            : 'assets/icons/e_learning/link.svg',
        fileContent: file.file.isNotEmpty
            ? file.file
            : 'https://yourserver.com/${file.fileName}', // Replace with your base URL
      );
    }).toList();
    switch (item.type.toLowerCase()) {
      case 'assignment':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminAssignmentScreen(
              syllabusId: widget.syllabusId,
              classId: widget.classId,
              courseId: widget.courseId,
              levelId: widget.levelId,
              courseName: widget.courseName,
              syllabusClasses: widget.syllabusClasses,
              editMode: true,
              assignmentToEdit: Assignment(
                id: item.id,
                title: item.title,
                description: item.description,
                selectedClass: item.classes.map((c) => c.name).join(', '),
                attachments: attachments,
                dueDate: item.endDate != null
                    ? DateTime.parse(item.endDate!)
                    : DateTime.now(),
                topic: item.topic ?? 'No Topic',
                marks: item.grade ?? '0',
              ),
              onSave: (assignment) {
                _loadSyllabusContents();
              },
            ),
          ),
        );
        break;

      case 'quiz':
      case 'question':
        if (widget.syllabusId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Syllabus ID is missing'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionScreen(
                classId: widget.classId,
                syllabusId: widget.syllabusId!,
                courseId: widget.courseId,
                levelId: widget.levelId,
                courseName: widget.courseName,
                onSave: (Question) {
                  _loadSyllabusContents();
                },
                // Pass the item data for editing
                editMode: true,
                questionToEdit: Question(
                  id: item.id, // Make sure your Question model has an id field
                  title: item.title,
                  description: item.description,
                  selectedClass: item.classes.map((c) => c.name).join(', '),
                  startDate: item.startDate != null
                      ? DateTime.parse(item.startDate!)
                      : DateTime.now(),
                  endDate: item.endDate != null
                      ? DateTime.parse(item.endDate!)
                      : DateTime.now(),
                      
                  duration: item.duration != null
                    ? Duration(minutes: int.tryParse(item.duration.toString()) ?? 0)
                    : Duration.zero, 
                  marks: item.grade ?? '0',
                  topic: item.topic ?? 'No Topic',
                ),
                //   onSave: (question) {
                //   _loadSyllabusContents();
                // },
              ),
            ));

        break;

      case 'material':
       Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AddMaterialScreen(
      syllabusClasses: widget.syllabusClasses,
      courseId: widget.courseId,
      levelId: widget.levelId,
      classId: widget.classId,
      id: item.id,
      syllabusId: widget.syllabusId,
      courseName: widget.courseName,
      editMode: true,
      materialToEdit: custom.Material(
        id: item.id,
        title: item.title,
        description: item.description,
        topic: item.topic ?? 'No Topic',
         attachments: attachments,
        selectedClass: item.classes.map((c) => c.name).join(', '),
        startDate: item.startDate != null ? DateTime.parse(item.startDate!) : DateTime.now(),
        endDate: item.endDate != null ? DateTime.parse(item.endDate!) : DateTime.now(),
        duration: const Duration(minutes: 30),
        marks: item.grade ?? '0',
      ),
      onSave: (material) {
        _loadSyllabusContents();
      },
    ),
  ),
);
        break;

      case 'topic':

  //     final topicToEdit = topicContent(
  //   id: item.id,
  //   topic: item.title, // or item.name if you have it
  //   objective: item.description ?? '', // if available
  //   classes: item.classes, // or map as needed
  //   // ...other fields as required by topicContents
  // );
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (BuildContext context) => CreateTopicScreen(
              syllabusId: widget.syllabusId,
              courseId: widget.courseId,
              levelId: widget.levelId,
              classId: widget.classId,
              editMode: true,
              // topicToEdit: TopicContent(
              //   id: item.id,
              //   name: item.title,
              //   description: item.description,
              // ),
            ),
          ),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Edit functionality not available for this item type'),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }

  void _showDeleteConfirmationDialog(SyllabusContentItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: Text(
              'Are you sure you want to delete "${item.title}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _handleDeleteItem(item);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteItem(SyllabusContentItem item) async {
    if (item.id == null) {
      CustomToaster.toastError(context, 'Error', 'Item ID is missing.');
      return;
    }

    try {
      String? error;

      switch (item.type.toLowerCase()) {
        case 'assignment':
          final provider = locator<AssignmentProvider>();
          await provider.DeleteAssignment(item.id!);
          error = provider.error;
          break;

        case 'material':
          final provider = locator<MaterialProvider>();
           await provider.deleteMaterial(item.id!);
          error = provider.error;
          break;

          case "quiz":
          case "question":
          final provider =locator<QuizProvider>();
          await provider.DeleteQuiz(item.id!);

          case "topic":


        // Other cases like 'quiz' and 'topic' would follow the same pattern
        default:
          CustomToaster.toastError(
              context, 'Error', 'Delete not implemented for this item type.');
          return;
      }

      // After the switch, check for success and refresh
      if (error == null) {
        CustomToaster.toastSuccess(
            context, 'Success', '"${item.title}" has been deleted.');
        _loadSyllabusContents(); // This is where the page is refreshed
      } else {
        CustomToaster.toastError(context, 'Error', error);
      }
    } catch (e) {
      print('Error during deletion: $e');
      CustomToaster.toastError(context, 'Error', 'An unexpected error occurred.');
    }
  }

  void _navigateToDetails(SyllabusContentItem item) {
    final attachments = item.contentFiles.map((file) {
      return AttachmentItem(
        fileName: file.fileName,
        iconPath: (file.type == 'image' || file.type == 'photo')
            ? 'assets/icons/e_learning/material.svg'
            : 'assets/icons/e_learning/link.svg',
        fileContent: file.file.isNotEmpty
            ? file.file
            : 'https://yourserver.com/${file.fileName}', // Replace with your base URL
      );
    }).toList();
    // The rest of the method (not in selection) will need to be updated to use this attachments structure.

    final assignment = Assignment(
      title: item.title,
      description: item.description,
      selectedClass: item.classes.map((c) => c.name).join(', '),
      attachments: attachments,
      dueDate:
          item.endDate != null ? DateTime.parse(item.endDate!) : DateTime.now(),
      topic: item.topic ?? 'No Topic',
      marks: item.grade ?? '0',
    );

    switch (item.type.toLowerCase()) {
      case 'assignment':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffAssignmentDetailsScreen(
              assignment: assignment,
            ),
          ),
        );
        break;
      case 'quiz':
      case 'question':
          
           // Here is a safer rewrite:

 final questions = item.questions;
final List<Map<String, dynamic>> correctAnswers = [];

if (item.questions != null) {
  for (var q in item.questions!) {
    final correctData = q['correct'];
    if (correctData != null && correctData is Map<String, dynamic>) {
      correctAnswers.add({
        'correct_answer': correctData['text']?.toString() ?? '', // Extract just the text
      });
    }
  }
}
  print(correctAnswers);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              questions: item.questions,
              correctAnswers: correctAnswers,
              question: Question(
                title: item.title,
                description: item.description,
                selectedClass: item.classes.map((c) => c.name).join(', '),
                startDate: item.startDate != null ? DateTime.parse(item.startDate!) : DateTime.now(),
                endDate: item.endDate != null ? DateTime.parse(item.endDate!) : DateTime.now(),
                topic: item.topic ?? 'No Topic',
                duration: item.duration != null
                    ? Duration(minutes: int.tryParse(item.duration.toString()) ?? 0)
                    : Duration.zero,
                marks: item.grade?.toString() ?? '0',
              ),
            )));

            break;
            case "material": 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StaffMaterialDetailsScreen(
                  material: custom.Material(
                    title: item.title,
                    description: item.description,
                    selectedClass: item.classes.map((c) => c.name).join(', '),
                    startDate: item.startDate != null ? DateTime.parse(item.startDate!) : DateTime.now(),
                    endDate: item.endDate != null ? DateTime.parse(item.endDate!) : DateTime.now(),
                    topic: item.topic ?? 'No Topic',
                    attachments: attachments,
                    duration: item.duration != null
                        ? Duration(minutes: int.tryParse(item.duration.toString()) ?? 0)
                        : Duration.zero,
                    marks: item.grade?.toString() ?? '0',
                  ),
                ),
              ),
            );
    };
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM, yyyy · hh:mma').format(date).toLowerCase();
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return Icons.assignment_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      case 'material':
        return Icons.library_books_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _getIconPathForType(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return 'assets/icons/e_learning/assignment.svg';
      case 'quiz':
        return 'assets/icons/e_learning/question_icon.svg';
      case 'material':
        return 'assets/icons/e_learning/material.svg';
      default:
        return 'assets/icons/e_learning/topic.svg';
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return 'Assignment';
      case 'quiz':
      case 'question':
        return 'Quiz';
      case 'material':
        return 'Materia';
      default:
        return 'Content';
    }
  }
}

// class AttachmentItem {
//   final String fileName;      // Display name or URL
//   final String iconPath;
//   final String fileContent;   // base64 or URL
//   AttachmentItem({
//     required this.fileName,
//     required this.iconPath,
//     required this.fileContent,
//   });
// }





// Import the necessary models for navigation
// import 'package:linkschool/modules/model/e-learning/question_model.dart';
// import 'package:linkschool/modules/model/e-learning/material_model.dart'
//     as custom;

// import '../../providers/admin/e_learning/syllabus_content_provider.dart';

// Dummy Assignment class for navigation compatibility
// class Assignment {
//   final String title;
//   final String description;
//   final String selectedClass;
//   final List<dynamic> attachments;
//   final DateTime dueDate;
//   final String topic;
//   final String marks;
//   final DateTime createdAt;

//   Assignment({
//     required this.title,
//     required this.description,
//     required this.selectedClass,
//     required this.attachments,
//     required this.dueDate,
//     required this.topic,
//     required this.marks,
//     DateTime? createdAt,
//   }) : createdAt = createdAt ?? DateTime.now();
// }







// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/e-learning/question_model.dart';
// import 'package:linkschool/modules/model/e-learning/material_model.dart'
//     as custom;
// import 'package:linkschool/modules/model/e-learning/topic_model.dart';
// import 'package:linkschool/modules/staff/e_learning/staff_create_syllabus_screen.dart';
// import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_add_material_screen.dart';
// import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_question_screen.dart';
// import 'package:linkschool/modules/staff/e_learning/view/quiz_answer_screen.dart';
// import 'package:linkschool/modules/staff/e_learning/view/staff_assignment_details_screen.dart';
// import 'package:linkschool/modules/staff/e_learning/view/staff_material_details_screen.dart';

// class EmptySubjectScreen extends StatefulWidget {
//   final String? courseTitle;
//   final String? courseId;
//   final String? levelId;
//   final String? classId;
//   final String? courseName;
//   final String? term;
//   final int? syllabusId;
//   final syllabusClasses;

//   const EmptySubjectScreen({
//     super.key,
//     this.syllabusId,
//     this.courseTitle,
//     this.courseId,
//     this.levelId,
//     this.classId,
//     this.courseName,
//     this.term,
//     this.syllabusClasses,
//   });

//   @override
//   State<EmptySubjectScreen> createState() => _EmptySubjectScreenState();
// }

// class _EmptySubjectScreenState extends State<EmptySubjectScreen> {
//   // final List<Map<String, dynamic>> _syllabusList = [];
//   // Map<String, dynamic>? _currentSyllabus;
//   late double opacity = 0.1;
//   List<Topic> topics = [];
//   bool _showCourseworkScreen = false;

//   @override
//   void initState() {
//     super.initState();
//     _addDummyData();
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
//         description: '',
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
//         description: '',
//       ),
//     ];
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
//         Navigator.pop(context);
//         switch (text) {
//           case 'Assignment':
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AdminAssignmentScreen(
//                   onSave: (assignment) {
//                     setState(() {
//                       _showCourseworkScreen = true;
//                     });
//                   },
//                 ),
//               ),
//             );
//             break;
//           case 'Question':
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => StaffQuestionScreen(
//                   onSave: (question) {
//                     setState(() {
//                       _showCourseworkScreen = true;
//                     });
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
//                 builder: (BuildContext context) =>
//                     const StaffCreateSyllabusScreen(),
//               ),
//             );
//             break;
//           case 'Material':
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => StaffAddMaterialScreen(
//                   onSave: (material) {
//                     setState(() {
//                       _showCourseworkScreen = true;
//                     });
//                   },
//                 ),
//               ),
//             );
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
//             Text(
//               text,
//               style: AppTextStyles.normal500(
//                   fontSize: 16, color: AppColors.backgroundDark),
//             ),
//           ],
//         ),
//       ),
//     );
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
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           "widget.courseTitle",
//           style: const TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: AppColors.paymentTxtColor1,
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
//       body: _buildCourseworkScreen(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showCreateOptionsBottomSheet(context),
//         backgroundColor: AppColors.staffBtnColor1,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildCourseworkScreen() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: Constants.customBoxDecoration(context),
//       child:
//           _showCourseworkScreen ? _buildSyllabusDetails() : _buildEmptyState(),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Text('No syllabus have been created'),
//         const SizedBox(height: 15),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             CustomMediumElevatedButton(
//               text: 'Create content',
//               onPressed: () {
//                 _showCreateOptionsBottomSheet(context);
//               },
//               backgroundColor: AppColors.eLearningBtnColor1,
//               textStyle: AppTextStyles.normal600(
//                 fontSize: 16,
//                 color: AppColors.backgroundLight,
//               ),
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//             )
//           ],
//         )
//       ],
//     );
//   }

//   Widget _buildSyllabusDetails() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Container(
//               height: 95,
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: Colors.transparent,
//               ),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   SvgPicture.asset(
//                     'assets/images/admission/background_img.svg',
//                     width: MediaQuery.of(context).size.width,
//                     height: 95,
//                     fit: BoxFit.cover,
//                   ),
//                   Positioned.fill(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "widget.courseTitle",
//                             style: AppTextStyles.normal700(
//                               fontSize: 18,
//                               color: AppColors.backgroundLight,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 5),
//                           Text(
//                             'Class: ${topics.isNotEmpty ? topics.first.assignments.first.selectedClass : "N/A"}',
//                             style: AppTextStyles.normal500(
//                               fontSize: 14,
//                               color: AppColors.backgroundLight,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           Text(
//                             'Teacher: Current Teacher',
//                             style: AppTextStyles.normal600(
//                               fontSize: 12,
//                               color: AppColors.backgroundLight,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (topics.isNotEmpty && topics.first.assignments.isNotEmpty)
//               InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => StaffAssignmentDetailsScreen(
//                         assignment: topics.first.assignments.first,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12.0),
//                   decoration: const BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey, width: 0.5),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: AppColors.eLearningBtnColor1.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: SvgPicture.asset(
//                           'assets/icons/e_learning/assignment.svg',
//                           color: AppColors.eLearningBtnColor1,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   'Assignment: ',
//                                   style: AppTextStyles.normal600(
//                                     fontSize: 14,
//                                     color: AppColors.backgroundDark,
//                                   ),
//                                 ),
//                                 Text(
//                                   topics.first.assignments.first.title,
//                                   style: AppTextStyles.normal400(
//                                     fontSize: 14,
//                                     color: AppColors.backgroundDark,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Created on ${DateFormat('dd MMMM, yyyy').format(topics.first.assignments.first.createdAt)} · ${DateFormat('hh:mma').format(topics.first.assignments.first.createdAt).toLowerCase()}',
//                               style: AppTextStyles.normal400(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             if (topics.isNotEmpty && topics.first.questions.isNotEmpty)
//               InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => QuizAnswersScreen(
//                         quizTitle: topics.first.questions.first.title,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12.0),
//                   decoration: const BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey, width: 0.5),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: AppColors.eLearningBtnColor1.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: SvgPicture.asset(
//                           'assets/icons/e_learning/question_icon.svg',
//                           color: AppColors.eLearningBtnColor1,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   'Quiz: ',
//                                   style: AppTextStyles.normal600(
//                                     fontSize: 14,
//                                     color: AppColors.backgroundDark,
//                                   ),
//                                 ),
//                                 Text(
//                                   topics.first.questions.first.title,
//                                   style: AppTextStyles.normal400(
//                                     fontSize: 14,
//                                     color: AppColors.backgroundDark,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Created on ${DateFormat('dd MMMM, yyyy').format(topics.first.questions.first.createdAt)} · ${DateFormat('hh:mma').format(topics.first.questions.first.createdAt).toLowerCase()}',
//                               style: AppTextStyles.normal400(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             if (topics.isNotEmpty && topics.first.materials.isNotEmpty)
//               InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => StaffMaterialDetailsScreen(
//                         material: topics.first.materials.first,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12.0),
//                   decoration: const BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(color: Colors.grey, width: 0.5),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: AppColors.eLearningBtnColor1.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: SvgPicture.asset(
//                           'assets/icons/e_learning/material.svg',
//                           color: AppColors.eLearningBtnColor1,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   'Material: ',
//                                   style: AppTextStyles.normal600(
//                                     fontSize: 14,
//                                     color: AppColors.backgroundDark,
//                                   ),
//                                 ),
//                                 Text(
//                                   topics.first.materials.first.title,
//                                   style: AppTextStyles.normal400(
//                                     fontSize: 14,
//                                     color: AppColors.backgroundDark,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Created on ${DateFormat('dd MMMM, yyyy').format(topics.first.materials.first.createdAt)} · ${DateFormat('hh:mma').format(topics.first.materials.first.createdAt).toLowerCase()}',
//                               style: AppTextStyles.normal400(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             if (topics.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     child: Text(
//                       topics.first.name,
//                       style: AppTextStyles.normal600(
//                         fontSize: 18,
//                         color: AppColors.backgroundDark,
//                       ),
//                     ),
//                   ),
//                   _buildTopicItem(
//                     'What is Punctuality?',
//                     '25 June, 2015 · 08:52am',
//                     Icons.help_outline,
//                   ),
//                   _buildTopicItem(
//                     'First C.A',
//                     '25 June, 2015 · 08:52am',
//                     Icons.quiz_outlined,
//                   ),
//                   _buildTopicItem(
//                     'Assignment',
//                     '25 June, 2015 · 08:52am',
//                     Icons.assignment_outlined,
//                   ),
//                   _buildTopicItem(
//                     'Second C.A',
//                     '25 June, 2015 · 08:52am',
//                     Icons.quiz_outlined,
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTopicItem(String title, String timestamp, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12.0),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: const BoxDecoration(
//               color: AppColors.eLearningBtnColor1,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: AppTextStyles.normal500(
//                     fontSize: 14,
//                     color: AppColors.backgroundDark,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Created on $timestamp',
//                   style: AppTextStyles.normal400(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }