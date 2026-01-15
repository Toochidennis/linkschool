import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkschool/modules/admin/home/quick_actions/student_details.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/home/level_class_model.dart';
import 'package:linkschool/modules/model/admin/home/manage_student_model.dart';
import 'package:linkschool/modules/providers/admin/home/level_class_provider.dart';
import 'package:linkschool/modules/providers/admin/home/manage_student_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class ManageStudentsScreen extends StatefulWidget {
  final int? levelId;
  final int? classId;
  
  const ManageStudentsScreen({super.key, this.levelId, this.classId});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  int? selectedLevelId;
  int? selectedClassId;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentProvider = Provider.of<ManageStudentProvider>(context, listen: false);
      
      if (widget.classId != null) {
        // Fetch students by class with pagination
        studentProvider.fetchStudentsByClass(classId: widget.classId!);
        selectedClassId = widget.classId;
      } else if (widget.levelId != null) {
        // Fetch students by level with pagination
        studentProvider.fetchStudentsByLevel(levelId: widget.levelId!);
        selectedLevelId = widget.levelId;
      } else {
        // Fetch all students (old behavior)
        studentProvider.fetchStudents();
      }
      
      Provider.of<LevelClassProvider>(context, listen: false).fetchLevels();
    });
    print("Init ManageStudentsScreen with levelId: ${widget.levelId}, classId: ${widget.classId}");
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final studentProvider = Provider.of<ManageStudentProvider>(context, listen: false);
      if (!studentProvider.isLoadingMore && studentProvider.hasMore) {
        studentProvider.loadMoreStudents();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Students> get filteredStudents {
    final provider = Provider.of<ManageStudentProvider>(context);
    
    // Get the base list of students
    List<Students> baseList;
    
    // If using level-based pagination, return students directly
    if (widget.levelId != null) {
      // Only filter by class if selected
      if (selectedClassId != null) {
        baseList = provider.students.where((student) => student.classId == selectedClassId).toList();
      } else {
        baseList = provider.students;
      }
    } else {
      // Original filtering for all students view
      baseList = provider.students.where((student) {
        bool levelMatch =
            selectedLevelId == null || student.levelId == selectedLevelId;
        bool classMatch =
            selectedClassId == null || student.classId == selectedClassId;
        return levelMatch && classMatch;
      }).toList();
    }
    
    // Apply search filter if there's a search query
    if (_searchQuery.isNotEmpty) {
      baseList = baseList.where((student) {
        final fullName = '${student.firstName} ${student.surname} ${student.middle}'.toLowerCase();
        final registrationNo = (student.registrationNo ?? student.id.toString()).toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return fullName.contains(query) || registrationNo.contains(query);
      }).toList();
    }
    
    return baseList;
  }

  bool _showAddForm = false;
  Students? _editingStudent;

  void _showAddEditStudentForm({Students? student}) {
    setState(() {
      _showAddForm = true;
      _editingStudent = student;
    });
  }

  // Get the pre-selected level and class IDs for new student form
  int? get preSelectedLevelId => selectedLevelId;
  int? get preSelectedClassId => selectedClassId;

  void _hideForm() {
    setState(() {
      _showAddForm = false;
      _editingStudent = null;
    });
  }

  void _showLevelFilterModal(BuildContext context, LevelClassProvider levelClassProvider) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Level',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.text3Light,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildModalFilterItem(
                      label: '',
                      isSelected: selectedLevelId == null,
                      onTap: () {
                        setState(() {
                          selectedLevelId = null;
                          selectedClassId = null;
                        });
                        // Fetch all students when "All Levels" is selected
                        Provider.of<ManageStudentProvider>(context, listen: false)
                            .fetchStudents();
                        Navigator.pop(context);
                      },
                    ),
                    ...levelClassProvider.levelsWithClasses.map((levelWithClasses) {
                      final isSelected = selectedLevelId == levelWithClasses.level.id;
                      return _buildModalFilterItem(
                        label: levelWithClasses.level.levelName,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedLevelId = levelWithClasses.level.id;
                            selectedClassId = null;
                          });
                          // Fetch students by the selected level with pagination
                          Provider.of<ManageStudentProvider>(context, listen: false)
                              .fetchStudentsByLevel(levelId: levelWithClasses.level.id);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClassFilterModal(BuildContext context, LevelClassProvider levelClassProvider) {
    if (selectedLevelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a level first')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final classes = levelClassProvider.levelsWithClasses
            .firstWhere((lwc) => lwc.level.id == selectedLevelId)
            .classes;

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Class',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.text3Light,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildModalFilterItem(
                      label: 'All Classes',
                      isSelected: selectedClassId == null,
                      onTap: () {
                        setState(() {
                          selectedClassId = null;
                          // Keep the level selected when showing all classes
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ...classes.map((cls) {
                      final isSelected = selectedClassId == cls.id;
                      return _buildModalFilterItem(
                        label: cls.className,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedClassId = cls.id;
                            // Ensure the level is set to the class's level
                            selectedLevelId ??= cls.levelId;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalFilterItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.text2Light.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.normal500(
                fontSize: 15,
                color: isSelected ? AppColors.text2Light : Colors.grey[800]!,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.text2Light,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<ManageStudentProvider>(context);
    final levelClassProvider = Provider.of<LevelClassProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: _showAddForm ? null : null,
        automaticallyImplyLeading: !_showAddForm,
        title: const Text('Manage Students',style: TextStyle(
          fontFamily: 'Urbanist',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),),
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
        actions: [
          if (_showAddForm)
            IconButton(
              onPressed: _hideForm,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: Stack(
        children: [
          studentProvider.isLoading || levelClassProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                 // decoration: Constants.customBoxDecoration(context),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        if (_showAddForm)
                          StudentFormWidget(
                            student: _editingStudent,
                            onCancel: _hideForm,
                            onSaved: _hideForm,
                            preSelectedLevelId: preSelectedLevelId,
                            preSelectedClassId: preSelectedClassId,
                          )
                        else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                            ),
                            child: Column(
                              children: [
                                // Search Bar
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                        _isSearching = value.isNotEmpty;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search by name or registration number...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: AppColors.text2Light,
                                      ),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                color: Colors.grey[600],
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _searchController.clear();
                                                  _searchQuery = '';
                                                  _isSearching = false;
                                                });
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Level Filter Button
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _showLevelFilterModal(context, levelClassProvider),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  selectedLevelId == null
                                                      ? 'All Levels'
                                                      : levelClassProvider.levelsWithClasses
                                                          .firstWhere(
                                                            (lwc) => lwc.level.id == selectedLevelId,
                                                            orElse: () => LevelWithClasses(
                                                              level: Levels(
                                                                id: 0,
                                                                levelName: 'All Levels',
                                                                schoolType: '',
                                                                rank: 0,
                                                                admit: 0,
                                                              ),
                                                              classes: [],
                                                            ),
                                                          )
                                                          .level
                                                          .levelName,
                                                  style: AppTextStyles.normal500(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]!,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.grey[600],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Class Filter Button
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _showClassFilterModal(context, levelClassProvider),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: AppColors.text2Light.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                                color: AppColors.text2Light.withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  selectedClassId == null
                                                      ? 'All Classes'
                                                      : (selectedLevelId != null
                                                          ? levelClassProvider.levelsWithClasses
                                                              .firstWhere(
                                                                (lwc) => lwc.level.id == selectedLevelId,
                                                              )
                                                              .classes
                                                              .firstWhere(
                                                                (cls) => cls.id == selectedClassId,
                                                                orElse: () => Class(
                                                                  id: 0,
                                                                  className: 'All Classes',
                                                                  levelId: 0,
                                                                  formTeacherIds: [],
                                                                ),
                                                              )
                                                              .className
                                                          : 'All Classes'),
                                                  style: AppTextStyles.normal500(
                                                    fontSize: 14,
                                                    color: AppColors.text2Light,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_drop_down,
                                                color: AppColors.text2Light,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    label: 'Male\nStudents',
                                    icon: Icons.male,
                                    iconColor: const Color.fromRGBO(45, 99, 255, 1),
                                    count: studentProvider.maleStudents.toString(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.female,
                                    iconColor: Colors.pink,
                                    count: studentProvider.femaleStudents.toString(),
                                    label: 'Female\nStudents',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          filteredStudents.isEmpty
                              ? Center(
                                  child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(_searchQuery.isNotEmpty 
                                    ? 'No students found matching "$_searchQuery"'
                                    : 'No students found'),
                                ))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredStudents.length,
                                  itemBuilder: (context, index) {
                                    final student = filteredStudents[index];
                                    final levelName =
                                        levelClassProvider.levelsWithClasses
                                            .firstWhere(
                                              (lwc) =>
                                                  lwc.level.id == student.levelId,
                                              orElse: () => LevelWithClasses(
                                                level: Levels(
                                                  id: 0,
                                                  levelName: 'Unknown',
                                                  schoolType: '',
                                                  rank: 0,
                                                  admit: 0,
                                                ),
                                                classes: [],
                                              ),
                                            )
                                            .level
                                            .levelName;
                                    final className =
                                        levelClassProvider.levelsWithClasses
                                            .firstWhere(
                                              (lwc) =>
                                                  lwc.level.id == student.levelId,
                                              orElse: () => LevelWithClasses(
                                                level: Levels(
                                                  id: 0,
                                                  levelName: 'Unknown',
                                                  schoolType: '',
                                                  rank: 0,
                                                  admit: 0,
                                                ),
                                                classes: [],
                                              ),
                                            )
                                            .classes
                                            .firstWhere(
                                              (cls) => cls.id == student.classId,
                                              orElse: () => Class(
                                                id: 0,
                                                className: 'Unknown',
                                                levelId: 0,
                                                formTeacherIds: [],
                                              ),
                                            )
                                            .className;

                                    return GestureDetector(
                                      onTap: () {
                                        final fullName =
                                            '${student.firstName} ${student.surname}';
                                        print(fullName);
                                        print(student.levelId);
                                        print(className);
                                        print(student.classId);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StudentProfileScreen(
                                              student: student,
                                              classId: student.classId.toString(),
                                              levelId: student.levelId,
                                              className: className,
                                              studentName: fullName,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
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
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          leading: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: AppColors.text2Light.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: CircleAvatar(
                                              radius: 24,
                                              backgroundColor: AppColors.text2Light,
                                              child: student.photoPath != null &&
                                                      student.photoPath!.isNotEmpty
                                                  ? ClipOval(
                                                      child: Image.network(
                                                        "https://linkskool.net/${student.photoPath}",
                                                        fit: BoxFit.cover,
                                                        width: 48,
                                                        height: 48,
                                                        errorBuilder: (context, error,
                                                            stackTrace) {
                                                          return Text(
                                                            student.getInitials(),
                                                            style: AppTextStyles.normal600(
                                                              fontSize: 16,
                                                              color: Colors.white,
                                                            ),
                                                          );
                                                        },
                                                        loadingBuilder: (context,
                                                            child, loadingProgress) {
                                                          if (loadingProgress == null) {
                                                            return child;
                                                          }
                                                          return const SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors.white,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : Text(
                                                      student.getInitials(),
                                                      style: AppTextStyles.normal600(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          title: Text(
                                            '${student.firstName} ${student.surname}',
                                            style: AppTextStyles.normal500(
                                              fontSize: 16,
                                              color: AppColors.text2Light,
                                            ),
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              '$levelName - $className | ID: ${student.registrationNo ?? student.id}',
                                              style: AppTextStyles.normal400(
                                                fontSize: 14,
                                                color: Colors.grey[600]!,
                                              ),
                                            ),
                                          ),
                                          trailing: PopupMenuButton<String>(
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
                                                _showAddEditStudentForm(
                                                    student: student);
                                              } else if (value == 'delete') {
                                                _showDeleteDialog(context, student);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: ListTile(
                                                  leading: Icon(Icons.edit),
                                                  title: Text('Edit'),
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: ListTile(
                                                  leading: Icon(Icons.delete,
                                                      color: Colors.red),
                                                  title: Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          // Loading more indicator
                          if (studentProvider.isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          // Show pagination info if using level-based pagination
                          if (widget.levelId != null && studentProvider.students.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'Showing ${studentProvider.students.length} students | Page ${studentProvider.currentPage} of ${studentProvider.totalPages}',
                                  style: AppTextStyles.normal400(
                                    fontSize: 12,
                                    color: Colors.grey[600]!,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
          // White overlay when searching
          if (_isSearching && _searchQuery.isNotEmpty)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Dismiss overlay when tapping outside
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _isSearching = false;
                  });
                },
                child: Container(
                  color: Colors.white.withOpacity(0.95),
                  child: Column(
                    children: [
                      // Search bar replica for the overlay
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _isSearching = value.isNotEmpty;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search by name or registration number...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.text2Light,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    _isSearching = false;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Search results
                      Expanded(
                        child: filteredStudents.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No students found matching "$_searchQuery"',
                                      style: AppTextStyles.normal400(
                                        fontSize: 14,
                                        color: Colors.grey[600]!,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final student = filteredStudents[index];
                                  final levelName = levelClassProvider.levelsWithClasses
                                      .firstWhere(
                                        (lwc) => lwc.level.id == student.levelId,
                                        orElse: () => LevelWithClasses(
                                          level: Levels(
                                            id: 0,
                                            levelName: 'Unknown',
                                            schoolType: '',
                                            rank: 0,
                                            admit: 0,
                                          ),
                                          classes: [],
                                        ),
                                      )
                                      .level
                                      .levelName;
                                  final className = levelClassProvider.levelsWithClasses
                                      .firstWhere(
                                        (lwc) => lwc.level.id == student.levelId,
                                        orElse: () => LevelWithClasses(
                                          level: Levels(
                                            id: 0,
                                            levelName: 'Unknown',
                                            schoolType: '',
                                            rank: 0,
                                            admit: 0,
                                          ),
                                          classes: [],
                                        ),
                                      )
                                      .classes
                                      .firstWhere(
                                        (cls) => cls.id == student.classId,
                                        orElse: () => Class(
                                          id: 0,
                                          className: 'Unknown',
                                          levelId: 0,
                                          formTeacherIds: [],
                                        ),
                                      )
                                      .className;

                                  return GestureDetector(
                                    onTap: () {
                                      final fullName = '${student.firstName} ${student.surname}';
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentProfileScreen(
                                            student: student,
                                            classId: student.classId.toString(),
                                            levelId: student.levelId,
                                            className: className,
                                            studentName: fullName,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.text2Light.withOpacity(0.2),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        leading: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: AppColors.text2Light.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: CircleAvatar(
                                            radius: 24,
                                            backgroundColor: AppColors.text2Light,
                                            child: student.photoPath != null &&
                                                    student.photoPath!.isNotEmpty
                                                ? ClipOval(
                                                    child: Image.network(
                                                      "https://linkskool.net/${student.photoPath}",
                                                      fit: BoxFit.cover,
                                                      width: 48,
                                                      height: 48,
                                                      errorBuilder:
                                                          (context, error, stackTrace) {
                                                        return Text(
                                                          student.getInitials(),
                                                          style: AppTextStyles.normal600(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      },
                                                      loadingBuilder:
                                                          (context, child, loadingProgress) {
                                                        if (loadingProgress == null) {
                                                          return child;
                                                        }
                                                        return const SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Text(
                                                    student.getInitials(),
                                                    style: AppTextStyles.normal600(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        title: Text(
                                          '${student.firstName} ${student.surname}',
                                          style: AppTextStyles.normal500(
                                            fontSize: 16,
                                            color: AppColors.text2Light,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            '$levelName - $className | ID: ${student.registrationNo ?? student.id}',
                                            style: AppTextStyles.normal400(
                                              fontSize: 14,
                                              color: Colors.grey[600]!,
                                            ),
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !_showAddForm
          ? FloatingActionButton.extended(
              onPressed: _showAddEditStudentForm,
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
            )
          : null,
    );
  }

  void _showDeleteDialog(BuildContext context, Students student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
            'Are you sure you want to delete ${student.firstName} ${student.surname}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<ManageStudentProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final success =
                          await provider.deleteStudent(student.id.toString());
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Student deleted successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                provider.error ?? 'Failed to delete student'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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
}

// Separate StatefulWidget for the form to isolate state management
class StudentFormWidget extends StatefulWidget {
  final Students? student;
  final VoidCallback onCancel;
  final VoidCallback onSaved;
  final int? preSelectedLevelId;
  final int? preSelectedClassId;

  const StudentFormWidget({
    super.key,
    this.student,
    required this.onCancel,
    required this.onSaved,
    this.preSelectedLevelId,
    this.preSelectedClassId,
  });

  @override
  State<StudentFormWidget> createState() => _StudentFormWidgetState();
}

class _StudentFormWidgetState extends State<StudentFormWidget> {
 late final TextEditingController _firstNameController;
  late final TextEditingController _surnameController;
  late final TextEditingController middleNameController;
  late final TextEditingController birthDateController;
  late final TextEditingController addressController;
  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController countryController;
  late final TextEditingController emailController;
  late final TextEditingController religionController;
  late final TextEditingController guardianNameController;
  late final TextEditingController guardianAddressController;
  late final TextEditingController guardianPhoneController;
  late final TextEditingController lgaOriginController;
  late final TextEditingController stateOriginController;
  late final TextEditingController nationalityController;
  late final TextEditingController healthStatusController;
  late final TextEditingController studentStatusController;
  late final TextEditingController pastRecordController;
  late final TextEditingController academicResultController;
  late final TextEditingController registrationNoController;

  String? gender;
  int? dialogLevelId;
  int? dialogClassId;
  File? tempImage;
  String oldFileName = '';

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();

    final student = widget.student;

   
    // Initialize all name controllers with their own values
    _firstNameController = TextEditingController(text: student?.firstName ?? '');
    _surnameController = TextEditingController(text: student?.surname ?? '');
    middleNameController = TextEditingController(text: student?.middle ?? '');
    birthDateController = TextEditingController(text: student?.birthDate ?? '');
    addressController = TextEditingController(text: student?.address ?? '');
    cityController =
        TextEditingController(text: student?.city?.toString() ?? '');
    stateController =
        TextEditingController(text: student?.state?.toString() ?? '');
    countryController =
        TextEditingController(text: student?.country?.toString() ?? '');
    emailController = TextEditingController(text: student?.email ?? '');
    religionController = TextEditingController(text: student?.religion ?? '');
    guardianNameController =
        TextEditingController(text: student?.guardianName ?? '');
    guardianAddressController =
        TextEditingController(text: student?.guardianAddress ?? '');
    guardianPhoneController =
        TextEditingController(text: student?.guardianPhoneNo ?? '');
    lgaOriginController = TextEditingController(text: student?.lgaOrigin ?? '');
    stateOriginController =
        TextEditingController(text: student?.stateOrigin ?? '');
    nationalityController =
        TextEditingController(text: student?.nationality ?? '');
    healthStatusController =
        TextEditingController(text: student?.healthStatus ?? '');
    studentStatusController =
        TextEditingController(text: student?.studentStatus ?? '');
    pastRecordController =
        TextEditingController(text: student?.pastRecord ?? '');
    academicResultController =
        TextEditingController(text: student?.academicResult ?? '');
    registrationNoController =
        TextEditingController(text: student?.registrationNo ?? '');

    gender = student?.gender.isNotEmpty == true
        ? (student!.gender.toLowerCase() == 'f' ? 'female' : 'male')
        : 'male';

    // Use pre-selected values for new students, or student's values when editing
    dialogLevelId = student?.levelId ?? widget.preSelectedLevelId;
    dialogClassId = student?.classId ?? widget.preSelectedClassId;

    if (isEditing &&
        student?.photo != null &&
        (student!.photo is String) &&
        (student.photo as String).isNotEmpty) {
      oldFileName = path.basename(student.photo as String);
    }
  }

  @override
  void dispose() {
        _firstNameController.dispose();
    _surnameController.dispose();
    middleNameController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    emailController.dispose();
    religionController.dispose();
    guardianNameController.dispose();
    guardianAddressController.dispose();
    guardianPhoneController.dispose();
    lgaOriginController.dispose();
    stateOriginController.dispose();
    nationalityController.dispose();
    healthStatusController.dispose();
    studentStatusController.dispose();
    pastRecordController.dispose();
    academicResultController.dispose();
    registrationNoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => tempImage = File(pickedFile.path));
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveStudent() async {
       final firstName = _firstNameController.text.trim();
    final surname = _surnameController.text.trim();
    // Validate full name first
    if (firstName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter first name'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }else if (surname.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter surname'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // validate level and class
    if (dialogLevelId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Level'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }else if (dialogClassId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Class'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

  
    // Validate gender
    if (gender == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Gender'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validate birth date
    if (birthDateController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Birth Date'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final studentProvider =
        Provider.of<ManageStudentProvider>(context, listen: false);

    // Handle photo upload
    String? base64Image;
    String? newFileName;

    if (tempImage != null) {
      final bytes = await tempImage!.readAsBytes();
      base64Image = base64Encode(bytes);
      newFileName = path.basename(tempImage!.path);
    }

    // Build student data
    final studentData = <String, dynamic>{
      'surname': surname,
      'first_name': firstName,
      'middle': middleNameController.text.trim(),
      'gender': gender,
      'birth_date': birthDateController.text.trim(),
      'address': addressController.text.trim(),
      'city': int.tryParse(cityController.text) ?? 0,
      'state': int.tryParse(stateController.text) ?? 0,
      'country': int.tryParse(countryController.text) ?? 0,
      'email': emailController.text.trim(),
      'religion': religionController.text.trim(),
      'guardian_name': guardianNameController.text.trim(),
      'guardian_address': guardianAddressController.text.trim(),
      'guardian_phone_no': guardianPhoneController.text.trim(),
      'lga_origin': lgaOriginController.text.trim(),
      'state_origin': stateOriginController.text.trim(),
      'nationality': nationalityController.text.trim(),
      'health_status': healthStatusController.text.trim(),
      'student_status': studentStatusController.text.trim(),
      'past_record': pastRecordController.text.trim(),
      'academic_result': academicResultController.text.trim(),
      'level_id': dialogLevelId,
      'class_id': dialogClassId,
      'registration_no': registrationNoController.text.trim(),
    };

    // CRITICAL FIX: Always send photo as an object/map structure
    if (tempImage != null && base64Image != null) {
      // New image selected - send with base64
      studentData['photo'] = {
        "file": base64Image,
        "file_name": newFileName,
        "old_file_name": oldFileName.isNotEmpty ? widget.student?.photoPath : "",
      };
    } else if (isEditing) {
      // Editing without new image - send existing path in proper structure
      studentData['photo'] = {
        "file": widget.student?.photoPath ?? "",
        "file_name": oldFileName.isNotEmpty ? widget.student?.photoPath : "",
        "old_file_name": "",
      };
    } else {
      // Creating new student without photo - send empty structure
      studentData['photo'] = {
        "file": "",
        "file_name": "",
        "old_file_name": "",
      };
    }

    bool success;
    if (isEditing) {
      success = await studentProvider.updateStudent(
          widget.student!.id.toString(), studentData);
    } else {
      success = await studentProvider.createStudent(studentData);
    }

    // Check if widget is still mounted before showing snackbar
    if (!mounted) return;

    if (success) {
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Student updated successfully'
              : 'Student added successfully'),
          backgroundColor: AppColors.attCheckColor2,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(studentProvider.error ?? 'Failed to save student'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<ManageStudentProvider>(context);

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.text2Light.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.text2Light.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Edit Student' : 'Add New Student',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.text2Light,
                ),
              ),
             
            ],
          ),
          const SizedBox(height: 16),

          // Image picker
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.textFieldLight,
                backgroundImage: tempImage != null
                    ? FileImage(tempImage!)
                    : (widget.student?.photoPath != null &&
                            widget.student!.photoPath!.isNotEmpty)
                        ? NetworkImage(
                                "https://linkskool.net/${widget.student!.photoPath}")
                            as ImageProvider<Object>
                        : null,
                child: tempImage == null &&
                        (widget.student?.photoPath == null ||
                            widget.student!.photoPath!.isEmpty)
                    ? const Icon(Icons.add_a_photo,
                        color: AppColors.text2Light, size: 40)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Form fields
          _buildTextField(
            controller: _firstNameController,
            label: "Surname First",
            icon: Icons.person,
            hintText: 'e.g., Smith ',
          ),
          const SizedBox(height: 12),
           _buildTextField(
            controller: _surnameController,
            label: 'Surename',
            icon: Icons.person,
            hintText: 'e.g.,  David',
          ),
          const SizedBox(height: 12),
          _buildTextField(
              controller: middleNameController,
              label: 'Middle Name',
              icon: Icons.person_outline),
          const SizedBox(height: 12),

          _buildDropdown(
            label: 'Gender',
            value: gender,
            items: ['male', 'female']
                .map((g) =>
                    DropdownMenuItem(value: g, child: Text(g.capitalize())))
                .toList(),
            onChanged: (val) => setState(() => gender = val),
          ),

          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selectBirthDate,
            child: AbsorbPointer(
              child: _buildTextField(
                controller: birthDateController,
                label: 'Birth Date',
                icon: Icons.cake,
                readOnly: true,
              ),
            ),
          ),

          const SizedBox(height: 12),
          _buildTextField(
              controller: addressController,
              label: 'Address',
              icon: Icons.location_on),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                      controller: cityController,
                      label: 'City ID',
                      icon: Icons.location_city,
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField(
                      controller: stateController,
                      label: 'State ID',
                      icon: Icons.map,
                      keyboardType: TextInputType.number)),
            ],
          ),

          const SizedBox(height: 12),
          _buildTextField(
              controller: countryController,
              label: 'Country ID',
              icon: Icons.flag,
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress),

          const SizedBox(height: 12),
          _buildTextField(
              controller: religionController,
              label: 'Religion',
              icon: Icons.church),
          const SizedBox(height: 12),
          _buildTextField(
              controller: guardianNameController,
              label: 'Guardian Name',
              icon: Icons.person),
          const SizedBox(height: 12),
          _buildTextField(
              controller: guardianAddressController,
              label: 'Guardian Address',
              icon: Icons.home),
          const SizedBox(height: 12),
          _buildTextField(
              controller: guardianPhoneController,
              label: 'Guardian Phone',
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone),

          const SizedBox(height: 12),
          Consumer<LevelClassProvider>(
            builder: (context, provider, _) => _buildDropdown(
              label: 'Level',
              value: dialogLevelId,
              items: provider.levelsWithClasses
                  .map((lvl) => DropdownMenuItem(
                        value: lvl.level.id,
                        child: Text(lvl.level.levelName),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                dialogLevelId = value;
                dialogClassId = null;
              }),
            ),
          ),

          const SizedBox(height: 12),
          Consumer<LevelClassProvider>(
            builder: (context, provider, _) => _buildDropdown(
              label: 'Class',
              value: dialogClassId,
              items: dialogLevelId == null
                  ? []
                  : provider.levelsWithClasses
                      .firstWhere((lvl) => lvl.level.id == dialogLevelId)
                      .classes
                      .map((cls) => DropdownMenuItem(
                          value: cls.id, child: Text(cls.className)))
                      .toList(),
              onChanged: (value) => setState(() => dialogClassId = value),
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: studentProvider.isLoading ? null : _saveStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.text2Light,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: studentProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      isEditing ? 'Update Student' : 'Add Student',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.text2Light),
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
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required Function(dynamic) onChanged,
  }) {
    return DropdownButtonFormField<dynamic>(
      initialValue: value,
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
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon Circle
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),

          // Count
          Text(
            count,
            style: AppTextStyles.normal600(
              fontSize: 24,
              color: AppColors.text3Light,
            ),
          ),
          const SizedBox(height: 4),

          // Label
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.normal400(
              fontSize: 12,
              color: Colors.grey[600]!,
            ),
          ),
        ],
      ),
    );
  }

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
