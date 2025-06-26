import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_teachers_dialog.dart';
import 'package:linkschool/modules/model/e-learning/syllabus_model.dart';
import 'package:linkschool/modules/providers/admin/e_learning/syllabus_provider.dart';
import 'package:linkschool/modules/services/admin/e_learning/syllabus_service.dart';
import 'package:linkschool/modules/services/api/api_service.dart';

class CreateSyllabusScreen extends StatefulWidget {
  final Map<String, dynamic>? syllabusData;
  final String? courseId;
  final String? classId;
  final String? levelId;
final String? courseName;
  const CreateSyllabusScreen({
    super.key,
    this.syllabusData,
    this.courseId,
    this.classId,
    this.levelId, 
     this.courseName,
  });

  @override
  _CreateSyllabusScreenState createState() => _CreateSyllabusScreenState();
}

class _CreateSyllabusScreenState extends State<CreateSyllabusScreen> {
  late String _selectedClass;
  late String _selectedTeacher;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _backgroundImagePath;
  late double opacity;
  bool isLoading = false;
  int? creatorId;
  String? creatorRole;
  String? academicYear;
   String? creatorName ;
  int? academicTerm;
  final SyllabusProvider syllabusProvider = SyllabusProvider(SyllabusService(ApiService()));
  final _formKey = GlobalKey<FormState>();

@override
void initState() {
  super.initState();
  _selectedClass = widget.syllabusData?['selectedClass'] ?? 'Select classes';
  _selectedTeacher = widget.syllabusData?['selectedTeacher'] ?? 'Select teachers';
  _titleController = TextEditingController(text: widget.syllabusData?['title'] ?? '');
  _descriptionController = TextEditingController(text: widget.syllabusData?['description'] ?? '');
  _backgroundImagePath = widget.syllabusData?['backgroundImagePath'] ?? 'assets/images/result/bg_box3.svg';

  // Only load preselected class IDs when editing (i.e., syllabusData is not null)
  if (widget.syllabusData != null && widget.syllabusData!['classes'] != null) {
    final classIds = (widget.syllabusData!['classes'] as List<ClassModel>)
        .map((cls) => cls.id)
        .toList();
    Hive.box('userData').put('selectedClassIds', classIds);
  } else {
    // When creating, ensure no class is pre-selected
    Hive.box('userData').put('selectedClassIds', []);
  }

  _loadUserData();
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
          creatorName = profile['name']?.toString() ?? 'Unknown';
          creatorRole = profile['role']?.toString();
          academicYear = settings['year']?.toString();
          academicTerm = settings['term'] as int?;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

Future<void> _handleSave() async {
  final userBox = Hive.box('userData');
  final selectedClassIds = userBox.get('selectedClassIds') ?? [];

  // Validation for class selection
  if ((selectedClassIds.isEmpty || selectedClassIds.length == 0) &&
      (widget.classId == null || widget.classId!.isEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select at least one class.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (_formKey.currentState!.validate()) {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final userBox = Hive.box('userData');
      final storedCourseId = userBox.get('selectedCourseId');
      final storedLevelId = userBox.get('selectedLevelId');
      final selectedClassIds = userBox.get('selectedClassIds') ?? [];

      final courseId = widget.courseId ?? storedCourseId?.toString() ?? 'course_not_selected';
      final levelId = widget.levelId ?? storedLevelId?.toString() ?? 'level_not_selected';

      // Retrieve class data from JSON to create ClassModel objects
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
      final processedData = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData;
      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      final classes = data['classes'] ?? [];

      // Create List<ClassModel> instead of List<Map>
      final classModels = selectedClassIds.map<ClassModel>((classId) {
        final classIdStr = classId.toString();
        final classData = classes.firstWhere(
          (cls) => cls['id'].toString() == classIdStr,
          orElse: () => {'id': classIdStr, 'name': 'Unknown'},
        );
        return ClassModel(
          id: classIdStr,
          name: classData['name']?.toString() ?? 
               classData['class_name']?.toString() ?? 
               'Unknown',
        );
      }).toList();

      // Use widget.classId as fallback if no classes selected
      if (classModels.isEmpty && widget.classId != null) {
        final classIdStr = widget.classId!;
        final classData = classes.firstWhere(
          (cls) => cls['id'].toString() == classIdStr,
          orElse: () => {'id': classIdStr, 'name': _selectedClass},
        );
        classModels.add(ClassModel(
          id: classIdStr,
          name: classData['name']?.toString() ?? 
               classData['class_name']?.toString() ?? 
               _selectedClass,
        ));
      }

      await syllabusProvider.addSyllabus(
        title: _titleController.text,
        description: _descriptionController.text,
        authorName: creatorName ?? 'Unknown',
        term: academicTerm?.toString() ?? '1', 
        courseId: courseId,
        courseName: widget.courseName ?? 'Unknown Course',
        classes: classModels, // Now passing List<ClassModel>
        levelId: levelId,
         creatorId: creatorId.toString()
      );

        print('Complete Syllabus Data:');
       

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Syllabus saved successfully',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    ),
  );
  Navigator.of(context).pop(academicTerm?.toString() ?? ''); // <-- Return the term
}
      } catch (e) {
        print('Error saving syllabus: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required fields',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.syllabusData == null ? 'Create Syllabus' : 'Edit Syllabus',
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
              onPressed: _handleSave,
              text: 'Save',
            ),
          ),
        ],
      ),
      body:isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title:',
                    style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Dying and bleaching',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.all(12.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Description:',
                    style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type here...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.all(12.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32.0),
                  Text(
                    'Select the learning group for this syllabus: *',
                    style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
                  ),
                  const SizedBox(height: 16.0),
                  _buildGroupRow(
                    context,
                    iconPath: 'assets/icons/e_learning/people.svg',
                    text: _selectedClass,
                    onTap: () async {
                      final result = await Navigator.of(context).push<String>(
                        MaterialPageRoute(
                          builder: (context) => SelectClassesDialog(
                            onSave: (selectedClass) {
                              setState(() {
                                _selectedClass = selectedClass;
                              });
                            },
                            levelId: widget.levelId,
                       
                        // <-- Add this
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _selectedClass = result;
                        });
                      }
                    },
                  ),
                  _buildGroupRow(
                    context,
                    iconPath: 'assets/icons/e_learning/profile.svg',
                    text: _selectedTeacher,
                    onTap: () async {
                      final result = await Navigator.of(context).push<String>(
                        MaterialPageRoute(
                          builder: (context) => SelectTeachersDialog(
                            onSave: (selectedTeacher) {
                              setState(() {
                                _selectedTeacher = selectedTeacher;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
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
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
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
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.eLearningBtnColor2,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text(
                        text,
                        style: AppTextStyles.normal600(
                          fontSize: 16.0,
                          color: AppColors.eLearningBtnColor1,
                        ),
                      ),
                    ),
                  ),
                ),
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
}