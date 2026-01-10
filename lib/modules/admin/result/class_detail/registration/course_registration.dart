import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/course_registration_model.dart';
import 'package:linkschool/modules/providers/admin/course_registration_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';

class CourseRegistrationScreen extends StatefulWidget {
  final String studentName;
  final int coursesRegistered;
  final String classId;
  final int studentId;

  const CourseRegistrationScreen({
    super.key,
    required this.studentName,
    required this.coursesRegistered,
    required this.classId,
    required this.studentId,
  });

  @override
  State createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  late List<bool> selectedSubjects;
  late List<Color> subjectColors;
  late List<Map<String, dynamic>> courses;
  bool _hasSelectedCourses = false;
  bool _isSaving = false;
  bool _isLoadingRegisteredCourses = true;
  List<int> _registeredCourseIds = [];
  String _academicSession = '';
  Map<String, dynamic> _settings = {};
  String _selectedTerm = 'First term';

  @override
  void initState() {
    super.initState();
    _loadSettingsFromHive();
    courses = getCoursesFromHive();
    selectedSubjects = List<bool>.filled(courses.length, false);
    subjectColors = List.generate(
      courses.length,
      (index) => Colors.primaries[index % Colors.primaries.length],
    );

    // Fetch registered courses from server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRegisteredCoursesForStudent();
    });
  }

  void _loadSettingsFromHive() {
    final userBox = Hive.box('userData');
    final userData = userBox.get('userData');

    if (userData != null &&
        userData['data'] != null &&
        userData['data']['settings'] != null) {
      setState(() {
        _settings = Map<String, dynamic>.from(userData['data']['settings']);
        int termNumber = _settings['term'] ?? 1;
        _selectedTerm = termNumber == 1
            ? 'First term'
            : termNumber == 2
                ? 'Second term'
                : 'Third term';
        _academicSession =
            "${int.parse(_settings['year'] ?? '2023') - 1}/${_settings['year'] ?? '2023'} academic session";
      });
    } else {
      print('No settings found in Hive, using defaults');
      _settings = {'year': '2023', 'term': 1};
      _selectedTerm = 'First term';
      _academicSession = '2022/2023 academic session';
    }
  }

  // Save registered courses to Hive
  Future<void> _saveRegisteredCoursesToHive(List<int> courseIds) async {
    final userBox = Hive.box('userData');
    final key =
        'registeredCourses_${widget.studentId}_${widget.classId}_${_settings['year']}_${_settings['term']}';
    await userBox.put(key, courseIds);
    print('Saved registered courses to Hive: $courseIds');
  }

  // Get registered courses from Hive
  List<int> _getRegisteredCoursesFromHive() {
    final userBox = Hive.box('userData');
    final key =
        'registeredCourses_${widget.studentId}_${widget.classId}_${_settings['year']}_${_settings['term']}';
    final cachedCourses = userBox.get(key);
    if (cachedCourses == null) {
      print('No cached courses found in Hive for key: $key');
      return [];
    }
    // Ensure cachedCourses is a List and cast its elements to int
    if (cachedCourses is List) {
      final result = cachedCourses
          .where((id) =>
              id is int || (id is num && id is int)) // Filter valid integers
          .cast<int>()
          .toList();
      print('Retrieved cached courses from Hive: $result');
      return result;
    }
    print('Invalid cached courses format in Hive: $cachedCourses');
    return [];
  }

  // Fetch already registered courses for this student
  Future<void> _fetchRegisteredCoursesForStudent() async {
    setState(() {
      _isLoadingRegisteredCourses = true;
      _registeredCourseIds = [];
      selectedSubjects = List<bool>.filled(courses.length, false);
      _hasSelectedCourses = false;
    });

    try {
      final userBox = Hive.box('userData');
      final userData = userBox.get('userData');
      final settings = userData?['data']?['settings'] ?? _settings;

      final year = settings['year']?.toString() ?? '2023';
      final term = settings['term']?.toString() ?? '1';
      final dbName = userData?['_db'] ?? 'aalmgzmy_linkskoo_practice';

      print('Fetching registered courses with params:');
      print('Student ID: ${widget.studentId}');
      print('Class ID: ${widget.classId}');
      print('Year: $year');
      print('Term: $term');
      print('DB Name: $dbName');

      final provider =
          Provider.of<CourseRegistrationProvider>(context, listen: false);
      final response = await provider.fetchStudentRegisteredCourses(
        studentId: widget.studentId,
        classId: widget.classId,
        year: year,
        term: term,
        dbName: dbName,
      );

      setState(() {
        _registeredCourseIds = response;
        // Update selectedSubjects based on server response
        for (int i = 0; i < courses.length; i++) {
          selectedSubjects[i] = _registeredCourseIds.contains(courses[i]['id']);
        }
        _hasSelectedCourses = selectedSubjects.contains(true);
        print('Updated selectedSubjects: $selectedSubjects');
        // Save to Hive for persistence
        _saveRegisteredCoursesToHive(_registeredCourseIds);
      });
    } catch (e) {
      print('Error fetching registered courses: $e');
      // Fallback to cached data
      setState(() {
        _registeredCourseIds = _getRegisteredCoursesFromHive();
        for (int i = 0; i < courses.length; i++) {
          selectedSubjects[i] = _registeredCourseIds.contains(courses[i]['id']);
        }
        _hasSelectedCourses = selectedSubjects.contains(true);
        print('Using cached selectedSubjects: $selectedSubjects');
      });
    } finally {
      setState(() {
        _isLoadingRegisteredCourses = false;
      });
    }
  }

  List<Map<String, dynamic>> getCoursesFromHive() {
    final userDataBox = Hive.box('userData');

    try {
      final userData = userDataBox.get('userData');
      if (userData != null &&
          userData['data'] != null &&
          userData['data']['courses'] != null) {
        final coursesList = userData['data']['courses'] as List;
        final result = coursesList
            .map((course) => Map<String, dynamic>.from(course as Map))
            .toList();
        print('Courses retrieved from Hive: $result');
        return result;
      }

      final courses = userDataBox.get('courses');
      if (courses != null && courses is List) {
        final result = courses
            .map((course) => Map<String, dynamic>.from(course as Map))
            .toList();
        print('Courses retrieved from Hive (fallback): $result');
        return result;
      }
    } catch (e) {
      print('Error converting courses data: $e');
    }
    print('No courses found in Hive');
    return [];
  }

  Future<void> _saveSelectedCourses() async {
    if (!_hasSelectedCourses) {
      CustomToaster.toastError(context, 'Error', 'No courses selected');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userBox = Hive.box('userData');
      final userData = userBox.get('userData');
      final settings = userData?['data']?['settings'] ?? _settings;

      final payload = {
        "year": settings['year'] ?? 2023,
        "term": settings['term'] ?? 0,
        "class_id": widget.classId,
        "registered_courses": courses
            .asMap()
            .entries
            .where((entry) => selectedSubjects[entry.key])
            .map((entry) => {"course_id": entry.value['id']})
            .toList(),
        "_db": userData?['_db'] ?? 'aalmgzmy_linkskoo_practice',
      };

      print('Saving courses with payload: $payload');

      final provider =
          Provider.of<CourseRegistrationProvider>(context, listen: false);
      final response = await provider.registerCourse(
        CourseRegistrationModel(
          studentId: widget.studentId,
          studentName: widget.studentName,
          courseCount: selectedSubjects.where((selected) => selected).length,
          classId: widget.classId,
          term: settings['term']?.toString(),
          year: settings['year']?.toString(),
        ),
        payload: payload,
      );

      if (response) {
        final selectedCourseIds = courses
            .asMap()
            .entries
            .where((entry) => selectedSubjects[entry.key])
            .map((entry) => entry.value['id'] as int)
            .toList();
        setState(() {
          _registeredCourseIds = selectedCourseIds;
          _hasSelectedCourses = selectedSubjects.contains(true);
        });
        await _saveRegisteredCoursesToHive(selectedCourseIds);

        CustomToaster.toastSuccess(
          context,
          'Success',
          'Courses saved successfully',
        );

        // Refresh the course list from the server
        await _fetchRegisteredCoursesForStudent();
      } else {
        CustomToaster.toastError(
          context,
          'Failed',
          'Failed to save courses',
        );
      }
    } catch (e) {
      CustomToaster.toastError(
        context,
        'Error',
        'Error: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _updateSelection(int index, bool isSelected) {
    setState(() {
      selectedSubjects[index] = isSelected;
      _hasSelectedCourses = selectedSubjects.contains(true);
      print(
          'Updated selection for index $index: $isSelected, selectedSubjects: $selectedSubjects');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Course Registration',
          style: AppTextStyles.normal600(
              fontSize: 20, color: AppColors.backgroundLight),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.backgroundLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/result/bg_course_reg.svg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top +
                    AppBar().preferredSize.height,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.18,
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16.0,
                      left: 16.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.studentName.toUpperCase(),
                            style: AppTextStyles.normal600(
                                fontSize: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _academicSession,
                            style: AppTextStyles.normal400(
                                fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    if (_hasSelectedCourses)
                      Positioned(
                        bottom: 2.0,
                        right: 8.0,
                        child: FloatingActionButton(
                          onPressed: _isSaving ? null : _saveSelectedCourses,
                          backgroundColor:
                              _isSaving ? Colors.grey : AppColors.primaryLight,
                          shape: const CircleBorder(),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 7,
                                  spreadRadius: 7,
                                  offset: const Offset(3, 5),
                                ),
                              ],
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Icon(
                                    Icons.save,
                                    color: AppColors.backgroundLight,
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, -4),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    child: _isLoadingRegisteredCourses
                        ? const Center(child: CircularProgressIndicator())
                        : courses.isEmpty
                            ? const Center(child: Text('No courses available'))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                itemCount: courses.length,
                                itemBuilder: (context, index) {
                                  final course = courses[index];
                                  final courseName =
                                      course['course_name'] as String;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: selectedSubjects[index]
                                          ? Colors.grey[200]
                                          : Colors.white,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: subjectColors[index],
                                        child: Text(
                                          courseName.isNotEmpty
                                              ? courseName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      title: Text(courseName),
                                      trailing: GestureDetector(
                                        onTap: () {
                                          _updateSelection(
                                              index, !selectedSubjects[index]);
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectedSubjects[index]
                                                ? Colors.green
                                                : Colors.white,
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                          child: selectedSubjects[index]
                                              ? const Icon(Icons.check,
                                                  size: 16, color: Colors.white)
                                              : null,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
