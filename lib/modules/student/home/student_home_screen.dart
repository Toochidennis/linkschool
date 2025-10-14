import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/explore/home/custom_button_item.dart';
import 'package:linkschool/modules/student/home/feed_details_screen.dart';
import 'package:linkschool/modules/student/home/new_post_dialog.dart';
import 'package:linkschool/modules/student/result/student_result_screen.dart';
import 'package:provider/provider.dart';

import '../../model/student/dashboard_model.dart';
import '../../model/student/single_elearningcontentmodel.dart';
import '../../providers/student/dashboard_provider.dart';
import '../../providers/student/single_elearningcontent_provider.dart';
import '../elearning/single_assignment_detail_screen.dart';
import '../elearning/single_assignment_score_view.dart';
import '../elearning/single_material_detail_screen.dart';
import '../elearning/single_quiz_intro_page.dart';
import '../elearning/single_quiz_score_page.dart';
import 'package:linkschool/modules/student/payment/student_view_detail_payment.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/student/payment_provider.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  DashboardData? dashboardData;
  SingleElearningContentData? elearningContentData;

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  int currentAssessmentIndex = 0;
  int currentActivityIndex = 0;
  late PageController activityController;
  Timer? assessmentTimer;
  Timer? activityTimer;
  late double opacity;

  final PageController _pageController = PageController(
    viewportFraction: 0.90,
  );
  Timer? _timer;
  int _currentPage = 0;
  String profileImageUrl =
      'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86';

  final List<Map<String, String>> notifications = [
    {
      'name': 'Dennis Toochi',
      'message': 'posted an Qsts on Homeostasis for JSS2',
      'time': 'Yesterday at 9:42 AM',
      'avatar': 'assets/images/student/avatar1.svg',
    },
    {
      'name': 'Ifeanyi Joseph',
      'message': 'posted new course materials for SSS3',
      'time': 'Today at 8:30 AM',
      'avatar': 'assets/images/student/avatar2.svg',
    },
    {
      'name': 'Sarah Okoro',
      'message': 'scheduled a class meeting for Mathematics',
      'time': 'Just now',
      'avatar': 'assets/images/student/avatar3.svg',
    },
  ];

  List<String> feedCardNames = ['John Dennis', 'Jane Emaka', 'Bob John'];

  @override
  void initState() {
    super.initState();
    activityController = PageController(viewportFraction: 0.90);
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      fetchDashboard();
    });
  }

  Future<void> fetchDashboard() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      final data = await provider.fetchDashboardData(
        class_id: getuserdata()['profile']['class_id'].toString(),
        level_id: getuserdata()['profile']['level_id'].toString(),
        term: getuserdata()['settings']['term'].toString(),
      );
      
      if (!mounted) return;
      
      setState(() {
        dashboardData = data;
        isLoading = false;
      });

      // Start auto-scroll only if we have data
      if (data?.recentActivities?.isNotEmpty == true) {
        _startActivityAutoScroll();
      }
      _startAutoScroll();
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to load dashboard: $e';
      });
    }
  }

  void _startActivityAutoScroll() {
    // Cancel existing timer
    activityTimer?.cancel();
    
    final activities = dashboardData?.recentActivities ?? [];
    if (activities.isEmpty) return;

    activityTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      
      if (activities.isEmpty) {
        activityTimer?.cancel();
        return;
      }
      
      if (activityController.hasClients && activityController.positions.isNotEmpty) {
        setState(() {
          currentActivityIndex = (currentActivityIndex + 1) % activities.length;
        });
        
        activityController.animateToPage(
          currentActivityIndex,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> fetchSingleElearning(int contentid) async {
    if (!mounted) return;
    
    final provider = Provider.of<SingleelearningcontentProvider>(context, listen: false);
    final data = await provider.fetchElearningContentData(contentid);
    
    if (!mounted) return;
    
    setState(() {
      elearningContentData = data;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    activityTimer?.cancel();
    assessmentTimer?.cancel();
    _pageController.dispose();
    activityController.dispose();
    super.dispose();
  }

  Map<String, dynamic> getuserdata() {
    final userBox = Hive.box('userData');
    final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
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

  void _startAutoScroll() {
    if (!_pageController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _pageController.hasClients) {
          _startAutoScroll();
        }
      });
      return;
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) {
        timer.cancel();
        return;
      }

      if (_currentPage < notifications.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state
    if (hasError) {
      return Scaffold(
        appBar: CustomStudentAppBar(
          title: 'Welcome',
          subtitle: getuserdata()['profile']['name'] ?? 'Guest',
          showNotification: true,
          showPostInput: true,
          onNotificationTap: () {},
          onPostTap: _showNewPostDialog,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to Load Data',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.normal400(
                  fontSize: 14,
                  color: AppColors.text5Light,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchDashboard,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Main content with proper empty state handling
    final activities = dashboardData?.recentActivities ?? [];
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    final userName = getuserdata()['profile']['name'] ?? 'Guest';

    return Scaffold(
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: userName,
        showNotification: true,
        showPostInput: true,
        onNotificationTap: () {},
        onPostTap: _showNewPostDialog,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 120.0),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(height: 8),
                  const SizedBox(height: 16),
                  
                  // Activities Section with Empty State
                  _buildActivitiesSection(activities),
                  
                  const SizedBox(height: 24),
                  Text(
                    'You can...',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildFeedSection(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesSection(List<dynamic> activities) {
    if (activities.isEmpty) {
      return Container(
        height: 125,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'No recent activities',
                style: AppTextStyles.normal500(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 125,
      child: PageView.builder(
        controller: activityController,
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return GestureDetector(
            onTap: () => _handleActivityTap(activity),
            child: Card(
              elevation: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl),
                      radius: 16.0,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity?.createdBy ?? 'Unknown',
                            style: AppTextStyles.normal500(
                              fontSize: 16,
                              color: AppColors.studentTxtColor2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "posted a ${activity?.type ?? 'activity'} on ${activity?.title ?? 'Untitled'}",
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activity?.datePosted ?? 'Unknown date',
                            style: AppTextStyles.normal500(
                              fontSize: 16,
                              color: AppColors.text5Light,
                            ),
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CustomButtonItem(
            backgroundColor: AppColors.studentCtnColor3,
            borderColor: AppColors.portalButton1BorderLight,
            textColor: AppColors.paymentBtnColor1,
            label: 'Check\nResults',
            iconPath: 'assets/icons/result.svg',
            iconHeight: 40.0,
            iconWidth: 36.0,
            destination: StudentResultScreen(
              studentName: getuserdata()['profile']['name'],
              className: getuserdata()['profile']['class_name'],
            ),
          ),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Builder(
            builder: (context) {
              final invoiceProvider = Provider.of<InvoiceProvider>(context);
              final invoices = invoiceProvider.invoices ?? [];
              return GestureDetector(
                onTap: () {
                  if (invoices.isNotEmpty && invoices[0].amount > 0) {
                    showDialog(
                      context: context,
                      builder: (context) => StudentViewDetailPaymentDialog(invoice: invoices[0]),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No invoice available for payment.')),
                    );
                  }
                },
                child: CustomButtonItem(
                  backgroundColor: AppColors.studentCtnColor4,
                  borderColor: AppColors.portalButton2BorderLight,
                  textColor: AppColors.paymentTxtColor2,
                  label: 'Make\nPayment',
                  iconPath: 'assets/icons/payment.svg',
                  iconHeight: 40.0,
                  iconWidth: 36.0,
                  destination: null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Feed',
              style: AppTextStyles.normal600(
                fontSize: 20,
                color: AppColors.primaryLight,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: _buildFeedCard(
            'This is a mock data showing the info details of a recording.',
            '30 minutes ago',
            14,
            0,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: _buildFeedCard(
            'This is a mock data showing the info details of a recording.',
            '45 minutes ago',
            18,
            1,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildFeedCard(
            'This is a mock data showing the info details of a recording.',
            '1 hour ago',
            22,
            2,
          ),
        ),
      ],
    );
  }

  Future<void> _handleActivityTap(dynamic activity) async {
    if (activity?.id == null) return;
    
    await fetchSingleElearning(activity.id ?? 0);
    if (!mounted) return;
    
    // Your existing navigation logic...
    if (elearningContentData?.settings != null) {
      final userBox = Hive.box('userData');
      final List<dynamic> quizzestaken = userBox.get('quizzes', defaultValue: []);
      final int? quizId = elearningContentData?.settings!.id;
      if (quizzestaken.contains(quizId)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleQuizScoreView(
              childContent: elearningContentData,
              year: int.parse(getuserdata()['settings']['year'].toString()),
              term: getuserdata()['settings']['term'],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleQuizIntroPage(
              childContent: elearningContentData,
            ),
          ),
        );
      }
    } else if (elearningContentData?.type == 'material') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SingleMaterialDetailScreen(
            childContent: elearningContentData,
          ),
        ),
      );
    } else if (elearningContentData?.type == "assignment") {
      final userBox = Hive.box('userData');
      final List<dynamic> assignmentssubmitted = userBox.get('assignments', defaultValue: []);
      final int? assignmentId = elearningContentData?.id;

      if (assignmentssubmitted.contains(assignmentId)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleAssignmentScoreView(
              childContent: elearningContentData,
              year: int.parse(getuserdata()['settings']['year'].toString()),
              term: getuserdata()['settings']['term'],
              attachedMaterials: [""],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleAssignmentDetailsScreen(
              childContent: elearningContentData,
              title: elearningContentData?.title,
              id: elearningContentData?.id ?? 0,
            ),
          ),
        );
      }
    }
  }

  // ... rest of your existing _buildNotificationCard, _buildActionContainer, _buildFeedCard methods
  Widget _buildNotificationCard(
      String name, String message, String time, String avatarPath) {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
              radius: 16.0,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.normal500(
                      fontSize: 16,
                      color: AppColors.studentTxtColor2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: AppTextStyles.normal500(
                      fontSize: 16,
                      color: AppColors.text5Light,
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

  Widget _buildActionContainer(String text, String iconPath, Color bgColor) {
    List<String> textParts = text.split(' ');

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: bgColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 50,
            height: 50,
          ),
          const SizedBox(height: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: textParts
                .map((part) => Text(
                      part,
                      style: AppTextStyles.normal500(
                        fontSize: 14,
                        color: text == 'Results'
                            ? AppColors.studentTxtColor1
                            : AppColors.paymentTxtColor2,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(
      String content, String time, int interactions, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedDetailsScreen(
              name: feedCardNames[index],
              content: content,
              time: time,
              interactions: interactions,
              profileImageUrl: profileImageUrl,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 16.0,
          bottom: 16.0,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: AppColors.newsBorderColor,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(profileImageUrl),
                        radius: 16.0,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        feedCardNames[index],
                        style: AppTextStyles.normal500(
                          fontSize: 16,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(content),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_outline),
                        onPressed: () {},
                      ),
                      Text('$interactions'),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/comment.svg',
                          height: 20.0,
                          width: 20.0,
                        ),
                        onPressed: () {},
                      ),
                      Text('$interactions'),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: AppTextStyles.normal500(
                fontSize: 12,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}