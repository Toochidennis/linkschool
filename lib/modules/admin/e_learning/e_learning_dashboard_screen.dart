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

class _ELearningDashboardScreenState extends State<ELearningDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  int currentAssessmentIndex = 0;
  int currentActivityIndex = 0;
  late PageController activityController;
  Timer? activityTimer;

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
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Animations will run after user data is loaded

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
    print(
        "total activities: ${Provider.of<OverviewProvider>(context, listen: false).recentQuizzes.length ?? 0}");

    // Load user data

    _loadUserData().then((_) {
      final recentProvider =
          Provider.of<OverviewProvider>(context, listen: false);
      try {
        recentProvider.fetchOverview(academicTerm); // Pass the actual term
      } catch (e) {
        print('Error fetching dashboard data: $e');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    activityController.dispose();
    activityTimer?.cancel();
    super.dispose();
  }

  void _runEntranceAnimations() {
    if (!mounted) return;
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bounceController.forward();
    });
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    // Calculate interval with proper bounds
    final double intervalStart = (index * 0.05).clamp(0.0, 0.8);
    final double intervalEnd = (intervalStart + 0.2).clamp(0.2, 1.0);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.3 + (index * 0.05).clamp(0.0, 0.5)),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                intervalStart,
                intervalEnd,
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

  Widget _buildQuickActionButton({
    required String label,
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 800 + (index * 200)),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Icon(
                            icon,
                            size: 24,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic>? userData;
  List<dynamic> levelNames = [];
  List<dynamic> courseNames = [];
  List<dynamic> classNames = [];
  List<dynamic> levelsWithCourses =
      []; // New list to store only levels with classes
  String selectedLevelId = '';
  String selectedCourseId = '';
  String academicTerm = '';

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
        levelNames = levels
            .map((level) =>
                [(level['id'] ?? '').toString(), level['level_name'] ?? ''])
            .toList();

        // Extract all courses
        final courses = data['courses'] ?? [];
        courseNames = courses
            .map((course) => [
                  (course['id'] ?? '').toString(),
                  (course['course_name'] ?? '').toString().trim(),
                  (course['level_id'] ?? '').toString()
                ])
            .toList();

        // Extract all classes (including empty ones if you want them)
        final classes = data['classes'] ?? [];
        classNames = classes
            .where((clazz) =>
                clazz['class_name'] != null &&
                clazz['class_name'].toString().trim().isNotEmpty)
            .map((clazz) => [
                  (clazz['id'] ?? '').toString(),
                  (clazz['class_name'] ?? '').toString().trim(),
                  (clazz['level_id'] ?? '').toString()
                ])
            .toList();

        setState(() {
          userData = processedData;
          levelsWithCourses = classNames;
          academicTerm = term; // Pass the actual term
        });

        print('All Levels: $levelNames');
        print('All Courses: $courseNames');
        print('All Classes: $classNames');

        // Start entrance animations now that user data is ready
        _runEntranceAnimations();
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
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await recentProvider
                .fetchOverview(academicTerm); // Pass the actual term
          } catch (e) {
            print('Error refreshing dashboard data: $e');
          }
        },
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildAnimatedCard(
                  index: 0,
                  child: _buildTopContainers(
                    recentProvider,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
              SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildAnimatedCard(
                      index: 1,
                      child: _buildRecentActivity(
                        recentProvider,
                      ),
                    ),
                  )),
              const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
              SliverToBoxAdapter(
                child: _buildAnimatedCard(
                  index: 2,
                  child: Constants.heading600(
                    title: 'Select Class',
                    titleSize: 18.0,
                    titleColor: AppColors.resultColor1,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildAnimatedCard(
                  index: 3,
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
              ),
            ],
          ),
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

            // classes text (kept your original logic intent)
            final classesText =
                (assessment is RecentQuizModel && assessment.levelId.isNotEmpty)
                    ? assessment.classes.map((c) => c.name).join(', ')
                    : "All Classes";

            final bg = _getAssessmentColor(index);

            return GestureDetector(
              onTap: () {
                print("Tapped on quiz id: $quizId");
                if (quizId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecentQuiz(
                        levelId:
                            assessment is RecentQuizModel ? assessment.levelId : '',
                        syllabusId: assessment is RecentQuizModel
                            ? assessment.syllabusId.toString()
                            : '',
                        courseId: assessment is RecentQuizModel
                            ? assessment.courseId.toString()
                            : '',
                        courseName:
                            assessment is RecentQuizModel ? assessment.courseName : '',
                        quizId: quizId,
                      ),
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
                      // Decorative soft circles (keeps card lively without clutter)
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
                            // TOP ROW: Title + Date pill
                           // TOP: Subject + Title + Date
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white.withOpacity(0.18),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
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

                            // MID: Classes block (clearer hierarchy)
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
                                        color: Colors.white.withOpacity(0.18)),
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
                                        color: Colors.white.withOpacity(0.18)),
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
          }).toList(),
          options: CarouselOptions(
            height: 205,
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
        .where((activity) =>
            activity.createdBy.isNotEmpty &&
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
                    print(
                        "navigating to assignment details for itemId: ${activity.id}");
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
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
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
