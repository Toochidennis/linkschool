import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';
import 'package:linkschool/modules/model/e-learning/syllabus_content_model.dart';
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/providers/admin/e_learning/topic_provider.dart';
import 'package:provider/provider.dart';

class CreateTopicScreen extends StatefulWidget {
  final String? classId;
  final String? levelId;
  final String? courseId;
  final String? courseName;
  final int? syllabusId;

  final bool editMode;
final TopicContent?  topicToEdit;

  const CreateTopicScreen({
    super.key,
    this.classId,
    this.levelId,
    this.courseId,
    this.syllabusId,
    this.editMode =false,
    this.topicToEdit, this.courseName
  });

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  String _selectedClass = 'Select classes';
  late double opacity;
  int? creatorId;
  String? creatorName;
  String? academicYear;
  int? academicTerm;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _populateFormForEdit();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _objectiveController.dispose();
    super.dispose();
  }


void _populateFormForEdit(){
 if (widget.editMode && widget.topicToEdit != null) {
      final topic = widget.topicToEdit!;
      _titleController.text = topic.name ?? '';
      _objectiveController.text = topic.children?.map((child) => child.title).join(', ') ?? '';
     // _selectedClass = ''
    }
}

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
      if (storedUserData != null) {
        final processedData = storedUserData is String
            ? json.decode(storedUserData)
            : storedUserData as Map<String, dynamic>;
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final profile = data['profile'] ?? {};
        final settings = data['settings'] ?? {};

        setState(() {
          creatorId = profile['staff_id'] as int?;
          creatorName = profile['name']?.toString();
          academicYear = settings['year']?.toString();
          academicTerm = settings['term'] as int?;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _addTopic() async {
    // Validation
    if (_titleController.text.trim().isEmpty) {
      CustomToaster.toastError(
        context,
        'Error',
        'Please enter a topic title.',
      );
      return;
    }
    if (_objectiveController.text.trim().isEmpty) {
      CustomToaster.toastError(
        context,
        'Error',
        'Please enter an objective.',
      );
      return;
    }
    if (_selectedClass == 'Select classes' || _selectedClass.trim().isEmpty) {
      CustomToaster.toastError(
        context,
        'Error',
        'Please select at least one class.',
      );
      return;
    }


    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
      final processedData = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData;
      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      final classes = data['classes'] ?? [];
      final selectedClassIds = userBox.get('selectedClassIds') ?? [];

      // Build the class list as List<ClassModel>
      final classModelList = selectedClassIds.map<ClassModel>((classId) {
        final classIdStr = classId.toString();
        final classData = classes.firstWhere(
          (cls) => cls['id'].toString() == classIdStr,
          orElse: () => {'id': classIdStr, 'class_name': 'Unknown'},
        );
        return ClassModel(
          id: int.parse(classIdStr),
          name: classData['class_name']?.toString() ?? 'Unknown',
        );
      }).toList();

      // Get the topicProvider from Provider
      final topicProvider = Provider.of<TopicProvider>(context, listen: false);

      // Only the required fields
      final topicData = {
        'syllabus_id': widget.syllabusId ?? 0,
        'topic': _titleController.text,
        'creator_name': creatorName ?? 'Unknown',
        'objective': _objectiveController.text,
        'creator_id': creatorId ?? 0,
        'classes': classModelList,
        'course_name':widget.courseName,
        'term':academicYear ?? 0,
        'course_id':widget.levelId
      };

      await topicProvider.addTopic(
        syllabusId: widget.syllabusId ?? 0,
        topic: _titleController.text,
        creatorName: creatorName ?? 'Unknown',
        objective: _objectiveController.text,
        term:academicYear ?? '',
        courseId: widget.courseId! ,
        levelId: widget.levelId!,
        courseName:widget.courseName ??'',
        creatorId: creatorId ?? 0,
        classes: classModelList,
      );

      print('Topic Data to POST: $topicData');

      Navigator.of(context).pop();
    } catch (e) {
      print('Error packaging topic data: $e');
      CustomToaster.toastError(
        context,
        'Error',
        'Failed to create topic: ${e.toString()}',
      );

     
    }
  }

  void _editObjective() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController editController =
            TextEditingController(text: _objectiveController.text);
        return AlertDialog(
          title: const Text('Edit Objective'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Enter objective"),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  _objectiveController.text = editController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Create topic',
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
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CustomSaveElevatedButton(
              onPressed: _addTopic,
              text: 'Save',
            ),
          ),
        ],
      ),
      body: Container(
       height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            opacity: opacity,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - kToolbarHeight - 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Topic',
                    style: AppTextStyles.normal600(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g Dying and Bleaching',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.all(12.0),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  Text(
                    'Select the learners for this outline*:',
                    style: AppTextStyles.normal600(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildGroupRow(
                    context,
                    iconPath: 'assets/icons/e_learning/people.svg',
                    text: _selectedClass,
                    onTap: () async {
                      await Navigator.of(context).push<String>(
                        MaterialPageRoute(
                          builder: (context) => SelectClassesDialog(
                            onSave: (selectedClass) {
                              setState(() {
                                _selectedClass = selectedClass;
                              });
                            },
                            levelId: widget.levelId,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32.0),
                  Text(
                    'Objective:',
                    style: AppTextStyles.normal600(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildObjectiveInput(),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupRow(
    BuildContext context, {
    required String iconPath,
    required String text,
    required VoidCallback onTap,
    bool showEditButton = false,
    bool isSelected = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  iconPath,
                  width: 32.0,
                  height: 32.0,
                ),
              ),
              const SizedBox(width: 8.0),
              IntrinsicWidth(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.eLearningBtnColor2,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.normal600(
                      fontSize: 16.0,
                      color: AppColors.eLearningBtnColor1,
                    ),
                  ),
                ),
              ),
              if (showEditButton)
                OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    textStyle: AppTextStyles.normal600(
                      fontSize: 14.0,
                      color: AppColors.backgroundLight,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: AppColors.eLearningBtnColor1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Edit'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Divider(color: Colors.grey.withOpacity(0.5)),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildObjectiveInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _objectiveController,
            decoration: InputDecoration(
              hintText: 'Enter the objective for this topic',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.all(12.0),
            ),
            maxLines: 2,
          ),
        ),
        // PopupMenuButton<String>(
        //   icon: const Icon(Icons.more_vert, color: Colors.grey),
        //   onSelected: (value) {
        //     if (value == 'edit') {
        //       _editObjective();
        //     } else if (value == 'delete') {
        //       setState(() {
        //         _objectiveController.clear();
        //       });
        //     }
        //   },
        //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        //     const PopupMenuItem<String>(
        //       value: 'edit',
        //       child: Text('Edit'),
        //     ),
        //     const PopupMenuItem<String>(
        //       value: 'delete',
        //       child: Text('Delete'),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}