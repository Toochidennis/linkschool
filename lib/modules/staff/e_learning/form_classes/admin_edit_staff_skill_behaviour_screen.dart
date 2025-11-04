import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

class EditSkillsBehaviourScreen extends StatefulWidget {
  final String classId;
  final String levelId;
  final String term;
  final String year;
  final String db;

  const EditSkillsBehaviourScreen({
    super.key,
    required this.classId,
    required this.levelId,
    this.term = '1',
    this.year = '2023',
    this.db = 'aalmgzmy_linkskoo_practice',
  });

  @override
  State<EditSkillsBehaviourScreen> createState() =>
      _EditSkillsBehaviourScreenState();
}

class _EditSkillsBehaviourScreenState extends State<EditSkillsBehaviourScreen> {
  late double opacity;
  final Map<int, Map<int, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    final skillsProvider =
        Provider.of<SkillsBehaviorTableProvider>(context, listen: false);
    skillsProvider.fetchSkillsAndBehaviours(
      classId: widget.classId,
      levelId: widget.levelId,
      term: widget.term,
      year: widget.year,
      db: widget.db,
    );
  }

  int? creatorId;
  String? creatorRole;
  String? creatorName;
  String? academicYear;
  int? academicTerm;
  String? schoolName;
  String? databaseName;

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');

      if (storedUserData == null) return;

      final processedData = storedUserData is String
          ? json.decode(storedUserData)
          : Map<String, dynamic>.from(storedUserData);

      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;

      final profile = data['profile'] ?? {};
      final settings = data['settings'] ?? {};

      setState(() {
        creatorId = profile['staff_id'] as int?;
        creatorName = profile['name']?.toString();
        creatorRole = profile['role']?.toString();

        academicYear = settings['year']?.toString();
        academicTerm = settings['term'] as int?;
        schoolName = settings['school_name']?.toString();

        debugPrint(
            'User data loaded: creatorId=$creatorId, academicTerm=$academicTerm');
        // ✅ Extract DB name from response (not inside data)
        databaseName = response['_db']?.toString();
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, studentControllers) {
      studentControllers.forEach((_, controller) => controller.dispose());
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Skills and Behaviour',
          style: AppTextStyles.normal600(
            fontSize: 18.0,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
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
        actions: [
          TextButton.icon(
            onPressed: () {
              _saveChanges();
            },
            icon: const Icon(Icons.save, color: AppColors.eLearningBtnColor1),
            label: const Text(
              'Save',
              style: TextStyle(color: AppColors.eLearningBtnColor1),
            ),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: Consumer<SkillsBehaviorTableProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              if (provider.students.isEmpty || provider.skills.isEmpty) {
                return const Center(
                  child: Text('No data available'),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSubjectsTable(provider.skills, provider.students),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    final provider =
        Provider.of<SkillsBehaviorTableProvider>(context, listen: false);
    final skillsPayload = {
      'skills': <Map<String, dynamic>>[],
      'year': widget.year,
      'term': widget.term,
      '_db': widget.db,
    };

    _controllers.forEach((studentIndex, skillControllers) {
      final student = provider.students[studentIndex];
      final studentSkills = <Map<String, dynamic>>[];

      skillControllers.forEach((skillId, controller) {
        if (controller.text.isNotEmpty) {
          final skill = provider.skills.firstWhere((s) => s.id == skillId);
          studentSkills.add({
            'skill_id': skillId.toString(),
            'value': int.tryParse(controller.text) ?? 0,
            'label': skill.name,
          });
        }
      });

      if (studentSkills.isNotEmpty) {
        (skillsPayload['skills'] as List<Map<String, dynamic>>).add({
          'student_id': student.id,
          'student_skills': studentSkills,
        });
      }
    });

    if ((skillsPayload['skills'] as List).isNotEmpty) {
      bool isEditing = false;
      // Check if any student already has skills (i.e., editing)
      for (var student in provider.students) {
        if (student.skills.isNotEmpty) {
          isEditing = true;
          break;
        }
      }

      bool success = false;
      if (isEditing) {
        success = await provider.updateSkillsAndBehaviours(
          skillsPayload: skillsPayload,
          classId: widget.classId,
          levelId: widget.levelId,
          term: widget.term,
          year: widget.year,
          db: widget.db,
        );
      } else {
        success = await provider.createSkillsAndBehaviours(
          skillsPayload: skillsPayload,
          classId: widget.classId,
          levelId: widget.levelId,
          term: widget.term,
          year: widget.year,
          db: widget.db,
        );
      }

      if (success && mounted) {
        CustomToaster.toastSuccess(
          context,
          'Success',
          isEditing
              ? 'Skills and behaviors updated successfully'
              : 'Skills and behaviors saved successfully',
        );
      } else if (mounted) {
        CustomToaster.toastError(
          context,
          'Error',
          'Failed to save: ${provider.errorMessage}',
        );
      }
    }
  }

  Widget _buildSubjectsTable(List<SkillsBehaviorTable> skills,
      List<StudentSkillBehaviorTable> students) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildSubjectColumn(students),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: skills
                      .asMap()
                      .entries
                      .map((entry) => _buildScrollableColumn(
                            entry.value.name,
                            100,
                            students,
                            entry.value.id,
                            entry.key,
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectColumn(List<StudentSkillBehaviorTable> students) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              'Student Name',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...students.asMap().entries.map((entry) {
            final student = entry.value;
            return Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrollableColumn(String title, double width,
      List<StudentSkillBehaviorTable> students, int skillId, int skillIndex) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.eLearningBtnColor1,
              border: Border(
                left: const BorderSide(color: Colors.white),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...students.asMap().entries.map((entry) {
            final studentIndex = entry.key;
            final student = entry.value;
            _controllers.putIfAbsent(studentIndex, () => {});
            _controllers[studentIndex]!.putIfAbsent(
                skillId,
                () =>
                    TextEditingController(text: student.skills[skillId] ?? ''));

            return Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _controllers[studentIndex]![skillId],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class CustomToaster {
  static void toastSuccess(BuildContext context, String title, String message) {
    MotionToast.success(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      description: Text(message, style: const TextStyle(color: Colors.white)),
      position: MotionToastPosition.top,
      animationType: AnimationType.fromTop,
      contentPadding: const EdgeInsets.all(10),
    ).show(context);
  }

  static void toastError(BuildContext context, String title, String message) {
    MotionToast.error(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      description: Text(message, style: const TextStyle(color: Colors.white)),
      position: MotionToastPosition.top,
      animationType: AnimationType.fromTop,
      contentPadding: const EdgeInsets.all(10),
    ).show(context);
  }
}
