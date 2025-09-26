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

  void _showAddCourseDialog() {
    final nameController = TextEditingController();
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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: dialogLevel,
                  decoration: const InputDecoration(
                    labelText: 'Level',
                    border: OutlineInputBorder(),
                  ),
                  items: levels.map((level) => DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      dialogLevel = value;
                      dialogClass = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        backgroundColor: AppColors.text2Light,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}