import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/admin/home/level_class_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/model/admin/home/level_class_model.dart';

class LevelClassManagementScreen extends StatefulWidget {
  const LevelClassManagementScreen({super.key});

  @override
  State<LevelClassManagementScreen> createState() =>
      _LevelClassManagementScreenState();
}

class _LevelClassManagementScreenState
    extends State<LevelClassManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LevelClassProvider>(context, listen: false);
      provider.fetchLevels().then((_) {
        if (provider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to load levels'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    });
  }

  void _showAddLevelDialog({Levels? levelToEdit}) {
    final levelController = TextEditingController(text: levelToEdit?.levelName);
    String? schoolType = levelToEdit?.schoolType.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(levelToEdit == null ? 'Add New Level' : 'Edit Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: levelController,
              decoration: const InputDecoration(
                labelText: 'Level Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'School Type',
                border: OutlineInputBorder(),
              ),
              value: schoolType,
              items: ['nursery', 'primary', 'secondary'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                schoolType = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<LevelClassProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (levelController.text.isNotEmpty &&
                          schoolType != null) {
                        final levelData = {
                          'level_name': levelController.text,
                          'school_type': schoolType,
                          //  'rank': 0, // Default or adjust as needed
                        };
                        final success = levelToEdit == null
                            ? await provider.createLevel(levelData)
                            : await provider.updateLevel(
                                levelToEdit.id.toString(), levelData);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? (provider.message ??
                                      (levelToEdit == null
                                          ? 'Level added successfully'
                                          : 'Level updated successfully'))
                                  : (provider.error ??
                                      (levelToEdit == null
                                          ? 'Failed to add level'
                                          : 'Failed to update level')),
                            ),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
              child: provider.isLoading
                  ? const CircularProgressIndicator()
                  : Text(levelToEdit == null ? 'Add Level' : 'Update Level'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddClassDialog(Levels level, {Class? classToEdit}) {
    final classController = TextEditingController(text: classToEdit?.className);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(classToEdit == null
            ? 'Add Class to ${level.levelName}'
            : 'Edit Class'),
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
          Consumer<LevelClassProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (classController.text.isNotEmpty) {
                        final classData = {
                          'class_name': classController.text,
                          'level_id': level.id,
                          'result_template': classToEdit?.resultTemplate == null
                              ? ""
                              : classToEdit!.resultTemplate,
                          'form_teacher_ids': classToEdit?.formTeacherIds ?? [],
                        };
                        final success = classToEdit == null
                            ? await provider.createClass(classData)
                            : await provider.updateClass(
                                classToEdit.id.toString(), classData);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? (provider.message ??
                                      (classToEdit == null
                                          ? 'Class added successfully'
                                          : 'Class updated successfully'))
                                  : (provider.error ??
                                      (classToEdit == null
                                          ? 'Failed to add class'
                                          : 'Failed to update class')),
                            ),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
              child: provider.isLoading
                  ? const CircularProgressIndicator()
                  : Text(classToEdit == null ? 'Add Class' : 'Update Class'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteLevelConfirmation(Levels level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Level'),
        content: Text('Are you sure you want to delete ${level.levelName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<LevelClassProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final success =
                          await provider.deleteLevel(level.id.toString());
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? (provider.message ??
                                    'Level deleted successfully')
                                : (provider.error ?? 'Failed to delete level'),
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
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

  void _showDeleteClassConfirmation(Levels level, Class classItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content:
            Text('Are you sure you want to delete ${classItem.className}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<LevelClassProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final success =
                          await provider.deleteClass(classItem.id.toString());
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? (provider.message ??
                                    'Class deleted successfully')
                                : (provider.error ?? 'Failed to delete class'),
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelClassProvider>(
      builder: (context, provider, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Manage Levels & Classes'),
          backgroundColor: AppColors.text2Light,
          foregroundColor: Colors.white,
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                decoration: Constants.customBoxDecoration(context),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.levelsWithClasses.length,
                  itemBuilder: (context, index) {
                    final levelWithClasses = provider.levelsWithClasses[index];
                    final level = levelWithClasses.level;
                    final classes = levelWithClasses.classes;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          level.levelName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${classes.length} classes'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddLevelDialog(levelToEdit: level);
                            } else if (value == 'delete') {
                              _showDeleteLevelConfirmation(level);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                        children: [
                          ...classes.map((classItem) => ListTile(
                                title: Text(classItem.className),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showAddClassDialog(level,
                                          classToEdit: classItem);
                                    } else if (value == 'delete') {
                                      _showDeleteClassConfirmation(
                                          level, classItem);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
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
          onPressed: () => _showAddLevelDialog(),
          backgroundColor: AppColors.text2Light,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
