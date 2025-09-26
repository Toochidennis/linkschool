import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';

class LevelClassManagementScreen extends StatefulWidget {
  const LevelClassManagementScreen({super.key});

  @override
  State<LevelClassManagementScreen> createState() => _LevelClassManagementScreenState();
}

class _LevelClassManagementScreenState extends State<LevelClassManagementScreen> {
  Map<String, List<String>> levelClasses = {
    'JSS1': ['JSS1A', 'JSS1B', 'JSS1C'],
    'JSS2': ['JSS2A', 'JSS2B', 'JSS2C'],
    'JSS3': ['JSS3A', 'JSS3B', 'JSS3C'],
    'SSS1': ['SSS1A', 'SSS1B', 'SSS1C'],
    'SSS2': ['SSS2A', 'SSS2B', 'SSS2C'],
    'SSS3': ['SSS3A', 'SSS3B', 'SSS3C'],
  };

  void _showAddLevelDialog() {
    final levelController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Level'),
        content: TextField(
          controller: levelController,
          decoration: const InputDecoration(
            labelText: 'Level Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (levelController.text.isNotEmpty) {
                setState(() {
                  levelClasses[levelController.text] = [];
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Level added successfully')),
                );
              }
            },
            child: const Text('Add Level'),
          ),
        ],
      ),
    );
  }

  void _showAddClassDialog(String level) {
    final classController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Class to $level'),
        content: TextField(
          controller: classController,
          decoration: const InputDecoration(
            labelText: 'Class Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (classController.text.isNotEmpty) {
                setState(() {
                  levelClasses[level]!.add(classController.text);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class added successfully')),
                );
              }
            },
            child: const Text('Add Class'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Levels & Classes'),
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: levelClasses.keys.length,
          itemBuilder: (context, index) {
            final level = levelClasses.keys.elementAt(index);
            final classes = levelClasses[level]!;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(level, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${classes.length} classes'),
                children: [
                  ...classes.map((className) => ListTile(
                    title: Text(className),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          levelClasses[level]!.remove(className);
                        });
                      },
                    ),
                  )),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add Class'),
                    onTap: () => _showAddClassDialog(level),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLevelDialog,
        backgroundColor: AppColors.text2Light,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}