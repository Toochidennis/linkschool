import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/main.dart';
import 'dart:convert';
import 'package:linkschool/modules/admin/home/portal_news_item.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_course_screen.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_level_class_screen.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_staffs_screen.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_students_screen.dart';
import 'package:linkschool/modules/admin/home/quick_actions/see_all_feed.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';

import 'package:linkschool/modules/providers/admin/home/dashboard_feed_provider.dart';

import 'package:linkschool/modules/student/home/feed_details_screen.dart';

import 'package:provider/provider.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';

class PortalHome extends StatefulWidget {
  final PreferredSizeWidget appBar;

  const PortalHome({
    super.key,
    required this.appBar,
  });

  @override
  State<PortalHome> createState() => _PortalHomeState();
}

class _PortalHomeState extends State<PortalHome>
    with TickerProviderStateMixin, RouteAware {
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
  final String _selectedType = 'question';
  int? creatorId;
  String? creatorName;
  int? academicTerm;
  String? userRole;
  @override
  void initState() {
    super.initState();
    _loadUserData();
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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _bounceController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch dashboard data (includes overview + feeds)
      Provider.of<DashboardFeedProvider>(context, listen: false)
          .fetchDashboardData();
    });
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    Provider.of<DashboardFeedProvider>(context, listen: false)
        .fetchDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _questionController.dispose();
    _newsController.dispose();
    _titleController.dispose();
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

          userRole = profile['role']?.toString() ?? 'admin';

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

  Widget _buildStatsCard({
    required String title,

    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required int index,
  }) {
    return _buildAnimatedCard(
      index: index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        margin: const EdgeInsets.symmetric(horizontal: 2.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
           
            
            Text(
              title,
              style: AppTextStyles.normal500(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

  Widget _buildAddContentForm() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
              ],
            ),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          TextField(
            controller: _newsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter news content here...',
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
          const SizedBox(height: 12),
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
                'Add News Feed',
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
    final title = _titleController.text.trim();
    final content = _newsController.text.trim(); // Always use newsController

    final provider = Provider.of<DashboardFeedProvider>(context, listen: false);

    try {
      // Validate input
      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a title'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter content'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      // Ensure user data is loaded
      if (creatorId == null || creatorName == null) {
        await _loadUserData();
        if (creatorId == null || creatorName == null) {
          throw Exception('User data not available');
        }
      }

      final payload = {
        'title': title,
        'type': 'news',
        'parent_id': 0,
        'content': content,
        'author_name': creatorName,
        'author_id': creatorId,
        'term': academicTerm,
        'files': <Map<String, dynamic>>[],
      };

      debugPrint('Creating feed with payload: $payload');

      await provider.createFeed(payload);

      if (mounted) {
        CustomToaster.toastSuccess(
            context, 'Success ', 'Feed added successfully');

        _titleController.clear();
        _newsController.clear();

        setState(() {
          _showAddForm = false;
        });

        // Refresh the feed list
        await provider.fetchDashboardData();
      }
    } catch (e, stackTrace) {
      debugPrint('Error creating feed: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add News Feed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: Container(
        height: double.infinity,
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: RefreshIndicator(
            onRefresh: () async {
              await Provider.of<DashboardFeedProvider>(context, listen: false)
                  .fetchDashboardData();
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: Consumer<DashboardFeedProvider>(
                builder: (context, provider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // School Overview Section (Now with Quick Action Button Design)
                      _buildAnimatedCard(
                        index: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.text2Light.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.analytics_rounded,
                                      color: AppColors.text2Light,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'School Overview',
                                    style: AppTextStyles.normal600(
                                      fontSize: 20,
                                      color: AppColors.text2Light,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      label: '${provider.overview?.students.toString() ?? '0'}',
                                      icon: Icons.people_rounded,
                                      title: "Students",
                                      backgroundColor: AppColors.bookText1,
                                      borderColor: AppColors.bookText1.withOpacity(0.3),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ManageStudentsScreen(),
                                          ),
                                        );
                                      },
                                      index: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      label: '${provider.overview?.staff.toString() ?? '0'}',
                                      title: "Staff",
                                      icon: Icons.school_rounded,
                                      backgroundColor: Colors.teal,
                                      borderColor: Colors.teal.withOpacity(0.3),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ManageStaffScreen(),
                                          ),
                                        );
                                      },
                                      index: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      label: '${provider.overview?.classes.toString() ?? '0'}',
                                      title: "Classes",
                                      icon: Icons.class_rounded,
                                      backgroundColor: Colors.orangeAccent,
                                      borderColor: Colors.orangeAccent.withOpacity(0.3),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LevelClassManagementScreen(),
                                          ),
                                        );
                                      },
                                      index: 3,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickActionButton(
                                      label: '${provider.overview?.levels.toString() ?? '0'}',
                                      title: "Levels",
                                      icon: Icons.layers_rounded,
                                      backgroundColor: Colors.purpleAccent,
                                      borderColor: Colors.purpleAccent.withOpacity(0.3),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LevelClassManagementScreen(),
                                          ),
                                        );
                                      },
                                      index: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Quick Actions Section (Now with Stats Card Design)
                      _buildAnimatedCard(
                        index: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                              children: [
                                Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                    AppColors.text2Light.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.dashboard_rounded,
                                  color: AppColors.text2Light,
                                  size: 24,
                                ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                'Quick Actions',
                                style: AppTextStyles.normal600(
                                  fontSize: 20,
                                  color: AppColors.text2Light,
                                ),
                                ),
                              ],
                              ),
                              const SizedBox(height: 12),
                              // Modern list view replacing the grid
                              Builder(builder: (context) {
                              final actions = [
                                {
                                'title': 'Manage Students ',
                                'subtitle': 'View & Edit Students',
                                'icon': Icons.people_alt_rounded,
                                'color': AppColors.portalButton1Light,
                                'route': const ManageStudentsScreen(),
                                },
                                {
                                'title': 'Manage Staff ',
                                'subtitle': 'Manage Staff Members',
                                'icon': Icons.badge_rounded,
                                'color': AppColors.portalButton2Light,
                                'route': const ManageStaffScreen(),
                                },
                                {
                                'title': 'Manage Courses',
                                'subtitle': 'Add & Edit Courses',
                                'icon': Icons.book_rounded,
                                'color': AppColors.attCheckColor2,
                                'route': const CourseManagementScreen(),
                                },
                                {
                                'title': 'Levels & Classes',
                                'subtitle': 'Manage Levels & Classes',
                                'icon': Icons.school_outlined,
                                'color': AppColors.secondaryLight,
                                'route': const LevelClassManagementScreen(),
                                },
                              ];

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: actions.length,
                                separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                                itemBuilder: (ctx, i) {
                                final item = actions[i];
                                return _buildAnimatedCard(
                                  index: i + 10,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                            item['route'] as Widget,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: (item['color'] as Color),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (item['color'] as Color)
                                              .withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              item['icon'] as IconData,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['title'] as String,
                                                    style: AppTextStyles
                                                      .normal600(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item['subtitle'] as String,
                                                    style: AppTextStyles
                                                      .normal400(
                                                        fontSize: 13,
                                                        color: Colors.white.withOpacity(0.9),
                                                      ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                                },
                              );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Feeds Section Header
                      _buildAnimatedCard(
                        index: 7,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.text2Light.withOpacity(0.1),
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
                                        borderRadius: BorderRadius.circular(20),
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
                                  // See All button

                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AllFeedsScreen(),
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
                      const SizedBox(height: 8),
                      // Add Content Form
                      if (_showAddForm)
                        _buildAnimatedCard(
                          index: 8,
                          child: _buildAddContentForm(),
                        ),
                      if (_showAddForm) const SizedBox(height: 8),
                      // Feeds Content
                      _buildAnimatedCard(
                        index: 9,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              if (provider.feeds.isNotEmpty)
                                Column(
                                  children: [
                                    // Show only first 3 feeds
                                    ...provider.feeds
                                        .asMap()
                                        .entries
                                        .map((entry) {
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
                                                      replies: [
                                                        ...feed.replies
                                                      ],
                                                      profileImageUrl:
                                                          'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg',
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
                                                        'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg',
                                                    name: feed.authorName,
                                                    newsContent: feed.content,
                                                    time: feed.createdAt,
                                                    title: feed.title,
                                                    CreatorId:
                                                        creatorId.toString(),
                                                    authorId:
                                                        feed.authorId,
                                                    role: userRole,
                                                    edit: () => _startEditing(
                                                        feed), // Direct function call
                                                    delete: () => _confirmDelete(
                                                        feed), // Direct function call
                                                    comments:
                                                        feed.replies.length,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startEditing(feed) {
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

// Modify _cancelEditing method
  void _cancelEditing() {
    _editTitleController.dispose();
    _editContentController.dispose();

    setState(() {
      _editingFeedId = null;
      _editingFeedData = null;
    });
  }

  void _saveEditing(feed) async {
    final provider = Provider.of<DashboardFeedProvider>(context, listen: false);

    try {
      final updatedFeed = {
        'id': feed.id,
        'title': _editingFeedData?['title'] ?? '',
        'content': _editingFeedData?['content'] ?? '',
        "author_id": feed.authorId,
        'author_name': feed.authorName,
        'type': feed.type,
        'term': academicTerm, // Use the global academicTerm instead
      };
      print('Updated Feed Data: $updatedFeed'); // Debug print
      await provider.updateFeed(updatedFeed, feed.id.toString());

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

  Widget _buildEditForm(feed, int index) {
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

  Future<void> _confirmDelete(feed) async {
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
          Provider.of<DashboardFeedProvider>(context, listen: false);
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
}
