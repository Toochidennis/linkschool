import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/student/elearning/course_detail_screen.dart';
import 'package:linkschool/modules/student/home/new_post_dialog.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../../model/student/dashboard_model.dart';
import '../../providers/student/dashboard_provider.dart';

class StudentElearningScreen extends StatefulWidget {
  const StudentElearningScreen({super.key});

  @override
  _StudentElearningScreenState createState() => _StudentElearningScreenState();
}

class _StudentElearningScreenState extends State<StudentElearningScreen> {
  DashboardData? dashboardData;
  bool isLoading = true;

  int currentAssessmentIndex = 0;
  int currentActivityIndex = 0;
  late PageController assessmentController;
  late PageController activityController;
  Timer? assessmentTimer;
  Timer? activityTimer;
  late double opacity;

  final String courseIcon = 'assets/icons/course-icon.svg';


  final List<Map<String, String>> assessments = [
    {
      'date': '11TH FEB 2026',
      'title': 'First C A',
      'subject': 'Mathematics',
      'classes': 'JSS 1, JSS3, SS3',
    },
    {
      'date': '10TH JAN 2025',
      'title': 'Third C A',
      'subject': 'Civic Edu..',
      'classes': 'JSS 1, JSS3, SS3',
    },
    {
      'date': '19TH OCT 2024',
      'title': 'Second C A',
      'subject': 'English Language',
      'classes': 'SSS 1, SSS2, SSS3',
    },
  ];





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

      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      dashboardProvider.fetchDashboardData(
class_id: getuserdata()['profile']['class_id'], level_id: getuserdata()['profile']['level_id'], term: getuserdata()['settings']['term'],
      );


    });


    // Start timers for auto-scrolling

    assessmentTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (assessmentController.hasClients) {
        setState(() {
          currentAssessmentIndex =
              (currentAssessmentIndex + 1) % assessments.length;
          assessmentController.animateToPage(
            currentAssessmentIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeIn,
          );
        });
      }
    });

    activityTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      final activities = dashboardProvider.dashboardData?.recentActivities ?? [];
      if (activityController.hasClients) {
        setState(() {
          currentActivityIndex = (currentActivityIndex + 1) % activities.length;
          activityController.animateToPage(
            currentActivityIndex,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeIn,
          );
        });
      }
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

  @override
  void dispose() {
    assessmentController.dispose();
    activityController.dispose();
    assessmentTimer?.cancel();
    activityTimer?.cancel();
    super.dispose();
  }
 getuserdata(){
  final userBox = Hive.box('userData');
  final storedUserData =
      userBox.get('userData') ?? userBox.get('loginResponse');
  final processedData = storedUserData is String
      ? json.decode(storedUserData)
      : storedUserData;
  final response = processedData['response'] ?? processedData;
  final data = response['data'] ?? response;
  return data;
}
  void _showNewPostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NewPostDialog();
      },
    );
  }

  void _navigateToCourseDetail(String courseTitle, DashboardData dashboardata, int syllabusid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(courseTitle: courseTitle, dashboardData: dashboardata, syllabusid:syllabusid),
      ),
    );
  }

//

  @override
  Widget build(BuildContext context) {

    if (isLoading || dashboardData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  final activities= dashboardData!.recentActivities;

    final courses = dashboardData!.availableCourses;
final assessments=dashboardData!.recentQuizzes;

    final userName =getuserdata()['profile']['name'] ?? 'Guest'; // Use the logged-in user's name

    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: userName,
        showNotification: true,
        // showPostInput: true,
        onNotificationTap: () {},
        // onPostTap: _showNewPostDialog,
      ),
      body:isLoading?const Center(child: CircularProgressIndicator(),): Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180, // Adjust height to fit design
                child: PageView.builder(
                  controller: assessmentController,
                  itemCount: assessments.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentAssessmentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final assessment = assessments[index];
                    return Container(
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
                                color: Colors
                                    .white, // White container wrapping everything
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Subject and Title Section
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
                                  // Date Section in a Blue Container

                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: AppColors
                                    .paymentTxtColor1, // Blue background
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
                            // Bottom Section: Time, Classes, Duration
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Time
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
                                    SizedBox(height: 4),
                                    Text(
                                      extractTime(assessment.datePosted),
                                      style: TextStyle(
                                        color: AppColors.backgroundLight,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                // Vertical Divider
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.white, // White line
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
                                    SizedBox(height: 4),
                                    Text(
                                      getuserdata()['profile']['class_name'],
                                      style: TextStyle(
                                        color: AppColors.backgroundLight,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),

                                // Classes
                                // Vertical Divider
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.white, // White line
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                ),
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
                                    SizedBox(height: 4),
                                    Text(
                                      "20 Minutes",
                                      style: TextStyle(
                                        color: AppColors.backgroundLight,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                // Duration

                              ],
                            ),
                          ],
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
                  assessments.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentAssessmentIndex == index
                          ? Colors.blue
                          : Colors.grey, // Highlight current page
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Recent Activity Carousel with Peek Effect
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
                  itemCount: activities?.length,
                  itemBuilder: (context, index) {
                    final activity = activities?[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage("Non rc"),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        children: [
                                          TextSpan(
                                              text: '${activity?.createdBy} '),
                                          TextSpan(
                                              text: '${activity?.type} ',
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal)),
                                          TextSpan(
                                              text: '${activity?.courseName}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activity!.datePosted,
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Courses Grid with Navigation
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
                    onTap: () => _navigateToCourseDetail(course.courseName, dashboardData!,course.syllabusId),
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
                              // Add course icon
                              SvgPicture.asset(
                                courseIcon,
                                width: 24,
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      8), // Add some spacing between icon and text
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
