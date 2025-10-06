import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/home/add_course_model.dart';
import 'package:linkschool/modules/model/admin/home/level_class_model.dart';
import 'package:linkschool/modules/providers/admin/home/add_course_provider.dart';
import 'package:linkschool/modules/providers/admin/home/assign_course_provider.dart';
import 'package:linkschool/modules/providers/admin/home/level_class_provider.dart';
import 'package:provider/provider.dart';

class AssignCoursesScreen extends StatefulWidget {
  final String staffId;

  const AssignCoursesScreen({super.key, required this.staffId});

  @override
  State<AssignCoursesScreen> createState() => _AssignCoursesScreenState();
}

class _AssignCoursesScreenState extends State<AssignCoursesScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, int>> _assignments = [];
  String? academicYear;
  int? academicTerm;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
    _slideController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      final levelClassProvider = Provider.of<LevelClassProvider>(context, listen: false);
      courseProvider.fetchCourses().then((_) {
        print('Courses Loaded: ${courseProvider.courses.map((c) => {'id': c.id, 'name': c.courseName, 'levelId': c.levelId}).toList()}');
      });
      levelClassProvider.fetchLevels().then((_) {
        print('LevelsWithClasses Loaded: ${levelClassProvider.levelsWithClasses.map((lwc) => {'levelId': lwc.level.id, 'classes': lwc.classes.map((c) => c.className).toList()}).toList()}');
      });

      final CourseAssignmentProvider = Provider.of<AssignCourseProvider>(context, listen: false);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.3 + (index * 0.1)),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                index * 0.1,
                1.0,
                curve: Curves.elasticOut,
              ),
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?)? onChanged,
    String? hintText,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.text5Light,
          fontSize: 14,
          fontFamily: 'Urbanist',
        ),
        filled: true,
        fillColor: AppColors.textFieldLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.textFieldBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.textFieldBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.text2Light, width: 2),
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.text7Light),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  void _addAssignment() {
    setState(() {
      _assignments.add({'course_id': 0, 'class_id': 0});
    });
  }

  void _removeAssignment(int index) {
    setState(() {
      _assignments.removeAt(index);
    });
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
        final settings = data['settings'] ?? {};

        setState(() {
          academicYear = settings['year']?.toString();
          academicTerm = settings['term'] as int?;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _submitAssignments() async {
      final CourseAssignmentProvider = Provider.of<AssignCourseProvider>(context, listen: false);
    final payload = {
      'year': academicYear,
      'term': academicTerm,
      'staff_id': int.parse(widget.staffId),
      'courses': _assignments
          .where((assignment) => assignment['course_id'] != 0 && assignment['class_id'] != 0)
          .toList(),
    };

  try{
  final success = await CourseAssignmentProvider.AssignCourse(payload);
    print('Payload: $payload');
    if(success){
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Course Assignment submitted '),
        backgroundColor: AppColors.attCheckColor2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    if (mounted) {
      Navigator.pop(context);
    }
    }
  }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error Assigning Course'),
        backgroundColor: AppColors.attCheckColor2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
    
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final levelClassProvider = Provider.of<LevelClassProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assign Courses',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: courseProvider.isLoading || levelClassProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : courseProvider.courses.isEmpty || levelClassProvider.levelsWithClasses.isEmpty
              ? Center(
                  child: Text(
                    courseProvider.courses.isEmpty
                        ? 'No courses available'
                        : 'No classes available',
                  ),
                )
              : _assignments.isEmpty
    ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/e-learning/Student stress-amico.svg',
                width: 220,
                height: 220,
              ),
              const SizedBox(height: 16),
              Text(
                'No courses and classes have been assigned',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.primaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addAssignment,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Assign Course",
                  style: TextStyle(
                    fontFamily: "Urbanist",
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.text2Light,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      )

               :Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedCard(
                          index: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             
                              const SizedBox(height: 16),
                           
                              const SizedBox(height: 16),
                              Text(
                                'Courses and Classes',
                                style: AppTextStyles.normal600(
                                  fontSize: 16,
                                  color: AppColors.text2Light,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _assignments.length,
                                itemBuilder: (context, index) {
                                  return _buildAnimatedCard(
                                    index: index + 1,
                                    child: Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0),
  ),
  elevation: 4,
  shadowColor: Colors.black12,
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Consumer<CourseProvider>(
                builder: (context, provider, _) {
                  return _buildDropdown<int>(
                    label: 'Course',
                    value: _assignments[index]['course_id'] == 0
                        ? null
                        : _assignments[index]['course_id'],
                    items: provider.courses
                        .map((course) => DropdownMenuItem<int>(
                              value: course.id,
                              child: Text(
                                '${course.courseName} (${course.courseCode})',
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _assignments[index]['course_id'] = value ?? 0;
                        _assignments[index]['class_id'] = 0;
                      });
                    },
                  );
                },
              ),
            ),
            IconButton(
              onPressed: () => _removeAssignment(index),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Consumer<LevelClassProvider>(
          builder: (context, provider, _) {
            final allClasses = provider.levelsWithClasses.expand((lwc) => lwc.classes).toList();
            return _buildDropdown<int>(
              label: 'Class',
              value: _assignments[index]['class_id'] == 0
                  ? null
                  : _assignments[index]['class_id'],
              items: allClasses
                  .map((cls) => DropdownMenuItem<int>(
                        value: cls.id,
                        child: Text(cls.className.isEmpty ? 'Unnamed Class' : cls.className),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _assignments[index]['class_id'] = value ?? 0;
                });
              },
            );
          },
        ),
      ],
    ),
  ),
),

                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _addAssignment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.text2Light,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Add Course Assignment',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    floatingActionButton: FloatingActionButton.extended(
  onPressed: _assignments.isEmpty ? null : _submitAssignments,
  backgroundColor: _assignments.isEmpty
      ? AppColors.text7Light
      : AppColors.text2Light,
  icon: const Icon(Icons.save, color: Colors.white),
  label: const Text(
    'Save Assignments',
    style: TextStyle(
      fontFamily: 'Urbanist',
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),

    );
  }
}