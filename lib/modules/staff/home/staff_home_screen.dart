import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/main.dart';
import 'package:linkschool/modules/admin/home/portal_news_item.dart';
import 'package:linkschool/modules/admin/home/quick_actions/see_all_feed.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/explore/home/custom_button_item.dart';
import 'package:linkschool/modules/model/staff/dashboard_model.dart'
    show StafFeed;
import 'package:linkschool/modules/model/admin/home/dashboard_feed_model.dart'
    show Feed;
import 'package:linkschool/modules/providers/staff/staff_dashboard_provider.dart';
import 'package:linkschool/modules/staff/home/form_classes_screen.dart';
import 'package:linkschool/modules/staff/result/staff_result_screen.dart';
import 'package:linkschool/modules/student/home/feed_details_screen.dart';
import 'package:provider/provider.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen>
    with TickerProviderStateMixin, RouteAware {
  final PageController _pageController = PageController(viewportFraction: 0.90);
  Timer? _timer;
  int _currentPage = 0;
  late double opacity;
  String profileImageUrl =
      'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late TextEditingController _editTitleController;
  late TextEditingController _editContentController;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _newsController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  int? _editingFeedId;
  Map<String, dynamic>? _editingFeedData;
  bool _showAddForm = false;
  String _selectedType = 'question';
  int? creatorId;
  String? creatorName;
  int? academicTerm;
  String? userRole;

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startAutoScroll();
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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StaffDashboardProvider>(context, listen: false)
          .fetchDashboardData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    Provider.of<StaffDashboardProvider>(context, listen: false)
        .fetchDashboardData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _questionController.dispose();
    _newsController.dispose();
    _titleController.dispose();
    if (_editingFeedId != null) {
      _editTitleController.dispose();
      _editContentController.dispose();
    }
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
      if (storedUserData != null) {
        final dataMap = storedUserData is String
            ? json.decode(storedUserData)
            : storedUserData as Map<String, dynamic>;
        final data = dataMap['response']?['data'] ?? dataMap['data'] ?? {};
        final profile = data['profile'] ?? {};
        final settings = data['settings'] ?? {};
        setState(() {
          creatorId = profile['staff_id'] is int
              ? profile['staff_id']
              : int.tryParse(profile['staff_id'].toString());
          userRole = profile['role']?.toString() ?? 'staff';
          creatorName = profile['name']?.toString() ?? '';
          academicTerm = settings['term'] is int
              ? settings['term']
              : int.tryParse(settings['term'].toString());
        });
        debugPrint(
            '✅ User loaded: ID=$creatorId, Name=$creatorName, Term=$academicTerm');
      } else {
        debugPrint('⚠️ No stored user data found.');
      }
    } catch (e, stack) {
      debugPrint(stack.toString());
      if (mounted) {
        CustomToaster.toastError(context, 'Error', 'Failed to load user data');
      }
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
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
              curve: Interval(
                index * 0.1,
                1.0,
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

  Widget _buildAddContentForm() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(8.0),
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
                'Add New Content',
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
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.textFieldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textFieldBorderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = 'news';
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.text2Light,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'News Feed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: const TextStyle(
                color: AppColors.text5Light,
                fontSize: 14,
                fontFamily: 'Urbanist',
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
            controller: _newsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "news content here...",
              hintStyle: const TextStyle(
                color: AppColors.text5Light,
                fontSize: 14,
                fontFamily: 'Urbanist',
              ),
              filled: true,
              fillColor: AppColors.textFieldLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: AppColors.textFieldBorderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: AppColors.textFieldBorderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: AppColors.text2Light, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _handleSubmit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.text2Light,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Add ${_selectedType == 'question' ? 'Announcement' : 'News Feed'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    final controller = _newsController;
    final title = _titleController.text.trim();
    final content = controller.text.trim();
    final provider =
        Provider.of<StaffDashboardProvider>(context, listen: false);
    try {
      if (content.isNotEmpty) {
        final payload = {
          'title': title,
          'type': 'news',
          'parent_id': 0,
          'content': content,
          'author_name': creatorName,
          'author_id': creatorId,
          'created_at': DateTime.now().toIso8601String(),
          'replies': [],
        };
        await provider.createFeed(payload);
        CustomToaster.toastSuccess(
            context, 'Success', 'Feed added successfully');
        _titleController.clear();
        controller.clear();
        setState(() {
          _showAddForm = false;
        });
      }
    } catch (e) {
      CustomToaster.toastError(context, 'Failed', 'Failed to add feed $e');
    }
  }

  void _startEditing(StafFeed feed) {
    _editTitleController = TextEditingController(text: feed.title);
    _editContentController = TextEditingController(text: feed.content);
    setState(() {
      _editingFeedId = feed.id;
      _editingFeedData = {
        'title': feed.title,
        'content': feed.content,
      };
    });
  }

  void _cancelEditing() {
    _editTitleController.dispose();
    _editContentController.dispose();
    setState(() {
      _editingFeedId = null;
      _editingFeedData = null;
    });
  }

  void _saveEditing(StafFeed feed) async {
    final provider =
        Provider.of<StaffDashboardProvider>(context, listen: false);
    try {
      final updatedFeed = {
        'id': feed.id,
        'title': _editingFeedData?['title'] ?? '',
        'content': _editingFeedData?['content'] ?? '',
        'author_id': feed.authorId,
        'author_name': feed.authorName,
        'type': feed.type,
        'created_at': feed.createdAt,
        'parent_id': feed.parentId,
        'replies': feed.replies.map((r) => r.toJson()).toList(),
      };
      debugPrint('Updated Feed Data: $updatedFeed');
      await provider.updateFeed(feed.id.toString(), updatedFeed);
      if (mounted) {
        CustomToaster.toastSuccess(
            context, 'Updated', 'Feed updated successfully');
        _cancelEditing();
      }
    } catch (e) {
      if (mounted) {
        CustomToaster.toastError(context, 'Error', 'Failed to update feed: $e');
        debugPrint('Error updating feed: ${feed.id}, Error: $e');
      }
    }
  }

  Future<void> _confirmDelete(StafFeed feed) async {
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
          Provider.of<StaffDashboardProvider>(context, listen: false);
      await provider.deleteFeed(feed.id.toString());
      if (mounted) {
        CustomToaster.toastSuccess(
            context, 'Deleted', 'Feed deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        CustomToaster.toastError(context, 'Error', 'Failed to delete feed');
      }
    }
  }

  Widget _buildEditForm(StafFeed feed, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                'Edit ${feed.type == 'announcement' ? 'Announcement' : 'News'}',
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

  String _formatNotificationMessage(
      String? title, String? type, String? courseName) {
    if (type == null) return 'posted a new update';
    final courseText =
        (courseName != null && courseName.isNotEmpty) ? ' for $courseName' : '';

    switch (type.toLowerCase()) {
      case 'news':
        return 'shared a news update: $title $courseText';

      case 'comment':
        return 'posted a comment $title $courseText';
      case 'question':
        return 'asked a question:  $title $courseText';
      case 'assignment':
        return 'uploaded an assignment:  $title $courseText';
      case 'material':
        return 'uploaded a material $title $courseText';
      default:
        return 'posted:  $title $courseText';
    }
  }

  Widget _buildNotificationCard(String name, String message, String time,
      String avatarPath, String courseName, String type) {
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
                        fontSize: 16, color: AppColors.studentTxtColor2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatNotificationMessage(message, type, courseName),
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: AppTextStyles.normal500(
                        fontSize: 16, color: AppColors.text5Light),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    final provider =
        Provider.of<StaffDashboardProvider>(context, listen: false);
    return Scaffold(
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: creatorName ?? 'Staff',
        showNotification: false,
        onNotificationTap: () {},
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await Provider.of<StaffDashboardProvider>(context,
                        listen: false)
                    .fetchDashboardData(refresh: true);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                child: Consumer<StaffDashboardProvider>(
                  builder: (context, provider, _) {
                    final feeds = [
                      ...provider.newsFeeds,
                      ...provider.questionFeeds
                    ];
                    final notifications = provider.recentActivities;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 140,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: provider.recentActivities.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return AnimatedBuilder(
                                animation: _pageController,
                                builder: (context, child) {
                                  double scale = 1.0;
                                  if (_pageController.position.haveDimensions) {
                                    num pageOffset =
                                        _pageController.page ?? _currentPage;
                                    scale =
                                        (1 - ((pageOffset - index).abs() * 0.2))
                                            .clamp(0.8, 1.0);
                                  }
                                  return Transform.scale(
                                    scale: scale,
                                    child: _buildNotificationCard(
                                      notifications[index].createdBy ??
                                          'Unknown',
                                      notifications[index].title ??
                                          '', // This becomes the 'title' parameter
                                      notifications[index].datePosted ??
                                          '', // This becomes 'time'
                                      'assets/images/student/avatar1.svg',
                                      notifications[index].courseName ??
                                          '', // This becomes 'courseName'
                                      notifications[index].type ??
                                          '', // This becomes 'type'
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                       
                        const SizedBox(height: 18),
                        Text(
                          'You can...',
                          style: AppTextStyles.normal600(
                              fontSize: 20, color: AppColors.primaryLight),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomButtonItem(
                              backgroundColor: AppColors.studentCtnColor3,
                              borderColor: AppColors.portalButton1BorderLight,
                              textColor: AppColors.staffTxtColor1,
                              label: 'Form Classes',
                              number: 5,
                              iconPath:
                                  'assets/icons/student/knowledge_icon.svg',
                              iconHeight: 40.0,
                              iconWidth: 28.0,
                              destination: FormClassesScreen(),
                            ),
                            const SizedBox(width: 8.0),
                            CustomButtonItem(
                                backgroundColor: AppColors.staffCtnColor1,
                                borderColor: AppColors.secondaryLight,
                                textColor: AppColors.staffTxtColor2,
                                label: 'Courses',
                                number: 3,
                                iconPath:
                                    'assets/icons/student/study_icon.svg',
                                iconHeight: 40.0,
                                iconWidth: 36.0,
                                destination: StaffResultScreen()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildAnimatedCard(
                          index: 7,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.text2Light
                                            .withOpacity(0.1),
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
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showAddForm = !_showAddForm;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.text2Light,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.text2Light
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _showAddForm
                                                  ? Icons.close
                                                  : Icons.add,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _showAddForm ? 'Close' : 'Add',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Urbanist',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_showAddForm)
                          _buildAnimatedCard(
                            index: 8,
                            child: _buildAddContentForm(),
                          ),
                        if (_showAddForm) const SizedBox(height: 16),
                        _buildAnimatedCard(
                          index: 9,
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
                              if (!provider.isLoading && feeds.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No feeds available yet.',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              if (feeds.isNotEmpty)
                                Column(
                                  children: feeds.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final feed = entry.value;
                                    if (_editingFeedId == feed.id) {
                                      return _buildEditForm(feed, index);
                                    }
                                    return TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0, end: 1),
                                      duration:
                                          const Duration(milliseconds: 600),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      FeedDetailsScreen(
                                                    replies: feed.replies
                                                        .map((stafFeed) =>
                                                            Feed.fromJson(
                                                                stafFeed
                                                                    .toJson()))
                                                        .toList(),
                                                    profileImageUrl:
                                                        profileImageUrl,
                                                    name: feed.authorName,
                                                    content: feed.content,
                                                    interactions:
                                                        feed.replies.length,
                                                    time: feed.createdAt,
                                                    parentId: feed.id,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                PortalNewsItem(
                                                  profileImageUrl:
                                                      profileImageUrl,
                                                  name: feed.authorName,
                                                  newsContent: feed.content,
                                                  time: feed.createdAt,
                                                  title: feed.title,
                                                  CreatorId:
                                                      creatorId.toString(),
                                                  authorId: feed.authorId,
                                                  role: userRole,
                                                  edit: () =>
                                                      _startEditing(feed),
                                                  delete: () =>
                                                      _confirmDelete(feed),
                                                  comments: feed.replies.length,
                                                ),
                                              ],
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
                      ],
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _showAddForm = !_showAddForm;
                    });
                  },
                  backgroundColor: Colors.red,
                  child: Icon(
                    _showAddForm ? Icons.close : Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
