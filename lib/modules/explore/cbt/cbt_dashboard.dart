import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/model/explore/cbt_history_model.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
import 'package:linkschool/modules/explore/cbt/all_test_history_screen.dart';
import 'package:linkschool/modules/explore/cbt/subject_selection_screen.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:linkschool/modules/explore/e_library/widgets/subscription_enforcement_dialog.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../common/text_styles.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';

class CBTDashboard extends StatefulWidget {
  final bool showAppBar;
  final bool fromELibrary;
  
  const CBTDashboard({
    super.key,
    this.showAppBar = true,
    this.fromELibrary = false,
  });

  @override
  State<CBTDashboard> createState() => _CBTDashboardState();
}

class _CBTDashboardState extends State<CBTDashboard> 
    with AutomaticKeepAliveClientMixin {
  final _subscriptionService = CbtSubscriptionService();
  final _authService = FirebaseAuthService();
  
  // 🚀 Cache subscription status to avoid repeated checks
  bool? _cachedCanTakeTest;
  bool _isCheckingSubscription = false;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CBTProvider>().loadBoards();
      _preloadSubscriptionStatus(); // Pre-cache subscription status
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always refresh user data when dashboard is shown
    final cbtUserProvider = Provider.of<CbtUserProvider>(context, listen: false);
    cbtUserProvider.refreshCurrentUser();

    // Listen for payment reference changes to update state
    cbtUserProvider.paymentReferenceNotifier.addListener(() {
      final reference = cbtUserProvider.paymentReferenceNotifier.value;
      if (reference != null && reference.isNotEmpty) {
        // User has paid, update cache and state
        _cachedCanTakeTest = true;
        if (mounted) setState(() {});
      }
    });
  }
  
  /// 🔥 PRE-LOAD subscription status to avoid UI blocking
  Future<void> _preloadSubscriptionStatus() async {
    try {
      final hasPaid = await _subscriptionService.hasPaid();
      final canTakeTest = await _subscriptionService.canTakeTest();
      
      if (mounted) {
        setState(() {
          _cachedCanTakeTest = hasPaid || canTakeTest;
        });
      }
    } catch (e) {
      print('❌ Error preloading subscription: $e');
    }
  }
  
  /// ⚡ OPTIMIZED: Non-blocking subscription check with cache and user data
  Future<bool> _checkSubscriptionBeforeTest() async {
    if (_isCheckingSubscription) return false;

    final cbtUserProvider = Provider.of<CbtUserProvider>(context, listen: false);
    // Use user data to check if user has paid
    if (cbtUserProvider.hasPaid == true) {
      _cachedCanTakeTest = true;
      return true;
    }

    // Use cached value if available (instant response)
    if (_cachedCanTakeTest != null && _cachedCanTakeTest == true) {
      return true;
    }

    setState(() => _isCheckingSubscription = true);

    try {
      final hasPaid = cbtUserProvider.hasPaid;
      final canTakeTest = await _subscriptionService.canTakeTest();
      final remainingTests = await _subscriptionService.getRemainingFreeTests();

      // Update cache
      _cachedCanTakeTest = hasPaid || canTakeTest;

      if (hasPaid || canTakeTest) {
        return true;
      }

      // User must pay - show enforcement dialog
      if (!mounted) return false;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SubscriptionEnforcementDialog(
          isHardBlock: true,
          remainingTests: remainingTests,
          amount: 400,
          onSubscribed: () {
            print('✅ User subscribed from CBT Dashboard');
            _cachedCanTakeTest = true; // Update cache
            if (mounted) {
              setState(() {});
            }
          },
        ),
      );

      return false;
    } catch (e) {
      print('❌ Subscription check error: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() => _isCheckingSubscription = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: widget.showAppBar
          ? Constants.customAppBar(
              context: context,
              showBackButton: true,
              title: 'CBT Dashboard',
            )
          : null,
      body: Consumer<CBTProvider>(
        builder: (context, provider, child) {
          return Skeletonizer(
            enabled: provider.isLoading,
            child: Container(
              color: AppColors.backgroundLight,
             // decoration: Constants.customBoxDecoration(context),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  SliverToBoxAdapter(
                    child: _buildPerformanceMetrics(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                  SliverToBoxAdapter(
                    child: _buildResumeTestBanner(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
                  SliverToBoxAdapter(
                    child: _buildTestHistory(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  SliverToBoxAdapter(
                    child: _buildCBTCategories(provider),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20.0)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

 Widget _buildCBTCategories(CBTProvider provider) {
  if (provider.isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            height: 145,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }),
      ),
    );
  }

  if (provider.boards.isEmpty) {
    return _buildEmptyBoardsState(provider);
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Exam Boards',
            style: AppTextStyles.normal600(
              fontSize: 22.0,
              color: AppColors.text4Light,
            ),
          ),
        ),
        ...provider.boards.map((board) {
          return _buildBoardCard(
            board: board,
            backgroundColor: Colors.transparent, // Not used anymore
            provider: provider,
          );
        }).toList(),
      ],
    ),
  );
}
Widget _buildBoardCard({
  required dynamic board,
  required Color backgroundColor,
  required CBTProvider provider,
}) {
  // Get unique color for this board based on its code
  final boardColor = _getBoardColor(board.boardCode);
  final shortName = board.shortName ?? board.boardCode;
  
  return GestureDetector(
    onTap: () => _handleBoardTap(board, provider),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
                decoration: BoxDecoration(
                color: boardColor.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                  color: boardColor.withOpacity(0.18),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
            
                children: [
                  // Icon and Badge Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: boardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.school,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Short name badge
                      Text(
                        shortName,
                        style: AppTextStyles.normal700P(
                          fontSize: 16.0,
                          color: boardColor,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  
                  // Title and Start Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        board.title,
                        style: AppTextStyles.normal700P(
                          fontSize: 16.0,
                          color: AppColors.text4Light,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: boardColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: boardColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () => _handleBoardTap(board, provider),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Start',
                                    style: AppTextStyles.normal700P(
                                      fontSize: 14,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Loading overlay when checking subscription
            if (_isCheckingSubscription)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}


Color _getBoardColor(String boardCode) {
  final Map<String, Color> boardColors = {
    'JAMB': const Color(0xFF6366F1),      // Indigo
    'WAEC': const Color(0xFF10B981),      // Emerald
    'BECE': const Color(0xFFEC4899),      // Pink
    'Million': const Color(0xFFF59E0B),   // Amber
    'PSTE': const Color(0xFF8B5CF6),      // Violet
    'ESUT': const Color(0xFF06B6D4),      // Cyan
    'PSLC': const Color(0xFFEF4444),      // Red
    'SCE': const Color(0xFF14B8A6),       // Teal
    'NCEE': const Color(0xFFF97316),      // Orange
  };
  
  return boardColors[boardCode] ?? const Color(0xFF6366F1);
}

  /// ⚡ OPTIMIZED: Non-blocking board tap handler
  Future<void> _handleBoardTap(dynamic board, CBTProvider provider) async {
    // Check subscription asynchronously
    final canProceed = await _checkSubscriptionBeforeTest();
    if (!canProceed || !mounted) return;
    
    provider.selectBoard(board.boardCode);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SubjectSelectionScreen(),
      ),
    );
  }

  Widget _buildEmptyBoardsState(CBTProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Exam Boards',
              style: AppTextStyles.normal600(
                fontSize: 22.0,
                color: AppColors.text4Light,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 60.0,
              horizontal: 24.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.text6Light.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.eLearningBtnColor1.withOpacity(0.1),
                        AppColors.eLearningBtnColor1.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 56,
                    color: AppColors.eLearningBtnColor1,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Exam Boards Available',
                  style: AppTextStyles.normal600(
                    fontSize: 18,
                    color: AppColors.text2Light,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Exam boards are currently not available.\nPlease check back later or contact support.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.normal400(
                    fontSize: 14,
                    color: AppColors.text7Light,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.loadBoards(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    'Retry',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.eLearningBtnColor1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Consumer<CBTProvider>(
      builder: (context, provider, child) {
        if (provider.recentHistory.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPerformanceCard(
                imagePath: 'assets/icons/test.png',
                title: 'Tests',
                completionRate: provider.totalTests.toString(),
                backgroundColor: AppColors.cbtColor1,
                borderColor: AppColors.cbtBorderColor1,
              ),
              const SizedBox(width: 16.0),
              _buildPerformanceCard(
                imagePath: 'assets/icons/success.png',
                title: 'Completed',
                completionRate: provider.successCount.toString(),
                backgroundColor: AppColors.cbtColor2,
                borderColor: AppColors.cbtBorderColor2,
              ),
              const SizedBox(width: 16.0),
              _buildPerformanceCard(
                imagePath: 'assets/icons/average.png',
                title: 'Average',
                completionRate: '${provider.averageScore.toStringAsFixed(0)}%',
                backgroundColor: AppColors.cbtColor3,
                borderColor: AppColors.cbtBorderColor3,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumeTestBanner() {
    return Consumer<CBTProvider>(
      builder: (context, provider, child) {
        final incompleteTest = provider.incompleteTest;
        
        if (incompleteTest == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.eLearningBtnColor1,
                AppColors.eLearningBtnColor1.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.eLearningBtnColor1.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue where you left off',
                      style: AppTextStyles.normal600(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${incompleteTest.subject} (${incompleteTest.year})',
                      style: AppTextStyles.normal500(
                        fontSize: 14.0,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${incompleteTest.percentage.toStringAsFixed(0)}% completed',
                      style: AppTextStyles.normal400(
                        fontSize: 12.0,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _handleResumeTest(incompleteTest, provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Resume',
                        style: AppTextStyles.normal600(
                          fontSize: 14.0,
                          color: AppColors.eLearningBtnColor1,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Icon(
                        Icons.arrow_forward,
                        size: 16.0,
                        color: AppColors.eLearningBtnColor1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleResumeTest(
    CbtHistoryModel test,
    CBTProvider provider,
  ) async {
    final canProceed = await _checkSubscriptionBeforeTest();
    if (!canProceed || !mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestScreen(
          examTypeId: test.examId,
          subjectId: null,
          subject: test.subject,
          year: test.year,
          calledFrom: 'dashboard',
        ),
      ),
    ).then((_) => provider.refreshStats());
  }

  Widget _buildTestHistory() {
    return Consumer<CBTProvider>(
      builder: (context, provider, child) {
        if (provider.recentHistory.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Constants.headingWithSeeAll600(
              title: 'Test history',
              titleSize: 18.0,
              titleColor: AppColors.text4Light,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllTestHistoryScreen(),
                  ),
                ).then((_) => provider.refreshStats());
              },
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 13.0),
                itemCount: provider.recentHistory.length,
                itemBuilder: (context, index) {
                  final history = provider.recentHistory[index];
                  final colors = [
                    AppColors.cbtColor3,
                    AppColors.cbtColor4,
                    AppColors.cbtColor1,
                  ];
                  
                  return _buildHistoryCard(
                    context: context,
                    history: history,
                    courseName: history.subject,
                    year: history.year.toString(),
                    progressValue: history.percentage / 100,
                    borderColor: colors[index % colors.length],
                    provider: provider,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPerformanceCard({
    required String title,
    required String completionRate,
    required String imagePath,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        height: 115.0,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              spreadRadius: 0,
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.25),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: 24.0,
              height: 24.0,
            ),
            const SizedBox(height: 4.0),
            Text(
              completionRate,
              style: AppTextStyles.normal600(
                fontSize: 24.0,
                color: AppColors.backgroundLight,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: AppTextStyles.normal600(
                fontSize: 15.0,
                color: AppColors.backgroundLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required BuildContext context,
    required CbtHistoryModel history,
    required String courseName,
    required String year,
    required double progressValue,
    required Color borderColor,
    required CBTProvider provider,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestScreen(
              examTypeId: history.examId,
              subjectId: null,
              subject: history.subject,
              year: history.year,
              calledFrom: 'dashboard',
            ),
          ),
        ).then((_) => provider.refreshStats());
      },
      child: Container(
        width: 195,
        margin: const EdgeInsets.only(left: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 70.0,
                  width: 70.0,
                  child: CircularProgressIndicator(
                    color: borderColor,
                    value: progressValue,
                    strokeWidth: 7.5,
                  ),
                ),
                Text(
                  '${(progressValue * 100).round()}%',
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: AppColors.text4Light,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName,
                    style: AppTextStyles.normal600(
                      fontSize: 14.0,
                      color: AppColors.text4Light,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '($year)',
                    style: AppTextStyles.normal600(
                      fontSize: 12.0,
                      color: AppColors.text7Light,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Tap to retake',
                    style: AppTextStyles.normal600(
                      fontSize: 14.0,
                      color: AppColors.text8Light,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}