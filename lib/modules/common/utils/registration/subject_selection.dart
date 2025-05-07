import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';

class SubjectSelection extends StatefulWidget {
  // Add callback function to pass selected courses data
  final Function(List<Map<String, dynamic>>) onCoursesSelected;

  const SubjectSelection({
    super.key,
    required this.onCoursesSelected,
  });

  @override
  _SubjectSelectionState createState() => _SubjectSelectionState();
}

class _SubjectSelectionState extends State<SubjectSelection> {
  // Map to keep track of selected courses with ID and name
  final Map<int, String> _selectedCourses = {};

  @override
  Widget build(BuildContext context) {
    // Get the AuthProvider to access the course data from Hive
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Get the courses from Hive using the AuthProvider method
    final courses = authProvider.getCourses();
    
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
        final int courseId = course['id'] as int;
        final String courseName = course['course_name'] as String;
        
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
              
              // Pass the selected courses back to parent
              final List<Map<String, dynamic>> selectedCoursesList = _selectedCourses.entries
                  .map((entry) => {
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


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';

// class SubjectSelection extends StatefulWidget {
//   const SubjectSelection({super.key});

//   @override
//   _SubjectSelectionState createState() => _SubjectSelectionState();
// }

// class _SubjectSelectionState extends State<SubjectSelection> {
//   // Set to keep track of selected subjects
//   final Set<String> _selectedSubjects = {};

//   @override
//   Widget build(BuildContext context) {
//     List<String> allSubjects = [
//       'Mathematics',
//       'English',
//       'Physics',
//       'Chemistry',
//       'Biology',
//       'History',
//       'Geography',
//       'Literature',
//       'Economics',
//       'Government',
//       'French',
//       'Computer Science',
//       'Fine Arts',
//       'Music',
//       'Physical Education'
//     ];
//     allSubjects.shuffle();

//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: allSubjects.map((subject) {
//         return ChoiceChip(
//           label: Text(
//             subject,
//             style: TextStyle(
//               color: _selectedSubjects.contains(subject)
//                   ? Colors.white
//                   : AppColors.videoColor4,
//               fontSize: 14,
//             ),
//           ),
//           selected: _selectedSubjects.contains(subject),
//           onSelected: (isSelected) {
//             setState(() {
//               if (isSelected) {
//                 _selectedSubjects.add(subject);
//               } else {
//                 _selectedSubjects.remove(subject);
//               }
//             });
//           },
//           backgroundColor: Colors.transparent,
//           selectedColor: AppColors.videoColor4, // Highlight color when selected
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//             side: BorderSide(color: AppColors.videoColor4),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }