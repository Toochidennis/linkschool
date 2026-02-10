import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/level_selection.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/performance_chart.dart';
import 'package:linkschool/modules/common/widgets/portal/result_dashboard/settings_section.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class ResultDashboardScreen extends StatefulWidget {
  final PreferredSizeWidget appBar;

  const ResultDashboardScreen({
    super.key,
    required this.appBar,
  });

  @override
  State<ResultDashboardScreen> createState() => _ResultDashboardScreenState();
}

class _ResultDashboardScreenState extends State<ResultDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  Map<String, dynamic>? userData;
  List<dynamic> levelNames = [];
  List<dynamic> classNames = [];
  List<dynamic> levelsWithClasses = [];

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

    // Animations will be triggered after data loads
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');

      // Debug: Print all keys in the box
      print('Hive Box Keys: ${userBox.keys.toList()}');

      // Try different approaches to retrieve the data
      final storedUserData = userBox.get('userData');
      final storedLoginResponse = userBox.get('loginResponse');

      print('Stored userData: $storedUserData');
      print('Stored loginResponse: $storedLoginResponse');

      // Determine which stored data to use
      dynamic dataToProcess;
      if (storedUserData != null) {
        dataToProcess = storedUserData;
      } else if (storedLoginResponse != null) {
        dataToProcess = storedLoginResponse;
      }

      if (dataToProcess != null) {
        // Ensure dataToProcess is a Map
        Map<String, dynamic> processedData = dataToProcess is String
            ? json.decode(dataToProcess)
            : dataToProcess;

        // Extract data from different possible structures
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;

        // Extract levels and classes
        final levels = data['levels'] ?? [];
        final classes = data['classes'] ?? [];

        setState(() {
          userData = processedData;
          // Transform levels to match the previous format [id, level_name]
          levelNames = levels
              .map((level) =>
                  [(level['id'] ?? '').toString(), level['level_name'] ?? ''])
              .toList();

          // Transform classes to match the previous format [id, class_name, level_id]
          classNames = classes
              .map((cls) => [
                    (cls['id'] ?? '').toString(),
                    cls['class_name'] ?? '',
                    (cls['level_id'] ?? '').toString()
                  ])
              .toList();

          // Filter out classes with empty class_name or zero level_id
          List<dynamic> validClasses = classNames
              .where((cls) =>
                  cls[1].toString().isNotEmpty && cls[2].toString() != '0')
              .toList();

          // Create a set of level IDs that have valid classes
          Set<String> levelIdsWithClasses =
              validClasses.map<String>((cls) => cls[2].toString()).toSet();

          // Filter levelNames to include only those with classes
          levelsWithClasses = levelNames
              .where(
                  (level) => levelIdsWithClasses.contains(level[0].toString()))
              .toList();

          print('Processed Level Names: $levelNames');
          print('Processed Class Names: $classNames');
          print('Levels with Classes: $levelsWithClasses');
        });

        // Start the entrance animations after data is processed
        _runEntranceAnimations();
      } else {
        print('No valid user data found in Hive');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: RefreshIndicator(
        onRefresh: () async {},
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
              SliverToBoxAdapter(
                child: _buildAnimatedCard(
                  index: 0,
                  child: Constants.heading600(
                    title: 'Overall Performance',
                    titleSize: 18.0,
                    titleColor: AppColors.resultColor1,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
              SliverToBoxAdapter(
                child: _buildAnimatedCard(
                  index: 1,
                  child: const PerformanceChart(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28.0)),
              SliverToBoxAdapter(
                child: _buildAnimatedCard(
                  index: 2,
                  child: Constants.heading600(
                    title: 'Settings',
                    titleSize: 18.0,
                    titleColor: AppColors.resultColor1,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildAnimatedCard(
                  index: 3,
                  child: const SettingsSection(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 48.0)),
              SliverToBoxAdapter(
                child: _buildAnimatedCard(
                  index: 4,
                  child: Constants.heading600(
                    title: 'Select Level',
                    titleSize: 18.0,
                    titleColor: AppColors.resultColor1,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildAnimatedCard(
                  index: 5,
                  child: LevelSelection(
                    levelNames: levelsWithClasses, // Use filtered levels list
                    classNames: classNames,
                    isSecondScreen: false,
                    subjects: ['Math', 'Science', 'English'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
