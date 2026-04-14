import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/cbt/cbt_games/cbt_games_dashboard.dart';
import 'package:linkschool/modules/explore/cbt/cbt_challange/join_challange.dart';
import 'package:linkschool/modules/explore/cbt/studys_subject_modal.dart';
import 'package:linkschool/modules/explore/cbt/cbt_discussion_screen.dart';
import 'package:linkschool/modules/explore/cbt/cbt_plans_screen.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/model/explore/cbt_active_session_model.dart';
import 'package:linkschool/modules/model/explore/cbt_history_model.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
import 'package:linkschool/modules/explore/cbt/all_test_history_screen.dart';
import 'package:linkschool/modules/explore/cbt/subject_selection_screen.dart';
import 'package:linkschool/modules/explore/cbt/widgets/cbt_auth_dialog.dart';
import 'package:linkschool/modules/services/cbt_subscription_service.dart';
import 'package:linkschool/modules/services/cbt_license_service.dart';
import 'package:linkschool/modules/common/ads/ad_manager.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../common/text_styles.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/services/user_profile_update_service.dart';
import 'package:linkschool/modules/widgets/user_profile_update_modal.dart';
import 'package:linkschool/modules/common/cbt_settings_helper.dart';
import 'package:linkschool/main.dart';

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
    with
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        RouteAware {
  final _subscriptionService = CbtSubscriptionService();
  final _licenseService = CbtLicenseService();

  bool _wasLoading = true;

  bool _isCheckingSubscription = false;
  bool _didCheckProfileModal = false;

  // Animation controllers for card animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;

  bool _animationTriggered = false;
  String? _pressedBoardCode;
  String? _lastNetworkMessage;
  bool _didSubscribeToRoute = false;
  bool _isHandlingBoardTap = false;
  bool _shouldShowAdOnResume = false;

  void _refreshLicenseInBackground(int userId) {
    final cbtUserProvider = Provider.of<CbtUserProvider>(context, listen: false);
    unawaited(() async {
      await _licenseService.refreshLicenseStatusInBackground(userId: userId);
      if (!mounted) return;
      await cbtUserProvider.syncLicenseStatus(forceRefresh: false);
      if (!mounted) return;
      setState(() {});
    }());
  }

  Future<bool> _handlePortalLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) return false;

    if (authProvider.isDemoLogin) {
      return false;
    }

    // Portal is logged in — ensure they also have a CBT account
    final cbtUserProvider =
        Provider.of<CbtUserProvider>(context, listen: false);
    if (cbtUserProvider.currentUser == null) {
      await cbtUserProvider.initialize();
    }

    // If still no CBT account, prompt them to sign up for CBT
    if (cbtUserProvider.currentUser == null) {
      final signedIn = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const CbtAuthDialog(), // normal CBT signup
      );
      if (signedIn != true) return false;
      await cbtUserProvider.initialize();
    }

    // Portal user is always on free trial — no license check
    await _subscriptionService.setAdMode('free_trial');
    return true;
  }

  Future<bool> _ensureAuthenticated() async {
    // ✅ Portal login takes priority — skips license check entirely
    final portalLoggedIn = await _handlePortalLogin();
    if (portalLoggedIn) return true;

    // --- From here: user is NOT portal logged in ---
    // Full CBT auth + license check applies

    final cbtUserProvider =
        Provider.of<CbtUserProvider>(context, listen: false);
    if (cbtUserProvider.currentUser == null) {
      await cbtUserProvider.initialize();
    }

    final isSignedIn = cbtUserProvider.currentUser != null;

    if (isSignedIn) {
      final userId = cbtUserProvider.currentUser?.id;
      if (userId == null) return false;

      try {
        final cachedStatus = await _licenseService.getCachedLicenseStatusForUse(userId);
        if (cachedStatus != null) {
          _refreshLicenseInBackground(userId);
          if (cachedStatus.active) {
            return true;
          }
          return await _showPlansAndReturn();
        }

        await cbtUserProvider.syncLicenseStatus(forceRefresh: true);
        if (!mounted) return false;

        if (cbtUserProvider.hasPaid || cbtUserProvider.isOnFreeTrial) {
          return true;
        }
        return await _showPlansAndReturn();
      } catch (e) {
        if (!mounted) return false;
        return await _resolveEntitlementFallback();
      }
    }

    // No CBT account at all — show signup dialog
    if (!mounted) return false;
    final signedIn = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const CbtAuthDialog(),
    );

    if (signedIn == true && mounted) {
      final userId = cbtUserProvider.currentUser?.id;
      if (userId == null) return false;

      await cbtUserProvider.syncLicenseStatus(forceRefresh: false);
      if (!mounted) return false;

      if (cbtUserProvider.hasPaid) {
        return true;
      }

      if (cbtUserProvider.isOnFreeTrial) {
        return await _showPlansAndReturn();
      }

      final licenseReason = cbtUserProvider.licenseReason;
      if (licenseReason == 'trial_expired' || licenseReason == 'expired') {
        return await _showPlansAndReturn();
      }

      // Check license after fresh signup
      final cachedStatus = await _licenseService.getCachedLicenseStatus(userId);
      if (cachedStatus == true) return true;
      if (cachedStatus == false) {
        return await _showPlansAndReturn();
      }

      final isActive = await _licenseService.isLicenseActive(userId: userId);
      if (!mounted) return false;
      if (!isActive) {
        return await _showPlansAndReturn();
      }
      return true;
    }

    return false;
  }

  Future<bool> _resolveEntitlementFallback() async {
    final hasPaidLocally = await _subscriptionService.hasPaid();
    if (hasPaidLocally) {
      return true;
    }

    final canTakeTestLocally = await _subscriptionService.canTakeTest();
    if (canTakeTestLocally) {
      return true;
    }

    return await _showPlansAndReturn();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<CBTProvider>().loadBoards();
      await _syncTrialSettingsOnEntry();
      await _subscriptionService.setTrialStartDate();
      if (mounted) {
        await AdManager.instance.warmUpPracticeAds(context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didSubscribeToRoute) {
      final route = ModalRoute.of(context);
      if (route != null) {
        routeObserver.subscribe(this, route);
        _didSubscribeToRoute = true;
      }
    }
    final cbtUserProvider =
        Provider.of<CbtUserProvider>(context, listen: false);
    // Show profile modal once after sign-in/payment if phone is missing
    if (!_didCheckProfileModal) {
      _didCheckProfileModal = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final user = cbtUserProvider.currentUser;
        if (user != null &&
            cbtUserProvider.hasPaid &&
            (user.phone == null || user.phone!.trim().isEmpty)) {
          await UserProfileUpdateModal.show(
            context,
            user: user,
            onSave: (
                {required String phone,
                required String gender,
                required String birthDate}) async {
              final profileService = UserProfileUpdateService();
              await profileService.updateUserPhone(
                userId: user.id!,
                firstName: user.name!.split(' ').first,
                lastName: user.name!.split(' ').last,
                phone: phone,
                attempt: user.attempt.toString(),
                email: user.email,
                gender: gender,
                birthDate: birthDate,
              );
              await cbtUserProvider.refreshCurrentUser(forceNetwork: true);
            },
          );
        }
      });
    }

    // Listen for payment reference changes to update state
    cbtUserProvider.paymentReferenceNotifier.addListener(() async {
      final reference = cbtUserProvider.paymentReferenceNotifier.value;
      if (reference != null && reference.isNotEmpty) {
        await cbtUserProvider.refreshCurrentUser(
          forceNetwork: true,
          forceLicenseRefresh: true,
        );

        if (!mounted) return;
        setState(() {});

        final user = cbtUserProvider.currentUser;
        if (user != null &&
            cbtUserProvider.hasPaid &&
            (user.phone == null || user.phone!.trim().isEmpty)) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            await UserProfileUpdateModal.show(
              context,
              user: user,
              onSave: (
                  {required String phone,
                  required String gender,
                  required String birthDate}) async {
                final profileService = UserProfileUpdateService();
                await profileService.updateUserPhone(
                  userId: user.id!,
                  firstName: user.name!.split(' ').first,
                  lastName: user.name!.split(' ').last,
                  phone: phone,
                  attempt: user.attempt.toString(),
                  email: user.email,
                  gender: gender,
                  birthDate: birthDate,
                );
                await cbtUserProvider.refreshCurrentUser(forceNetwork: true);
              },
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_didSubscribeToRoute) {
      routeObserver.unsubscribe(this);
    }
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    context.read<CBTProvider>().refreshStats();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused &&
        !AdManager.instance.isPresentingFullscreenAd) {
      _shouldShowAdOnResume = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _shouldShowAdOnResume) {
      _shouldShowAdOnResume = false;
      AdManager.instance.showAppOpenIfEligible(context: context);
    }
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    final start = (index * 0.06).clamp(0.0, 0.85);
    final end = (start + 0.25).clamp(0.0, 1.0);

    final fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    final slideAnim = CurvedAnimation(
      parent: _slideController,
      curve: Interval(start, end, curve: Curves.elasticOut),
    );

    final bounceAnim = CurvedAnimation(
      parent: _bounceController,
      curve: Interval(start, end, curve: Curves.elasticOut),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(slideAnim),
        child: ScaleTransition(
          // Increase scale delta so the bounce is visible
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(bounceAnim),
          child: child,
        ),
      ),
    );
  }

  Future<void> _syncTrialSettingsOnEntry() async {
    try {
      final settings = await CbtSettingsHelper.getSettings();
      await _subscriptionService.setMaxFreeTests(settings.freeTrialDays);
    } catch (e) {
      // Intentionally ignored.
    }
  }

  /// ⚡ OPTIMIZED: Non-blocking subscription check with cache and user data
  Future<bool> _checkSubscriptionBeforeTest() async {
    if (_isCheckingSubscription) return false;
    _isCheckingSubscription = true;

    try {
      final authenticated = await _ensureAuthenticated();
      if (!authenticated || !mounted) return false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      return await _showPlansAndReturn();
    } finally {
      _isCheckingSubscription = false;
    }
  }

  Future<bool> _showPlansAndReturn() async {
    final cbtUserProvider =
        Provider.of<CbtUserProvider>(context, listen: false);
    if (cbtUserProvider.hasPaid || cbtUserProvider.isOnFreeTrial) {
      return true;
    }

    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(builder: (_) => const CbtPlansScreen()),
    );
    if (result == 'continue_free_trial') {
      return true;
    }
    if (result == 'continue_ads') {
      await _subscriptionService.setContinueWithAds(true);
      return true;
    }
    if (result != true) return false;

    if (cbtUserProvider.isOnFreeTrial) {
      return true;
    }

    final userId = cbtUserProvider.currentUser?.id;
    if (userId == null) return false;

    final isActive = await _licenseService.isLicenseActive(
        userId: userId, forceRefresh: true);
    return isActive;
  }

  void _showNetworkMessage(String message) {
    if (message.isEmpty || message == _lastNetworkMessage) return;
    _lastNetworkMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(message),
      //     backgroundColor: Colors.orange,
      //   ),
      // );
    });
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
          if (provider.error != null && provider.error!.isNotEmpty) {
            _showNetworkMessage(provider.error!);
          }

          final loading = provider.isLoading;

// If we enter loading again, allow replay next time
          if (!_wasLoading && loading) {
            _animationTriggered = false;

            // Optional: reset controllers so they don't stay at 1.0 during loading
            _fadeController.reset();
            _slideController.reset();
            _bounceController.reset();
          }

// When loading finishes, start animations AFTER the first real-content frame
          if (_wasLoading && !loading && !_animationTriggered) {
            _animationTriggered = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              _fadeController
                ..reset()
                ..forward();

              _slideController
                ..reset()
                ..forward();

              _bounceController
                ..reset()
                ..forward();
            });
          }

          _wasLoading = loading;

          return Stack(
            children: [
              Skeletonizer(
                enabled: provider.isLoading,
                child: Container(
                  color: AppColors.backgroundLight,
                  // decoration: Constants.customBoxDecoration(context),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: _buildSlivers(provider),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build slivers conditionally based on data availability
  /// Eliminates empty heights when sections have no content
  List<Widget> _buildSlivers(CBTProvider provider) {
    final slivers = <Widget>[
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
    ];

    // Add performance metrics section only if history is not empty
    if (provider.recentHistory.isNotEmpty) {
      slivers.addAll([
        SliverToBoxAdapter(child: _buildPerformanceMetrics()),
        const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
      ]);
    }

    // Add resume test banner when there is a live saved session or incomplete test
    if (provider.activeSession != null || provider.incompleteTest != null) {
      slivers.addAll([
        SliverToBoxAdapter(child: _buildResumeTestBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
      ]);
    }

    // Add test history only if history is not empty
    if (provider.recentHistory.isNotEmpty) {
      slivers.addAll([
        SliverToBoxAdapter(child: _buildTestHistory()),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ]);
    }

    // Add CBT categories (boards)
    slivers.add(SliverToBoxAdapter(child: _buildCBTCategories(provider)));

    // Add bottom padding only if boards exist
    if (provider.boards.isNotEmpty) {
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 20.0)));
    }

    return slivers;
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
              'All Exams',
              style: AppTextStyles.normal600(
                fontSize: 22.0,
                color: AppColors.text4Light,
              ),
            ),
          ),
          ...provider.boards.asMap().entries.map((entry) {
            final index = entry.key;
            final board = entry.value;
            return _buildAnimatedCard(
              index: index,
              child: _buildBoardCard(
                board: board,
                backgroundColor: Colors.transparent, // Not used anymore
                provider: provider,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBoardCard({
    required dynamic board,
    required Color backgroundColor,
    required CBTProvider provider,
  }) {
    final boardColor = _getBoardColor(board.boardCode);
    final shortName = board.shortName ?? board.boardCode;

    final isPressed = _pressedBoardCode == board.boardCode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias, // ✅ important for ripple + overlay
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: boardColor.withValues(alpha: 0.18),
          highlightColor: boardColor.withValues(alpha: 0.10),
          onTap: () async {
            // ✅ instant visual feedback
            setState(() => _pressedBoardCode = board.boardCode);

            // short delay so user sees it before modal/navigation
            await Future.delayed(const Duration(milliseconds: 120));
            if (!mounted) return;

            setState(() => _pressedBoardCode = null);

            await _handleBoardTap(board, provider);
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: isPressed ? 0.98 : 1.0, // ✅ subtle press-down effect
            child: SizedBox(
              height: 120,
              child: Stack(
                children: [
                  // Background
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: boardColor.withValues(alpha: 0.15),
                        border: Border.all(
                          color: boardColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: boardColor.withValues(alpha: 0.18),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ Press overlay (this is what makes it obvious)
                  if (isPressed)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: boardColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: boardColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.school,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                        const SizedBox(height: 12),
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
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Circular arrow button at top right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () async {
                        setState(() => _pressedBoardCode = board.boardCode);
                        await Future.delayed(const Duration(milliseconds: 120));
                        if (!mounted) return;
                        setState(() => _pressedBoardCode = null);

                        await _handleBoardTap(board, provider);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: boardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: boardColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBoardColor(String boardCode) {
    final Map<String, Color> boardColors = {
      // 'JAMB': const Color(0xFF6366F1),      // Indigo
      // 'WAEC': const Color(0xFF10B981),      // Emerald
      // 'BECE': const Color(0xFFEC4899),      // Pink
      // 'Million': const Color(0xFFF59E0B),   // Amber
      // 'PSTE': const Color(0xFF8B5CF6),      // Violet
      // 'ESUT': const Color(0xFF06B6D4),      // Cyan
      // 'PSLC': const Color(0xFFEF4444),      // Red
      // 'SCE': const Color(0xFF14B8A6),       // Teal
      // 'NCEE': const Color(0xFFF97316),      // Orange
    };

    // List of random fallback colors
    final List<Color> fallbackColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Pink
      const Color(0xFFEF4444), // Red
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF97316), // Orange
    ];

    if (boardColors.containsKey(boardCode)) {
      return boardColors[boardCode]!;
    } else {
      // Pick a random color from the fallback list
      final random = Random(boardCode.hashCode);
      return fallbackColors[random.nextInt(fallbackColors.length)];
    }
  }

  /// ⚡ OPTIMIZED: Non-blocking board tap handler
  Future<void> _handleBoardTap(dynamic board, CBTProvider provider) async {
    if (_isHandlingBoardTap) return;
    _isHandlingBoardTap = true;
    try {
      final canProceed = await _checkSubscriptionBeforeTest();
      if (!canProceed || !mounted) return;

      provider.selectBoard(board.boardCode);

      // Show board options modal
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _BoardOptionsModal(
          boardName: board.title,
          onPractice: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubjectSelectionScreen(),
              ),
            ).then((_) => provider.refreshStats());
          },
          onStudy: () {
            Navigator.pop(context);
            // Show study subject selection modal using current board subjects
            final examTypeId =
                int.tryParse(provider.selectedBoard?.id ?? '0') ?? 0;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => StudySubjectSelectionModal(
                subjects: provider.currentBoardSubjects,
                examTypeId: examTypeId,
              ),
            );
          },
          onDiscussion: () {
            Navigator.pop(context);
            Navigator.push(
              this.context,
              MaterialPageRoute(
                builder: (context) => CbtDiscussionScreen(
                  boardName: board.title,
                ),
              ),
            );
          },
          onGamify: () {
            Navigator.pop(context);
            final examTypeId =
                int.tryParse(provider.selectedBoard?.id ?? '0') ?? 0;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameDashboardScreen(
                  subjects: provider.currentBoardSubjects,
                  examTypeId: examTypeId,
                ),
              ),
            );
          },
          onChallenge: () async {
            Navigator.pop(context);

            final cbtuserProvider =
                Provider.of<CbtUserProvider>(context, listen: false);
            if (cbtuserProvider.currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Challenge requires a CBT profile. Please sign in to CBT.',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            final cbtProvider =
                Provider.of<CBTProvider>(context, listen: false);
            final CurrentexamTypeId = cbtProvider.selectedBoard?.id ?? 0;

            final userName = cbtuserProvider.currentUser?.displayName ?? 'User';
            int userId = cbtuserProvider.currentUser?.id ?? 0;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModernChallengeScreen(
                  userName: userName,
                  userId: userId,
                  examTypeId: CurrentexamTypeId.toString(),
                ),
              ),
            );
          },
        ),
      );
    } finally {
      _isHandlingBoardTap = false;
    }
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
                color: AppColors.text6Light.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
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
                        AppColors.eLearningBtnColor1.withValues(alpha: 0.1),
                        AppColors.eLearningBtnColor1.withValues(alpha: 0.05),
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
        final activeSession = provider.activeSession;
        final incompleteTest = provider.incompleteTest;

        if (activeSession == null && incompleteTest == null) {
          return const SizedBox.shrink();
        }

        final subjectLabel = activeSession != null
            ? '${activeSession.subject ?? 'CBT Test'} (${activeSession.year ?? DateTime.now().year})'
            : '${incompleteTest!.subject} (${incompleteTest.year})';
        final progressLabel = activeSession != null
            ? '${activeSession.progressPercentage.toStringAsFixed(0)}% completed'
            : '${incompleteTest!.percentage.toStringAsFixed(0)}% completed';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.eLearningBtnColor1,
                AppColors.eLearningBtnColor1.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.eLearningBtnColor1.withValues(alpha: 0.3),
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
                  color: Colors.white.withValues(alpha: 0.2),
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
                      subjectLabel,
                      style: AppTextStyles.normal500(
                        fontSize: 14.0,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      progressLabel,
                      style: AppTextStyles.normal400(
                        fontSize: 12.0,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => activeSession != null
                    ? _handleSavedSessionResume(activeSession, provider)
                    : _handleResumeTest(incompleteTest!, provider),
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

  Future<void> _handleSavedSessionResume(
    CbtActiveSessionModel session,
    CBTProvider provider,
  ) async {
    final canProceed = await _checkSubscriptionBeforeTest();
    if (!canProceed || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestScreen(
          examTypeId: session.examTypeId,
          subjectId: session.subjectId,
          subject: session.subject,
          year: session.year,
          calledFrom: 'dashboard',
          totalDurationInSeconds: session.totalDurationInSeconds,
          questionLimit: session.questionLimit,
          resumeSession: session,
        ),
      ),
    ).then((_) => provider.refreshStats());
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
              onPressed: () async {
                final canProceed = await _checkSubscriptionBeforeTest();
                if (!canProceed || !mounted) return;
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
              color: Colors.black.withValues(alpha: 0.25),
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
      onTap: () async {
        final canProceed = await _checkSubscriptionBeforeTest();
        if (!canProceed || !mounted) return;
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
                    overflow: TextOverflow.ellipsis,
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

/// Modal for board options
class _BoardOptionsModal extends StatelessWidget {
  final String boardName;
  final VoidCallback onPractice;
  final VoidCallback onStudy;
  final VoidCallback onDiscussion;
  final VoidCallback onGamify;
  final VoidCallback onChallenge;

  const _BoardOptionsModal({
    required this.boardName,
    required this.onPractice,
    required this.onStudy,
    required this.onDiscussion,
    required this.onGamify,
    required this.onChallenge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Choose Learning Mode',
                    style: AppTextStyles.normal700(
                      fontSize: 20,
                      color: AppColors.text4Light,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    boardName,
                    style: AppTextStyles.normal500(
                      fontSize: 14,
                      color: AppColors.text7Light,
                    ),
                  ),
                ],
              ),
            ),

            // Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _OptionTile(
                    icon: Icons.school,
                    title: 'Practice',
                    subtitle: 'Take practice tests',
                    color: const Color(0xFF6366F1),
                    onTap: onPractice,
                  ),
                  const SizedBox(height: 12),
                  _OptionTile(
                    icon: Icons.menu_book,
                    title: 'Study',
                    subtitle: 'Learn with explanations',
                    color: const Color(0xFF10B981),
                    onTap: onStudy,
                  ),
                  const SizedBox(height: 12),
                  _OptionTile(
                    icon: Icons.videogame_asset,
                    title: 'Gamify',
                    subtitle: 'Make learning fun',
                    color: const Color(0xFFF59E0B),
                    onTap: onGamify,
                  ),
                  const SizedBox(height: 12),
                  _OptionTile(
                    icon: Icons.emoji_events,
                    title: 'Challenge',
                    subtitle: 'Compete with others',
                    color: const Color(0xFFEC4899),
                    onTap: onChallenge,
                  ),
                  const SizedBox(height: 12),
                  _OptionTile(
                    icon: Icons.forum_rounded,
                    title: 'Discussion',
                    subtitle: 'Ask questions and share ideas',
                    color: const Color(0xFF06B6D4),
                    onTap: onDiscussion,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.normal600(
                      fontSize: 16,
                      color: AppColors.text4Light,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.normal400(
                      fontSize: 13,
                      color: AppColors.text7Light,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
