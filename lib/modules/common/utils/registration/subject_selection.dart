import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';

class SubjectSelection extends StatefulWidget {
  // Add callback function to pass selected courses data
  final Function(List<Map<String, dynamic>>) onCoursesSelected;
  // Add parameter for pre-registered courses
  final List<Map<String, dynamic>> preRegisteredCourses;

  const SubjectSelection({
    super.key,
    required this.onCoursesSelected,
    this.preRegisteredCourses = const [],
  });

  @override
  _SubjectSelectionState createState() => _SubjectSelectionState();
}

class _SubjectSelectionState extends State<SubjectSelection> {
  // Map to keep track of selected courses with ID and name
  final Map<int, String> _selectedCourses = {};

  @override
  void initState() {
    super.initState();
    
    // Pre-populate selected courses with registered courses
    _initializeSelectedCourses();
  }

  void _initializeSelectedCourses() {
    // Clear existing selections
    _selectedCourses.clear();
    
    // Add pre-registered courses to selected courses
    for (var registeredCourse in widget.preRegisteredCourses) {
      final int courseId = registeredCourse['id'] is int 
          ? registeredCourse['id'] 
          : int.parse(registeredCourse['id'].toString());
      final String courseName = registeredCourse['course_name']?.toString() ?? 'Unknown Course';
      
      _selectedCourses[courseId] = courseName;
    }
    
    // Immediately notify parent of pre-selected courses
    if (_selectedCourses.isNotEmpty) {
      final List<Map<String, dynamic>> selectedCoursesList = _selectedCourses.entries
          .map((entry) => <String, dynamic>{
                "id": entry.key,
                "name": entry.value,
              })
          .toList();
      
      // Delay the callback to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCoursesSelected(selectedCoursesList);
      });
    }
    
    print('Initialized with ${_selectedCourses.length} pre-registered courses: $_selectedCourses');
  }

  @override
  void didUpdateWidget(SubjectSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Re-initialize if pre-registered courses have changed
    if (oldWidget.preRegisteredCourses != widget.preRegisteredCourses) {
      _initializeSelectedCourses();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the AuthProvider to access the course data from Hive
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Get the courses from Hive using the AuthProvider method
    final List<dynamic> rawCourses = authProvider.getCourses();
    
    // Process the raw courses to ensure they are properly typed
    final List<Map<String, dynamic>> courses = rawCourses.map((course) {
      // Convert each course to a properly typed Map<String, dynamic>
      final Map<String, dynamic> typedCourse = Map<String, dynamic>.from(course);
      return typedCourse;
    }).toList();
    
    // If no courses are available, display a message
    if (courses.isEmpty) {
      return const Center(
        child: Text(
          'No courses available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: courses.map((course) {
        // Safely access and convert course id and name 
        final int courseId = course['id'] is int ? course['id'] : int.parse(course['id'].toString());
        final String courseName = course['course_name']?.toString() ?? 'Unknown Course';
        
        // Check if this course is pre-registered (already selected)
        final bool isPreRegistered = _selectedCourses.containsKey(courseId);
        
        return ChoiceChip(
          label: Text(
            courseName,
            style: TextStyle(
              color: _selectedCourses.containsKey(courseId)
                  ? Colors.white
                  : AppColors.videoColor4,
              fontSize: 14,
            ),
          ),
          selected: _selectedCourses.containsKey(courseId),
          onSelected: (isSelected) {
            setState(() {
              if (isSelected) {
                _selectedCourses[courseId] = courseName;
              } else {
                _selectedCourses.remove(courseId);
              }
              
              // Pass the selected courses back to parent with explicit type
              final List<Map<String, dynamic>> selectedCoursesList = _selectedCourses.entries
                  .map((entry) => <String, dynamic>{
                        "id": entry.key,
                        "name": entry.value,
                      })
                  .toList();
              
              widget.onCoursesSelected(selectedCoursesList);
            });
          },
          backgroundColor: Colors.transparent,
          selectedColor: AppColors.videoColor4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.videoColor4),
          ),
        );
      }).toList(),
    );
  }
}

