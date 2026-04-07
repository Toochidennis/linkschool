import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkschool/modules/model/cbt_user_model.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/explore/cbt/widgets/cbt_auth_dialog.dart';
import '../../model/explore/courses/course_model.dart';
import '../../providers/explore/courses/program_courses_provider.dart';
import 'package:linkschool/modules/services/network/connectivity_service.dart';
import 'package:linkschool/modules/services/explore/courses/course_checkout_service.dart';
import 'package:linkschool/modules/services/user_profile_update_service.dart';
import 'package:linkschool/modules/explore/courses/widgets/course_checkout_webview.dart';
import 'package:linkschool/modules/widgets/user_profile_update_modal.dart';

class CourseSelectionScreen extends StatefulWidget {
  final String slug;
  final bool returnToExploreCourses;
  final Future<void> Function()? onReturnToExploreCourses;

  const CourseSelectionScreen({
    super.key,
    required this.slug,
    this.returnToExploreCourses = false,
    this.onReturnToExploreCourses,
  });

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  late Map<int, bool> _selectedCourses;
  bool _isProcessingCheckout = false;
  _CheckoutAction? _activeCheckoutAction;
  String? _checkoutErrorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCourses = {};
    debugPrint('CourseSelectionScreen initState: slug=${widget.slug}, returnToExploreCourses=${widget.returnToExploreCourses}');
    
    if (widget.slug.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_fetchCourses());
      });
    }
  }

  Future<void> _fetchCourses() async {
    final slug = widget.slug.trim();
    if (slug.isEmpty) return;
    debugPrint('CourseSelectionScreen fetching courses for slug: $slug');
    await context.read<ProgramCoursesProvider>().fetchBySlug(slug);
    debugPrint('CourseSelectionScreen fetch complete for slug: $slug');
  }

  List<CourseModel> _getDisplayCourses(List<CourseModel> courses) {
    return courses;
  }

  double get _total => _getDisplayCourses(_getCourses())
      .where((c) => _selectedCourses[c.id] ?? false)
      .fold(0, (sum, c) => sum + c.discountedPrice);

  int get _selectedCount =>
      _getDisplayCourses(_getCourses())
          .where((c) => _selectedCourses[c.id] ?? false)
          .length;

  int get _paidCount => _getDisplayCourses(_getCourses())
      .where((c) => (_selectedCourses[c.id] ?? false) && c.discountedPrice > 0)
      .length;

  List<CourseModel> _getCourses() {
    return context.read<ProgramCoursesProvider>().courses;
  }

  void _selectAll() => setState(() {
        for (var c in _getCourses()) {
          _selectedCourses[c.id] = true;
        }
        _checkoutErrorMessage = null;
      });

  void _clearAll() => setState(() {
        _selectedCourses.clear();
        _checkoutErrorMessage = null;
      });

  void _toggleCourseSelection(int courseId, [bool? selected]) => setState(() {
        final nextValue = selected ?? !(_selectedCourses[courseId] ?? false);
        _selectedCourses[courseId] = nextValue;
        _checkoutErrorMessage = null;
      });

  Future<void> _handleReserveSeat(List<CourseModel> courses) async {
    if (_isProcessingCheckout) return;

    final selectedCourses = courses
        .where((course) => _selectedCourses[course.id] ?? false)
        .toList();

    if (selectedCourses.isEmpty) {
      return;
    }

    _activeCheckoutAction = _CheckoutAction.reserve;
    final online = await ConnectivityService.isOnline();
    if (!online) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect to the internet to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final canContinue = await _ensureCheckoutIdentity();
    if (!canContinue || !mounted) return;

    final activeProfileData = await _loadActiveProfileData();
    final firstName = _resolveFirstName(
      activeProfileData.profile,
      activeProfileData.user,
      activeProfileData.profileName,
    );
    final lastName = _resolveLastName(
      activeProfileData.profile,
      activeProfileData.user,
      activeProfileData.profileName,
    );
    final phone = _resolvePhone(activeProfileData.user);
    final email = _resolveEmail(activeProfileData.user);

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty) {
      if (!mounted) return;
      setState(() {
        _checkoutErrorMessage =
            'Please complete your profile before reserving a seat.';
      });
      return;
    }

    final programId = context.read<ProgramCoursesProvider>().program?.id ??
        selectedCourses.first.programId;
    if (programId == null) {
      if (!mounted) return;
      setState(() {
        _checkoutErrorMessage = 'Unable to determine the selected program.';
      });
      return;
    }

    final checkoutItems = selectedCourses
        .where((course) => course.cohortId != null)
        .map(
          (course) => CourseCheckoutItem(
            courseId: course.id,
            cohortId: course.cohortId!,
          ),
        )
        .toList();

    if (checkoutItems.isEmpty) {
      if (!mounted) return;
      setState(() {
        _checkoutErrorMessage =
            'Selected courses are missing cohort information.';
      });
      return;
    }

    setState(() {
      _isProcessingCheckout = true;
      _checkoutErrorMessage = null;
    });

    try {
      final dynamic reserveService = CourseCheckoutService();
      final result = await reserveService.reserveSeat(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        programId: programId,
        items: checkoutItems,
      );

      if (!mounted) return;

      final dialogResult = await _showResultDialog(
        titlePrefix: 'Seat Reservation',
        success: result.success,
        message: result.message,
      );

      if (!mounted) return;

      if (result.success && dialogResult == true) {
        await context.read<ProgramCoursesProvider>().fetchBySlug(widget.slug);
        await _finishAndReturn(true);
        return;
      }

      if (!result.success && dialogResult == false) {
        setState(() {
          _checkoutErrorMessage = result.message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checkoutErrorMessage = _cleanError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCheckout = false;
          _activeCheckoutAction = null;
        });
      }
    }

  }

  Future<void> _handlePayNow(List<CourseModel> courses) async {
    if (_isProcessingCheckout) return;

    final selectedCourses = courses
        .where((course) => _selectedCourses[course.id] ?? false)
        .toList();

    if (selectedCourses.isEmpty) {
      return;
    }

    _activeCheckoutAction = _CheckoutAction.pay;
    final online = await ConnectivityService.isOnline();
    if (!online) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect to the internet to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final canContinue = await _ensureCheckoutIdentity();
    if (!canContinue || !mounted) return;

    final activeProfileData = await _loadActiveProfileData();
    final firstName = _resolveFirstName(
      activeProfileData.profile,
      activeProfileData.user,
      activeProfileData.profileName,
    );
    final lastName = _resolveLastName(
      activeProfileData.profile,
      activeProfileData.user,
      activeProfileData.profileName,
    );
    final phone = _resolvePhone(activeProfileData.user);
    final email = _resolveEmail(activeProfileData.user);

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty) {
      if (!mounted) return;
      setState(() {
        _checkoutErrorMessage =
            'Please complete your profile before continuing payment.';
      });
      return;
    }

    final programId = context.read<ProgramCoursesProvider>().program?.id ??
        selectedCourses.first.programId;
    if (programId == null) {
      if (!mounted) return;
      setState(() {
        _checkoutErrorMessage = 'Unable to determine the selected program.';
      });
      return;
    }

    final checkoutItems = selectedCourses
        .where((course) => course.cohortId != null)
        .map(
          (course) => CourseCheckoutItem(
            courseId: course.id,
            cohortId: course.cohortId!,
          ),
        )
        .toList();

    if (checkoutItems.isEmpty) {
      if (!mounted) return;
      setState(() {
        _checkoutErrorMessage =
            'Selected courses are missing cohort information.';
      });
      return;
    }

    setState(() {
      _isProcessingCheckout = true;
      _checkoutErrorMessage = null;
    });

    try {
      final init = await CourseCheckoutService().initializeCheckout(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        programId: programId,
        callbackUrl: 'https://linkskool.com/payments',
        items: checkoutItems,
      );

      if (!init.success || init.reference.isEmpty || init.paymentUrl.isEmpty) {
        throw Exception(init.message);
      }

      if (!mounted) return;

      final webViewResult = await Navigator.of(context, rootNavigator: true).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => CourseCheckoutWebViewScreen(
            paymentUrl: init.paymentUrl,
            callbackUrl: init.callbackUrl,
          ),
        ),
      );

      if (!mounted) return;

      if (webViewResult != true) {
        setState(() {
          _isProcessingCheckout = false;
          _activeCheckoutAction = null;
        });
        return;
      }

      final verifyResult = await _pollCheckoutStatus(reference: init.reference);
      if (!mounted) return;

      setState(() {
        _isProcessingCheckout = false;
        _activeCheckoutAction = null;
      });

      final dialogResult = await _showResultDialog(
        titlePrefix: 'Payment',
        success: verifyResult.success,
        message: verifyResult.message,
      );

      if (!mounted) return;

      if (verifyResult.success && dialogResult == true) {
        await _finishAndReturn(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessingCheckout = false;
        _activeCheckoutAction = null;
        _checkoutErrorMessage = _cleanError(e.toString());
      });
    }
  }

  Future<bool> _ensureCheckoutIdentity() async {
    final cbtUserProvider = context.read<CbtUserProvider>();
    CbtUserModel? user = cbtUserProvider.currentUser;

    if (user == null) {
      final signedIn = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const CbtAuthDialog(),
      );

      if (signedIn == true) {
        await cbtUserProvider.refreshCurrentUser();
        user = cbtUserProvider.currentUser;
      } else {
        return false;
      }
    }

    if (user == null) {
      return false;
    }

    final activeUser = user;

    if (cbtUserProvider.isPhoneMissing) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return false;

      await UserProfileUpdateModal.show(
        context,
        user: activeUser,
        onSave: ({
          required String phone,
          required String gender,
          required String birthDate,
        }) async {
          final profileService = UserProfileUpdateService();
          try {
            await profileService.updateUserPhone(
              userId: activeUser.id!,
              firstName: _userFirstName(activeUser),
              lastName: _userLastName(activeUser),
              phone: phone,
              attempt: activeUser.attempt.toString(),
              email: activeUser.email,
              gender: gender,
              birthDate: birthDate,
            );
            await cbtUserProvider.refreshCurrentUser();
          } catch (_) {
            // Let the caller continue using the existing data if needed.
          }
        },
      );

      await cbtUserProvider.refreshCurrentUser();
      if (!mounted) return false;

      if (cbtUserProvider.isPhoneMissing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number is required to continue.'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _finishAndReturn([bool success = false]) async {
    if (!mounted) return;

    if (widget.returnToExploreCourses) {
      if (widget.onReturnToExploreCourses != null) {
        await widget.onReturnToExploreCourses!();
        return;
      }
      return;
    }

    Navigator.of(context).pop(success);
  }

  Future<CourseCheckoutVerifyResult> _pollCheckoutStatus({
    required String reference,
  }) async {
    CourseCheckoutVerifyResult? lastResult;
    const delays = <Duration>[
      Duration.zero,
      Duration(seconds: 2),
      Duration(seconds: 3),
      Duration(seconds: 4),
      Duration(seconds: 5),
    ];

    for (var i = 0; i < delays.length; i++) {
      final delay = delays[i];
      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }

      lastResult = await CourseCheckoutService().verifyCheckoutStatus(
        reference: reference,
      );
      if (lastResult.success) {
        return lastResult;
      }
    }

    return lastResult ??
        const CourseCheckoutVerifyResult(
          success: false,
          message: 'Payment could not be confirmed. Please try again.',
        );
  }

  Future<bool> _showResultDialog({
    required String titlePrefix,
    required bool success,
    required String message,
  }) async {
    final title =
        success ? '$titlePrefix Successful!' : '$titlePrefix Failed';
    final backgroundColor =
        success ? const Color(0xFFE6F4EA) : const Color(0xFFFFF2F2);
    final iconColor =
        success ? const Color(0xFF2E7D32) : const Color(0xFFE02424);
    final buttonColor =
        success ? const Color(0xFF2E7D32) : const Color(0xFFE02424);

    final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      success ? Icons.check_circle : Icons.error_outline,
                      color: iconColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    success
                        ? (message.isNotEmpty
                            ? message
                            : 'Your payment has been confirmed.')
                        : (message.isNotEmpty
                            ? message
                            : 'Payment could not be confirmed. Please try again.'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(success),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    return result ?? false;
  }

  Future<_ActiveProfileData> _loadActiveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final activeProfileId = prefs.getInt('active_profile_id');
    final activeProfileName = prefs.getString('active_profile_name') ?? '';
    final userProvider = context.read<CbtUserProvider>();
    final providerUser = userProvider.currentUser;
    final storedUser = await _loadStoredUserFromPreferences();
    final user = providerUser ?? storedUser;
    final profiles = user?.profiles ?? const <CbtUserProfile>[];

    CbtUserProfile? activeProfile;
    if (activeProfileId != null) {
      for (final profile in profiles) {
        if (profile.id == activeProfileId) {
          activeProfile = profile;
          break;
        }
      }
    }

    activeProfile ??= profiles.isNotEmpty ? profiles.first : null;

    return _ActiveProfileData(
      user: user,
      profile: activeProfile,
      profileName: activeProfileName,
    );
  }

  Future<CbtUserModel?> _loadStoredUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cbt_current_user');
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final user = CbtUserModel.fromJson(decoded);
      final cachedProfiles = await _loadStoredProfilesFromPreferences();
      if (cachedProfiles.isNotEmpty) {
        return user.copyWith(profiles: cachedProfiles);
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<List<CbtUserProfile>> _loadStoredProfilesFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cbt_user_profiles');
      if (raw == null || raw.isEmpty) return const <CbtUserProfile>[];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <CbtUserProfile>[];

      return decoded
          .whereType<Map>()
          .map((profile) => CbtUserProfile.fromJson(
                Map<String, dynamic>.from(profile as Map),
              ))
          .toList();
    } catch (_) {
      return const <CbtUserProfile>[];
    }
  }

  String _resolveFirstName(
    CbtUserProfile? profile,
    CbtUserModel? user,
    String fallbackName,
  ) {
    final direct = _textFromProfile(profile, ['first_name', 'firstName']);
    if (direct.isNotEmpty) return direct;

    final userDirect = _textFromMap(user?.toJson() ?? const <String, dynamic>{}, [
      'first_name',
      'firstName',
    ]);
    if (userDirect.isNotEmpty) return userDirect;

    final name = profile == null ? '' : _profileDisplayName(profile);
    if (name.isNotEmpty) return name.split(RegExp(r'\s+')).first;

    final userName = _displayNameFromUser(user);
    if (userName.isNotEmpty) return userName.split(RegExp(r'\s+')).first;

    if (fallbackName.trim().isNotEmpty) {
      return fallbackName.trim().split(RegExp(r'\s+')).first;
    }

    return '';
  }

  String _resolveLastName(
    CbtUserProfile? profile,
    CbtUserModel? user,
    String fallbackName,
  ) {
    final direct = _textFromProfile(profile, ['last_name', 'lastName']);
    if (direct.isNotEmpty) return direct;

    final userDirect = _textFromMap(user?.toJson() ?? const <String, dynamic>{}, [
      'last_name',
      'lastName',
    ]);
    if (userDirect.isNotEmpty) return userDirect;

    final name = profile == null ? '' : _profileDisplayName(profile);
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      if (parts.length < 2) return '';
      return parts.sublist(1).join(' ');
    }

    final userName = _displayNameFromUser(user);
    if (userName.isNotEmpty) {
      final parts = userName.split(RegExp(r'\s+'));
      if (parts.length < 2) return '';
      return parts.sublist(1).join(' ');
    }

    final fallbackParts =
        fallbackName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (fallbackParts.length < 2) return '';
    return fallbackParts.sublist(1).join(' ');
  }

  String _resolvePhone(CbtUserModel? user) {
    if (user == null) return '';
    return _textFromMap(user.toJson(), [
      'phone',
      'phone_number',
      'phoneNumber',
      'mobile',
      'mobile_number',
      'telephone',
    ]);
  }

  String _resolveEmail(CbtUserModel? user) {
    if (user == null) return '';
    return _textFromMap(user.toJson(), ['email', 'email_address', 'emailAddress']);
  }

  String _textFromProfile(CbtUserProfile? profile, List<String> keys) {
    if (profile == null) return '';
    return _textFromMap(profile.toJson(), keys);
  }

  String _textFromMap(Map<String, dynamic> profile, List<String> keys) {
    for (final key in keys) {
      final value = profile[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _profileDisplayName(CbtUserProfile profile) {
    final parts = <String>[
      profile.firstName?.trim() ?? '',
      profile.lastName?.trim() ?? '',
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(' ');
  }

  String _displayNameFromUser(CbtUserModel? user) {
    if (user == null) return '';
    final parts = <String>[
      user.first_name?.trim() ?? '',
      user.last_name?.trim() ?? '',
    ].where((part) => part.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(' ');

    final name = user.name?.trim() ?? '';
    if (name.isNotEmpty) return name;

    return '';
  }

  String _userFirstName(CbtUserModel user) {
    final explicit = user.first_name?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final name = (user.name ?? '').trim();
    if (name.isEmpty) return 'User';
    return name.split(' ').first;
  }

  String _userLastName(CbtUserModel user) {
    final explicit = user.last_name?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final name = (user.name ?? '').trim();
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.length <= 1) return '';
    return parts.last;
  }

  String _cleanError(String error) {
    final trimmed = error.replaceFirst('Exception: ', '').trim();
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(trimmed);
    if (match != null) {
      return match.group(1) ?? trimmed;
    }
    return trimmed;
  }

  String get _totalLabel {
    if (_selectedCount == 0) return '₦0';
    if (_total == 0) return 'Free';
    return '\u20A6${_total.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
  }

  String get _subLabel {
    if (_selectedCount == 0) return 'No course selected';
    if (_paidCount == 0) return 'All free';
    return '$_paidCount paid course${_paidCount > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'CourseSelectionScreen build: slug=${widget.slug}, isMounted=$mounted',
    );
    return Consumer<ProgramCoursesProvider>(
      builder: (context, provider, _) {
        return _buildScaffold(
          context: context,
          courses: provider.courses,
          isLoading: provider.isLoading && provider.courses.isEmpty,
          programTitle: provider.program?.name ?? 'Programme',
        );
      },
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required List<CourseModel> courses,
    required bool isLoading,
    required String programTitle,
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (courses.isEmpty)
                  const Center(
                    child: Text('No courses available'),
                  )
                else
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppBar(context, programTitle, courses),
                        _buildBody(courses),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                if (!isLoading && courses.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildCTA(courses),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    String programTitle,
    List<CourseModel> courses,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF3B2FA0),
        
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _finishAndReturn(false);
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Enroll in $programTitle',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              
              if (courses.isNotEmpty) ...[
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: courses
                        .map(
                          (course) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _PillButton(
                              label: course.courseName,
                              filled: _selectedCourses[course.id] ?? false,
                              onTap: () => _toggleCourseSelection(course.id),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<CourseModel> courses) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Choose Courses',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Row(
                children: [
                  _UnderlineAction(
                    label: 'Select All',
                    onTap: _selectAll,
                  ),
                  const SizedBox(width: 14),
                  _UnderlineAction(
                    label: 'Clear',
                    onTap: _clearAll,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Select one or more courses and complete a single checkout flow.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0x8A000000),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ...courses.map(
            (course) => _CourseCard(
              course: course,
              isSelected: _selectedCourses[course.id] ?? false,
              onTap: () => _toggleCourseSelection(course.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(List<CourseModel> courses) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          if (_checkoutErrorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFC7C7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFE02424), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _checkoutErrorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE02424),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCount == 0
                        ? 'No courses selected'
                        : '$_selectedCount course${_selectedCount > 1 ? 's' : ''} selected',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _totalLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _selectedCount == 0
                          ? const Color(0xFF1A1A1A)
                          : _total == 0
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B6B6B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _selectedCount == 0 || _isProcessingCheckout
                      ? null
                      : () async {
                          await _handleReserveSeat(courses);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isProcessingCheckout &&
                          _activeCheckoutAction == _CheckoutAction.reserve
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Color(0xFF4F46E5),
                          ),
                        )
                      : const Text(
                          'Reserve Seat',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedCount == 0 || _isProcessingCheckout
                      ? null
                      : () async {
                          await _handlePayNow(courses);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    disabledBackgroundColor: const Color(0xFFCBCBF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessingCheckout &&
                          _activeCheckoutAction == _CheckoutAction.pay
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Pay Now',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
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
}

enum _CheckoutAction {
  reserve,
  pay,
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled ? const Color(0xFF4F46E5) : const Color(0xFFD1D5DB),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: filled ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

class _UnderlineAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _UnderlineAction({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              height: 2,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final bool isSelected;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.isSelected,
    required this.onTap,
  });

  String get _priceLabel {
    if (course.discountedPrice == 0) return 'Free';
    final formatted = course.discountedPrice
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '\u20A6$formatted';
  }

  Color get _priceColor =>
      course.discountedPrice == 0
          ? const Color(0xFF16A34A)
          : const Color(0xFF111827);

  bool get _hasDiscount =>
      course.discount > 0 && course.discountedPrice < course.cost;

  String get _discountLabel => '${course.discount}% off';

  String _formattedCurrency(double value) {
    return '\u20A6${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C73F6)
                : const Color(0xFFECECF3),
            width: isSelected ? 1.25 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0x1A4F46E5)
                  : const Color(0x120F172A),
              blurRadius: isSelected ? 18 : 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 52),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CourseImage(
                        imageUrl: course.imageUrl,
                        fallbackLabel: _initialsForCourse(course.courseName),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.courseName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (_hasDiscount) ...[
                                  Text(
                                    _formattedCurrency(course.cost),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF9CA3AF),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Text(
                                  _priceLabel,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _priceColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                if (_hasDiscount)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF7EF),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _discountLabel,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE9FE),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Instructor-led',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF5B21B6),
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
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _Checkbox(checked: isSelected),
                    ),
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

class _Checkbox extends StatelessWidget {
  final bool checked;
  const _Checkbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: checked ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: checked ? const Color(0xFF4F46E5) : const Color(0xFFD1D5DB),
          width: 1.4,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _ActiveProfileData {
  final CbtUserModel? user;
  final CbtUserProfile? profile;
  final String profileName;

  const _ActiveProfileData({
    required this.user,
    required this.profile,
    required this.profileName,
  });
}

class _CourseImage extends StatelessWidget {
  final String imageUrl;
  final String fallbackLabel;

  const _CourseImage({
    required this.imageUrl,
    required this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveImageUrl(imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 76,
        height: 66,
        color: const Color(0xFFF3F4F6),
        child: resolvedUrl == null
            ? Center(
                child: Text(
                  fallbackLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                    height: 1.1,
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: resolvedUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    fallbackLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4B5563),
                      height: 1.1,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

String? _resolveImageUrl(String imageUrl) {
  final trimmed = imageUrl.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return 'https://linkskool.net/$trimmed';
}

String _initialsForCourse(String courseName) {
  final parts = courseName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'C';
  if (parts.length == 1) {
    return parts.first.isEmpty ? 'C' : parts.first.substring(0, 1).toUpperCase();
  }
  final first = parts.first.isEmpty ? 'C' : parts.first[0].toUpperCase();
  final last = parts.last.isEmpty ? '' : parts.last[0].toUpperCase();
  return '$first$last';
}
