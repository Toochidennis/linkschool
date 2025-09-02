import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/staff/syllabus_model.dart';
import 'package:linkschool/modules/providers/staff/syllabus_provider.dart';
import 'package:provider/provider.dart';

class StaffCreateSyllabusScreen extends StatefulWidget {
  final Map<String, dynamic>? syllabusData;
  final String? courseId;
  final String? classId;
  final String? levelId;
  final String? courseName;
  final String? className;

  const StaffCreateSyllabusScreen({
    super.key,
    this.syllabusData,
    this.courseId,
    this.classId,
    this.levelId,
    this.courseName,
    this.className,
  });

  @override
  _StaffCreateSyllabusScreen createState() => _StaffCreateSyllabusScreen();
}

class _StaffCreateSyllabusScreen extends State<StaffCreateSyllabusScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _backgroundImagePath;
  late double opacity;
  bool isLoading = false;
  int? creatorId;
  String? creatorName;
  String? creatorRole;
  String? academicYear;
  int? levelId;
  int? academicTerm;
  final _formKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>> _classes; // To store classes as List<Map<String, dynamic>>

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.syllabusData?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.syllabusData?['description'] ?? '');
    _backgroundImagePath = widget.syllabusData?['backgroundImagePath'] ?? 'assets/images/result/bg_box3.svg';

    // Initialize classes list
    if (widget.syllabusData != null && widget.syllabusData!['classes'] != null) {
      // Editing mode: Use classes from syllabusData
      _classes = (widget.syllabusData!['classes'] as List<dynamic>)
          .map((cls) => {
                'id': cls is ClassModel ? cls.id : cls['id'].toString(),
                'name': cls is ClassModel ? cls.name : cls['name'].toString(),
              })
          .toList();
    } else if (widget.classId != null && widget.className != null) {
      // Creating mode: Use classId and className from widget
      _classes = [
        {
          'id': widget.classId!,
          'name': widget.className!,
        }
      ];
    } else {
      _classes = [];
    }

    _loadUserData();
  }

// declare at class level so it's accessible outside

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
      final formClasses = data['form_classes'] as List<dynamic>? ?? [];

      // just grab the first level_id
      if (formClasses.isNotEmpty) {
        levelId = formClasses.first['level_id'] as int?;
      }

      setState(() {
        creatorId = profile['staff_id'] as int?;
        creatorName = profile['name']?.toString() ?? 'Unknown';
        creatorRole = profile['role']?.toString();
        academicTerm = settings['term'] != null
            ? int.tryParse(settings['term'].toString())
            : null;
        academicYear = settings['year']?.toString();
      });

      print('Loaded user data: creatorId=$creatorId, creatorName=$creatorName, '
          'creatorRole=$creatorRole, academicTerm=$academicTerm, academicYear=$academicYear, '
          'levelId=$levelId');
    }
  } catch (e) {
    print('Error loading user data: $e');
  }
}


  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_classes.isEmpty) {
        CustomToaster.toastError(
          context,
          'Class Error',
          'No class provided for the syllabus.',
        );
        return;
      }

      if (isLoading) return;

      setState(() => isLoading = true);

      try {
        final syllabusProvider = Provider.of<StaffSyllabusProvider>(context, listen: false);
        final courseId = widget.courseId ?? 'course_not_selected';
   

        // Convert _classes to List<ClassModel> for the provider
        final classModels = _classes.map((cls) => ClassModel(id: cls['id'], name: cls['name'])).toList();

        if (widget.syllabusData != null) {
          // Editing mode
          final syllabusId = widget.syllabusData!['id'] as int;
          final updateData = {
            'title': _titleController.text,
            'description': _descriptionController.text,
            'term': academicTerm?.toString() ?? '1',
            'levelId': levelId,
            'syllabusId': syllabusId,
            'classes': _classes,
          };
          print('Update Syllabus Data: $updateData');
          await syllabusProvider.updateSyllabus(
            title: _titleController.text,
            description: _descriptionController.text,
            term: academicTerm?.toString() ?? '1',
            levelId: levelId!,
            syllabusId: syllabusId,
            classes:classModels , // Use classModels instead of classes
          );

          if (mounted) {
            CustomToaster.toastSuccess(
              context,
              'Syllabus Updated',
              'Syllabus updated successfully',
            );
            Navigator.of(context).pop({
              'title': _titleController.text,
              'description': _descriptionController.text,
              'classes': _classes,
            });
          }
        } else {

          // final createData = {
          //   'title': _titleController.text,
          //   'description': _descriptionController.text,
          //   'authorName': creatorName ?? 'Unknown',
          //   'term': academicTerm?.toString() ?? '1',
          //   'courseId': courseId,
          //   'courseName': widget.courseName ?? 'Unknown Course',
          //   'classes': _classes,
          //   'levelId': levelId,
          //   'classId': widget.classId ?? '',
          //   'creatorId': creatorId?.toString() ?? '',
          // };
         // print('Create Syllabus Data: $createData');
          await syllabusProvider.addSyllabus(
            title: _titleController.text,
            description: _descriptionController.text,
            authorName: creatorName ?? 'Unknown',
            term: academicTerm?.toString() ?? '1',
            courseId: courseId,
            courseName: widget.courseName ?? 'Unknown Course',
            classes: classModels, // Use classModels instead of classes
            levelId: levelId.toString(),
            classId: widget.classId ?? '',
            creatorId: creatorId?.toString() ?? '',
          );

          if (mounted) {
            CustomToaster.toastSuccess(
              context,
              'Syllabus Created',
              'Syllabus created successfully',
            );
            Navigator.of(context).pop({
              'title': _titleController.text,
              'description': _descriptionController.text,
              'course_id': courseId,
              'course_name': widget.courseName,
              'level_id': levelId,
              'classes': _classes,
              'creator_id': creatorId?.toString(),
              'creator_name': creatorName,
            });
          }
        }
      } catch (e) {
        print('Error saving syllabus: $e');
        if (mounted) {
          CustomToaster.toastError(
            context,
            'Error',
            'Failed to save syllabus: ${e.toString()}',
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } else {
      CustomToaster.toastError(
        context,
        'Validation Error',
        'Please fill all required fields',
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
      body: isLoading
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
                        const SizedBox(height: 16.0),
                        Text(
                          'Class:',
                          style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          _classes.isNotEmpty ? _classes.map((c) => c['name']).join(', ') : 'No class selected',
                          style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}