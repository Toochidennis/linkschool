import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/skills_behavior_table_provider.dart';
import 'package:linkschool/modules/services/staff/settings_service.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

class StaffSkillsBehaviourScreen extends StatefulWidget {
  final String classId;
  final String levelId;
  final String? term;
  final String? year;
  final String? db;

  const StaffSkillsBehaviourScreen({
    super.key,
    required this.classId,
    required this.levelId,
    this.term,
    this.year,
    this.db,
  });

  @override
  State<StaffSkillsBehaviourScreen> createState() => _StaffSkillsBehaviourScreenState();
}

class _StaffSkillsBehaviourScreenState extends State<StaffSkillsBehaviourScreen> {
  late double opacity;
  late String currentYear;
  late String currentTerm;
  late String currentDb;
  final Map<int, Map<int, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Get current settings from stored data, with fallback to passed parameters
    currentYear = widget.year ?? SettingsService.getCurrentYear();
    currentTerm = widget.term ?? SettingsService.getCurrentTerm().toString();
    currentDb = widget.db ?? SettingsService.getDatabaseName();
    
    print('Skills Behaviour Screen - Year: $currentYear, Term: $currentTerm, DB: $currentDb');
    
    final skillsProvider = Provider.of<SkillsBehaviorTableProvider>(context, listen: false);
    skillsProvider.fetchSkillsAndBehaviours(
      classId: widget.classId,
      levelId: widget.levelId,
      term: currentTerm,
      year: currentYear,
      db: currentDb,
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
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');

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
          'Skills and Behaviour',
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.eLearningBtnColor1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$currentYear - Term $currentTerm',
              style: TextStyle(
                color: AppColors.eLearningBtnColor1,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        provider.errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          provider.fetchSkillsAndBehaviours(
                            classId: widget.classId,
                            levelId: widget.levelId,
                            term: currentTerm,
                            year: currentYear,
                            db: currentDb,
                          );
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (provider.students.isEmpty || provider.skills.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No skills and behaviour data found for this class.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Academic Year: $currentYear/${int.parse(currentYear) + 1} - ${SettingsService.getTermName(int.parse(currentTerm))}',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSubjectsTable(provider.skills, provider.students),
                    SizedBox(height: 20),
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
    final provider = Provider.of<SkillsBehaviorTableProvider>(context, listen: false);
    final skillsPayload = {
      'skills': <Map<String, dynamic>>[],
      'year': currentYear,
      'term': currentTerm,
      '_db': currentDb,
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
          term: currentTerm,
          year: currentYear,
          db: currentDb,
        );
      } else {
        success = await provider.createSkillsAndBehaviours(
          skillsPayload: skillsPayload,
          classId: widget.classId,
          levelId: widget.levelId,
          term: currentTerm,
          year: currentYear,
          db: currentDb,
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

  Widget _buildSubjectsTable(List<SkillsBehaviorTable> skills, List<StudentSkillBehaviorTable> students) {
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

  Widget _buildScrollableColumn(String title, double width, List<StudentSkillBehaviorTable> students, int skillId, int skillIndex) {
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
            _controllers[studentIndex]!.putIfAbsent(skillId, () => TextEditingController(text: student.skills[skillId] ?? ''));

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