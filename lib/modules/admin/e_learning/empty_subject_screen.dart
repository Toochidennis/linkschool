import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/model/e-learning/quiz_model.dart';
import 'package:linkschool/modules/providers/admin/e_learning/quiz_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/admin/e_learning/add_material_screen.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';
import 'package:linkschool/modules/admin/e_learning/create_topic_screen.dart';
import 'package:linkschool/modules/admin/e_learning/question_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
// Your content models
import 'package:linkschool/modules/staff/e_learning/staff_create_syllabus_screen.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_add_material_screen.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_question_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/quiz_answer_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/staff_assignment_details_screen.dart';
import 'package:linkschool/modules/staff/e_learning/view/staff_material_details_screen.dart';
// Import your provider here
// import 'package:linkschool/providers/content_provider.dart';

class EmptySubjectScreen extends StatefulWidget {
  final String? courseTitle;
  final String? courseId;
  final String? levelId;
  final String? classId;
  final String? courseName;
  final String? term;
  final int? syllabusId;
  final syllabusClasses;

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

class _EmptySubjectScreenState extends State<EmptySubjectScreen> {
  late double opacity = 0.1;
  bool _showCourseworkScreen = false;
  
  // Filtered content by topic
  Map<String, List<ChildContent>> contentByTopic = {};
  List<ChildContent> contentWithoutTopic = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.syllabusId != null) {
      _loadContent();
    }
  }

  void _loadContent() async {
    // Load content using your provider
    final provider = Provider.of<QuizProvider>(context, listen: false);
    await provider.loadContent(widget.syllabusId!);
    
    // For now, using dummy data structure similar to your API response
    _filterContentByTopic();
  }

  void _filterContentByTopic() {
   
    
    final provider = Provider.of<QuizProvider>(context, listen: false);
    if (provider.contentResponse != null) {
      contentByTopic.clear();
      contentWithoutTopic.clear();
      
      for (var item in provider.contentResponse!.response) {
        for (var child in item.children) {
          if (child is ChildContent) {
            if (child.topicId != null && child.topicId > 0) {
              // Group by topic
              if (!contentByTopic.containsKey(child.topic)) {
                contentByTopic[child.topic] = [];
              }
              contentByTopic[child.topic]!.add(child);
            } else {
              // Content without topic
              contentWithoutTopic.add(child);
            }
          }
        }
      }
      setState(() {
        _showCourseworkScreen = true;
      });
    }
  
    
    // Dummy data for demonstration
    setState(() {
      _showCourseworkScreen = true;
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
                  syllabusClasses: widget.syllabusClasses,
                  classId: widget.classId,
                  courseId: widget.courseId,
                  levelId: widget.levelId,
                  syllabusId: widget.syllabusId!,
                  courseName: widget.courseName,
                  onSave: (assignment) {
                    _loadContent(); // Reload content after saving
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
                  classId: widget.classId,
                  syllabusId: widget.syllabusId!,
                  courseId: widget.courseId,
                  levelId: widget.levelId,
                  courseName: widget.courseName,
                  onSave: (question) {
                    _loadContent(); // Reload content after saving
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
                    _loadContent(); // Reload content after saving
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
          widget.courseTitle ?? '',
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
            // Course header
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
                            widget.courseTitle ?? '',
                            style: AppTextStyles.normal700(
                              fontSize: 18,
                              color: AppColors.backgroundLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Class: ${widget.courseName ?? "N/A"}',
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
            
            // Content grouped by topics
            ...contentByTopic.entries.map((entry) => _buildTopicSection(entry.key, entry.value)),
            
            // Content without topics (displayed after syllabus details)
            if (contentWithoutTopic.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...contentWithoutTopic.map((content) => _buildContentItem(content)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopicSection(String topicName, List<ChildContent> contents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            topicName, // Using actual topic name instead of "Punctuality"
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: AppColors.backgroundDark,
            ),
          ),
        ),
        ...contents.map((content) => _buildContentItem(content)),
      ],
    );
  }

  Widget _buildContentItem(ChildContent content) {
    IconData icon;
    String prefix;
    Color iconColor = AppColors.eLearningBtnColor1;
    
    switch (content.type.toLowerCase()) {
      case 'assignment':
        icon = Icons.assignment_outlined;
        prefix = 'Assignment: ';
        break;
      case 'quiz':
      case 'question':
        icon = Icons.quiz_outlined;
        prefix = 'Quiz: ';
        break;
      case 'material':
        icon = Icons.description_outlined;
        prefix = 'Material: ';
        break;
      default:
        icon = Icons.help_outline;
        prefix = 'Content: ';
    }

    return InkWell(
      onTap: () {
        _navigateToContentDetails(content);
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
              decoration: BoxDecoration(
                color: iconColor,
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
                  Row(
                    children: [
                      Text(
                        prefix,
                        style: AppTextStyles.normal600(
                          fontSize: 14,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          content.title,
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
                    'Created on ${_formatDate(content.datePosted)}',
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
    );
  }

  void _navigateToContentDetails(ChildContent content) {
    switch (content.type.toLowerCase()) {
      case 'assignment':
        // Navigate to assignment details
        // You'll need to convert ChildContent to your Assignment model
        break;
      case 'quiz':
      case 'question':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizAnswersScreen(
              quizTitle: content.title,
            ),
          ),
        );
        break;
      case 'material':
        // Navigate to material details
        // You'll need to convert ChildContent to your Material model
        break;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    
    try {
      final date = DateTime.parse(dateString);
      return '${DateFormat('dd MMMM, yyyy').format(date)} · ${DateFormat('hh:mma').format(date).toLowerCase()}';
    } catch (e) {
      return dateString;
    }
  }
}
