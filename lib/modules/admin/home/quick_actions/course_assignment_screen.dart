import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
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

class _AssignCoursesScreenState extends State<AssignCoursesScreen>
    with TickerProviderStateMixin {
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
      final assignCourseProvider = Provider.of<AssignCourseProvider>(context, listen: false);
      
      courseProvider.fetchCourses().then((_) {
        print('Courses Loaded: ${courseProvider.courses.length}');
      });
      
      levelClassProvider.fetchLevels().then((_) {
        print('LevelsWithClasses Loaded: ${levelClassProvider.levelsWithClasses.length}');
      });
      
      // Load existing assignments for this staff
      assignCourseProvider.loadCourseAssignments(
        int.parse(widget.staffId), 
        academicYear.toString(), 
        academicTerm.toString(),
      ).then((_) {
        print('Existing assignments loaded: ${assignCourseProvider.assignments.length}');
      });
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
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
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
    final assignCourseProvider = Provider.of<AssignCourseProvider>(context, listen: false);
    
    final payload = {
      'year': academicYear,
      'term': academicTerm,
      'staff_id': int.parse(widget.staffId),
      'courses': _assignments
          .where((assignment) =>
              assignment['course_id'] != 0 && assignment['class_id'] != 0)
          .toList(),
    };

    try {
      final success = await assignCourseProvider.AssignCourse(payload);
      if (success) {
        // Reload assignments after successful save
        await assignCourseProvider.loadCourseAssignments(
          int.parse(widget.staffId), 
          academicYear.toString(), 
          academicTerm.toString()
        );
        
        setState(() {
          _assignments.clear(); 
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Course assignments saved successfully'),
              backgroundColor: AppColors.attCheckColor2,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error assigning course'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final levelClassProvider = Provider.of<LevelClassProvider>(context);
    final assignCourseProvider = Provider.of<AssignCourseProvider>(context);

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
      body: courseProvider.isLoading || 
             levelClassProvider.isLoading || 
             assignCourseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : courseProvider.courses.isEmpty ||
                levelClassProvider.levelsWithClasses.isEmpty
              ? Center(
                  child: Text(
                    courseProvider.courses.isEmpty
                        ? 'No courses available'
                        : 'No classes available',
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display existing assignments
                      if (assignCourseProvider.assignments.isNotEmpty) ...[
                        Text(
                          'Current Assignments',
                          style: AppTextStyles.normal600(
                            fontSize: 18,
                            color: AppColors.text2Light,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: assignCourseProvider.assignments.length,
                          itemBuilder: (context, index) {
                            final assignment = assignCourseProvider.assignments[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.text2Light.withOpacity(0.1),
                                  child: Icon(
                                    Icons.book,
                                    color: AppColors.text2Light,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  '${assignment.courseName} (${assignment.courseCode})',
                                  style: AppTextStyles.normal600(
                                    fontSize: 14,
                                    color: AppColors.text2Light,
                                  ),
                                ),
                                subtitle: Text(
                                  '${assignment.className} • ${assignment.levelName}',
                                  style: AppTextStyles.normal500(
                                    fontSize: 12,
                                    color: AppColors.text5Light,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.check_circle,
                                  color: AppColors.attCheckColor2,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],
                      
                      // Add new assignments section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add New Assignments',
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.text2Light,
                            ),
                          ),
                          if (_assignments.isEmpty)
                            IconButton(
                              onPressed: _addAssignment,
                              icon: const Icon(Icons.add_circle),
                              color: AppColors.text2Light,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Editable assignments list
                      if (_assignments.isNotEmpty) 
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _assignments.length,
                          itemBuilder: (context, index) {
                            return _buildAnimatedCard(
                              index: index,
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
                                          final allClasses = provider.levelsWithClasses
                                              .expand((lwc) => lwc.classes)
                                              .toList();
                                          return _buildDropdown<int>(
                                            label: 'Class',
                                            value: _assignments[index]['class_id'] == 0
                                                ? null
                                                : _assignments[index]['class_id'],
                                            items: allClasses
                                                .map((cls) => DropdownMenuItem<int>(
                                                      value: cls.id,
                                                      child: Text(cls.className.isEmpty
                                                          ? 'Unnamed Class'
                                                          : cls.className),
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
                        )
                      else
                        Center(
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                'assets/images/e-learning/Student stress-amico.svg',
                                width: 180,
                                height: 180,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No new assignments to add',
                                style: AppTextStyles.normal500(
                                  fontSize: 14,
                                  color: AppColors.text5Light,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _addAssignment,
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text('Add Assignment'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.text2Light,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Add Another Assignment button (only shown when there are assignments)
                      if (_assignments.isNotEmpty) ...[
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
                            ),
                            child: const Text(
                              'Add Another Assignment',
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
                    ],
                  ),
                ),
      floatingActionButton: _assignments.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _submitAssignments,
              backgroundColor: AppColors.text2Light,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Save New Assignments',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}