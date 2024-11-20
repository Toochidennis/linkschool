import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/student_portal/elearning/course_detail_screen.dart';
import 'package:linkschool/modules/student_portal/home/new_post_dialog.dart';

class StudentElearningScreen extends StatefulWidget {
  const StudentElearningScreen({Key? key}) : super(key: key);

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

  final List<Map<String, String>> assessments = [
    {
      'date': '11TH FEBRUARY 2026',
      'title': 'First Continuous Assessment',
      'subject': 'Mathematics',
      'classes': 'JSS 1, JSS3, SS3',
    },
    {
      'date': '10TH FEBRUARY 2025',
      'title': 'Third Continuous Assessment',
      'subject': 'Civic Education',
      'classes': 'JSS 1, JSS3, SS3',
    },
    {
      'date': '19TH FEBRUARY 2024',
      'title': 'Second Continuous Assessment',
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
    'assets/icons/student/small-blue-bg-illustration.svg',
    'assets/icons/student/small-yellow-bg-illustration.svg',
    'assets/icons/student/small-yellow-bg-illustration.svg',
    'assets/icons/student/small-blue-bg-illustration.svg',
    'assets/icons/student/small-blue-bg-illustration.svg',
    'assets/icons/student/small-yellow-bg-illustration.svg',
    'assets/icons/student/small-yellow-bg-illustration.svg',
    'assets/icons/student/small-blue-bg-illustration.svg',
    'assets/icons/student/small-blue-bg-illustration.svg',
    'assets/icons/student/small-yellow-bg-illustration.svg',
    'assets/icons/student/small-yellow-bg-illustration.svg',
    'assets/icons/student/small-blue-bg-illustration.svg',
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
          currentAssessmentIndex = (currentAssessmentIndex + 1) % assessments.length;
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
              // Assessment Carousel with SVG Background Peek Effect
              SizedBox(
                height: 150,
                child: PageView.builder(
                  controller: assessmentController,
                  itemCount: assessments.length,
                  itemBuilder: (context, index) {
                    final assessment = assessments[index];
                    return Container(
                      // margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Stack(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/student/big-blue-bg-illustration.svg',
                              width: double.infinity,
                              // width: MediaQuery.of(context).size.width * 0.9,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    assessment['date']!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    assessment['title']!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Subject: ${assessment['subject']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                   const SizedBox(height: 4),
                                  Text(
                                    'For: ${assessment['classes']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Recent Activity Carousel with Peek Effect
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: const Text(
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
                                backgroundImage: AssetImage(activity['avatar']!),
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
                                          TextSpan(text: '${activity['name']} '),
                                          TextSpan(
                                              text: '${activity['activity']} ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.normal)),
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
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: const Text(
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
                  final svgBackground = courseBackgrounds[index % courseBackgrounds.length];
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
                          Text(
                            course,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
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