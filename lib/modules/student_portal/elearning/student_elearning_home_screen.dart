import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/student_portal/elearning/course_detail_screen.dart';
import 'package:linkschool/modules/student_portal/home/new_post_dialog.dart';

class StudentElearningScreen extends StatefulWidget {
  const StudentElearningScreen({super.key});

  @override
  _StudentElearningScreenState createState() => _StudentElearningScreenState();
}

class _StudentElearningScreenState extends State<StudentElearningScreen> {
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

  final List<Map<String, String>> activities = [
    {
      'name': 'Dennis Toochi',
      'activity': 'posted an assignment on',
      'subject': 'Homeostasis for JSS2',
      'timestamp': 'Yesterday at 9:42 AM',
      'avatar': 'assets/images/student/avatar3.svg',
    },
    {
      'name': 'Ifeanyi Toochi',
      'activity': 'posted an assignment on',
      'subject': 'Hygiene for JSS2',
      'timestamp': 'Yesterday at 9:42 AM',
      'avatar': 'assets/images/student/avatar3.svg',
    },
    {
      'name': 'Raphael Toochi',
      'activity': 'posted an assignment on',
      'subject': 'Exercises for JSS2',
      'timestamp': 'Yesterday at 9:42 AM',
      'avatar': 'assets/images/student/avatar3.svg',
    },
  ];

  final List<String> courses = [
    'Civic Education',
    'Mathematics',
    'English',
    'Biology',
    'Chemistry',
    'Physics',
    'History',
    'Geography',
    'Computer Science',
    'Physical Education',
    'Music',
    'Art',
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

  @override
  void initState() {
    super.initState();
    assessmentController = PageController(viewportFraction: 0.90);
    activityController = PageController(viewportFraction: 0.90);

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

  void _navigateToCourseDetail(String courseTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(courseTitle: courseTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: 'Tochukwu',
        showNotification: true,
        // showPostInput: true,
        onNotificationTap: () {},
        // onPostTap: _showNewPostDialog,
      ),
      body: Container(
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
                                      '${assessment['subject']} ${assessment['title']}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Date Section in a Blue Container
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
                                          assessment['date']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Bottom Section: Time, Classes, Duration
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Time
                                const Column(
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
                                      '08:00 AM',
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
                                // Classes
                                Column(
                                  children: [
                                    const Text(
                                      'Classes',
                                      style: TextStyle(
                                        color: AppColors.backgroundLight,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      assessment['classes']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
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
                                // Duration
                                const Column(
                                  children: [
                                    Text(
                                      'Duration',
                                      style: TextStyle(
                                        color: AppColors.backgroundLight,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '2h 30m',
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
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
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
                                    AssetImage(activity['avatar']!),
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
                                              text: '${activity['name']} '),
                                          TextSpan(
                                              text: '${activity['activity']} ',
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal)),
                                          TextSpan(
                                              text: '${activity['subject']}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activity['timestamp']!,
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
                    onTap: () => _navigateToCourseDetail(course),
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
                                course,
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
