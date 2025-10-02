import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkschool/modules/admin/home/portal_news_item.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';


// Manage Students Screen
class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  String? selectedLevel;
  String? selectedClass;
  List<String> levels = ['JSS1', 'JSS2', 'JSS3', 'SSS1', 'SSS2', 'SSS3'];
  Map<String, List<String>> classesPerLevel = {
    'JSS1': ['JSS1A', 'JSS1B', 'JSS1C'],
    'JSS2': ['JSS2A', 'JSS2B', 'JSS2C'],
    'JSS3': ['JSS3A', 'JSS3B', 'JSS3C'],
    'SSS1': ['SSS1A', 'SSS1B', 'SSS1C'],
    'SSS2': ['SSS2A', 'SSS2B', 'SSS2C'],
    'SSS3': ['SSS3A', 'SSS3B', 'SSS3C'],
  };

  List<Map<String, String>> students = [
    {'name': 'Sarah Johnson', 'level': 'JSS1', 'class': 'JSS1A', 'id': '001'},
    {'name': 'Michael Chen', 'level': 'JSS1', 'class': 'JSS1A', 'id': '002'},
    {'name': 'Emma Davis', 'level': 'JSS1', 'class': 'JSS1B', 'id': '003'},
    {'name': 'David Wilson', 'level': 'JSS2', 'class': 'JSS2A', 'id': '004'},
    {'name': 'Lisa Brown', 'level': 'JSS2', 'class': 'JSS2B', 'id': '005'},
  ];

  List<Map<String, String>> get filteredStudents {
    return students.where((student) {
      bool levelMatch = selectedLevel == null || student['level'] == selectedLevel;
      bool classMatch = selectedClass == null || student['class'] == selectedClass;
      return levelMatch && classMatch;
    }).toList();
  }

  void _showAddStudentBottomSheet() {
    final nameController = TextEditingController();
    String? dialogLevel;
    String? dialogClass;

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
                  'Add New Student',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Name field
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Level dropdown
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
                              students.add({
                                'name': nameController.text,
                                'level': dialogLevel!,
                                'class': dialogClass!,
                                'id': (students.length + 1).toString().padLeft(3, '0'),
                              });
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Student added successfully')),
                            );
                          }
                        },
                        child: const Text('Add Student'),
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

  void _showEditStudentDialog(Map<String, String> student, int index) {
    final nameController = TextEditingController(text: student['name']);
    String? dialogLevel = student['level'];
    String? dialogClass = student['class'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
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
                      dialogClass = classesPerLevel[value]?.first;
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
                    students[index] = {
                      'name': nameController.text,
                      'level': dialogLevel!,
                      'class': dialogClass!,
                      'id': student['id']!,
                    };
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Student updated successfully')),
                  );
                }
              },
              child: const Text('Update'),
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
        title: const Text('Manage Students'),
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedLevel,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Level',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Levels'),
                        ),
                        ...levels.map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedLevel = value;
                          if (value == null) selectedClass = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Class',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Classes'),
                        ),
                        if (selectedLevel != null)
                          ...classesPerLevel[selectedLevel]!.map((cls) => DropdownMenuItem(
                            value: cls,
                            child: Text(cls),
                          )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedClass = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Students List
            Expanded(
              child: filteredStudents.isEmpty
                ? const Center(
                    child: Text('No students found'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final originalIndex = students.indexOf(student);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.text2Light,
                            child: Text(
                              student['name']!.substring(0, 2).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(student['name']!),
                          subtitle: Text('${student['level']} - ${student['class']} | ID: ${student['id']}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditStudentDialog(student, originalIndex);
                              } else if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Student'),
                                    content: Text('Are you sure you want to delete ${student['name']}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            students.removeAt(originalIndex);
                                          });
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Student deleted successfully')),
                                          );
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentBottomSheet,
        backgroundColor: AppColors.text2Light,

        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Student',
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
