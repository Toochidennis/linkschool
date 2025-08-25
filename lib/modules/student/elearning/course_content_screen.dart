import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/student/elearning/material_detail_screen.dart';
import 'package:linkschool/modules/student/elearning/quiz_intro_page.dart';
import 'package:linkschool/modules/auth/model/user.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/providers/student/elearningcontent_provider.dart';
import 'package:linkschool/modules/student/elearning/assignment_detail_screen.dart';
import 'package:linkschool/modules/student/elearning/material_screen.dart';
import 'package:provider/provider.dart';

import '../../model/student/dashboard_model.dart';
import '../../model/student/elearningcontent_model.dart';

class CourseContentScreen extends StatefulWidget {

  final DashboardData dashboardData;
  final String courseTitle;

  const CourseContentScreen({super.key, required this.dashboardData,required this.courseTitle});
  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  bool _isPunctualityExpanded = false;

  List<ElearningContentData>? elearningContentData;
  bool isLoading = true;

  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final elearningcontentprovider = Provider.of<ElearningContentProvider>(
          context, listen: false);
      elearningcontentprovider.fetchElearningContentData();
    });
    fetchElearningContentData();

  }
  String ellipsize(String? text, [int maxLength = 44]) {
    if (text == null) return '';
    return text.length <= maxLength ? text : '${text.substring(0, maxLength).trim()}...';
  }
  Future<void> fetchElearningContentData() async {
    final provider = Provider.of<ElearningContentProvider>(context, listen: false);
    final data = await provider.fetchElearningContentData(
    );

    setState(() {
      elearningContentData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if ( elearningContentData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    String termString = getTermString(getuserdata()['settings']['term']);
    String sessionString = deduceSession(widget.dashboardData.recentActivities.last.datePosted);

    AvailableCourse  selectedCourse = widget.dashboardData.availableCourses.firstWhere(
      (course) => course.courseName.toLowerCase() == widget.courseTitle.toLowerCase(),
);
    return SingleChildScrollView(
      child: Container(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(selectedCourse,sessionString,termString),
              const SizedBox(height: 16),

              Column(
                children: (elearningContentData ?? [])
                    .where((e) => e.type.toLowerCase() == 'no topic')
                    .map((e) => buildWithNoTopicSection(e
                ))
                    .toList(),
              ),
              Column(
                children: (elearningContentData ?? [])
                    .where((e) => e.type.toLowerCase() != 'no topic')
                    .map((e) => buildWithTopicSection(e
                ))
                    .toList(),
              )


            ],
          ),
        ),
      ),
    );
  }
  String deduceSession(String datePosted) {
    DateTime date = DateTime.parse(datePosted);
    int year = date.year;

    // If before September, session started the previous year
    if (date.month < 9) {
      return "${year - 1}/${year} Session";
    } else {
      return "${year}/${year + 1} Session";
    }
  }
  String getTermString(int term) {
    return {
      1: "1st",
      2: "2nd",
      3: "3rd",
    }[term] ?? "Unknown";
  }
  Widget buildWithNoTopicSection(ElearningContentData e) {
    return              Column(
      children: [
        // Row 1: What is Punctuality

        const SizedBox(height: 16),
        ...e.children.map<Widget>((child) {
          // If it's a quiz with settings
          if (child.settings!=null) {
            final settings = child.settings;
            return
              buildContentRowWithIconAndProgress(
                  iconPath: 'assets/icons/student/quiz_icon.svg',

                  title: settings?.title ?? "No title",
                  description: ellipsize(settings?.description) ?? "No description",
                  progressBarPercentage: 75,
                  onTap:(){
                    Navigator.push(
                      context,MaterialPageRoute(
                      builder: (context) => QuizIntroPage(childContent: child,),),
                    );
                  }
              );
          }
          else if (child.type == 'material') {
            return buildContentRowWithIconAndProgress(
                iconPath: 'assets/icons/student/note_icon.svg',

                title: child?.title ?? "No title",
                description: ellipsize(child?.description) ?? "No description",
                progressBarPercentage: 75,
                onTap:(){
                  Navigator.push(
                    context,MaterialPageRoute(
                    builder: (context) => MaterialDetailScreen(childContent: child,),),
                  );
                }
            );
          } else if (child.type=="assignment") {
            return buildContentRowWithIconAndProgress(
                iconPath: 'assets/icons/student/assignment_icon.svg',

                title: child?.title ?? "No title",
                description: ellipsize(child?.description) ?? "No description",
                progressBarPercentage: 75,
                onTap:(){
                  Navigator.push(
                    context,MaterialPageRoute(
                    builder: (context) => AssignmentDetailsScreen(childContent: child, title: e.title, id: e.id ?? 0),),
                  );
                }
            );
          } else {
            return SizedBox.shrink(); // If neither condition is met
          }
        }).toList(),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (e.title == "title" &&
                e.children.any((child) => child.settings?.type == "assignment")) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: buildContentRowWithIconAndProgress(
                  iconPath: 'assets/icons/student/loading_icon.svg',
                  title: 'Assignment',
                  description: 'Due date: 25 June, 2015 08:52am',
                  progressBarPercentage: 30, // Adjust this value as required
                  onTap: () {
                    // Handle tap
                  },
                ),
              ),
            ]

          ],
        ),

        const SizedBox(height: 16),
        // Row 3: First C.A

      ],
    );

  }

  Widget buildWithTopicSection(ElearningContentData e) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isPunctualityExpanded = !_isPunctualityExpanded;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                   Text(
                    e.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.paymentTxtColor1,
                    ),
                  ),
                  const Spacer(),
                  // Expand/collapse arrow
                  RotatedBox(
                    quarterTurns: _isPunctualityExpanded ? 2 : 0,
                    child: SvgPicture.asset(
                      'assets/icons/student/dropdown_icon.svg',
                      height: 24,
                      width: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.paymentTxtColor1,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade400),
          // Dropdown Content
          if (_isPunctualityExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child:
              Column(
                children: [
                  // Row 1: What is Punctuality

                  ...e.children.map<Widget>((child) {
                    // If it's a quiz with settings
                    if (child.settings!=null) {
                      final settings = child.settings;
                      return
                      buildContentRowWithIconAndProgress(
                        iconPath: 'assets/icons/student/quiz_icon.svg',

                        title: settings?.title ?? "No title",
                        description: ellipsize(settings?.description) ?? "No description",
                        progressBarPercentage: 75,
                        onTap:(){
                          Navigator.push(
                            context,MaterialPageRoute(
                            builder: (context) => QuizIntroPage(childContent: child,),),
                          );
                        }
                      );
                    }
                    else if (child.type == 'material') {
                      return buildContentRowWithIconAndProgress(
                          iconPath: 'assets/icons/student/note_icon.svg',

                          title: child?.title ?? "No title",
                          description: ellipsize(child?.description) ?? "No description",
                          progressBarPercentage: 75,
                          onTap:(){
                            Navigator.push(
                              context,MaterialPageRoute(
                              builder: (context) => MaterialDetailScreen(childContent: child,),),
                            );
                          }
                      );
                    } else if (child.type=="assignment") {
                      return buildContentRowWithIconAndProgress(
                          iconPath: 'assets/icons/student/assignment_icon.svg',

                          title: child?.title ?? "No title",
                          description: ellipsize(child?.description) ?? "No description",
                          progressBarPercentage: 75,
                          onTap:(){
                            Navigator.push(
                              context,MaterialPageRoute(
                              builder: (context) => AssignmentDetailsScreen(childContent: child, title: e.title, id: e.id!),),
                            );
                          }
                      );
                    } else {
                      return SizedBox.shrink(); // If neither condition is met
                    }
                  }).toList(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (e.title == "title" &&
                        e.children.any((child) => child.settings?.type == "assignment")) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: buildContentRowWithIconAndProgress(
                          iconPath: 'assets/icons/student/loading_icon.svg',
                          title: 'Assignment',
                          description: 'Due date: 25 June, 2015 08:52am',
                          progressBarPercentage: 30, // Adjust this value as required
                          onTap: () {
                            // Handle tap
                          },
                        ),
                      ),
                    ]

                  ],
                ),

                  const SizedBox(height: 16),
                  // Row 3: First C.A

                ],
              ),
            ),
        ],
      ),
    );
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
  Widget buildHeader(AvailableCourse availableCourse, String session, String term) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/student/header_background.svg',
                fit: BoxFit.cover,
              ),
            ),
             Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    availableCourse.courseName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    session,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    term,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContentRow(
    String iconPath,
    String title,
    String subtitle, [
    VoidCallback? onTap,
    List<ExpandedContentRow>? additionalContent,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SvgPicture.asset(iconPath, height: 32, width: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${title.split(':')[0]}: ',
                          style: const TextStyle(
                              color: AppColors.paymentTxtColor1,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: title.split(':').length > 1
                              ? title.split(':')[1].trim()
                              : '',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (additionalContent != null) ...additionalContent,
          ],
        ),
      ),
    );
  }

  Widget buildContentRowWithSubtitle(
      String iconPath, String title, String subtitle) {
    return Row(
      children: [
        SvgPicture.asset(iconPath, height: 32, width: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.backgroundDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildContentRowWithBadge(
      String iconPath, String title, String subtitle,
      {required String badgeText, required Color badgeColor}) {
    return Row(
      children: [
        SvgPicture.asset(iconPath, height: 32, width: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.backgroundDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            badgeText,
            style: const TextStyle(
              color: AppColors.paymentBtnColor1,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildContentRowWithIconAndProgress({
    required String iconPath,
    required String title,
    required String description,
    required int progressBarPercentage,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Row(
          children: [
            // SVG Icon
            SvgPicture.asset(
              iconPath,
              height: 45,
              width: 45,
            ),
            const SizedBox(width: 12),
            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (e.g., "Continue Reading")
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.paymentTxtColor1,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  // Description Text
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  LinearProgressIndicator(
                    value: progressBarPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 15),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandedContentRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final int progressBarPercentage;
  final String? badgeText;
  final Color? badgeColor;

  const ExpandedContentRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.progressBarPercentage,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.paymentTxtColor1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressBarPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          if (badgeText != null)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ContentRow extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final Color titleColor;

  const ContentRow({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    this.titleColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, height: 32, width: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${title.split(':')[0]}: ',
                        style: TextStyle(
                            color: titleColor, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: title.split(':').length > 1
                            ? title.split(':')[1].trim()
                            : '',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}