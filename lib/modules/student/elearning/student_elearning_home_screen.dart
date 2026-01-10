import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/model/student/single_elearningcontentmodel.dart';
import 'package:linkschool/modules/providers/student/single_elearningcontent_provider.dart';
import 'package:linkschool/modules/student/elearning/course_detail_screen.dart';
import 'package:linkschool/modules/student/elearning/single_assignment_detail_screen.dart';
import 'package:linkschool/modules/student/elearning/single_assignment_score_view.dart';
import 'package:linkschool/modules/student/elearning/single_material_detail_screen.dart';
import 'package:linkschool/modules/student/elearning/single_quiz_intro_page.dart';
import 'package:linkschool/modules/student/elearning/single_quiz_score_page.dart';
import 'package:provider/provider.dart';

import '../../model/student/dashboard_model.dart';
import '../../providers/student/dashboard_provider.dart';

class StudentElearningScreen extends StatefulWidget {
  const StudentElearningScreen({super.key});

  @override
  _StudentElearningScreenState createState() => _StudentElearningScreenState();
}

class _StudentElearningScreenState extends State<StudentElearningScreen> {
  DashboardData? dashboardData;
  SingleElearningContentData? elearningContentData;

  bool isLoading = true;

  int currentAssessmentIndex = 0;
  int currentActivityIndex = 0;
  late PageController assessmentController;
  late PageController activityController;
  Timer? assessmentTimer;
  Timer? activityTimer;
  late double opacity;

  final String courseIcon = 'assets/icons/course-icon.svg';

  // Remove the hardcoded assessments to avoid conflict
  final List<String> courseBackgrounds = [
    'assets/images/student/bg-light-blue.svg',
    'assets/images/student/bg-light-blue.svg',
    'assets/images/student/bg-green.svg',
    'assets/images/student/bg-green.svg',
    'assets/images/student/bg-light-blue.svg',
    'assets/images/student/bg-light-blue.svg',
    'assets/images/student/bg-dark-blue.svg',
    'assets/images/student/bg-dark-blue.svg',
    'assets/images/student/bg-green.svg',
    'assets/images/student/bg-green.svg',
    'assets/images/student/bg-purple.svg',
    'assets/images/student/bg-purple.svg',
  ];

  String extractTime(String datetime) {
    DateTime dt = DateTime.parse(datetime);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();

    assessmentController = PageController(viewportFraction: 0.90);
    activityController = PageController(viewportFraction: 0.90);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardProvider =
          Provider.of<DashboardProvider>(context, listen: false);
      dashboardProvider.fetchDashboardData(
        class_id: getuserdata()['profile']['class_id'].toString(),
        level_id: getuserdata()['profile']['level_id'],
        term: getuserdata()['settings']['term'],
      );
    });

    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final data = await provider.fetchDashboardData(
      class_id: getuserdata()['profile']['class_id'].toString(),
      level_id: getuserdata()['profile']['level_id'].toString(),
      term: getuserdata()['settings']['term'].toString(),
    );
    setState(() {
      dashboardData = data;
      isLoading = false;
    });
  }

  // FIXED: Use Consumer pattern to safely access provider
  Future<void> _handleAssessmentTap(int contentId, BuildContext context) async {
    try {
      final provider =
          Provider.of<SingleelearningcontentProvider>(context, listen: false);
      final data = await provider.fetchElearningContentData(contentId);

      if (mounted) {
        setState(() {
          elearningContentData = data;
        });
      }

      final userBox = Hive.box('userData');
      final List<dynamic> quizzestaken =
          userBox.get('quizzes', defaultValue: []);
      int? theid = data?.id;

      if (quizzestaken.contains(theid)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleQuizScoreView(
                childContent: data,
                year: int.parse(getuserdata()['settings']['year']),
                term: getuserdata()['settings']['term']),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleQuizIntroPage(childContent: data),
          ),
        );
      }
    } catch (e) {
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load content: $e')),
      );
    }
  }

  // FIXED: Handle activity tap with proper provider access
  Future<void> _handleActivityTap(
      dynamic activity, BuildContext context) async {
    try {
      final provider =
          Provider.of<SingleelearningcontentProvider>(context, listen: false);
      final data = await provider.fetchElearningContentData(activity.id);

      if (mounted) {
        setState(() {
          elearningContentData = data;
        });
      }

      if (data?.settings != null) {
        final userBox = Hive.box('userData');
        final List<dynamic> quizzestaken =
            userBox.get('quizzes', defaultValue: []);
        final int? quizId = data?.settings!.id;

        if (quizzestaken.contains(quizId)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleQuizScoreView(
                  childContent: data,
                  year: int.parse(getuserdata()['settings']['year']),
                  term: getuserdata()['settings']['term']),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleQuizIntroPage(childContent: data),
            ),
          );
        }
      } else if (data?.type == 'material') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SingleMaterialDetailScreen(childContent: data),
          ),
        );
      } else if (data?.type == "assignment") {
        final userBox = Hive.box('userData');
        final List<dynamic> assignmentssubmitted =
            userBox.get('assignments', defaultValue: []);
        final int? assignmentId = data?.id;

        if (assignmentssubmitted.contains(assignmentId)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleAssignmentScoreView(
                  childContent: data,
                  year: int.parse(getuserdata()['settings']['year']),
                  term: getuserdata()['settings']['term'],
                  attachedMaterials: [""]),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleAssignmentDetailsScreen(
                  childContent: data, title: data?.title, id: data?.id ?? 0),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load content: $e')),
      );
    }
  }

  @override
  void dispose() {
    assessmentController.dispose();
    activityController.dispose();
    assessmentTimer?.cancel();
    activityTimer?.cancel();
    super.dispose();
  }

  getuserdata() {
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData =
        storedUserData is String ? json.decode(storedUserData) : storedUserData;
    final response = processedData['response'] ?? processedData;
    final data = response['data'] ?? response;
    return data;
  }

  void _navigateToCourseDetail(
      String courseTitle, DashboardData dashboardata, int syllabusid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(
            courseTitle: courseTitle,
            dashboardData: dashboardata,
            syllabusid: syllabusid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || dashboardData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final activities = dashboardData!.recentActivities;
    final courses = dashboardData!.availableCourses;
    final recentQuizzes =
        dashboardData!.recentQuizzes; // FIXED: Renamed to avoid conflict

    final userName = getuserdata()['profile']['name'] ?? 'Guest';
    String getFirstName(String fullName) {
      return fullName.trim().split(' ').last;
    }

    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: userName,
        showNotification: true,
        onNotificationTap: () {},
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assessments Carousel
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: assessmentController,
                  itemCount: recentQuizzes.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentAssessmentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final assessment = recentQuizzes[index];
                    return GestureDetector(
                      onTap: () => _handleAssessmentTap(
                          assessment.id, context), // FIXED: Use the new method
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: AppColors.paymentTxtColor1,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Section: Subject and Date
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${assessment.title} ${assessment.courseName}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: AppColors.paymentTxtColor1,
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/student/calender-icon.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      assessment.datePosted,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Time',
                                        style: TextStyle(
                                          color: AppColors.backgroundLight,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        extractTime(assessment.datePosted),
                                        style: TextStyle(
                                          color: AppColors.backgroundLight,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.white,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Classes',
                                        style: TextStyle(
                                          color: AppColors.backgroundLight,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        getuserdata()['profile']['class_name'],
                                        style: TextStyle(
                                          color: AppColors.backgroundLight,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.white,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Duration',
                                        style: TextStyle(
                                          color: AppColors.backgroundLight,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "20 Minutes",
                                        style: TextStyle(
                                          color: AppColors.backgroundLight,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Carousel Dots
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  recentQuizzes.length,
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

              const SizedBox(height: 24),
              // Recent Activity Carousel
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Recent activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: PageView.builder(
                  controller: activityController,
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return GestureDetector(
                      onTap: () => _handleActivityTap(
                          activity, context), // FIXED: Use the new method
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // FIXED: Replace invalid asset with placeholder
                                CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person,
                                      color: Colors.grey[600]),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                          children: [
                                            TextSpan(
                                                text: '${activity.createdBy} '),
                                            TextSpan(
                                                text: '${activity.type} ',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal)),
                                            TextSpan(
                                                text: activity.courseName,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        activity.datePosted,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              // Courses Grid
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Courses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 3,
                ),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  final svgBackground =
                      courseBackgrounds[index % courseBackgrounds.length];
                  return GestureDetector(
                    onTap: () => _navigateToCourseDetail(
                        course.courseName, dashboardData!, course.syllabusId),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            svgBackground,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
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
                              Text(
                                course.courseName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }
}
