import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart'; // Import Hive
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/class_course_registration_model.dart';
import 'package:linkschool/modules/providers/admin/class_course_provider.dart';
import 'package:linkschool/modules/providers/admin/getcurrent_course_registration_provider.dart';
import 'package:provider/provider.dart';

class CourseRegistrationScreen extends StatefulWidget {
  final String studentName;
  final String studentId; // Add studentId to the constructor
  final int coursesRegistered;

  const CourseRegistrationScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.coursesRegistered,
  });

  @override
  State createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  late List<bool> selectedSubjects;
  late List<Color> subjectColors;
  late List<String> subjects;

  @override
  void initState() {
    super.initState();
    // Load courses from Hive on initialization
    subjects = getSubjectsFromHive();
    selectedSubjects = List<bool>.filled(subjects.length, false);
    // Initialize colors with primary colors cycle

    subjectColors = List.generate(
      subjects.length,
      (index) => Colors.primaries[index % Colors.primaries.length],
    );

    // Optional: Maintain original random selection pattern if needed
    // for (int i = 0; i < selectedSubjects.length; i++) {
    //   selectedSubjects[i] = i % 2 == 0;
    // }
  }

  String titleCase(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String getCurrentAcademicSession() {
    DateTime now = DateTime.now();
    int startYear = now.month >= 9 ? now.year : now.year - 1;
    int endYear = startYear + 1;
    return "$startYear/$endYear";
  }

  // Check if any subject is selected
  bool isAnySubjectSelected() {
    return selectedSubjects.contains(true);
  }

  // Method to retrieve courses from Hive storage
  List<String> getSubjectsFromHive() {
    final userDataBox = Hive.box('userData');
    final coursesData = userDataBox.get('userData')?['courses'] ?? {};
    return coursesData['rows']
            ?.map<String>(
                (row) => row[1] as String) // Get course names from row index 1
            ?.toList() ??
        [];
  }

  bool isHoveringSave = false;

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      Provider.of<getCurrentCourseRegistrationProvider>(context, listen: false)
          .fetchCurrentCourseRegistration(widget.studentId, "72", "1", "2023");
    });
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Course Registration',
          style: AppTextStyles.normal600(
            fontSize: 20,
            color: AppColors.backgroundLight,
          ),
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
                            titleCase(widget.studentName),
                            style: AppTextStyles.normal600(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            getCurrentAcademicSession() + ' Academic Session',
                            style: AppTextStyles.normal400(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 2.0,
                      right: 8.0,
                      child: Visibility(
                        visible: isAnySubjectSelected(),
                        child: FloatingActionButton(
                          onPressed: () async {
                            // Access the provider without listening to changes
                            final providerClassRegistration =
                                Provider.of<StudentClassCourseProvider>(context,
                                    listen: false);

                            // Map selected courses to Course objects
                            List<Course> selectedCourses = [];
                            for (int i = 0; i < subjects.length; i++) {
                              if (selectedSubjects[i]) {
                                selectedCourses
                                    .add(Course(courseId: subjects[i]));
                              }
                            }

                            // Create a StudentClassCourseRegistration object
                            StudentClassCourseRegistration studentClassReg =
                                StudentClassCourseRegistration(
                              classId: widget
                                  .studentId, // Replace with actual classId
                              term: 'First Term', // Replace with actual term
                              year: getCurrentAcademicSession().split('/')[0],
                              course: selectedCourses,
                              studentId: widget.studentId,
                            );

                            // Show a loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            // Submit the data
                            bool success = await providerClassRegistration
                                .submitStudentClass(studentClassReg);

                            // Hide the loading indicator
                            Navigator.of(context).pop();

                            // Show a SnackBar based on the result
                            CustomToaster.toastSuccess(
                                context,
                                "success",
                                success
                                    ? "Class submitted successfully"
                                    : "Failed to submit class");
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text(success
                            //         ? 'Class submitted successfully!'
                            //         : 'Failed to submit class.'),
                            //   ),
                            // );
                          },
                          backgroundColor: isHoveringSave
                              ? Colors.blueGrey
                              : AppColors.primaryLight,
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
                            child: const Icon(
                              Icons.save,
                              color: AppColors.backgroundLight,
                            ),
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
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSubjects[index] =
                                  !selectedSubjects[index];
                            });
                          },
                          child: Container(
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
                                  titleCase(subjects[index][0]),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(titleCase(subjects[index])),
                              trailing: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectedSubjects[index]
                                      ? Colors.green
                                      : Colors.white,
                                  border: Border.all(color: Colors.grey),
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
