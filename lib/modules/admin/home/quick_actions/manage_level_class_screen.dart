import 'package:flutter/material.dart';
import 'package:linkschool/modules/providers/admin/home/level_class_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/home/level_class_model.dart';

class LevelClassManagementScreen extends StatefulWidget {
  const LevelClassManagementScreen({super.key});

  @override
  State<LevelClassManagementScreen> createState() =>
      _LevelClassManagementScreenState();
}

class _LevelClassManagementScreenState
    extends State<LevelClassManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LevelWithClasses> _filteredLevels = [];
  bool _isSearching = false;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLevels(String query, List<LevelWithClasses> allLevels) {
    if (query.isEmpty) {
      setState(() {
        _filteredLevels = [];
        _isSearching = false;
      });
    } else {
      final filtered = allLevels.where((levelWithClasses) {
        final levelName = levelWithClasses.level.levelName.toLowerCase();
        final schoolType = levelWithClasses.level.schoolType.toLowerCase();
        final searchLower = query.toLowerCase();
        
        // Search in level name and school type
        final levelMatch = levelName.contains(searchLower) || 
                           schoolType.contains(searchLower);
        
        // Search in class names
        final classMatch = levelWithClasses.classes.any((classItem) =>
            classItem.className.toLowerCase().contains(searchLower));
        
        return levelMatch || classMatch;
      }).toList();
      
      setState(() {
        _isSearching = true;
        _filteredLevels = filtered;
      });
    }
  }

  Widget _buildSearchBar(List<LevelWithClasses> allLevels) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _filterLevels(value, allLevels),
        decoration: InputDecoration(
          hintText: 'Search levels or classes...',
          hintStyle: TextStyle(
            color: AppColors.text7Light,
            fontSize: 14,
            fontFamily: 'Urbanist',
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.text2Light,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.text7Light,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _filterLevels('', allLevels);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<LevelWithClasses> levels) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${levels.length} result${levels.length != 1 ? 's' : ''} found',
                  style: AppTextStyles.normal600(
                    fontSize: 16,
                    color: AppColors.text2Light,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: levels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.text7Light,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No levels or classes found',
                          style: AppTextStyles.normal500(
                            fontSize: 16,
                            color: AppColors.text7Light,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: AppTextStyles.normal400(
                            fontSize: 14,
                            color: AppColors.text9Light,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final levelWithClasses = levels[index];
                      final level = levelWithClasses.level;
                      final classes = levelWithClasses.classes;
                      return _buildLevelCard(level, classes);
                    },
                  ),
          ),
        ],
      ),
    );
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
              initialValue: schoolType,
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
          title: const Text(
            'Manage Levels & Classes',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Urbanist',
            ),
          ),
          backgroundColor: AppColors.text2Light,
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isSearching
                ? Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildSearchBar(provider.levelsWithClasses),
                        Expanded(
                          child: _buildSearchResults(_filteredLevels),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: Constants.customBoxDecoration(context),
                    child: Column(
                      children: [
                        _buildSearchBar(provider.levelsWithClasses),
                        Expanded(
                          child: provider.levelsWithClasses.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.school_outlined,
                                        size: 80,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No Levels Yet',
                                        style: AppTextStyles.normal600(
                                          fontSize: 18,
                                          color: Colors.grey[600]!,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap the + button to add a level',
                                        style: AppTextStyles.normal400(
                                          fontSize: 14,
                                          color: Colors.grey[500]!,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: provider.levelsWithClasses.length,
                                  itemBuilder: (context, index) {
                                    final levelWithClasses =
                                        provider.levelsWithClasses[index];
                                    final level = levelWithClasses.level;
                                    final classes = levelWithClasses.classes;

                                    return _buildLevelCard(level, classes);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddLevelDialog(),
          backgroundColor: AppColors.text2Light,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Level',
            style: TextStyle(
              fontFamily: 'Urbanist',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(Levels level, List<Class> classes) {
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
          // Level Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.text2Light.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.text2Light.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school,
                    color: AppColors.text2Light,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.levelName,
                        style: AppTextStyles.normal600(
                          fontSize: 18,
                          color: AppColors.text2Light,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.text2Light.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              level.schoolType.toUpperCase(),
                              style: AppTextStyles.normal500(
                                fontSize: 11,
                                color: AppColors.text2Light,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${classes.length} ${classes.length == 1 ? 'Class' : 'Classes'}',
                            style: AppTextStyles.normal400(
                              fontSize: 14,
                              color: Colors.grey[600]!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.text2Light.withOpacity(0.1),
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
                      _showAddLevelDialog(levelToEdit: level);
                    } else if (value == 'delete') {
                      _showDeleteLevelConfirmation(level);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, size: 20),
                        title: Text('Edit Level'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red, size: 20),
                        title: Text('Delete Level',
                            style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Classes List
          if (classes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No classes yet',
                    style: AppTextStyles.normal400(
                      fontSize: 14,
                      color: Colors.grey[500]!,
                    ),
                  ),
                ],
              ),
            )
          else
            ...classes.asMap().entries.map((entry) {
              final index = entry.key;
              final classItem = entry.value;
              final isLast = index == classes.length - 1;

              return Column(
                children: [
                  _buildClassTile(level, classItem),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[100],
                      indent: 72,
                      endIndent: 20,
                    ),
                ],
              );
            }),

          // Add Class Button
          InkWell(
            onTap: () => _showAddClassDialog(level),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.text2Light.withOpacity(0.02),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AppColors.text2Light,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Class',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: AppColors.text2Light,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassTile(Levels level, Class classItem) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.text2Light.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.class_,
          color: AppColors.text2Light,
          size: 20,
        ),
      ),
      title: Text(
        classItem.className,
        style: AppTextStyles.normal500(
          fontSize: 16,
          color: AppColors.text2Light,
        ),
      ),
      subtitle: classItem.formTeacherIds.isNotEmpty
          ? Text(
              '${classItem.formTeacherIds.length} Form Teacher${classItem.formTeacherIds.length > 1 ? 's' : ''}',
              style: AppTextStyles.normal400(
                fontSize: 14,
                color: Colors.grey[600]!,
              ),
            )
          : null,
      trailing: PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.text2Light.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.more_horiz,
            color: AppColors.text2Light,
            size: 18,
          ),
        ),
        onSelected: (value) {
          if (value == 'edit') {
            _showAddClassDialog(level, classToEdit: classItem);
          } else if (value == 'delete') {
            _showDeleteClassConfirmation(level, classItem);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit, size: 18),
              title: Text('Edit'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete, color: Colors.red, size: 18),
              title: Text('Delete', style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }
}
