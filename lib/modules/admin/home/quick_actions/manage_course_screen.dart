import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  List<Map<String, dynamic>> courses = [
    {'name': 'Mathematics', 'level': 'JSS1', 'class': 'JSS1A', 'id': 'MTH001'},
    {'name': 'English Language', 'level': 'JSS1', 'class': 'JSS1A', 'id': 'ENG001'},
    {'name': 'Basic Science', 'level': 'JSS1', 'class': 'JSS1B', 'id': 'BSC001'},
  ];

  void _showAddCourseBottomSheet() {
    final nameController = TextEditingController();
    final courseCodeController = TextEditingController();

    String? dialogLevel;
    String? dialogClass;
    final levels = ['JSS1', 'JSS2', 'JSS3', 'SSS1', 'SSS2', 'SSS3'];
    final classesPerLevel = {
      'JSS1': ['JSS1A', 'JSS1B', 'JSS1C'],
      'JSS2': ['JSS2A', 'JSS2B', 'JSS2C'],
      'JSS3': ['JSS3A', 'JSS3B', 'JSS3C'],
      'SSS1': ['SSS1A', 'SSS1B', 'SSS1C'],
      'SSS2': ['SSS2A', 'SSS2B', 'SSS2C'],
      'SSS3': ['SSS3A', 'SSS3B', 'SSS3C'],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                const Text(
                  'Add New Course',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Course name field
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Level dropdown
                TextField(
                  controller: courseCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Course code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Class dropdown
                DropdownButtonFormField<String>(
                  value: dialogClass,
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    border: OutlineInputBorder(),
                  ),
                  items: dialogLevel == null
                      ? []
                      : classesPerLevel[dialogLevel]!.map((cls) => DropdownMenuItem(
                    value: cls,
                    child: Text(cls),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      dialogClass = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty &&
                              dialogLevel != null &&
                              dialogClass != null) {
                            setState(() {
                              courses.add({
                                'name': nameController.text,
                                'level': dialogLevel!,
                                'class': dialogClass!,
                                'id': 'CRS${(courses.length + 1).toString().padLeft(3, '0')}',
                              });
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Course added successfully')),
                            );
                          }
                        },
                        child: const Text('Add Course'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.attCheckColor2,
                  child: const Icon(Icons.book, color: Colors.white),
                ),
                title: Text(course['name']),
                subtitle: Text('${course['level']} - ${course['class']} | ID: ${course['id']}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Course'),
                          content: Text('Are you sure you want to delete ${course['name']}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  courses.removeAt(index);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCourseBottomSheet,
        backgroundColor: AppColors.text2Light,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Course',
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