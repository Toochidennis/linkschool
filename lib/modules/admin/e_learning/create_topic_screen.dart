import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

// Assuming these are custom files in your project
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';
import 'package:linkschool/modules/model/e-learning/objective_item.dart';

class CreateTopicScreen extends StatefulWidget {
  final String? classId;
  final String? levelId; 
  final  String? courseId;
  const CreateTopicScreen({super.key, this.classId, this.levelId, this.courseId});

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  String _selectedClass = 'Select classes';
  final bool _isTitleFocused = false;
  bool _showObjectives = false;
  final List<ObjectiveItem> _objectives = [];
  final FocusNode _titleFocusNode = FocusNode();
  late double opacity;
  int? creatorId;
  String? creatorName;
  String? academicYear;
  int? academicTerm;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _titleFocusNode.addListener(_onTitleFocusChange);
  }

  @override
  void dispose() {
    _titleFocusNode.removeListener(_onTitleFocusChange);
    _titleFocusNode.dispose();
    _titleController.dispose();
    _objectiveController.dispose();
    super.dispose();
  }

void _onTitleFocusChange() {
  if (_titleFocusNode.hasFocus && !_showObjectives) {
    setState(() {
      _showObjectives = true;
    });
  }
}

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
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
    try {
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
      final processedData = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData;
      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      final classes = data['classes'] ?? [];
      final selectedClassIds = userBox.get('selectedClassIds') ?? [];

      final classIdList = selectedClassIds.map<Map<String, String>>((classId) {
        final classIdStr = classId.toString();
        final classData = classes.firstWhere(
          (cls) => cls['id'].toString() == classIdStr,
          orElse: () => {'id': classIdStr, 'class_name': 'Unknown'},
        );
        return {
          'id': classIdStr,
          'class_name': (classData['class_name']?.toString() ?? 'Unknown'),
        };
      }).toList();

      if (classIdList.isEmpty && widget.classId != null) {
        final classIdStr = widget.classId!;
        final classData = classes.firstWhere(
          (cls) => cls['id'].toString() == classIdStr,
          orElse: () => {'id': classIdStr, 'class_name': _selectedClass},
        );
        classIdList.add({
          'id': classIdStr,
          'class_name': (classData['class_name']?.toString() ?? _selectedClass),
        });
      }

      final material = {
        'title': _titleController.text,
        "objectives": _objectiveController.text,
        'topic_id': '', 
        'classids': classIdList.isNotEmpty
            ? classIdList
            : [
                {'id': '', 'class_name': ''},
              ],
        'level_id': widget.levelId,
        'course_id': widget.courseId,
        'creator_id': creatorId,
        'creator_name': creatorName,
        'term': academicTerm?.toInt(),
      };

      print('Complete Material Data:');
      print(const JsonEncoder.withIndent('  ').convert(material));

      // widget.onSave(material);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving material: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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
              fontSize: 24.0, color: AppColors.primaryLight),
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CustomSaveElevatedButton(
              onPressed:_addTopic,
              text: 'Save',
            ),
          ),
        ],
      ),
body: Container(
  height: MediaQuery.of(context).size.height, // Ensures the container covers the full screen height
  decoration: Constants.customBoxDecoration(context),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(), // Allows scroll even if the content doesn't fill the screen
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - kToolbarHeight - 32, // Ensures content covers the remaining screen height
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic',
              style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
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
                  fontSize: 16.0, color: Colors.black),
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
                      levelId:widget.levelId,
                    ),
                  ),
                );
              },
            ),
            if (_showObjectives) ...[
              const SizedBox(height: 32.0),
              Text(
                'Topic Objectives:',
                style: AppTextStyles.normal600(
                    fontSize: 16.0, color: Colors.black),
              ),
              const SizedBox(height: 16.0),
              ..._objectives.map((objective) => _buildObjectiveListItem(objective)),
              _buildObjectiveInput(),
            ],
            // Add a spacer to push content to the bottom
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
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
                        fontSize: 14.0, color: AppColors.backgroundLight),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _isTitleFocused ? AppColors.primaryLight : const Color(0xFFB2B2B2),
            width: _isTitleFocused ? 2 : 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _addObjective,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.bgGray,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.bgGray,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: TextField(
              controller: _objectiveController,
              decoration: const InputDecoration(
                hintText: 'Add new Objective',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveListItem(ObjectiveItem objective) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                objective.isSelected = !objective.isSelected;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
              child: Icon(
                Icons.check,
                size: 18,
                color: objective.isSelected ? Colors.black : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(objective.text),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                // Handle edit
                _editObjective(objective);
              } else if (value == 'delete') {
                setState(() {
                  _objectives.remove(objective);
                });
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
        ],
      ),
    );
  }

  void _addObjective() {
    if (_objectiveController.text.isNotEmpty) {
      setState(() {
        _objectives.add(ObjectiveItem(_objectiveController.text));
        _objectiveController.clear();
      });
    }
  }

  void _editObjective(ObjectiveItem objective) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController editController = TextEditingController(text: objective.text);
        return AlertDialog(
          title: const Text('Edit Objective'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Enter new objective"),
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
                  objective.text = editController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}