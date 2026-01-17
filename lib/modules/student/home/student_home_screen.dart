import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:hive/hive.dart';
import 'package:linkschool/modules/admin/home/quick_actions/see_all_feed.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/custom_toaster.dart'; // For toasts
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/explore/home/custom_button_item.dart';
import 'package:linkschool/modules/model/admin/home/dashboard_feed_model.dart'
    show Feed;
import 'package:linkschool/modules/student/home/feed_details_screen.dart';
import 'package:linkschool/modules/student/home/new_post_dialog.dart';
import 'package:linkschool/modules/student/payment/student_payment_home_screen.dart';
import 'package:linkschool/modules/student/result/student_result_screen.dart';
import 'package:linkschool/modules/admin/home/portal_news_item.dart'; // Reuse for feed items
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
import 'package:linkschool/modules/providers/student/payment_provider.dart';
import 'package:linkschool/modules/providers/student/home/student_dashboard_feed_provider.dart';

class StudentHomeScreen extends StatefulWidget {
  final VoidCallback logout;
  const StudentHomeScreen({super.key, required this.logout});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with TickerProviderStateMixin {
  DashboardData? dashboardData;
  SingleElearningContentData? elearningContentData;
  // Add these with your other controllers
  final TextEditingController _questionTitleController =
      TextEditingController();
  final TextEditingController _questionContentController =
      TextEditingController();

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  int currentAssessmentIndex = 0;
  int currentActivityIndex = 0;
  late PageController activityController;
  Timer? assessmentTimer;
  Timer? activityTimer;
  late double opacity;

  final PageController _pageController = PageController(viewportFraction: 0.90);
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

  // Animation controllers for feed section (similar to PortalHome)
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  // Feed form controllers and state
  late TextEditingController _editTitleController;
  late TextEditingController _editContentController;
  int? _editingFeedId;
  Map<String, dynamic>? _editingFeedData;
  bool _showAddForm = false;
  final String _selectedType = 'feed'; // Default type
  int? creatorId;
  String? creatorName;
  int? academicTerm;
  String? userRole;

  @override
  void initState() {
    super.initState();
    activityController = PageController(viewportFraction: 0.90);

    // Initialize animation controllers
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
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _bounceController.forward();
    });

    // Initialize feed form controllers
    _editTitleController = TextEditingController();
    _editContentController = TextEditingController();

    _initializeData();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
      final dataMap = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData as Map<String, dynamic>;
      final data = dataMap['response']?['data'] ?? dataMap['data'] ?? {};
      final profile = data['profile'] ?? {};
      final settings = data['settings'] ?? {};

      setState(() {
        creatorId =
            int.tryParse(profile['id'].toString()) ?? 0; // Adjust to student ID
        creatorName = profile['name']?.toString() ?? 'Student';
        userRole = profile['role']?.toString() ?? 'student';
        academicTerm = int.tryParse(settings['term'].toString()) ?? 0;
      });
    } catch (e) {
      if (mounted) {
        CustomToaster.toastError(context, 'Error', 'Failed to load user data');
      }
    }
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      fetchDashboard();
      // Fetch feed data
      Provider.of<StudentDashboardFeedProvider>(context, listen: false)
          .fetchFeedData(
        class_id: getuserdata()['profile']['class_id'].toString(),
        level_id: getuserdata()['profile']['level_id'].toString(),
        term: getuserdata()['settings']['term'].toString(),
      );
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

      if (data?.recentActivities.isNotEmpty == true) {
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
    activityTimer?.cancel();
    final activities = dashboardData?.recentActivities ?? [];
    if (activities.isEmpty) return;

    activityTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      if (activities.isEmpty) {
        activityTimer?.cancel();
        return;
      }
      if (activityController.hasClients &&
          activityController.positions.isNotEmpty) {
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

    final provider =
        Provider.of<SingleelearningcontentProvider>(context, listen: false);
    final data = await provider.fetchElearningContentData(contentid);

    if (!mounted) return;

    setState(() {
      elearningContentData = data;
    });
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

  Map<String, dynamic> getuserdata() {
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData =
        storedUserData is String ? json.decode(storedUserData) : storedUserData;
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

  @override
  void dispose() {
    _timer?.cancel();
    activityTimer?.cancel();
    assessmentTimer?.cancel();
    _pageController.dispose();
    activityController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _editTitleController.dispose();
    _editContentController.dispose();
    _questionTitleController.dispose(); // Add this
    _questionContentController.dispose(); // Add this
    super.dispose();
  }

  // Animation wrapper for feed items
  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.3 + (index * 0.1)),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Interval(index * 0.1, 1.0, curve: Curves.elasticOut),
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Edit form for feeds
  Widget _buildEditForm(Feed feed, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border:
            Border.all(color: AppColors.text2Light.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.text2Light.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Feed',
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.text2Light,
                ),
              ),
              IconButton(
                onPressed: _cancelEditing,
                icon: const Icon(Icons.close, color: AppColors.text5Light),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _editTitleController,
            onChanged: (value) {
              setState(() {
                _editingFeedData?['title'] = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: const TextStyle(color: AppColors.text5Light),
              filled: true,
              fillColor: AppColors.textFieldLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.textFieldBorderLight),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _editContentController,
            onChanged: (value) {
              setState(() {
                _editingFeedData?['content'] = value;
              });
            },
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Content',
              hintStyle: const TextStyle(color: AppColors.text5Light),
              filled: true,
              fillColor: AppColors.textFieldLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.textFieldBorderLight),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.text5Light),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.text5Light,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveEditing(feed),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.text2Light,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  void _startEditing(Feed feed) {
    _editTitleController = TextEditingController(text: feed.title ?? '');
    _editContentController = TextEditingController(text: feed.content ?? '');
    setState(() {
      _editingFeedId = feed.id;
      _editingFeedData = {
        'title': feed.title ?? '',
        'content': feed.content ?? '',
      };
    });
  }

  void _cancelEditing() {
    _editTitleController.dispose();
    _editContentController.dispose();
    setState(() {
      _editingFeedId = null;
      _editingFeedData = null;
      _editTitleController = TextEditingController();
      _editContentController = TextEditingController();
    });
  }

  void _saveEditing(Feed feed) async {
    final provider =
        Provider.of<StudentDashboardFeedProvider>(context, listen: false);
    try {
      final updatedFeed = {
        'id': feed.id,
        'title': _editingFeedData?['title'] ?? '',
        'content': _editingFeedData?['content'] ?? '',
        'author_id': creatorId,
        'author_name': creatorName,
        'type': feed.type ?? 'news',
        'term': academicTerm,
      };
      await provider.updateFeed(updatedFeed, feed.id.toString());
      if (mounted) {
        CustomToaster.toastSuccess(
            context, 'Updated', 'Feed updated successfully');
        _cancelEditing();
        await provider.fetchFeedData(
            refresh: true,
            class_id: getuserdata()['profile']['class_id'].toString(),
            level_id: getuserdata()['profile']['level_id'].toString(),
            term: getuserdata()['settings']['term'].toString());
      }
    } catch (e) {
      if (mounted) {
        CustomToaster.toastError(context, 'Error', 'Failed to update feed: $e');
      }
    }
  }

  Future<void> _confirmDelete(Feed feed) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Feed'),
        content: const Text('Are you sure you want to delete this feed post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final provider =
          Provider.of<StudentDashboardFeedProvider>(context, listen: false);
      await provider.deleteFeed(feed.id.toString());
      if (mounted) {
        CustomToaster.toastSuccess(
            context, 'Deleted', 'Feed deleted successfully');
        await provider.fetchFeedData(
            refresh: true,
            class_id: getuserdata()['profile']['class_id'].toString(),
            level_id: getuserdata()['profile']['level_id'].toString(),
            term: getuserdata()['settings']['term'].toString());
      }
    } catch (e) {
      if (mounted) {
        CustomToaster.toastError(context, 'Error', 'Failed to delete feed: $e');
      }
    }
  }

  Widget _buildAddContentForm() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.text2Light.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.text2Light.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add New Question',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.text2Light,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showAddForm = false;
                  });
                },
                icon: const Icon(
                  Icons.close,
                  color: AppColors.text5Light,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _questionTitleController, // Use class-level controller
            decoration: InputDecoration(
              hintText: 'Question Title',
              hintStyle: const TextStyle(
                color: AppColors.text5Light,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.textFieldLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: AppColors.textFieldBorderLight),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller:
                _questionContentController, // Use class-level controller
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter your question here...',
              hintStyle: const TextStyle(
                color: AppColors.text5Light,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.textFieldLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: AppColors.textFieldBorderLight),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _handleSubmit(
                    _questionTitleController, _questionContentController);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.text2Light,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Add Question',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit(TextEditingController titleController,
      TextEditingController contentController) async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final provider =
        Provider.of<StudentDashboardFeedProvider>(context, listen: false);

    try {
      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a question title'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter question content'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final payload = {
        'title': title,
        'type': 'question',
        'parent_id': 0,
        'content': content,
        'author_name': creatorName,
        'author_id': creatorId,
        'term': academicTerm,
        'files': <Map<String, dynamic>>[],
      };

      await provider.createFeed(
        payload,
        class_id: getuserdata()['profile']['class_id'].toString(),
        level_id: getuserdata()['profile']['level_id'].toString(),
        term: getuserdata()['settings']['term'].toString(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Question added successfully!'),
            backgroundColor: AppColors.text2Light,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Clear the controllers
        titleController.clear();
        contentController.clear();

        setState(() {
          _showAddForm = false;
        });

        // Refresh feeds
        await provider.fetchFeedData(
          refresh: true,
          class_id: getuserdata()['profile']['class_id'].toString(),
          level_id: getuserdata()['profile']['level_id'].toString(),
          term: getuserdata()['settings']['term'].toString(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add question: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Scaffold(
        appBar: CustomStudentAppBar(
          title: 'Welcome',
          subtitle: getuserdata()['profile']['name'] ?? 'Guest',
          showNotification: true,
          showPostInput: false,
          onNotificationTap: () {},
          //onPostTap: _showNewPostDialog,
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

    final activities = dashboardData?.recentActivities ?? [];
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    final userName = getuserdata()['profile']['name'] ?? 'Guest';

    return Scaffold(
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: userName,
        showNotification: true,
        showPostInput: false,
        onNotificationTap: () {},
        // onPostTap: _showNewPostDialog,
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await fetchDashboard();
                await Provider.of<StudentDashboardFeedProvider>(context,
                        listen: false)
                    .fetchFeedData(
                        refresh: true,
                        class_id:
                            getuserdata()['profile']['class_id'].toString(),
                        level_id:
                            getuserdata()['profile']['level_id'].toString(),
                        term: getuserdata()['settings']['term'].toString());
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(height: 8),
                  const SizedBox(height: 16),
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
                      builder: (context) =>
                          StudentViewDetailPaymentDialog(invoice: invoices[0]),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('No invoice available for payment.')),
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
                  destination: StudentPaymentHomeScreen(
                    logout: widget.logout,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedSection() {
    return Consumer<StudentDashboardFeedProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedCard(
              index: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.text2Light.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.feed_rounded,
                            color: AppColors.text2Light,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'School Feeds',
                          style: AppTextStyles.normal600(
                            fontSize: 20,
                            color: AppColors.text2Light,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAddForm = !_showAddForm;
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.text2Light.withOpacity(0.1),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                _showAddForm ? Icons.close : Icons.add,
                                color: AppColors.text2Light,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _showAddForm ? 'Close' : 'Add',
                                style: TextStyle(
                                  color: AppColors.text2Light,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AllFeedsScreen(), // Ensure you have this screen
                          ),
                        );
                      },
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: AppColors.text2Light,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_showAddForm)
              _buildAnimatedCard(
                index: 1,
                child: _buildAddContentForm(),
              ),
            if (_showAddForm) const SizedBox(height: 16),
            _buildAnimatedCard(
              index: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (!provider.isLoading && provider.feeds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No feeds available yet.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    if (provider.feeds.isNotEmpty)
                      Column(
                        children: provider.feeds.asMap().entries.map((entry) {
                          final index = entry.key;
                          final feed = entry.value;
                          if (_editingFeedId == feed.id) {
                            return _buildEditForm(feed, index);
                          }
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FeedDetailsScreen(
                                          replies: [...feed.replies],
                                          profileImageUrl: profileImageUrl,
                                          name: feed.authorName ?? 'Unknown',
                                          content: feed.content,
                                          interactions: feed.replies.length,
                                          time: feed.createdAt ?? 'Unknown',
                                          parentId: feed.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: PortalNewsItem(
                                    profileImageUrl: profileImageUrl,
                                    name: feed.authorName ?? 'Unknown',
                                    newsContent: feed.content,
                                    time: feed.createdAt ?? 'Unknown',
                                    title: feed.title ?? '',
                                    CreatorId: creatorId.toString(),
                                    authorId: feed.authorId ?? 0,
                                    role: userRole,
                                    edit: () => _startEditing(feed),
                                    delete: () => _confirmDelete(feed),
                                    comments: feed.replies.length,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleActivityTap(dynamic activity) async {
    if (activity?.id == null) return;

    await fetchSingleElearning(activity.id ?? 0);
    if (!mounted) return;

    if (elearningContentData?.settings != null) {
      final userBox = Hive.box('userData');
      final List<dynamic> quizzestaken =
          userBox.get('quizzes', defaultValue: []);
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
      final List<dynamic> assignmentssubmitted =
          userBox.get('assignments', defaultValue: []);
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
}
