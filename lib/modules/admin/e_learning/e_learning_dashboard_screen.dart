import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/admin/e_learning/View/recent_activity_screen/recent_assignment.dart';

import 'package:linkschool/modules/admin/e_learning/View/recent_activity_screen/recent_material.dart';
import 'package:linkschool/modules/admin/e_learning/View/recent_activity_screen/recent_quiz.dart';

import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/level_selection.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:linkschool/modules/model/e-learning/activity_model.dart';

import 'package:linkschool/modules/providers/admin/e_learning/activity_provider.dart';

import 'package:provider/provider.dart';

class ELearningDashboardScreen extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  const ELearningDashboardScreen({super.key, this.appBar});

  @override
  State<ELearningDashboardScreen> createState() =>
      _ELearningDashboardScreenState();
}

class _ELearningDashboardScreenState extends State<ELearningDashboardScreen> {
  int currentAssessmentIndex = 0;
  int currentActivityIndex = 0;
  late PageController activityController;
  Timer? activityTimer;


 

  @override
  void initState() {
    super.initState();

    
  
    activityController = PageController(viewportFraction: 0.90);
 activityTimer = Timer.periodic(const Duration(seconds: 7), (_) {
  if (activityController.hasClients) {
    final provider = Provider.of<OverviewProvider>(context, listen: false);
    final totalActivities = provider.recentActivities.length ?? 0;
 
    if (totalActivities > 0) {
      setState(() {
        currentActivityIndex = (currentActivityIndex + 1) % totalActivities;
        activityController.animateToPage(
          currentActivityIndex,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeIn,
        );
      });
    }
  }
});
print("total activities: ${Provider.of<OverviewProvider>(context, listen: false).recentQuizzes.length ?? 0}");

    // Load user data

 _loadUserData().then((_) {
  final recentProvider = Provider.of<OverviewProvider>(context, listen: false);
  try {

    recentProvider.fetchOverview(academicTerm); // Pass the actual term
    
;

 
  } catch (e) {
    print('Error fetching dashboard data: $e');
  }
});
    
  }

  @override
  void dispose() {
    activityController.dispose();
    activityTimer?.cancel();
    super.dispose();
  }


Map<String, dynamic>? userData;
  List<dynamic> levelNames = [];
  List<dynamic> courseNames = [];
  List<dynamic> classNames = [];
  List<dynamic> levelsWithCourses = []; // New list to store only levels with classes
  String selectedLevelId = '';
  String selectedCourseId = '';
  String academicTerm= '';

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
 // Extract the term from settings
  final settings = data['settings'] ?? {};
  final term = settings['term']?.toString() ?? '';
      // Extract all levels
      final levels = data['levels'] ?? [];
      levelNames = levels.map((level) => [
        (level['id'] ?? '').toString(),
        level['level_name'] ?? ''
      ]).toList();

      // Extract all courses
      final courses = data['courses'] ?? [];
      courseNames = courses.map((course) => [
        (course['id'] ?? '').toString(),
        (course['course_name'] ?? '').toString().trim(),
        (course['level_id'] ?? '').toString()
      ]).toList();

      // Extract all classes (including empty ones if you want them)
      final classes = data['classes'] ?? [];
      classNames = classes
          .where((clazz) => clazz['class_name'] != null && 
                           clazz['class_name'].toString().trim().isNotEmpty)
          .map((clazz) => [
            (clazz['id'] ?? '').toString(),
            (clazz['class_name'] ?? '').toString().trim(),
            (clazz['level_id'] ?? '').toString()
          ]).toList();

      setState(() {
        userData = processedData;
        levelsWithCourses = classNames;
        academicTerm = term; // Pass the actual term
      });

      print('All Levels: $levelNames');
      print('All Courses: $courseNames');
      print('All Classes: $classNames');
    }
  } catch (e) {
    print('Error loading user data: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    final recentProvider = Provider.of<OverviewProvider>(context, listen: true);

    return Scaffold(
      appBar: widget.appBar,
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopContainers(recentProvider,
            ),),
            const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverToBoxAdapter(
                child: _buildRecentActivity(recentProvider,
              ),)
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
            SliverToBoxAdapter(
  child: Constants.heading600(
    title: 'Select Class',
    titleSize: 18.0,
    titleColor: AppColors.resultColor1,
  ),
),
SliverToBoxAdapter(
  child: LevelSelection(
    isSecondScreen: true,
    term: academicTerm, // Pass the actual term
    levelNames: levelNames, // Pass all classes directly
    courseNames: courseNames,
    levelId: selectedLevelId,
    courseId: selectedCourseId,
    subjects: [
      'Civic Education',
      'Mathematics',
      'English',
      'Physics',
      'Chemistry'
    ], 
  ),
),
          ],
        ),
      ),
    );
  }

Widget _buildTopContainers(OverviewProvider overviewProvider) {
  final recentQuizzes = overviewProvider.recentQuizzes ?? [];

  final displayAssessments = recentQuizzes.isNotEmpty ? recentQuizzes : [];

  if (displayAssessments.isEmpty) {
    return const Center(child: Text("No recent quizzes available"));
  }

  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Column(
      children: [
        CarouselSlider(
          items: displayAssessments.asMap().entries.map((entry) {
            final index = entry.key;
            final assessment = entry.value;

            // normalized fields
            String title = "Quiz";
            String subject = "Subject";
            String date = "";
            String quizId = "";

            if (assessment is RecentQuizModel) {
              title = assessment.title;
              subject = assessment.courseName;
              date = assessment.datePosted;
              quizId = assessment.id.toString();
            } else if (assessment is Map<String, dynamic>) {
              title = assessment['title'] ?? 'Quiz';
              subject = assessment['subject'] ?? 'Subject';
              date = assessment['date'] ?? '';
              quizId = (assessment['id'] ?? '').toString();
            }

            return GestureDetector(
              onTap: () {
                print("Tapped on quiz id: $quizId");
                if (quizId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecentQuiz(
                          levelId: assessment is RecentQuizModel ? assessment.levelId : '',
                          syllabusId: assessment is RecentQuizModel ? assessment.syllabusId.toString() : '',
                          courseId: assessment is RecentQuizModel ? assessment.courseId.toString() : '',
                          courseName: assessment is RecentQuizModel ? assessment.courseName : '',
                        quizId: quizId),
                        settings: const RouteSettings(name: '/recent_quiz'),
                    ),
                   
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid quiz id")),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: _getAssessmentColor(index),
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
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '$subject $title',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
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
                                    date,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Column(
                            children: [
                              Text("Time",
                                  style: TextStyle(
                                      color: AppColors.backgroundLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("N/A",
                                  style: TextStyle(
                                      color: AppColors.backgroundLight,
                                      fontSize: 14)),
                            ],
                          ),
                          Container(height: 40, width: 1, color: Colors.white),
                          Column(
                            children: [
                              const Text("Classes",
                                  style: TextStyle(
                                      color: AppColors.backgroundLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                assessment is RecentQuizModel &&
                                        assessment.levelId.isNotEmpty
                                    ? assessment.classes.map((c) => c.name).join(', ')
                                    : "All Classes",
                                style: const TextStyle(
                                    color: AppColors.backgroundLight,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          Container(height: 40, width: 1, color: Colors.white),
                          const Column(
                            children: [
                              Text("Duration",
                                  style: TextStyle(
                                      color: AppColors.backgroundLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("N/A",
                                  style: TextStyle(
                                      color: AppColors.backgroundLight,
                                      fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 185,
            viewportFraction: 0.90,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayCurve: Curves.easeIn,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() => currentAssessmentIndex = index);
            },
          ),
        ),
      ],
    ),
  );
}


Widget _buildRecentActivity(OverviewProvider recentProvider) {
  final activities = recentProvider.recentActivities ?? [];

  if (recentProvider.isLoading && activities.isEmpty) {
    return const Center(child: CircularProgressIndicator());
  }

final displayActivities = activities
      .where((activity) => activity.createdBy.isNotEmpty &&
          activity.type.isNotEmpty &&
          activity.courseName.isNotEmpty &&
          activity.datePosted.isNotEmpty)
      .toList();

  if (displayActivities.isEmpty) {
    return const Center(child: Text("No recent activities available"));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Recent activity",
          style: AppTextStyles.normal600(
              fontSize: 18, color: AppColors.backgroundDark),
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
                if (activity.type.toLowerCase() == 'material') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecentMaterial(
                      itemId: activity.id,
                        syllabusId: activity.syllabusId,
                        courseId: activity.courseId.toString(),
                        levelId: activity.levelId,
                       // classId: activity.classId,
                        courseName: activity.courseName,
                      ),
                    ),
                  );
                } else if (activity.type.toLowerCase() == 'assignment') {
                  print("navigating to assignment details for itemId: ${activity.id}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecentAssignment(
                      
                        itemId: activity.id,
                        syllabusId: activity.syllabusId,
                        courseId: activity.courseId.toString(),
                        levelId: activity.levelId,
                     
                        courseName: activity.courseName,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
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
                        backgroundImage:
                            AssetImage("assets/images/student/avatar3.svg"),
                      ),
                      const SizedBox(width: 12),
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
                                  TextSpan(text: "${activity.createdBy} "),
                                  TextSpan(
                                      text: "${activity.type} ",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  TextSpan(
                                      text: activity.courseName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(activity.datePosted,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
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
}


  Color _getAssessmentColor(int index) {
    final colors = [
      AppColors.paymentTxtColor1,
      Colors.orangeAccent,
      Colors.greenAccent,
    ];
    return colors[index % colors.length];
  }
}
