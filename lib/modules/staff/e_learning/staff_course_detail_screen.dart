import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/e-learning/syllabus_model.dart'
    as elModel;
import 'package:linkschool/modules/model/staff/syllabus_model.dart'
    as staffModel;
import 'package:linkschool/modules/providers/admin/e_learning/delete_sylabus_content.dart';
import 'package:linkschool/modules/providers/staff/syllabus_provider.dart';
import 'package:linkschool/modules/staff/e_learning/empty_staff_subjectscreen.dart';
import 'package:linkschool/modules/staff/e_learning/staff_create_syllabus_screen.dart';

import 'package:provider/provider.dart';

class StaffCourseDetailScreen extends StatefulWidget {
  final String selectedSubject;
  final String courseId;
  final List<Map<String, dynamic>>
      classesList; // Receives List<Map<String, dynamic>>
  final String? classId;
  final String? levelId;
  final String? course_name;
  final String? term;

  const StaffCourseDetailScreen({
    super.key,
    required this.selectedSubject,
    required this.courseId,
    required this.classesList,
    this.classId,
    this.levelId,
    this.course_name,
    this.term,
  });

  @override
  State<StaffCourseDetailScreen> createState() =>
      _StaffCourseDetailScreenState();
}

class _StaffCourseDetailScreenState extends State<StaffCourseDetailScreen>
    with WidgetsBindingObserver {
  final List<Map<String, dynamic>> _syllabusList = [];
  bool isLoading = false;
  int? creatorId;
  String? creatorName;
  String? creatorRole;
  String? academicYear;
  int? academicTerm;
  String? _levelId;
  final List<String> _imagePaths = [
    'assets/images/result/bg_box1.svg',
    'assets/images/result/bg_box2.svg',
    'assets/images/result/bg_box3.svg',
    'assets/images/result/bg_box4.svg',
    'assets/images/result/bg_box5.svg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSyllabuses();
    _loadUserData();
    print("Received classesList: ${widget.classesList}");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
        final formClasses = (data['form_classes'] ?? []) as List;

        // grab first form class if available
        final firstClass = formClasses.isNotEmpty ? formClasses.first : null;
        final fallbackLevelId = firstClass?['level_id']?.toString();

        setState(() {
          creatorId = profile['staff_id'] as int?;
          creatorName = profile['name']?.toString() ?? 'Unknown';
          creatorRole = profile['role']?.toString();
          academicTerm = settings['term'] != null
              ? int.tryParse(settings['term'].toString())
              : null;
          academicYear = settings['year']?.toString();

          // add levelId and term from your format
          _levelId = fallbackLevelId ?? '';
        });

        print('Loaded user data: '
            'creatorId=$creatorId, creatorName=$creatorName, creatorRole=$creatorRole, '
            'academicTerm=$academicTerm, academicYear=$academicYear, '
            'levelId=$_levelId');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadSyllabuses() async {
    print(
        "Loading syllabuses with courseId: ${widget.courseId}, classId: ${widget.classId}, levelId: ${widget.levelId}, classesList: ${widget.classesList}");

    final syllabusProvider =
        Provider.of<StaffSyllabusProvider>(context, listen: false);
    setState(() => isLoading = true);

    try {
      String levelId = widget.levelId ?? "";
      String term = widget.term ?? "";
      String? courseId = widget.courseId;
      String classId = widget.classId ?? '';

      if (levelId.isEmpty || term.isEmpty) {
        final userBox = Hive.box('userData');
        final storedUserData =
            userBox.get('userData') ?? userBox.get('loginResponse');

        if (storedUserData != null) {
          final processedData = storedUserData is String
              ? json.decode(storedUserData)
              : storedUserData as Map<String, dynamic>;

          final response = processedData['response'] ?? processedData;
          final data = response['data'] ?? response;
          final settings = data['settings'] ?? {};
          final formClasses = (data['form_classes'] ?? []) as List;

          final firstClass = formClasses.isNotEmpty ? formClasses.first : null;
          final fallbackLevelId = firstClass?['level_id']?.toString();

          setState(() {
            levelId = fallbackLevelId ?? '';
            term = settings['term']?.toString() ?? '';
          });
        }
      }

      await syllabusProvider.fetchSyllabus(
        levelId,
        term ?? '',
        courseId ?? '',
        classId,
      );

      final syllabusModels = syllabusProvider.syllabusList;
      print('Received ${syllabusModels.length} syllabus models');

      if (syllabusProvider.error.isNotEmpty) {
        throw Exception(syllabusProvider.error);
      }

      setState(() {
        _syllabusList.clear();
        _syllabusList.addAll(
          syllabusModels.asMap().entries.map((entry) {
            final index = entry.key;
            final syllabus = entry.value;

            if (syllabus.id == null) {
              print('Warning: Syllabus at index $index has null ID');
              return null;
            }

            // Use widget.classesList if available, otherwise fall back to syllabus.classes
            final classes = widget.classesList.isNotEmpty
                ? widget.classesList
                : syllabus.classes
                    .map((c) => {'id': c.id.toString(), 'name': c.name})
                    .toList();

            final classNames =
                classes.map((c) => c['name']?.toString() ?? '').join(', ');
            final selectedClass =
                classNames.isEmpty ? 'No classes selected' : classNames;

            return {
              'id': syllabus.id,
              'title': syllabus.title,
              'description': syllabus.description,
              'author_name': syllabus.authorName,
              'term': syllabus.term,
              'upload_date': syllabus.uploadDate,
              'classes': classes, // Use List<Map<String, dynamic>>
              'selectedClass': selectedClass,
              'selectedTeacher': syllabus.authorName,
              'backgroundImagePath': _imagePaths.isNotEmpty
                  ? _imagePaths[index % _imagePaths.length]
                  : '',
              'course_id': syllabus.courseId ?? widget.courseId ?? '',
              'course_name': syllabus.courseName ?? widget.course_name ?? '',
              'level_id': syllabus.levelId ?? levelId,
              'creator_id': syllabus.creatorId ?? '',
            };
          }).whereType<Map<String, dynamic>>(),
        );
      });

      print('Successfully processed ${_syllabusList.length} syllabuses for UI');
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        CustomToaster.toastError(
            context, 'Error', 'Failed to load syllabuses: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _addNewSyllabus() async {
    print(
        "Adding new syllabus with courseId: ${widget.courseId}, levelId: ${widget.levelId}, course_name: ${widget.course_name}, classId: ${widget.classId}, classesList: ${widget.classesList}");
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => StaffCreateSyllabusScreen(
          classList: widget.classesList,
          classId: widget.classId,
          courseId: widget.courseId,
          levelId: widget.levelId,
          courseName: widget.course_name,
          className: widget.classesList.isNotEmpty
              ? widget.classesList[0]['name']
              : '',
        ),
      ),
    );

    if (result != null) {
      _loadSyllabuses();
    }
  }

  void _editSyllabus(int index) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => StaffCreateSyllabusScreen(
          syllabusData: _syllabusList[index],
          classId: widget.classId,
          courseId: widget.courseId,
          levelId: widget.levelId,
          courseName: widget.course_name,
        ),
      ),
    );

    // If the user saved changes, result should contain the new values
    if (result != null && result is Map<String, dynamic>) {
      final String newTitle = result['title'];
      final String newDescription = result['description'];
      final List<staffModel.ClassModel> newClasses =
          ((result['classes'] as List?) ?? []).map((c) {
        if (c is staffModel.ClassModel) return c;
        if (c is elModel.ClassModel) {
          return staffModel.ClassModel(id: c.id, name: c.name);
        }
        if (c is Map) {
          return staffModel.ClassModel(
            id: (c['id'] ?? '').toString(),
            name: (c['name'] ?? c['class_name'] ?? '').toString(),
          );
        }
        return staffModel.ClassModel(id: c.toString(), name: '');
      }).toList();
      updateSyllabus(index, newTitle, newDescription, newClasses);
    }
  }

  void updateSyllabus(int index, String newTitle, String newDescription,
      List<staffModel.ClassModel> newClasses) async {
    final int syllabusId = _syllabusList[index]['id'];
    final String term = _syllabusList[index]['term'];
    final String levelId = widget.levelId ?? '';
    final syllabusProvider =
        Provider.of<StaffSyllabusProvider>(context, listen: false);
    try {
      await syllabusProvider.updateSyllabus(
        title: newTitle,
        description: newDescription,
        term: term,
        levelId: int.parse(levelId),
        syllabusId: syllabusId,
        classes: newClasses,
      );
      CustomToaster.toastSuccess(
        context,
        'Syllabus Updated',
        'Syllabus updated successfully',
      );
      _loadSyllabuses();
    } catch (e) {
      CustomToaster.toastError(
        context,
        'Error',
        'Failed to update syllabus: $e',
      );
    }
  }

  Widget _buildSyllabusList() {
    print('Building syllabus list with ${_syllabusList.length} items');
    print(
        'Widget parameters - classId: ${widget.classId}, levelId: ${widget.levelId}, courseId: ${widget.courseId}, course_name: ${widget.course_name}, classesList: ${widget.classesList}');

    return ListView.builder(
      itemCount: _syllabusList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffEmptySubjectScreen(
                classList: widget.classesList,
                syllabusId: _syllabusList[index]['id'] as int?,
                syllabusClasses: _syllabusList[index]['classes']
                    as List<Map<String, dynamic>>,
                classId: widget.classId,
                courseId: widget.courseId,
                levelId: _levelId,
                // authorName: _syllabusList[index]['author_name']?.toString() ?? '',
                courseName: widget.course_name,
                term: _syllabusList[index]['term']?.toString() ?? '',
                courseTitle: _syllabusList[index]['title']?.toString() ?? '',
              ),
              settings: const RouteSettings(name: '/empty_subject'),
            ),
          ),
          child: _buildOutlineContainers(_syllabusList[index], index),
        );
      },
    );
  }

  Widget _buildOutlineContainers(Map<String, dynamic> syllabus, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (syllabus['backgroundImagePath'] != null)
              SvgPicture.asset(
                syllabus['backgroundImagePath'] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          syllabus['title']?.toString() ?? '',
                          style: AppTextStyles.normal700(
                            fontSize: 18,
                            color: AppColors.backgroundLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/result/edit.svg',
                          color: Colors.white,
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () => _editSyllabus(index),
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/result/delete.svg',
                          color: Colors.white,
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () => _confirmDeleteSyllabus(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    syllabus['selectedClass']?.toString() ?? '',
                    style: AppTextStyles.normal500(
                      fontSize: 18,
                      color: AppColors.backgroundLight,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    syllabus['selectedTeacher']?.toString() ?? '',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: AppColors.backgroundLight,
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

  void _confirmDeleteSyllabus(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Syllabus',
            style: AppTextStyles.normal600(
              fontSize: 20,
              color: AppColors.backgroundDark,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this syllabus?',
            style: AppTextStyles.normal500(
              fontSize: 16,
              color: AppColors.backgroundDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'No',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSyllabus(index);
              },
              child: Text(
                'Yes',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteSyllabus(int index) async {
    final int syllabusId = _syllabusList[index]['id'];
    final deleteProvider =
        Provider.of<DeleteSyllabusProvider>(context, listen: false);

    try {
      await deleteProvider.deletesyllabus(syllabusId);
      CustomToaster.toastSuccess(
        context,
        'Syllabus Deleted',
        'Syllabus deleted successfully',
      );
      _loadSyllabuses();
    } catch (e) {
      CustomToaster.toastError(
        context,
        'Error',
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Syllabus',
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
              ),
            ],
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            opacity: opacity,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _syllabusList.isEmpty
                ? _buildEmptyState()
                : _buildSyllabusList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSyllabus,
        backgroundColor: AppColors.staffBtnColor1,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
              text: 'Create new syllabus',
              onPressed: _addNewSyllabus,
              backgroundColor: AppColors.eLearningBtnColor1,
              textStyle: AppTextStyles.normal600(
                fontSize: 16,
                color: AppColors.backgroundLight,
              ),
              padding: const EdgeInsets.all(12),
            ),
          ],
        ),
      ],
    );
  }
}
