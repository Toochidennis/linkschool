import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/home/add_course_model.dart';
import 'package:linkschool/modules/providers/admin/home/add_course_provider.dart';
import 'package:provider/provider.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Courses> _filteredCourses = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
    _slideController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).fetchCourses();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterCourses(String query, List<Courses> allCourses) {
    setState(() {
      if (query.isEmpty) {
        _filteredCourses = [];
        _isSearching = false;
      } else {
        _isSearching = true;
        _filteredCourses = allCourses.where((course) {
          final courseName = course.courseName.toLowerCase();
          final courseCode = course.courseCode.toLowerCase();
          final searchLower = query.toLowerCase();
          return courseName.contains(searchLower) ||
              courseCode.contains(searchLower);
        }).toList();
      }
    });
  }

  Widget _buildSearchBar(List<Courses> allCourses) {
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
        focusNode: _searchFocusNode,
        onChanged: (value) => _filterCourses(value, allCourses),
        decoration: InputDecoration(
          hintText: 'Search courses...',
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
                    _filterCourses('', allCourses);
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

  Widget _buildSearchResults(List<Courses> courses) {
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
                  '${courses.length} result${courses.length != 1 ? 's' : ''} found',
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
            child: courses.isEmpty
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
                          'No courses found',
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
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return Container(
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
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.text2Light,
                              ),
                              child: const Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                          title: Text(
                            course.courseName,
                            style: AppTextStyles.normal500(
                              fontSize: 16,
                              color: AppColors.text2Light,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.text2Light.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    course.courseCode.toUpperCase(),
                                    style: AppTextStyles.normal600(
                                      fontSize: 11,
                                      color: AppColors.text2Light,
                                    ),
                                  ),
                                ),
                              ],
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
                                _showAddEditCourseForm(course: course);
                              } else if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Course'),
                                    content: Text(
                                        'Are you sure you want to delete ${course.courseName}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      Consumer<CourseProvider>(
                                        builder: (context, provider, _) =>
                                            ElevatedButton(
                                          onPressed: provider.isLoading
                                              ? null
                                              : () async {
                                                  final success =
                                                      await provider
                                                          .deleteCourse(course
                                                              .id
                                                              .toString());
                                                  if (success) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                            'Course deleted successfully'),
                                                        backgroundColor:
                                                            AppColors
                                                                .attCheckColor2,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(provider
                                                                .error ??
                                                            'Failed to delete course'),
                                                        backgroundColor:
                                                            Colors.red,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                          child: provider.isLoading
                                              ? const CircularProgressIndicator()
                                              : const Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                        ),
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
                                  leading: Icon(Icons.edit, size: 20),
                                  title: Text('Edit'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete,
                                      size: 20, color: Colors.red),
                                  title: Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                  contentPadding: EdgeInsets.zero,
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
    );
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.3 + (index * 0.1)),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                index * 0.1,
                1.0,
                curve: Curves.elasticOut,
              ),
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
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
        counterText: "",
      ),
    );
  }

  void _showAddEditCourseForm({Courses? course}) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final isEditing = course != null;
    final nameController =
        TextEditingController(text: course?.courseName ?? '');
    final courseCodeController =
        TextEditingController(text: course?.courseCode ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 20.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Course' : 'Add New Course',
                    style: AppTextStyles.normal600(
                      fontSize: 18,
                      color: AppColors.text2Light,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.text5Light,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: nameController,
                label: 'Course Name',
                icon: Icons.book,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: courseCodeController,
                label: 'Course Code',
                icon: Icons.code,
                maxLength: 5,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: courseProvider.isLoading
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Please enter the Course Name'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }
                          if (courseCodeController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Please enter the Course Code'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }
                          if (courseCodeController.text.trim().length > 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Course Code must not be more than 5 characters'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }

                          final courseData = {
                            'course_name': nameController.text.trim(),
                            'course_code': courseCodeController.text.trim(),
                            '_db': '',
                          };

                          bool success;
                          if (isEditing) {
                            success = await courseProvider.updateCourse(
                                course.id.toString(), courseData);
                          } else {
                            success =
                                await courseProvider.createCourse(courseData);
                          }

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEditing
                                    ? 'Course updated successfully'
                                    : 'Course added successfully'),
                                backgroundColor: AppColors.attCheckColor2,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(courseProvider.error ??
                                    'Failed to ${isEditing ? 'update' : 'add'} course'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.text2Light,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: courseProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'Update Course' : 'Add Course',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Courses',
          style: TextStyle(
            fontFamily: 'Urbanist',
          color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.text2Light,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: courseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSearching
              ? Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _buildSearchBar(courseProvider.courses),
                      Expanded(
                        child: _buildSearchResults(_filteredCourses),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: Constants.customBoxDecoration(context),
                  child: Column(
                    children: [
                      _buildSearchBar(courseProvider.courses),
                      Expanded(
                        child: courseProvider.courses.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.book_outlined,
                                      size: 64,
                                      color: AppColors.text7Light,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No courses found',
                                      style: AppTextStyles.normal500(
                                        fontSize: 16,
                                        color: AppColors.text7Light,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add courses to get started',
                                      style: AppTextStyles.normal400(
                                        fontSize: 14,
                                        color: AppColors.text9Light,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: courseProvider.courses.length,
                                itemBuilder: (context, index) {
                                  final course = courseProvider.courses[index];

                                  return _buildAnimatedCard(
                                    index: index,
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
                                          child: Container(
                                            width: 46,
                                            height: 46,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.text2Light,
                                            ),
                                            child: const Icon(
                                              Icons.book,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          course.courseName,
                                          style: AppTextStyles.normal500(
                                            fontSize: 16,
                                            color: AppColors.text2Light,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.text2Light.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  course.courseCode.toUpperCase(),
                                                  style: AppTextStyles.normal600(
                                                    fontSize: 11,
                                                    color: AppColors.text2Light,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                                              _showAddEditCourseForm(course: course);
                                            } else if (value == 'delete') {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Delete Course'),
                                                  content: Text(
                                                      'Are you sure you want to delete ${course.courseName}?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    Consumer<CourseProvider>(
                                                      builder: (context, provider, _) =>
                                                          ElevatedButton(
                                                        onPressed: provider.isLoading
                                                            ? null
                                                            : () async {
                                                                final success =
                                                                    await provider
                                                                        .deleteCourse(course
                                                                            .id
                                                                            .toString());
                                                                if (success) {
                                                                  Navigator.pop(context);
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content: const Text(
                                                                          'Course deleted successfully'),
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .attCheckColor2,
                                                                      behavior:
                                                                          SnackBarBehavior
                                                                              .floating,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius
                                                                                .circular(
                                                                                    10),
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(provider
                                                                              .error ??
                                                                          'Failed to delete course'),
                                                                      backgroundColor:
                                                                          Colors.red,
                                                                      behavior:
                                                                          SnackBarBehavior
                                                                              .floating,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius
                                                                                .circular(
                                                                                    10),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                        child: provider.isLoading
                                                            ? const CircularProgressIndicator()
                                                            : const Text('Delete',
                                                                style: TextStyle(
                                                                    color: Colors.red)),
                                                      ),
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
                                                leading: Icon(Icons.edit, size: 20),
                                                title: Text('Edit'),
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: ListTile(
                                                leading: Icon(Icons.delete,
                                                    size: 20, color: Colors.red),
                                                title: Text('Delete',
                                                    style: TextStyle(color: Colors.red)),
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
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditCourseForm(),
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
