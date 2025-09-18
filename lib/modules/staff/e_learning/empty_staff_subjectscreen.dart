import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/View/assignment_details.dart';
import 'package:linkschool/modules/admin/e_learning/View/material_details.dart';
import 'package:linkschool/modules/admin/e_learning/View/question/view_question_screen.dart'
    hide AttachmentItem;
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

import 'package:linkschool/modules/providers/admin/e_learning/delete_sylabus_content.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_add_material_screen.dart';

import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_assignment_screen.dart' hide Assignment;
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_create_topic_screen.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_question_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/staff_assignment_details_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/staff_material_details_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/staff_quiz_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/staffview_question.dart' hide AttachmentItem;

import 'package:provider/provider.dart';
import 'package:linkschool/modules/model/e-learning/material_model.dart' as custom;
import 'package:linkschool/modules/services/api/service_locator.dart';
import '../../common/widgets/portal/attachmentItem.dart';

import '../../providers/admin/e_learning/syllabus_content_provider.dart';

class StaffEmptySubjectScreen extends StatefulWidget {
  final String? courseTitle;
  final List<Map<String, dynamic>>? classList;
  final String? courseId;
  final String? levelId;
  final String? classId;
  final String? courseName;
  final String? term;
  final int? syllabusId;
  final List<Map<String, dynamic>>? syllabusClasses;

  const StaffEmptySubjectScreen({
    super.key,
    this.syllabusId,
    this.courseTitle,
    this.courseId,
    this.classList,
    this.levelId,
    this.classId,
    this.courseName,
    this.term,
    this.syllabusClasses,
  });

  @override
  State<StaffEmptySubjectScreen> createState() => _EmptySubjectScreenState();
}

class _EmptySubjectScreenState extends State<StaffEmptySubjectScreen>
    with WidgetsBindingObserver {
  late double opacity = 0.1;
  List<TopicContent> _topics = [];
  List<SyllabusContentItem> _noTopicItems = [];
  bool _shouldRefresh = false;
  int _currentIndex = 0;
  bool _showCourseworkScreen = false;
    static const String _courseworkIconPath = 'assets/icons/student/coursework_icon.svg';
  static const String _forumIconPath = 'assets/icons/student/forum_icon.svg';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeState();
    }
  }

  @override
  void didUpdateWidget(StaffEmptySubjectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRefresh) {
      _loadSyllabusContents();
      _shouldRefresh = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initializeState() {
    setState(() {
      _topics = [];
      _noTopicItems = [];
      _shouldRefresh = false;
    });
    _loadSyllabusContents();
  }

  void setRefreshFlag() {
    setState(() {
      _shouldRefresh = true;
    });
  }

  Future<void> _loadSyllabusContents() async {
    if (widget.syllabusId == null) {
      CustomToaster.toastError(context, 'Error', 'Syllabus ID is missing');
      return;
    }
    try {
      final contentProvider = locator<SyllabusContentProvider>();
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
      final processedData = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData;
      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      final settings = data['settings'] ?? {};
      final dbName = settings['db_name']?.toString() ?? 'aalmgzmy_linkskoo_practice';
      await contentProvider.fetchSyllabusContents(widget.syllabusId!, dbName);

      if (contentProvider.error.isEmpty) {
        _processContents(contentProvider.contents);
      } else {
        CustomToaster.toastError(context, 'Error', contentProvider.error);
      }
    } catch (e) {
      print('Error loading syllabus contents: $e');
      CustomToaster.toastError(context, 'Error', 'Failed to load syllabus contents: $e');
    }
  }

  void _processContents(List<Map<String, dynamic>> contents) {
    _topics = [];
    _noTopicItems = [];
    Map<int, TopicContent> topicMap = {};

    // Process topics
    for (var content in contents) {
      if (content['type'] == 'topic') {
        final topicId = content['id'] != null
            ? int.tryParse(content['id'].toString()) ?? 0
            : 0;
        final topicName = content['title']?.toString() ?? 'Untitled';
        final topicChildren = <SyllabusContentItem>[];

        for (var child in content['children'] ?? []) {
          if (child is Map<String, dynamic> && child.containsKey('settings')) {
            final settings = child['settings'] as Map<String, dynamic>;
            topicChildren.add(SyllabusContentItem.fromJson({
              ...settings,
              'questions': child['questions'] ?? [],
            }));
          } else {
            topicChildren.add(SyllabusContentItem.fromJson(child as Map<String, dynamic>));
          }
        }

        topicMap[topicId] = TopicContent(
          id: topicId,
          name: topicName,
          type: content['type']?.toString() ?? '',
          children: topicChildren,
        );
        _debugTopicData(topicMap[topicId]!);
      }
    }

    // Process non-topic items
    for (var content in contents) {
      if (content['type'] != 'topic') {
        for (var child in content['children'] ?? []) {
          SyllabusContentItem item;
          if (child is Map<String, dynamic> && child.containsKey('settings')) {
            final settings = child['settings'] as Map<String, dynamic>;
            item = SyllabusContentItem.fromJson({
              ...settings,
              'questions': child['questions'] ?? [],
            });
          } else {
            item = SyllabusContentItem.fromJson(child as Map<String, dynamic>);
          }
          final topicId = item.topicId ?? 0;
          if (topicId != 0 && topicMap.containsKey(topicId)) {
            topicMap[topicId]!.children.add(item);
            print('Reassigned item ${item.id} to topic $topicId');
          } else {
            _noTopicItems.add(item);
          }
        }
      }
    }

    setState(() {
      _topics = topicMap.values.toList();
      _noTopicItems = _noTopicItems;
    });
  }

  void _debugTopicData(TopicContent topic) {
    print('Topic: ${topic.name}, ID: ${topic.id}');
    for (int i = 0; i < topic.children.length; i++) {
      final child = topic.children[i];
      print('Child $i: ${child.title} (${child.type})');
    }
    print('========================');
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
    print(
        "Adding new ${widget.courseId} syllabus with ${widget.term} levelId: ${widget.levelId}, course_name: ${widget.courseName}");

    return InkWell(
      onTap: () {
        print("1233${widget.classList}");
        Navigator.pop(context);
        switch (text) {
          case 'Assignment':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StaffAssignmentScreen(
               
                  syllabusId: widget.syllabusId,
                  classId: widget.classId,
                  levelId: widget.levelId,
                  courseId: widget.courseId,
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
                builder: (context) => StaffQuestionScreen(
                   classes:widget.classList,
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
                builder: (BuildContext context) => StaffCreateTopicScreen(
                   classes:widget.classList,
                  syllabusId: widget.syllabusId,
                  courseId: widget.courseId,
                  courseName: widget.courseName,
                  levelId: widget.levelId,
                  classId: widget.classId,
                ),
              ),
            );
            print("bbbbbbbbb${widget.classId}");
            break;
          case 'Material':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StaffAddMaterialScreen(

                  syllabusClasses:widget.syllabusClasses,
                  courseId: widget.courseId,
                  levelId: widget.levelId,
                  classId: widget.classId,
                  syllabusId: widget.syllabusId,
                  courseName: widget.courseName,
                  onSave: (material) {
                    _loadSyllabusContents();
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

  Widget _buildForumScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: Constants.customBoxDecoration(context),
      child: _buildForumContent(),
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
        physics: const BouncingScrollPhysics(),
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
            const SizedBox(height: 70),
          ],
        ),
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
                  title: _topics.isNotEmpty ? _topics.first.name : "What is Punctuality?",
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
        content: "This is a mock data showing the info details of a post.",
        date: "03 Jan",
      ),
      _buildComment(
        name: "Tochukwu Dennis",
        content: "This is a mock data showing the info details of a post.",
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                topic.name,
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.backgroundDark,
                ),
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
                    _handleEditTopic(topic);
                    break;
                  case 'delete':
                    _handleTopicDelete(topic);
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

  Widget _buildTopicItem(String title, String timestamp, IconData icon, SyllabusContentItem item) {
    return InkWell(
      onTap: () => _navigateToDetails(item),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _navigateToDetails(SyllabusContentItem item) {
    _loadSyllabusContents();
    final attachments = item.contentFiles.map((file) {
      return AttachmentItem(
        fileName: file.fileName,
        iconPath: (file.type == 'image' || file.type == 'photo' || file.type == 'video')
            ? 'assets/icons/e_learning/material.svg'
            : 'assets/icons/e_learning/link.svg',
        fileContent: file.file.isNotEmpty
            ? file.file
            : 'https://linkskool.net/${file.fileName}',
      );
    }).toList();

    final syllabusItem = SyllabusContentItem(
      id: item.id,
      title: item.title,
      description: item.description,
      type: item.type,
      classes: item.classes,
      startDate: item.startDate,
      endDate: item.endDate,
      duration: item.duration,
      grade: item.grade,
      topicId: item.topicId,
      topic: item.topic,
      contentFiles: [],
      datePosted: item.datePosted,
      questions: item.questions,
      rank: 0,
    );

    final assignment = Assignment(
      title: item.title,
      description: item.description,
      selectedClass: item.classes.map((c) => c.name).join(', '),
      attachments: attachments,
      dueDate: item.endDate != null ? DateTime.parse(item.endDate!) : DateTime.now(),
      topic: item.topic ?? 'No Topic',
      marks: item.grade ?? '0',
    );

    switch (item.type.toLowerCase()) {
      case 'assignment':
        print('Navigating to assignment details for: ${item.id}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffAssignmentDetailsScreen(
              itemId: item.id,
              assignment: assignment,
              syllabusId: widget.syllabusId,
              courseId: widget.courseId,
              levelId: widget.levelId,
              classId: widget.classId,
              courseName: widget.courseName,
              syllabusClasses: widget.syllabusClasses,
            ),
          ),
        ).then((_) {
          _loadSyllabusContents();
        });
        break;
      case 'quiz':
      case 'question':
        final questions = item.questions;
        final List<Map<String, dynamic>> correctAnswers = [];
        if (item.questions != null) {
          for (var q in item.questions!) {
            final correctData = q['correct'];
            if (correctData != null && correctData is Map<String, dynamic>) {
              correctAnswers.add({
                'correct_answer': correctData['text']?.toString() ?? '',
              });
            }
          }
        }

        final questionData = {
          'id': item.id,
          'title': item.title,
          'description': item.description,
          'course_name': widget.courseName,
          'level_id': widget.levelId,
          'course_id': widget.courseId,
          'class_id': widget.classId,
          'start_date': item.startDate,
          'end_date': item.endDate,
          'duration': item.duration,
          'marks': item.grade ?? '0',
          'syllabus_id': widget.syllabusId,
          'topic_id': item.topicId,
          'topic': item.topic ?? 'No Topic',
          'creator_id': null,
          'creator_name': null,
          'term': widget.term,
        };

        print(correctAnswers);
        print("${item.id}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffQuizScreen(
              questiondata: questionData,
              class_ids: item.classes
                  .map((c) => {'id': c.id.toString(), 'name': c.name})
                  .toList(),
              syllabusClasses:widget.syllabusClasses,
                 
              questions: item.questions,
              correctAnswers: correctAnswers,
              question: Question(
                title: item.title,
                description: item.description,
                id: item.id,
                selectedClass: item.classes.map((c) => c.name).join(', '),
                startDate: item.startDate != null ? DateTime.parse(item.startDate!) : DateTime.now(),
                endDate: item.endDate != null ? DateTime.parse(item.endDate!) : DateTime.now(),
                topic: item.topic ?? 'No Topic',
                duration: item.duration != null
                    ? Duration(minutes: int.tryParse(item.duration.toString()) ?? 0)
                    : Duration.zero,
                marks: item.grade?.toString() ?? '0',
              ),
            ),
          ),
        ).then((_) {
          _loadSyllabusContents();
        });
        break;
      case "material":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StaffMaterialDetailsScreen(
              itemId: item.id,
              syllabusId: widget.syllabusId,
              courseId: widget.courseId,
              levelId: widget.levelId,
              classId: widget.classId,
              courseName: widget.courseName,
              syllabusClasses: widget.syllabusClasses,
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
        ).then((_) {
          _loadSyllabusContents();
        });
        break;
    }
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
            : 'https://linkskool.net/${file.fileName}',
      );
    }).toList();

    print("Editing item: ${item.title}, ID: ${item.id}");

    final questionData = {
      'id': item.id,
      'title': item.title,
      'description': item.description,
      'course_name': widget.courseName,
      'level_id': widget.levelId,
      'course_id': widget.courseId,
      'class_id': widget.classId,
      'start_date': item.startDate,
      'end_date': item.endDate,
      'duration': item.duration,
      'marks': item.grade ?? '0',
      'syllabus_id': widget.syllabusId,
      'topic_id': item.topicId,
      'topic': item.topic ?? 'No Topic',
      'creator_id': null,
      'creator_name': null,
      'term': widget.term,
    };

    switch (item.type.toLowerCase()) {
      case 'assignment':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffAssignmentScreen(
              syllabusId: widget.syllabusId,
              classId: widget.classId,
              courseId: widget.courseId,
              levelId: widget.levelId,
              courseName: widget.courseName,
              syllabusClasses: widget.syllabusClasses,
              editMode: true,
              assignmentToEdit: AssignmentFormData(
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
            builder: (context) => StaffViewQuestionScreen(
              question: Question(
                id: item.id,
                title: item.title,
                description: item.description,
                selectedClass: item.classes.map((c) => c.name).join(', '),
                startDate: item.startDate != null
                    ? DateTime.parse(item.startDate!)
                    : DateTime.now(),
                endDate: item.endDate != null
                    ? DateTime.parse(item.endDate!)
                    : DateTime.now(),
                topic: item.topic ?? 'No Topic',
                duration: item.duration != null
                    ? Duration(minutes: int.tryParse(item.duration.toString()) ?? 0)
                    : Duration.zero,
                marks: item.grade?.toString() ?? '0',
                topicId: item.topicId,
              ),
              questiondata: questionData,
              class_ids: item.classes
                  .map((c) => {'id': c.id.toString(), 'name': c.name})
                  .toList(),
              syllabusClasses:widget.syllabusClasses,
              questions: item.questions,
              editMode: true,
              onSaveFlag: setRefreshFlag,
              onCreation: () {
                _loadSyllabusContents();
              },
            ),
          ),
        ).then((_) {
          _loadSyllabusContents();
        });
        break;
      case 'material':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffAddMaterialScreen(
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
                startDate: item.startDate != null
                    ? DateTime.parse(item.startDate!)
                    : DateTime.now(),
                endDate: item.endDate != null
                    ? DateTime.parse(item.endDate!)
                    : DateTime.now(),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (BuildContext context) => StaffCreateTopicScreen(
              syllabusId: widget.syllabusId,
              courseId: widget.courseId,
              levelId: widget.levelId,
              classId: widget.classId,
              editMode: true,
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit functionality not available for this item type'),
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
      final provider = locator<DeleteSyllabusProvider>();
      switch (item.type.toLowerCase()) {
        case 'assignment':
          await provider.deleteAssignment(item.id.toString());
          break;
        case 'material':
          await provider.deleteMaterial(item.id.toString());
          break;
        case 'quiz':
        case 'question':
          await provider.DeleteQuiz(item.id.toString());
          break;
        case 'topic':
          await provider.DeleteTopic(item.id.toString());
          break;
        default:
          CustomToaster.toastError(
              context, 'Error', 'Delete not implemented for this item type.');
          return;
      }
      CustomToaster.toastSuccess(
          context, 'Success', '"${item.title}" has been deleted.');
      _loadSyllabusContents();
    } catch (e) {
      print('Error during deletion: $e');
      CustomToaster.toastError(context, 'Error', 'An unexpected error occurred.');
    }
  }

  void _handleEditTopic(TopicContent topic) {
    print('Editing topic: ${topic.name}, ID: ${topic.id}');
    if (topic.id == null || topic.id.toString().isEmpty) {
      CustomToaster.toastError(context, 'Error', 'Topic ID is missing or invalid');
      return;
    }

    final topicToEdit = TopicContent(
      id: topic.id,
      name: topic.name,
      type: topic.type,
      children: topic.children,
    );

    print('Passing ${topicToEdit.name} topic${topicToEdit.type} to edit screen: ${topicToEdit.children.length}');
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => StaffCreateTopicScreen(
          syllabusId: widget.syllabusId,
          courseId: widget.courseId,
          levelId: widget.levelId,
          classId: widget.classId,
          editMode: true,
          topicToEdit: topicToEdit,
        ),
      ),
    ).then((_) {
      _loadSyllabusContents();
    });
  }

  void _handleTopicDelete(TopicContent topic) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Topic'),
        content: Text('Are you sure you want to delete "${topic.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      final provider = locator<DeleteSyllabusProvider>();
      await provider.DeleteTopic(topic.id.toString());
      _loadSyllabusContents();
      CustomToaster.toastSuccess(
        context,
        'Success',
        'Topic deleted successfully',
      );
    } catch (e) {
      CustomToaster.toastError(
        context,
        'Error',
        'Failed to delete topic: ${e.toString()}',
      );
    }
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
        return 'Material';
      default:
        return 'Content';
    }
  }
}