import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
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

class _AssignCoursesScreenState extends State<AssignCoursesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

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
    _fadeController.forward();
    _slideController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      final levelClassProvider = Provider.of<LevelClassProvider>(context, listen: false);
      final assignCourseProvider = Provider.of<AssignCourseProvider>(context, listen: false);
      
      courseProvider.fetchCourses();
      levelClassProvider.fetchLevels();
      
      // Load existing assignments for this staff
      assignCourseProvider.loadCourseAssignments(
        int.parse(widget.staffId), 
        academicYear.toString(), 
        academicTerm.toString(),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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

  // Group assignments by class
  Map<String, List<dynamic>> _groupAssignmentsByClass(List<dynamic> assignments) {
    final Map<String, List<dynamic>> grouped = {};
    for (final assignment in assignments) {
      final className = assignment.className;
      if (!grouped.containsKey(className)) {
        grouped[className] = [];
      }
      grouped[className]!.add(assignment);
    }
    return grouped;
  }

  // Show class selection modal
  void _showClassSelectionModal({List<int>? preSelectedClassIds}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ClassSelectionModal(
        preSelectedClassIds: preSelectedClassIds,
        onContinue: (selectedClasses) {
          Navigator.pop(context);
          _showCourseSelectionModal(selectedClasses);
        },
      ),
    );
  }

  // Show course selection modal
  void _showCourseSelectionModal(List<Class> selectedClasses) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CourseSelectionModal(
        selectedClasses: selectedClasses,
        staffId: widget.staffId,
        academicYear: academicYear,
        academicTerm: academicTerm,
        onChangeClasses: (currentClassIds) {
          Navigator.pop(context);
          _showClassSelectionModal(preSelectedClassIds: currentClassIds);
        },
        onAssignmentComplete: () {
          // Reload assignments
          final assignCourseProvider = Provider.of<AssignCourseProvider>(context, listen: false);
          assignCourseProvider.loadCourseAssignments(
            int.parse(widget.staffId),
            academicYear.toString(),
            academicTerm.toString(),
          );
        },
      ),
    );
  }

  // Delete assignment
  void _deleteAssignment(int assignmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<AssignCourseProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      // TODO: Implement delete assignment API call
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Assignment deleted successfully'),
                          backgroundColor: AppColors.attCheckColor2,
                        ),
                      );
                    },
              child: provider.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  // Edit assignment for a specific class
  void _editAssignmentForClass(String className, List<dynamic> classAssignments) {
    final levelClassProvider = Provider.of<LevelClassProvider>(context, listen: false);
    final allClasses = levelClassProvider.levelsWithClasses
        .expand((lwc) => lwc.classes)
        .toList();
    
    final currentClass = allClasses.where((cls) => cls.className == className).toList();
    
    if (currentClass.isNotEmpty) {
      _showCourseSelectionModal(currentClass);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignCourseProvider = Provider.of<AssignCourseProvider>(context);
    final groupedAssignments = _groupAssignmentsByClass(assignCourseProvider.assignments);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assign Courses',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: assignCourseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              child: assignCourseProvider.assignments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/e-learning/Student stress-amico.svg',
                            width: 200,
                            height: 200,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No Course Assignments Yet',
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: Colors.grey[600]!,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to assign courses',
                            style: AppTextStyles.normal400(
                              fontSize: 14,
                              color: Colors.grey[500]!,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groupedAssignments.keys.length,
                      itemBuilder: (context, index) {
                        final className = groupedAssignments.keys.elementAt(index);
                        final classAssignments = groupedAssignments[className]!;
                        return _buildClassCard(className, classAssignments);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClassSelectionModal(),
        backgroundColor: AppColors.text2Light,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildClassCard(String className, List<dynamic> assignments) {
    // Get level name from first assignment (all assignments in group have same class/level)
    final levelName = assignments.first.levelName;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Class Header with Edit and Delete
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.text2Light,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Container(
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: AppColors.text2Light.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Icon(
                //     Icons.class_,
                //     color: AppColors.text2Light,
                //     size: 24,
                //   ),
                // ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        style: AppTextStyles.normal600(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                     
                     
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.text2Light.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${assignments.length} ${assignments.length == 1 ? 'Course' : 'Courses'}',
                    style: AppTextStyles.normal600(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: AppColors.text2Light,
                      size: 20,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editAssignmentForClass(className, assignments);
                    } else if (value == 'delete') {
                      // Delete all assignments for this class
                      // TODO: Implement bulk delete
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, size: 20),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red, size: 20),
                        title: Text('Delete All', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Courses List
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...assignments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final assignment = entry.value;
                  final isLast = index == assignments.length - 1;
                  
                  return Column(
                    children: [
                      Row(
                        children: [
                          // Container(
                          //   padding: const EdgeInsets.all(8),
                          //   decoration: BoxDecoration(
                          //     color: AppColors.text2Light.withOpacity(0.08),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: Icon(
                          //     Icons.book,
                          //     color: AppColors.text2Light,
                          //     size: 18,
                          //   ),
                          // ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  assignment.courseName,
                                  style: AppTextStyles.normal600(
                                    fontSize: 15,
                                    color: AppColors.text2Light,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Text(
                                //   assignment.courseCode,
                                //   style: AppTextStyles.normal400(
                                //     fontSize: 12,
                                //     color: Colors.grey[600]!,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                         
                        ],
                      ),
                      if (!isLast) const SizedBox(height: 16),
                      if (!isLast) Divider(color: Colors.grey[200], height: 1),
                      if (!isLast) const SizedBox(height: 16),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Class Selection Modal Widget
class _ClassSelectionModal extends StatefulWidget {
  final List<int>? preSelectedClassIds;
  final Function(List<Class>) onContinue;

  const _ClassSelectionModal({
    this.preSelectedClassIds,
    required this.onContinue,
  });

  @override
  State<_ClassSelectionModal> createState() => _ClassSelectionModalState();
}

class _ClassSelectionModalState extends State<_ClassSelectionModal> {
  final Set<int> _selectedClassIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedClassIds != null) {
      _selectedClassIds.addAll(widget.preSelectedClassIds!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelClassProvider = Provider.of<LevelClassProvider>(context);
    final allClasses = levelClassProvider.levelsWithClasses
        .expand((lwc) => lwc.classes)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.text2Light.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Classes',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: AppColors.text2Light,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.text2Light,
                ),
              ],
            ),
          ),
          // Warning Message - Only show when MORE THAN ONE class is selected
          if (_selectedClassIds.length > 1)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The course selected will be registered for the ${_selectedClassIds.length} classes',
                      style: AppTextStyles.normal500(
                        fontSize: 13,
                        color: Colors.orange[900]!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Classes List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: allClasses.length,
              itemBuilder: (context, index) {
                final classItem = allClasses[index];
                final isSelected = _selectedClassIds.contains(classItem.id);
                final level = levelClassProvider.levelsWithClasses
                    .firstWhere((lwc) => lwc.classes.contains(classItem))
                    .level;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.text2Light.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.text2Light
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedClassIds.remove(classItem.id);
                        } else {
                          _selectedClassIds.add(classItem.id);
                        }
                      });
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.text2Light
                            : AppColors.text2Light.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.class_,
                        color: isSelected ? Colors.white : AppColors.text2Light,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      classItem.className,
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: isSelected ? AppColors.text2Light : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      level.levelName,
                      style: AppTextStyles.normal400(
                        fontSize: 14,
                        color: Colors.grey[600]!,
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.text2Light,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          // Continue Button
          if (_selectedClassIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final selectedClasses = allClasses
                        .where((cls) => _selectedClassIds.contains(cls.id))
                        .toList();
                    widget.onContinue(selectedClasses);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.text2Light,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue (${_selectedClassIds.length} ${_selectedClassIds.length == 1 ? 'Class' : 'Classes'})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Course Selection Modal Widget
class _CourseSelectionModal extends StatefulWidget {
  final List<Class> selectedClasses;
  final String staffId;
  final String? academicYear;
  final int? academicTerm;
  final Function(List<int>) onChangeClasses;
  final VoidCallback onAssignmentComplete;

  const _CourseSelectionModal({
    required this.selectedClasses,
    required this.staffId,
    required this.academicYear,
    required this.academicTerm,
    required this.onChangeClasses,
    required this.onAssignmentComplete,
  });

  @override
  State<_CourseSelectionModal> createState() => _CourseSelectionModalState();
}

class _CourseSelectionModalState extends State<_CourseSelectionModal> {
  final Set<int> _selectedCourseIds = {};

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header with Class Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.text2Light.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select Courses',
                        style: AppTextStyles.normal600(
                          fontSize: 20,
                          color: AppColors.text2Light,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.text2Light,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Selected Classes Display - Clickable to change
                InkWell(
                  onTap: () {
                    final currentClassIds =
                        widget.selectedClasses.map((c) => c.id).toList();
                    widget.onChangeClasses(currentClassIds);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.text2Light.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assigning to:',
                                style: AppTextStyles.normal500(
                                  fontSize: 12,
                                  color: Colors.grey[600]!,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.selectedClasses.map((classItem) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.text2Light.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      classItem.className,
                                      style: AppTextStyles.normal500(
                                        fontSize: 12,
                                        color: AppColors.text2Light,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit,
                          color: AppColors.text2Light,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Courses List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courseProvider.courses.length,
              itemBuilder: (context, index) {
                final course = courseProvider.courses[index];
                final isSelected = _selectedCourseIds.contains(course.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.text2Light.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.text2Light
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCourseIds.remove(course.id);
                        } else {
                          _selectedCourseIds.add(course.id);
                        }
                      });
                    },
                    title: Text(
                      course.courseName,
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: isSelected ? AppColors.text2Light : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      course.courseCode,
                      style: AppTextStyles.normal400(
                        fontSize: 14,
                        color: Colors.grey[600]!,
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.text2Light,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          // Assign Button
          if (_selectedCourseIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: Consumer<AssignCourseProvider>(
                  builder: (context, provider, _) => ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            // Create assignments for each combination of selected courses and classes
                            final assignments = <Map<String, int>>[];
                            for (final courseId in _selectedCourseIds) {
                              for (final classItem in widget.selectedClasses) {
                                assignments.add({
                                  'course_id': courseId,
                                  'class_id': classItem.id,
                                });
                              }
                            }

                            final payload = {
                              'year': widget.academicYear,
                              'term': widget.academicTerm,
                              'staff_id': int.parse(widget.staffId),
                              'courses': assignments,
                            };

                            final success = await provider.AssignCourse(payload);
                            if (success) {
                              widget.onAssignmentComplete();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Successfully assigned ${_selectedCourseIds.length} ${_selectedCourseIds.length == 1 ? 'course' : 'courses'} to ${widget.selectedClasses.length} ${widget.selectedClasses.length == 1 ? 'class' : 'classes'}',
                                  ),
                                  backgroundColor: AppColors.attCheckColor2,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error assigning courses'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.text2Light,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Assign (${_selectedCourseIds.length} ${_selectedCourseIds.length == 1 ? 'Course' : 'Courses'})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}