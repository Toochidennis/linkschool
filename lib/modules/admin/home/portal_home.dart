import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkschool/modules/admin/home/portal_news_item.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_course_screen.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_level_class_screen.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_staffs_screen.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_students_screen.dart';
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

class _PortalHomeState extends State<PortalHome> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _newsController = TextEditingController();
  bool _showAddForm = false;
  String _selectedType = 'question';

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _questionController.dispose();
    _newsController.dispose();
    super.dispose();
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

  Widget _buildQuickActionButton({
    required String label,
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
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(12.0), // Reduced padding
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius:
                    BorderRadius.circular(16.0), // Slightly smaller radius
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8, // Reduced shadow
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 800 + (index * 200)),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(8), // Reduced padding
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            icon,
                            size: 24, // Reduced icon size
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8), // Reduced spacing
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12, // Reduced font size
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required int index,
  }) {
    return _buildAnimatedCard(
      index: index,
      child: Container(
        padding: const EdgeInsets.all(14.0), // Reduced padding
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0), // Reduced radius
          border: Border.all(color: AppColors.text6Light, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.text2Light.withOpacity(0.1),
              blurRadius: 8, // Reduced shadow
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // Reduced padding
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18, // Reduced icon size
                  ),
                ),
                Text(
                  '+12%',
                  style: AppTextStyles.normal500(
                    fontSize: 10, // Reduced font size
                    color: AppColors.attCheckColor2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Reduced spacing
            Text(
              value,
              style: AppTextStyles.normal700(
                fontSize: 20, // Reduced font size
                color: AppColors.text2Light,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.normal400(
                fontSize: 12, // Reduced font size
                color: AppColors.text7Light,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.normal400(
                fontSize: 10, // Reduced font size
                color: AppColors.text9Light,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.text6Light, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text2Light.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.normal600(
                          fontSize: 14,
                          color: AppColors.text2Light,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.normal400(
                          fontSize: 12,
                          color: AppColors.text7Light,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: AppTextStyles.normal400(
                    fontSize: 11,
                    color: AppColors.text9Light,
                  ),
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
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = 'question';
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 'question'
                            ? AppColors.text2Light
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Announcement',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedType == 'question'
                              ? Colors.white
                              : AppColors.text5Light,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ),
                ),
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
                        color: _selectedType == 'news'
                            ? AppColors.text2Light
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'News Feed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedType == 'news'
                              ? Colors.white
                              : AppColors.text5Light,
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
            controller: _selectedType == 'question'
                ? _questionController
                : _newsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: _selectedType == 'question'
                  ? 'Enter announcement here...'
                  : 'Enter news content here...',
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

  void _handleSubmit() {
    final controller =
        _selectedType == 'question' ? _questionController : _newsController;
    if (controller.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_selectedType == 'question' ? 'Announcement' : 'News feed'} added successfully!'),
          backgroundColor: AppColors.text2Light,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      controller.clear();
      setState(() {
        _showAddForm = false;
      });
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
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Overview Stats Section
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
                                color: AppColors.text2Light.withOpacity(0.1),
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
                        const SizedBox(height: 16), // Reduced spacing
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatsCard(
                                title: 'Total Students',
                                value: '1,247',
                                subtitle: 'Active this term',
                                icon: Icons.people_rounded,
                                iconColor: AppColors.portalButton1Light,
                                backgroundColor: AppColors.boxColor2,
                                index: 1,
                              ),
                            ),
                            const SizedBox(width: 8), // Reduced spacing
                            Expanded(
                              child: _buildStatsCard(
                                title: 'Staff Members',
                                value: '89',
                                subtitle: 'Teaching & Admin',
                                icon: Icons.school_rounded,
                                iconColor: AppColors.attCheckColor2,
                                backgroundColor: AppColors.boxColor4,
                                index: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8), // Reduced spacing
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatsCard(
                                title: 'Classes',
                                value: '24',
                                subtitle: 'Active classes',
                                icon: Icons.class_rounded,
                                iconColor: AppColors.secondaryLight,
                                backgroundColor: AppColors.boxColor1,
                                index: 3,
                              ),
                            ),
                            const SizedBox(width: 8), // Reduced spacing
                            Expanded(
                              child: _buildStatsCard(
                                title: 'Attendance',
                                value: '94%',
                                subtitle: 'Today\'s rate',
                                icon: Icons.how_to_reg_rounded,
                                iconColor: AppColors.text2Light,
                                backgroundColor: AppColors.boxColor3,
                                index: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Reduced spacing

                // Quick Actions Section (Admin-specific) - Now with 4 buttons
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
                                color: AppColors.text2Light.withOpacity(0.1),
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
                        const SizedBox(height: 16), // Reduced spacing
                        // First row of buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionButton(
                                label: 'Manage\nStudents',
                                icon: Icons.people_alt_rounded,
                                backgroundColor: AppColors.portalButton1Light,
                                borderColor: AppColors.portalButton1BorderLight,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ManageStudentsScreen(),
                                    ),
                                  );
                                },
                                index: 0,
                              ),
                            ),
                            const SizedBox(width: 12), // Reduced spacing
                            Expanded(
                              child: _buildQuickActionButton(
                                label: 'Staff\nDirectory',
                                icon: Icons.badge_rounded,
                                backgroundColor: AppColors.portalButton2Light,
                                borderColor: AppColors.portalButton2BorderLight,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ManageStaffScreen(),
                                    ),
                                  );
                                },
                                index: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12), // Spacing between rows
                        // Second row of buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionButton(
                                label: 'Manage\nCourses',
                                icon: Icons.book_rounded,
                                backgroundColor: AppColors.attCheckColor2,
                                borderColor:
                                    AppColors.attCheckColor2.withOpacity(0.3),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CourseManagementScreen(),
                                    ),
                                  );
                                },
                                index: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionButton(
                                label: 'Levels &\nClasses',
                                icon: Icons.school_outlined,
                                backgroundColor: AppColors.secondaryLight,
                                borderColor:
                                    AppColors.secondaryLight.withOpacity(0.3),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Reduced spacing

                // Recent Activities Section
                _buildAnimatedCard(
                  index: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                    Icons.history_rounded,
                                    color: AppColors.text2Light,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recent Activities',
                                  style: AppTextStyles.normal600(
                                    fontSize: 18,
                                    color: AppColors.text2Light,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle see all activities
                              },
                              child: const Text(
                                'View all',
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
                        const SizedBox(height: 16),
                        _buildRecentActivityItem(
                          title: 'New Student Registration',
                          subtitle: 'Sarah Johnson enrolled in JSS1A',
                          time: '10 min ago',
                          icon: Icons.person_add_rounded,
                          iconColor: AppColors.attCheckColor2,
                          index: 0,
                        ),
                        _buildRecentActivityItem(
                          title: 'Fee Payment Received',
                          subtitle: 'Michael Chen - Term 2 fees paid',
                          time: '25 min ago',
                          icon: Icons.payment_rounded,
                          iconColor: AppColors.portalButton1Light,
                          index: 1,
                        ),
                        _buildRecentActivityItem(
                          title: 'Exam Schedule Updated',
                          subtitle: 'Mathematics exam moved to Friday',
                          time: '1 hour ago',
                          icon: Icons.schedule_rounded,
                          iconColor: AppColors.secondaryLight,
                          index: 2,
                        ),
                        _buildRecentActivityItem(
                          title: 'Staff Meeting Scheduled',
                          subtitle: 'Department heads meeting tomorrow',
                          time: '2 hours ago',
                          icon: Icons.meeting_room_rounded,
                          iconColor: AppColors.text2Light,
                          index: 3,
                        ),
                        _buildRecentActivityItem(
                          title: 'New Course Added',
                          subtitle: 'Computer Science added to SSS1',
                          time: '3 hours ago',
                          icon: Icons.add_circle_rounded,
                          iconColor: AppColors.attCheckColor2,
                          index: 4,
                        ),
                        _buildRecentActivityItem(
                          title: 'Class Assignment',
                          subtitle: 'Students moved to new classes',
                          time: '4 hours ago',
                          icon: Icons.swap_horiz_rounded,
                          iconColor: AppColors.portalButton1Light,
                          index: 5,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Feeds Section Header with Add Button
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
                                      color:
                                          AppColors.text2Light.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _showAddForm ? Icons.close : Icons.add,
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
                                // Handle see all
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

                // Add Content Form (conditionally shown)
                if (_showAddForm)
                  _buildAnimatedCard(
                    index: 8,
                    child: _buildAddContentForm(),
                  ),

                if (_showAddForm) const SizedBox(height: 16),

                // Feeds Content
                _buildAnimatedCard(
                  index: 9,
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: const PortalNewsItem(
                              profileImageUrl:
                                  'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
                              name: 'School Administration',
                              newsContent:
                                  'Important: Parent-Teacher conference scheduled for next week. Please check your email for detailed schedule.',
                              time: '1 hour ago',
                            ),
                          );
                        },
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: const PortalNewsItem(
                              profileImageUrl:
                                  'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
                              name: 'Academic Department',
                              newsContent:
                                  'Congratulations to our students for excellent performance in the recent inter-school competition!',
                              time: '3 hours ago',
                            ),
                          );
                        },
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: const PortalNewsItem(
                              profileImageUrl:
                                  'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
                              name: 'Sports Department',
                              newsContent:
                                  'Annual Sports Day preparations are underway! Students can register for various events starting Monday.',
                              time: '5 hours ago',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}








// class PortalHome extends StatefulWidget {
//   final PreferredSizeWidget appBar;

//   const PortalHome({
//     super.key,
//     required this.appBar,
//   });

//   @override
//   State<PortalHome> createState() => _PortalHomeState();
// }

// class _PortalHomeState extends State<PortalHome>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late AnimationController _bounceController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _bounceAnimation;

//   final TextEditingController _questionController = TextEditingController();
//   final TextEditingController _newsController = TextEditingController();
//   bool _showAddForm = false;
//   String _selectedType = 'question'; // 'question' or 'news'

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize animation controllers
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
    
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
    
//     _bounceController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     // Initialize animations
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.elasticOut,
//     ));

//     _bounceAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _bounceController,
//       curve: Curves.elasticOut,
//     ));

//     // Start animations
//     _fadeController.forward();
//     Future.delayed(const Duration(milliseconds: 200), () {
//       _slideController.forward();
//     });
//     Future.delayed(const Duration(milliseconds: 400), () {
//       _bounceController.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _bounceController.dispose();
//     _questionController.dispose();
//     _newsController.dispose();
//     super.dispose();
//   }

//   Widget _buildAnimatedCard({
//     required Widget child,
//     required int index,
//   }) {
//     return AnimatedBuilder(
//       animation: _fadeAnimation,
//       builder: (context, child) {
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: Offset(0, 0.3 + (index * 0.1)),
//               end: Offset.zero,
//             ).animate(CurvedAnimation(
//               parent: _slideController,
//               curve: Interval(
//                 index * 0.1,
//                 1.0,
//                 curve: Curves.elasticOut,
//               ),
//             )),
//             child: child,
//           ),
//         );
//       },
//       child: child,
//     );
//   }

//   Widget _buildQuickActionButton({
//     required String label,
//     required IconData icon,
//     required Color backgroundColor,
//     required Color borderColor,
//     required VoidCallback onTap,
//     required int index,
//   }) {
//     return AnimatedBuilder(
//       animation: _bounceAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _bounceAnimation.value,
//           child: GestureDetector(
//             onTap: () {
//               HapticFeedback.lightImpact();
//               onTap();
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               curve: Curves.easeInOut,
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: backgroundColor,
//                 borderRadius: BorderRadius.circular(20.0),
//                 border: Border.all(color: borderColor, width: 2),
//                 boxShadow: [
//                   BoxShadow(
//                     color: backgroundColor.withOpacity(0.3),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TweenAnimationBuilder<double>(
//                     tween: Tween<double>(begin: 0, end: 1),
//                     duration: Duration(milliseconds: 800 + (index * 200)),
//                     curve: Curves.elasticOut,
//                     builder: (context, value, child) {
//                       return Transform.scale(
//                         scale: value,
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(
//                             icon,
//                             size: 32,
//                             color: Colors.white,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Urbanist',
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatsCard({
//     required String title,
//     required String value,
//     required String subtitle,
//     required IconData icon,
//     required Color iconColor,
//     required Color backgroundColor,
//     required int index,
//   }) {
//     return _buildAnimatedCard(
//       index: index,
//       child: Container(
//         padding: const EdgeInsets.all(20.0),
//         margin: const EdgeInsets.symmetric(horizontal: 4.0),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(20.0),
//           border: Border.all(color: AppColors.text6Light, width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.text2Light.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: iconColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     icon,
//                     color: iconColor,
//                     size: 20,
//                   ),
//                 ),
//                 Text(
//                   '+12%',
//                   style: AppTextStyles.normal500(
//                     fontSize: 12,
//                     color: AppColors.attCheckColor2,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               value,
//               style: AppTextStyles.normal700(
//                 fontSize: 24,
//                 color: AppColors.text2Light,
//               ),
//             ),
//             Text(
//               title,
//               style: AppTextStyles.normal400(
//                 fontSize: 14,
//                 color: AppColors.text7Light,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: AppTextStyles.normal400(
//                 fontSize: 12,
//                 color: AppColors.text9Light,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentActivityItem({
//     required String title,
//     required String subtitle,
//     required String time,
//     required IconData icon,
//     required Color iconColor,
//     required int index,
//   }) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween<double>(begin: 0, end: 1),
//       duration: Duration(milliseconds: 600 + (index * 100)),
//       curve: Curves.easeOutBack,
//       builder: (context, value, child) {
//         return Transform.scale(
//           scale: value,
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 12.0),
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.0),
//               border: Border.all(color: AppColors.text6Light, width: 1),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.text2Light.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: iconColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     icon,
//                     color: iconColor,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: AppTextStyles.normal600(
//                           fontSize: 14,
//                           color: AppColors.text2Light,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         subtitle,
//                         style: AppTextStyles.normal400(
//                           fontSize: 12,
//                           color: AppColors.text7Light,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   time,
//                   style: AppTextStyles.normal400(
//                     fontSize: 11,
//                     color: AppColors.text9Light,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAddContentForm() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       margin: const EdgeInsets.symmetric(horizontal: 16.0),
//       padding: const EdgeInsets.all(20.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20.0),
//         border: Border.all(color: AppColors.text2Light.withOpacity(0.2)),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.text2Light.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Add New Content',
//                 style: AppTextStyles.normal600(
//                   fontSize: 18,
//                   color: AppColors.text2Light,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () {
//                   setState(() {
//                     _showAddForm = false;
//                   });
//                 },
//                 icon: const Icon(
//                   Icons.close,
//                   color: AppColors.text5Light,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
          
//           // Toggle buttons for content type
//           Container(
//             decoration: BoxDecoration(
//               color: AppColors.textFieldLight,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.textFieldBorderLight),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedType = 'question';
//                       });
//                     },
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: _selectedType == 'question' 
//                           ? AppColors.text2Light 
//                           : Colors.transparent,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         'Announcement',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: _selectedType == 'question' 
//                             ? Colors.white 
//                             : AppColors.text5Light,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Urbanist',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedType = 'news';
//                       });
//                     },
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: _selectedType == 'news' 
//                           ? AppColors.text2Light 
//                           : Colors.transparent,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         'News Feed',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: _selectedType == 'news' 
//                             ? Colors.white 
//                             : AppColors.text5Light,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Urbanist',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 20),
          
//           // Content input field
//           TextField(
//             controller: _selectedType == 'question' ? _questionController : _newsController,
//             maxLines: 4,
//             decoration: InputDecoration(
//               hintText: _selectedType == 'question' 
//                 ? 'Enter announcement here...' 
//                 : 'Enter news content here...',
//               hintStyle: const TextStyle(
//                 color: AppColors.text5Light,
//                 fontSize: 14,
//                 fontFamily: 'Urbanist',
//               ),
//               filled: true,
//               fillColor: AppColors.textFieldLight,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//                 borderSide: BorderSide(color: AppColors.textFieldBorderLight),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//                 borderSide: BorderSide(color: AppColors.textFieldBorderLight),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//                 borderSide: BorderSide(color: AppColors.text2Light, width: 2),
//               ),
//             ),
//           ),
          
//           const SizedBox(height: 20),
          
//           // Submit button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 _handleSubmit();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.text2Light,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(
//                 'Add ${_selectedType == 'question' ? 'Announcement' : 'News Feed'}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'Urbanist',
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleSubmit() {
//     final controller = _selectedType == 'question' ? _questionController : _newsController;
//     if (controller.text.trim().isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${_selectedType == 'question' ? 'Announcement' : 'News feed'} added successfully!'),
//           backgroundColor: AppColors.text2Light,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
      
//       controller.clear();
//       setState(() {
//         _showAddForm = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget.appBar,
//       body: Container(
//         height: double.infinity,
//         decoration: Constants.customBoxDecoration(context),
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 100.0),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Admin Overview Stats Section
//                 _buildAnimatedCard(
//                   index: 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: AppColors.text2Light.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Icon(
//                                 Icons.analytics_rounded,
//                                 color: AppColors.text2Light,
//                                 size: 24,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               'School Overview',
//                               style: AppTextStyles.normal600(
//                                 fontSize: 20,
//                                 color: AppColors.text2Light,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildStatsCard(
//                                 title: 'Total Students',
//                                 value: '1,247',
//                                 subtitle: 'Active this term',
//                                 icon: Icons.people_rounded,
//                                 iconColor: AppColors.portalButton1Light,
//                                 backgroundColor: AppColors.boxColor2,
//                                 index: 1,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: _buildStatsCard(
//                                 title: 'Staff Members',
//                                 value: '89',
//                                 subtitle: 'Teaching & Admin',
//                                 icon: Icons.school_rounded,
//                                 iconColor: AppColors.attCheckColor2,
//                                 backgroundColor: AppColors.boxColor4,
//                                 index: 2,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildStatsCard(
//                                 title: 'Classes',
//                                 value: '24',
//                                 subtitle: 'Active classes',
//                                 icon: Icons.class_rounded,
//                                 iconColor: AppColors.secondaryLight,
//                                 backgroundColor: AppColors.boxColor1,
//                                 index: 3,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: _buildStatsCard(
//                                 title: 'Attendance',
//                                 value: '94%',
//                                 subtitle: 'Today\'s rate',
//                                 icon: Icons.how_to_reg_rounded,
//                                 iconColor: AppColors.text2Light,
//                                 backgroundColor: AppColors.boxColor3,
//                                 index: 4,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Quick Actions Section (Admin-specific)
//                 _buildAnimatedCard(
//                   index: 5,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: AppColors.text2Light.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Icon(
//                                 Icons.dashboard_rounded,
//                                 color: AppColors.text2Light,
//                                 size: 24,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               'Quick Actions',
//                               style: AppTextStyles.normal600(
//                                 fontSize: 20,
//                                 color: AppColors.text2Light,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildQuickActionButton(
//                                 label: 'Manage\nStudents',
//                                 icon: Icons.people_alt_rounded,
//                                 backgroundColor: AppColors.portalButton1Light,
//                                 borderColor: AppColors.portalButton1BorderLight,
//                                 onTap: () {
//                                   // Navigate to student management
//                                 },
//                                 index: 0,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildQuickActionButton(
//                                 label: 'Staff\nDirectory',
//                                 icon: Icons.badge_rounded,
//                                 backgroundColor: AppColors.portalButton2Light,
//                                 borderColor: AppColors.portalButton2BorderLight,
//                                 onTap: () {
//                                   // Navigate to staff directory
//                                 },
//                                 index: 1,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Recent Activities Section
//                 _buildAnimatedCard(
//                   index: 6,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.text2Light.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Icon(
//                                     Icons.history_rounded,
//                                     color: AppColors.text2Light,
//                                     size: 20,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Recent Activities',
//                                   style: AppTextStyles.normal600(
//                                     fontSize: 18,
//                                     color: AppColors.text2Light,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 // Handle see all activities
//                               },
//                               child: const Text(
//                                 'View all',
//                                 style: TextStyle(
//                                   decoration: TextDecoration.underline,
//                                   color: AppColors.text2Light,
//                                   fontFamily: 'Urbanist',
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         _buildRecentActivityItem(
//                           title: 'New Student Registration',
//                           subtitle: 'Sarah Johnson enrolled in JSS1A',
//                           time: '10 min ago',
//                           icon: Icons.person_add_rounded,
//                           iconColor: AppColors.attCheckColor2,
//                           index: 0,
//                         ),
//                         _buildRecentActivityItem(
//                           title: 'Fee Payment Received',
//                           subtitle: 'Michael Chen - Term 2 fees paid',
//                           time: '25 min ago',
//                           icon: Icons.payment_rounded,
//                           iconColor: AppColors.portalButton1Light,
//                           index: 1,
//                         ),
//                         _buildRecentActivityItem(
//                           title: 'Exam Schedule Updated',
//                           subtitle: 'Mathematics exam moved to Friday',
//                           time: '1 hour ago',
//                           icon: Icons.schedule_rounded,
//                           iconColor: AppColors.secondaryLight,
//                           index: 2,
//                         ),
//                         _buildRecentActivityItem(
//                           title: 'Staff Meeting Scheduled',
//                           subtitle: 'Department heads meeting tomorrow',
//                           time: '2 hours ago',
//                           icon: Icons.meeting_room_rounded,
//                           iconColor: AppColors.text2Light,
//                           index: 3,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Feeds Section Header with Add Button
//                 _buildAnimatedCard(
//                   index: 7,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: AppColors.text2Light.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Icon(
//                                 Icons.feed_rounded,
//                                 color: AppColors.text2Light,
//                                 size: 20,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'School Feeds',
//                               style: AppTextStyles.normal600(
//                                 fontSize: 20,
//                                 color: AppColors.text2Light,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   _showAddForm = !_showAddForm;
//                                 });
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 8,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.text2Light,
//                                   borderRadius: BorderRadius.circular(20),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: AppColors.text2Light.withOpacity(0.3),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       _showAddForm ? Icons.close : Icons.add,
//                                       color: Colors.white,
//                                       size: 16,
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       _showAddForm ? 'Close' : 'Add',
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                         fontFamily: 'Urbanist',
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             TextButton(
//                               onPressed: () {
//                                 // Handle see all
//                               },
//                               child: const Text(
//                                 'See all',
//                                 style: TextStyle(
//                                   decoration: TextDecoration.underline,
//                                   color: AppColors.text2Light,
//                                   fontFamily: 'Urbanist',
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Add Content Form (conditionally shown)
//                 if (_showAddForm)
//                   _buildAnimatedCard(
//                     index: 8,
//                     child: _buildAddContentForm(),
//                   ),

//                 if (_showAddForm) const SizedBox(height: 16),

//                 // Feeds Content
//                 _buildAnimatedCard(
//                   index: 9,
//                   child: Column(
//                     children: [
//                       TweenAnimationBuilder<double>(
//                         tween: Tween<double>(begin: 0, end: 1),
//                         duration: const Duration(milliseconds: 600),
//                         curve: Curves.easeOutBack,
//                         builder: (context, value, child) {
//                           return Transform.scale(
//                             scale: value,
//                             child: const PortalNewsItem(
//                               profileImageUrl:
//                                   'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
//                               name: 'School Administration',
//                               newsContent:
//                                   'Important: Parent-Teacher conference scheduled for next week. Please check your email for detailed schedule.',
//                               time: '1 hour ago',
//                             ),
//                           );
//                         },
//                       ),
//                       TweenAnimationBuilder<double>(
//                         tween: Tween<double>(begin: 0, end: 1),
//                         duration: const Duration(milliseconds: 800),
//                         curve: Curves.easeOutBack,
//                         builder: (context, value, child) {
//                           return Transform.scale(
//                             scale: value,
//                             child: const PortalNewsItem(
//                               profileImageUrl:
//                                   'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
//                               name: 'Academic Department',
//                               newsContent:
//                                   'Congratulations to our students for excellent performance in the recent inter-school competition!',
//                               time: '3 hours ago',
//                             ),
//                           );
//                         },
//                       ),
//                       TweenAnimationBuilder<double>(
//                         tween: Tween<double>(begin: 0, end: 1),
//                         duration: const Duration(milliseconds: 1000),
//                         curve: Curves.easeOutBack,
//                         builder: (context, value, child) {
//                           return Transform.scale(
//                             scale: value,
//                             child: const PortalNewsItem(
//                               profileImageUrl:
//                                   'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
//                               name: 'Sports Department',
//                               newsContent:
//                                   'Annual Sports Day preparations are underway! Students can register for various events starting Monday.',
//                               time: '5 hours ago',
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }