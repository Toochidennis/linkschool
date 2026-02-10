import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/providers/staff/overview.dart';
import 'package:linkschool/modules/staff/e_learning/recent_activity_screen/recent_assignment.dart';
import 'package:linkschool/modules/staff/e_learning/recent_activity_screen/recent_material.dart';
import 'package:linkschool/modules/staff/e_learning/recent_activity_screen/recent_quiz.dart';
import 'package:linkschool/modules/staff/e_learning/staff_course_detail_screen.dart';
import 'package:linkschool/modules/student/home/new_post_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart' show Consumer, Provider;

class StaffElearningScreen extends StatefulWidget {
  const StaffElearningScreen({super.key});

  @override
  _StaffElearningScreenState createState() => _StaffElearningScreenState();
}

class _StaffElearningScreenState extends State<StaffElearningScreen> {
  int currentAssessmentIndex = 0;
  int currentActivityIndex = 0;
  late PageController assessmentController;
  late PageController activityController;
  Timer? assessmentTimer;
  Timer? activityTimer;
  late double opacity;
  String creatorName = '';
  final String courseIcon = 'assets/icons/course-icon.svg';

  // Remove the hardcoded courses list
  // final List<String> courses = [...];

  final List<String> courseBackgrounds = [
    'assets/images/student/bg-light-blue.svg',
    'assets/images/student/bg-green.svg',
    'assets/images/student/bg-dark-blue.svg',
    'assets/images/student/bg-purple.svg',
  ];

  Map<String, dynamic>? userData;
  List<dynamic> levelNames = [];
  List<dynamic> courseNames = [];
  List<dynamic> classNames = [];
  List<dynamic> levelsWithCourses = [];
  String selectedLevelId = '';
  String selectedCourseId = '';
  String academicTerm = '';
  String academicYear = '';
  String staffIds = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<StaffOverviewProvider>(context, listen: false);
      // pass term/year dynamically if you have them
    });
    assessmentController = PageController(viewportFraction: 0.90);
    activityController = PageController(viewportFraction: 0.90);

    // Load user data
    _loadUserData();

    // Start timers for auto-scrolling
    assessmentTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (assessmentController.hasClients) {
        final provider =
            Provider.of<StaffOverviewProvider>(context, listen: false);
        setState(() {
          currentAssessmentIndex =
              (currentAssessmentIndex + 1) % provider.recentQuizzes.length;
          assessmentController.animateToPage(
            currentAssessmentIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeIn,
          );
        });
      }
    });

    activityTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (activityController.hasClients) {
        final provider =
            Provider.of<StaffOverviewProvider>(context, listen: false);
        setState(() {
          currentActivityIndex =
              (currentActivityIndex + 1) % provider.recentActivities.length;
          activityController.animateToPage(
            currentActivityIndex,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeIn,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    assessmentController.dispose();
    activityController.dispose();
    assessmentTimer?.cancel();
    activityTimer?.cancel();
    super.dispose();
  }

  void _showNewPostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NewPostDialog();
      },
    );
  }

  void _navigateToCourseDetail(Map<String, dynamic> course, String classId) {
    print("======Navigating to Course Detail=====");
    print("Course Name: ${course['course_name']}");
    print("Course ID: ${course['course_id']}");
    print("Class ID: $classId");

    // Find the classData from levelsWithCourses to get class_name
    final classData = levelsWithCourses.firstWhere(
      (data) => data['class_id'].toString() == classId,
      orElse: () => {'class_id': '', 'class_name': ''},
    );

    // Construct classesList
    final List<Map<String, dynamic>> classesList = [
      {
        'id': classId,
        'name': classData['class_name']?.toString() ?? '',
      }
    ];
    print("Class Name: $classesList");
    // Validate classesList
    if (classesList[0]['id'].isEmpty || classesList[0]['name'].isEmpty) {
      print("Warning: Invalid class data - id or name is empty");
      CustomToaster.toastError(
        context,
        'Navigation Error',
        'Invalid class data. Please try again.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffCourseDetailScreen(
          selectedSubject: course['course_name'] ?? '',
          classId: classId,
          courseId: course['course_id']?.toString() ?? '',
          course_name: course['course_name'] ?? '',
          classesList: classesList, // Pass the extracted classes list
          levelId:
              classData['level_id']?.toString(), // Pass levelId if available
          term: academicTerm, // Pass academicTerm
        ),
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData');
      final storedLoginResponse = userBox.get('loginResponse');

      dynamic dataToProcess;
      if (storedUserData != null) {
        dataToProcess = storedUserData;
      } else if (storedLoginResponse != null) {
        dataToProcess = storedLoginResponse;
      }

      if (dataToProcess != null) {
        Map<String, dynamic> processedData = dataToProcess is String
            ? json.decode(dataToProcess)
            : dataToProcess;

        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final settings = data['settings'] ?? {};
        final profile = data['profile'] ?? {};
        final staffId = profile['staff_id']?.toString() ?? '';
        final term = settings['term']?.toString() ?? '';
        final year = settings['year']?.toString() ?? '';
        final rawCourses = data['courses'] ?? [];
            creatorName = profile['name']?.toString() ?? '';
        // Build a simpler "levelsWithCourses"
        final grouped = rawCourses.map((classData) {
          return {
            "class_name": classData["class_name"] ?? "",
            "class_id": classData["class_id"] ?? "",
            "courses": (classData["courses"] ?? []).map((c) {
              return {
                "course_id": (c["course_id"] ?? "").toString(),
                "course_name": (c["course_name"] ?? "").toString().trim(),
              };
            }).toList()
          };
        }).toList();

        setState(() {
          userData = processedData;
          levelsWithCourses = grouped;
          academicTerm = term;
          academicYear = year;
          staffIds = staffId;
        });

        final provider =
            Provider.of<StaffOverviewProvider>(context, listen: false);
        provider.fetchOverview(academicTerm, year, staffId);

        print("levelsWithCourses: $levelsWithCourses");
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final provider = Provider.of<StaffOverviewProvider>(context, listen: false);
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: creatorName,
        showNotification: true,
        onNotificationTap: () {},
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<StaffOverviewProvider>(context, listen: false)
              .fetchOverview(academicTerm, academicYear, staffIds);
        },
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : provider.recentQuizzes.isEmpty
                        ? const Center(child: Text("No quizzes available"))
                        : CarouselSlider(
  items: provider.recentQuizzes.asMap().entries.map((entry) {
    final index = entry.key;
    final quiz = entry.value;

    final subject = quiz.courseName; // or "${quiz.courseName}"
    final title = quiz.title;        // already a quiz title
    final date = quiz.datePosted;

    final classesText = quiz.classes.map((c) => c.name).join(", ");

    return _buildStaffQuizCard(
      index: index,
      subject: subject,
      title: title,
      date: date,
      classesText: classesText,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffRecentQuiz(
              levelId: quiz.levelId,
              syllabusId: quiz.syllabusId.toString(),
              courseName: quiz.courseName,
              courseId: quiz.courseId.toString(),
              quizId: quiz.id.toString(),
            ),
          ),
        );
      },
    );
  }).toList(),
  options: CarouselOptions(
    height: 205, // match dashboard look
    viewportFraction: 0.90,
    enableInfiniteScroll: true,
    autoPlay: true,
    autoPlayInterval: const Duration(seconds: 5),
    autoPlayCurve: Curves.easeOutCubic,
    enlargeCenterPage: false,
    onPageChanged: (index, reason) {
      setState(() => currentAssessmentIndex = index);
    },
  ),
),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    provider.recentQuizzes.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentAssessmentIndex == index
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<StaffOverviewProvider>(
                  builder: (context, provider, child) {
                    final activities = provider.recentActivities;

                    if (provider.isLoading && activities.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // filter out incomplete activity objects
                    final displayActivities = activities
                        .where((activity) =>
                            activity.createdBy.isNotEmpty &&
                            activity.type.isNotEmpty &&
                            activity.courseName.isNotEmpty &&
                            activity.datePosted.isNotEmpty)
                        .toList();

                    if (displayActivities.isEmpty) {
                      return const Center(
                          child: Text("No recent activities available"));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Recent activity",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 110,
                          child: PageView.builder(
                            controller: activityController,
                            itemCount: displayActivities.length,
                            itemBuilder: (context, index) {
                              final activity = displayActivities[index];

                              return GestureDetector(
                                onTap: () {
                                  if (activity.type.toLowerCase() ==
                                      'material') {
                                    print(
                                        "syllabus classes ${activity.classes.map((e) => e.toJson()).toList()}");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StaffRecentMaterial(
                                          itemId: activity.id,
                                          syllabusId: activity.syllabusId,
                                          courseId:
                                              activity.courseId.toString(),
                                          syllabusClasses: activity.classes
                                              .map((e) => e.toJson())
                                              .toList(),
                                          levelId: activity.levelId,
                                          //classId: activity.classes.first.id,
                                          courseName: activity.courseName,
                                        ),
                                      ),
                                    );
                                  } else if (activity.type.toLowerCase() ==
                                      'assignment') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StaffRecentAssignment(
                                          itemId: activity.id,
                                          syllabusClasses: activity.classes
                                              .map((e) => e.toJson())
                                              .toList(),
                                          syllabusId: activity.syllabusId,
                                          courseId:
                                              activity.courseId.toString(),
                                          levelId: activity.levelId,
                                          courseName: activity.courseName,
                                          // if it’s the Assignment model
                                        ),
                                      ),
                                    );
                                  } else if (activity.type.toLowerCase() ==
                                      'quiz') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StaffRecentQuiz(
                                          levelId: activity.levelId,
                                          syllabusId:
                                              activity.syllabusId.toString(),
                                          courseName: activity.courseName,
                                          courseId:
                                              activity.courseId.toString(),
                                          quizId: activity.id.toString(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 20,
                                          backgroundImage: AssetImage(
                                              "assets/images/student/avatar3.png"),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            "${activity.createdBy} "),
                                                    TextSpan(
                                                        text:
                                                            "${activity.type} ",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                    TextSpan(
                                                        text:
                                                            activity.courseName,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                activity.datePosted,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            ],
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
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Courses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var classData in levelsWithCourses) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          classData['class_name'] ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      GridView.builder(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 3,
                        ),
                        itemCount: classData['courses'].length,
                        itemBuilder: (context, index) {
                          final course = classData['courses'][index];
                          final svgBackground = courseBackgrounds[
                              index % courseBackgrounds.length];

                          return GestureDetector(
                            onTap: () => _navigateToCourseDetail(
                                course, classData['class_id'].toString()),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(svgBackground,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        courseIcon,
                                        width: 24,
                                        height: 24,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          course['course_name'] ?? '',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 100)
              ],
            ),
          ),
        ),
      ),
    );
  }


  Color _getAssessmentColor(int index) {
  final colors = [
    AppColors.paymentTxtColor1,
    Colors.orangeAccent,
    Colors.greenAccent,
  ];
  return colors[index % colors.length];
}

Widget _buildStaffQuizCard({
  required int index,
  required String title,
  required String subject,
  required String date,
  required String classesText,
  required VoidCallback onTap,
}) {
  final bg = _getAssessmentColor(index);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bg.withOpacity(0.95), bg.withOpacity(0.70)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // decorative circles
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -70,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP: Subject + Date pill + Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white.withOpacity(0.18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/student/calender-icon.svg',
                                  width: 14,
                                  height: 14,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 90),
                                  child: Text(
                                    date.isEmpty ? "—" : date,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // MID: Classes block
                  Text(
                    "Classes",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    classesText.isEmpty ? "All Classes" : classesText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),

                  const Spacer(),

                  // BOTTOM: Stats + CTA
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Time",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "N/A",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Duration",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "N/A",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: const Text(
                          "View quiz",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
