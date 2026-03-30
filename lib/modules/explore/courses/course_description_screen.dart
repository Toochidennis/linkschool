import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/cohorts/cohort_model.dart';
import 'package:linkschool/modules/model/explore/courses/course_model.dart';
import 'package:linkschool/modules/model/cbt_user_model.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/user_profile_update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linkschool/modules/providers/explore/courses/enrollment_provider.dart';
import 'course_content_screen.dart';
import 'course_waiting_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linkschool/modules/providers/explore/courses/cohort_provider.dart';

import 'package:linkschool/modules/services/explore/courses/cohort_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'course_payment_dialog.dart';

class CourseDescriptionScreen extends StatefulWidget {
  final CourseModel course;
  final String provider;
  final String providerSubtitle;
  final String categoryName;
  final int categoryId;
  final Color categoryColor;
  final String cohortId;
  final int? profileId;
  final bool? hasEnrolled;
  final String? firstName;
  final String? lastName;
  final bool? isFree;
  final String? trialExpiryDate;

  const CourseDescriptionScreen({
    super.key,
    required this.course,
    required this.provider,
    required this.categoryName,
    required this.categoryId,
    required this.cohortId,
    this.providerSubtitle = 'Powered By Digital Dreams',
    this.categoryColor = const Color(0xFF6366F1),
    this.profileId,
    this.hasEnrolled,
    this.firstName,
    this.lastName,
    this.isFree,
    this.trialExpiryDate,
  });

  @override
  State<CourseDescriptionScreen> createState() =>
      _CourseDescriptionScreenState();
}

class _CourseDescriptionScreenState extends State<CourseDescriptionScreen> {
  late CohortProvider _cohortProvider;

  @override
  void initState() {
    super.initState();
    _cohortProvider = CohortProvider(CohortService());
    _cohortProvider.loadCohort(widget.cohortId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncActiveProfileAndUpdateUser();
    });
  }

  Future<void> _syncActiveProfileAndUpdateUser() async {
    if (!mounted) return;
    final cbtUserProvider = Provider.of<CbtUserProvider>(context, listen: false);
    final user = cbtUserProvider.currentUser;
    if (user == null) return;

    final profiles = user.profiles;
    final savedId = await _loadActiveProfileId();
    final targetId = widget.profileId ?? savedId;
    CbtUserProfile? activeProfile;

    if (profiles.isNotEmpty) {
      if (targetId != null) {
        activeProfile = profiles.firstWhere(
          (profile) => profile.id == targetId,
          orElse: () => profiles.first,
        );
      } else {
        activeProfile = profiles.first;
      }
    }

    if (widget.profileId != null) {
      await _saveActiveProfileId(widget.profileId,
          birthDate: activeProfile?.birthDate);
    } else if (activeProfile?.id != null) {
      await _saveActiveProfileId(activeProfile!.id,
          birthDate: activeProfile.birthDate);
    }

    final userId = user.id;
    final phone = user.phone?.trim() ?? '';
    final email = user.email.trim();
    final firstName = _resolveFirstName(user);
    final lastName = _resolveLastName(user);
    final gender = activeProfile?.gender?.trim() ?? '';
    final birthDate = activeProfile?.birthDate?.trim() ?? '';

    if (userId == null ||
        phone.isEmpty ||
        email.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        gender.isEmpty ||
        birthDate.isEmpty) {
      return;
    }

    try {
      await UserProfileUpdateService().updateUserPhone(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        attempt: user.attempt.toString(),
        email: email,
        gender: gender,
        birthDate: birthDate,
      );
    } catch (_) {
      // Silent failure
    }
  }

  String _resolveFirstName(CbtUserModel user) {
    final explicit = user.first_name?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final name = user.name?.trim() ?? '';
    if (name.isEmpty) return '';
    return name.split(' ').first;
  }

  String _resolveLastName(CbtUserModel user) {
    final explicit = user.last_name?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final name = user.name?.trim() ?? '';
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  Future<void> _saveActiveProfileId(int? id, {String? birthDate}) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setInt('active_profile_id', id);
      if (birthDate != null) {
        await prefs.setString('active_profile_dob', birthDate);
      } else {
        await prefs.remove('active_profile_dob');
      }
    }
  }

  Future<int?> _loadActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('active_profile_id');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CohortProvider>(
      create: (_) => _cohortProvider,
      child: Consumer<CohortProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFA500),
                ),
              ),
            );
          }

          if (provider.error != null) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load course details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => provider.loadCohort(widget.cohortId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final cohort = provider.cohort!;
          final enrollmentProvider = Provider.of<EnrollmentProvider>(context);
          final isFree = cohort.isFree == 1;

          final trialType = (cohort.trialType).toLowerCase();
          final int trialValue = cohort.trialValue;
          final bool hasValidTrial = trialValue > 0 &&
              (trialType == 'views' || trialType == 'days');

          final String displayCost = _formatCostDisplay(cohort.cost);
          final String mediaImageUrl = _buildMediaUrl(
            cohort.imageUrl.isNotEmpty ? cohort.imageUrl : widget.course.imageUrl,
          );
          final String? rawVideoUrl = _normalizeOptionalValue(cohort.videoUrl);
          final String? videoUrl =
              rawVideoUrl != null ? _buildMediaUrl(rawVideoUrl) : null;
          final String learningTypeLabel =
              _formatLearningType(cohort.learningType);
          final String? discountLabel = _formatDiscount(cohort.discount);
          final DateTime? enrollmentDeadline =
              _parseDateTime(cohort.enrollmentDeadline);
          final bool isSelfPaced = _isSelfPaced(cohort.learningType);
          final bool isEnrollmentClosed = enrollmentDeadline != null &&
              enrollmentDeadline.isBefore(DateTime.now()) &&
              !isSelfPaced;

          return Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              onRefresh: () => provider.loadCohort(widget.cohortId),
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // 1. App Bar
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        iconTheme: const IconThemeData(color: Colors.black87),
                        leading: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.08),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      // 2. Content
                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 250,
                              width: double.infinity,
                              child: _CourseMediaHeader(
                                videoUrl: videoUrl,
                                imageUrl: mediaImageUrl,
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.12),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: widget.categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.categoryName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: widget.categoryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Course Title
                              Text(
                                cohort.courseName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Provider Info
                              Row(
  children: [
    Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA500), Color(0xFFFF6B00)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'B',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    ),
    const SizedBox(width: 12),

    /// 👇 THIS is the magic
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.provider,
            softWrap: true,
          
           
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            widget.providerSubtitle,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    ),
  ],
),

                              const SizedBox(height: 24),
                              const Divider(height: 1),
                              const SizedBox(height: 24),

                              // Description
                              const Text(
                                'About this course',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                cohort.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 32),

                              const Text(
                                "What you'll learn",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),

                              if (cohort.benefits.isNotEmpty)
                                Html(
                                  data: cohort.benefits,
                                  style: {
                                    "li": Style(
                                      padding: HtmlPaddings.only(bottom: 12),
                                      margin: Margins.zero,
                                      listStyleType: ListStyleType.none,
                                    ),
                                    "ul": Style(
                                      padding: HtmlPaddings.zero,
                                      margin: Margins.zero,
                                    ),
                                    "p": Style(
                                      padding: HtmlPaddings.zero,
                                      margin: Margins.zero,
                                    ),
                                  },
                                  extensions: [
                                    TagExtension(
                                      tagsToExtend: {"li"},
                                      builder: (extensionContext) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.check_circle_outline,
                                                size: 20,
                                                color: Color(0xFF10B981),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  extensionContext.innerHtml
                                                      .replaceAll(
                                                          RegExp(r'<[^>]*>'),
                                                          ''),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        Colors.grey.shade700,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                )
                              ,
                              const SizedBox(height: 24),

                              if (isFree) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    'Free',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ] else
                                const SizedBox(height: 24),

                              const Text(
                                'Cohort timeline',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoCard(
                                      'Start date',
                                      _formatDate(cohort.startDate),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInfoCard(
                                      'End date',
                                      _formatDate(cohort.endDate),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoCard(
                                      'Learning type',
                                      learningTypeLabel,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInfoCard(
                                      'Enrollment deadline',
                                      enrollmentDeadline != null
                                          ? _formatDateTime(enrollmentDeadline)
                                          : 'Open',
                                    ),
                                  ),
                                ],
                              ),
                              if (isEnrollmentClosed) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFFCA5A5),
                                    ),
                                  ),
                                  child: Text(
                                    'Enrollment closed on ${_formatDateTime(enrollmentDeadline)}.',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),

                              const Text(
                                'Pricing',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),

                              if (isFree) ...[
                                _buildPricingRow('Cost', 'Free'),
                              ] else ...[
                                _buildPricingRow('Cost', displayCost),
                                if (discountLabel != null)
                                  _buildPricingRow('Discount', discountLabel),
                                if (hasValidTrial)
                                  _buildPricingRow(
                                    'Trial',
                                    trialType == 'views'
                                        ? '$trialValue views'
                                        : '$trialValue days',
                                  ),
                              ],

                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom button
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Builder(
                        builder: (buttonContext) {
                          if (isEnrollmentClosed) {
                            return SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFA500),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  disabledForegroundColor: Colors.grey.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Enrollment Closed',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }

                          final String enrollmentType = isFree
                              ? 'free'
                              : (hasValidTrial ? 'trial' : 'paid');
                          final bool showPaidLabel = !isFree && !hasValidTrial;
                          final bool showDualButtons =
                              !isFree && hasValidTrial;

                          Future<void> handlePaidEnrollment() async {
                            if (isEnrollmentClosed) return;
                            final amount = _parseCostToInt(cohort.cost);
                            int lastPaidAmount = amount;
                            showDialog(
                              context: context,
                              builder: (dialogContext) => CoursePaymentDialog(
                                amount: amount,
                                onPaymentSuccess: () {
                                  if (!mounted) return;
                                  final lessonImage =
                                      cohort.imageUrl.isNotEmpty
                                          ? cohort.imageUrl
                                          : widget.course.imageUrl;
                                  _navigateAfterEnrollment(
                                    cohort: cohort,
                                    isFree: cohort.isFree == 1,
                                    courseTitle: cohort.title,
                                    lessonImage: lessonImage,
                                    lessonsTaken: widget.course.lessonsTaken,
                                    cohortCost: lastPaidAmount,
                                  );
                                },
                                onPaymentCompleted:
                                    (reference, amountPaid) async {
                                  lastPaidAmount = amountPaid;
                                  final enrollmentData = {
                                    "profile_id": widget.profileId,
                                    "course_id": widget.course.id,
                                    "course_name": widget.course.courseName,
                                    "program_id": widget.categoryId,
                                    "first_name": widget.firstName,
                                    "last_name": widget.lastName,
                                    "enrollment_type": "paid",
                                    "cohort_name": cohort.title,
                                    "reference": reference,
                                    "amount": amountPaid,
                                  };

                                  try {
                                    final response =
                                        await enrollmentProvider
                                            .processEnrollmentPayment(
                                                enrollmentData,
                                                widget.cohortId);
                                    final data = response['data']
                                        as Map<String, dynamic>?;
                                    final statusValue = data?['payment_status'];
                                    bool paymentConfirmed = false;
                                    if (statusValue is bool) {
                                      paymentConfirmed = statusValue;
                                    } else if (statusValue is num) {
                                      paymentConfirmed = statusValue == 1;
                                    } else if (statusValue is String) {
                                      final normalized =
                                          statusValue.toLowerCase();
                                      paymentConfirmed = normalized == 'paid' ||
                                          normalized == 'true' ||
                                          normalized == '1';
                                    }

                                    if (!paymentConfirmed) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Payment not confirmed. Please try again.'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      }
                                      return false;
                                    }

                                    return true;
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Enrollment failed: $e'),
                                        ),
                                      );
                                    }
                                    return false;
                                  }
                                },
                              ),
                            );
                          }

                          Future<void> handleTrialEnrollment() async {
                            if (isEnrollmentClosed) return;
                            DateTime? trialEndDate;
                            if (trialType == 'days' && trialValue > 0) {
                              trialEndDate = DateTime.now()
                                  .add(Duration(days: trialValue));
                            }

                            final enrollmentData = {
                              "profile_id": widget.profileId,
                              "course_id": widget.course.id,
                              "course_name": widget.course.courseName,
                              "program_id": widget.categoryId,
                              "first_name": widget.firstName,
                              "last_name": widget.lastName,
                              "enrollment_type": "trial",
                              "cohort_name": cohort.title,
                              if (trialEndDate != null)
                                "trial_expiry_date":
                                    trialEndDate.toIso8601String(),
                            };

                            try {
                              await enrollmentProvider.enrollUser(
                                  enrollmentData, widget.cohortId);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Enrollment successful'),
                                    backgroundColor: Color(0xFF4CAF50),
                                  ),
                                );

                                final lessonImage =
                                    cohort.imageUrl.isNotEmpty
                                        ? cohort.imageUrl
                                        : widget.course.imageUrl;
                                _navigateAfterEnrollment(
                                  cohort: cohort,
                                  isFree: isFree,
                                  courseTitle: cohort.courseName,
                                  lessonImage: lessonImage,
                                  lessonsTaken: 0,
                                  cohortCost: _parseCostToInt(cohort.cost),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Enrollment failed: $e'),
                                  ),
                                );
                              }
                            }
                          }

                          if (showDualButtons) {
                            return Row(
  children: [

     
    Expanded(
      child: _EnrollmentButton(
        label: 'Free Trial',
        onPressed: handleTrialEnrollment,
        isLoading: enrollmentProvider.isLoading,
        isPrimary: false,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _EnrollmentButton(
        label: 'Pay Now',
        onPressed: handlePaidEnrollment,
        isLoading: enrollmentProvider.isLoading,
        isPrimary: true,
      ),
    ),
   
  ],
);
                          }

                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: enrollmentProvider.isLoading
                                  ? null
                                  : () async {
                                      if (enrollmentType == 'paid') {
                                        await handlePaidEnrollment();
                                        return;
                                      }

                                      DateTime? trialEndDate;
                                      if (enrollmentType == 'trial' &&
                                          trialType == 'days' &&
                                          trialValue > 0) {
                                        trialEndDate = DateTime.now()
                                            .add(Duration(days: trialValue));
                                      }

                                      final enrollmentData = {
                                        "profile_id": widget.profileId,
                                        "course_id": widget.course.id,
                                        "course_name":
                                            widget.course.courseName,
                                        "program_id": widget.categoryId,
                                        "first_name": widget.firstName,
                                        "last_name": widget.lastName,
                                        "enrollment_type": enrollmentType,
                                        "cohort_name": cohort.title,
                                        if (trialEndDate != null)
                                          "trial_expiry_date":
                                              trialEndDate.toIso8601String(),
                                      };

                                      try {
                                        await enrollmentProvider.enrollUser(
                                            enrollmentData, widget.cohortId);

                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Enrollment successful'),
                                              backgroundColor:
                                                  Color(0xFF4CAF50),
                                            ),
                                          );

                                          final lessonImage =
                                              cohort.imageUrl.isNotEmpty
                                                  ? cohort.imageUrl
                                                  : widget.course.imageUrl;
                                          _navigateAfterEnrollment(
                                            cohort: cohort,
                                            isFree: isFree,
                                            courseTitle: cohort.courseName,
                                            lessonImage: lessonImage,
                                            lessonsTaken: 0,
                                            cohortCost:
                                                _parseCostToInt(cohort.cost),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Enrollment failed: $e'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFA500),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: enrollmentProvider.isLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Processing...',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : showPaidLabel
                                      ? Text.rich(
                                          TextSpan(
                                            text: 'Enroll Now (',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: displayCost,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const TextSpan(text: ')'),
                                            ],
                                          ),
                                        )
                                      : Text(
                                          isFree
                                              ? 'Enroll Now'
                                              : 'Start Free Trial',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  

  void _navigateAfterEnrollment({
    required CohortModel cohort,
    required bool isFree,
    required String courseTitle,
    required String lessonImage,
    int? lessonsTaken,
    int? cohortCost,
  }) {
    final startDate = _parseDateTime(cohort.startDate);
    final trialExpiryDate =
        widget.trialExpiryDate ?? widget.course.trialExpiryDate;
    if (startDate != null && DateTime.now().isBefore(startDate)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CourseWaitingScreen(
            slug: (widget.course.slug ?? cohort.slug ?? ''),
            providerSubtitle: widget.providerSubtitle,
            category: widget.categoryName.toUpperCase(),
            categoryColor: widget.categoryColor,
            categoryId: widget.categoryId,
            isFree: isFree,
            trialExpiryDate: trialExpiryDate,
            profileId: widget.profileId,
            trialType: cohort.trialType,
            trialValue: cohort.trialValue,
            lessonsTaken: lessonsTaken,
            cohortCost: cohortCost,
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CourseContentScreen(
          courseTitle: courseTitle,
          courseDescription: cohort.description,
          provider: widget.provider,
          courseId: cohort.courseId,
          categoryId: widget.categoryId,
          cohortId: widget.cohortId,
          isFree: isFree,
          trialExpiryDate: trialExpiryDate,
          providerSubtitle: widget.providerSubtitle,
          category: widget.categoryName.toUpperCase(),
          categoryColor: widget.categoryColor,
          profileId: widget.profileId,
          courseName: cohort.courseName,
          lessonImage: lessonImage,
          trialType: cohort.trialType,
          trialValue: cohort.trialValue,
          lessonsTaken: lessonsTaken,
          cohortCost: cohortCost,
        ),
      ),
    );
  }

  Widget _buildObjectiveItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Color(0xFF10B981),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return 'TBD';
    try {
      final parsed = DateTime.parse(raw).toLocal();
      return DateFormat('d MMM, yyyy').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  String _formatDateTime(DateTime value) {
    return DateFormat('d MMM, yyyy h:mm a').format(value);
  }

  DateTime? _parseDateTime(String? raw) {
    final normalized = _normalizeOptionalValue(raw);
    if (normalized == null) return null;
    try {
      return DateTime.parse(normalized).toLocal();
    } catch (_) {
      return null;
    }
  }

  String? _normalizeOptionalValue(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return null;
    return value;
  }

  bool _isSelfPaced(String raw) {
    final normalized = raw.trim().toLowerCase().replaceAll('_', '');
    return normalized == 'selfpaced';
  }

  String _formatLearningType(String raw) {
    final normalized = _normalizeOptionalValue(raw) ?? 'Not specified';
    if (normalized.toLowerCase() == 'selfpaced') {
      return 'Self Paced';
    }
    if (normalized.toLowerCase() == 'instructor_led') {
      return 'Instructor Led';
    }
    return normalized
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  String? _formatDiscount(String? raw) {
    final normalized = _normalizeOptionalValue(raw);
    if (normalized == null) return null;
    if (normalized == '0' || normalized == '0.0') return null;
    if (normalized.contains('%') ||
        normalized.contains('\u20A6') ||
        normalized.toLowerCase().contains('off')) {
      return normalized;
    }
    return '$normalized%';
  }

  String _buildMediaUrl(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) return '';
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }
    return 'https://linkskool.net/$normalized';
  }

  String _formatCostDisplay(String raw) {
    const naira = '\u20A6';
    const legacy1 = '\u00E2\u201A\u00A6';
    const legacy2 = '\u0192,\u0130';
    final cleaned = raw
        .replaceAll(legacy1, naira)
        .replaceAll(legacy2, naira)
        .trim();
    if (cleaned.isEmpty) return '';
    if (cleaned.contains(naira)) return cleaned;
    return naira + cleaned;
  }

  int _parseCostToInt(String raw) {
    const naira = '\u20A6';
    const legacy1 = '\u00E2\u201A\u00A6';
    const legacy2 = '\u0192,\u0130';
    final cleaned = raw
        .replaceAll(legacy1, '')
        .replaceAll(legacy2, '')
        .replaceAll(naira, '')
        .replaceAll(',', '')
        .trim();
    if (cleaned.isEmpty) return 0;
    final parsedDouble = double.tryParse(cleaned);
    if (parsedDouble == null) return 0;
    return parsedDouble.round();
  }
}

class _CourseMediaHeader extends StatefulWidget {
  final String? videoUrl;
  final String imageUrl;

  const _CourseMediaHeader({
    required this.videoUrl,
    required this.imageUrl,
  });

  @override
  State<_CourseMediaHeader> createState() => _CourseMediaHeaderState();
}

class _CourseMediaHeaderState extends State<_CourseMediaHeader> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _activeVideoUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _CourseMediaHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _initializeForUrl(String? rawUrl) async {
    print('🎬 Video URL received: $rawUrl');
   if (_activeVideoUrl == rawUrl) return;
    _activeVideoUrl = rawUrl;
    await _disposeControllers();

    final videoUrl = rawUrl?.trim();
    if (videoUrl == null || videoUrl.isEmpty) {
      print('⚠️ Video URL is empty or null');
      if (mounted) setState(() {});
      return;
    }

    final videoId = _extractYouTubeId(videoUrl);
    print('🔍 Extracted YouTube ID: $videoId from URL: $videoUrl');
    if (videoId != null && videoId.isNotEmpty) {
      print('✅ Creating YouTube player with ID: $videoId');
      final controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          controlsVisibleAtStart: true,
        ),
      );
      if (mounted) {
        setState(() {
          _youtubeController = controller;
        });
      }
      return;
    }

    print('📹 Attempting to load as network video: $videoUrl');
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      print('✅ Network video initialized successfully');
      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        aspectRatio: controller.value.aspectRatio == 0
            ? 16 / 9
            : controller.value.aspectRatio,
        allowFullScreen: true,
      );
      if (mounted) {
        setState(() {
          _videoController = controller;
          _chewieController = chewieController;
        });
      } else {
        await controller.dispose();
        chewieController.dispose();
      }
    } catch (e) {
      print('❌ Failed to load network video: $e');
      print('🖼️ Falling back to image thumbnail');
      if (mounted) setState(() {});
    }
  }

  String? _extractYouTubeId(String url) {
    final sanitized = url.replaceAll(r'\/', '/').trim();
    final converted = YoutubePlayer.convertUrlToId(sanitized);
    if (converted != null && converted.isNotEmpty) {
      return converted;
    }

    final uri = Uri.tryParse(sanitized);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    }

    if (uri.host.contains('youtube.com') || uri.host.contains('m.youtube.com')) {
      final vParam = uri.queryParameters['v'];
      if (vParam != null && vParam.isNotEmpty) return vParam;
      final segments = uri.pathSegments;
      final idx = segments.indexWhere(
        (s) => s == 'shorts' || s == 'embed' || s == 'live' || s == 'v',
      );
      if (idx != -1 && segments.length > idx + 1) {
        return segments[idx + 1];
      }
    }

    return null;
  }

  Future<void> _disposeControllers() async {
    final youtubeController = _youtubeController;
    final videoController = _videoController;
    final chewieController = _chewieController;

    _youtubeController = null;
    _videoController = null;
    _chewieController = null;

    youtubeController?.dispose();
    chewieController?.dispose();
    await videoController?.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CourseMediaPlayer(
      videoUrl: widget.videoUrl,
      imageUrl: widget.imageUrl,
    );
  }
}

class _CourseMediaPlayer extends StatefulWidget {
  final String? videoUrl;
  final String imageUrl;

  const _CourseMediaPlayer({
    required this.videoUrl,
    required this.imageUrl,
  });

  @override
  State<_CourseMediaPlayer> createState() => _CourseMediaPlayerState();
}

class _CourseMediaPlayerState extends State<_CourseMediaPlayer> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _lastInitializedUrl;
  bool _isYoutubeVideo = false;
  bool _isVideoInitialized = false;
  bool _isInitializing = false;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _initializeVideo(widget.videoUrl);
  }

  @override
  void didUpdateWidget(covariant _CourseMediaPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializeVideo(widget.videoUrl);
    }
  }

  Future<void> _initializeVideo(String? url) async {
    final raw = url?.trim();
    if (raw == null || raw.isEmpty) {
      await _disposeControllers();
      if (mounted) {
        setState(() {
          _lastInitializedUrl = null;
          _isYoutubeVideo = false;
          _isVideoInitialized = true;
          _isInitializing = false;
          _videoError = null;
        });
      }
      return;
    }

    if (_lastInitializedUrl == raw) return;

    if (mounted) {
      setState(() {
        _isInitializing = true;
        _isVideoInitialized = false;
        _videoError = null;
      });
    }

    await _disposeControllers();

    try {
      final sanitized = raw.replaceAll(r'\/', '/').trim();
      if (_isYouTubeUrl(sanitized)) {
        await _initializeYouTubePlayer(sanitized);
      } else {
        await _initializeDirectVideoPlayer(sanitized);
      }
      _lastInitializedUrl = raw;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isYoutubeVideo = false;
          _videoError = 'Failed to load video: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _initializeYouTubePlayer(String url) async {
    final videoId = _extractYouTubeId(url);
    if (videoId == null || videoId.isEmpty) {
      throw Exception('Could not extract YouTube video ID from URL');
    }
    if (videoId.length != 11) {
      throw Exception('Invalid YouTube video ID');
    }

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: false,
      ),
    );

    controller.addListener(() {
      if (controller.value.hasError && mounted) {
        setState(() {
          _videoError = 'YouTube player error';
        });
      }
    });

    if (mounted) {
      setState(() {
        _youtubeController = controller;
        _isYoutubeVideo = true;
        _isVideoInitialized = true;
        _videoError = null;
      });
    }
  }

  Future<void> _initializeDirectVideoPlayer(String url) async {
    if (url.contains('youtube') || url.contains('youtu.be')) {
      throw Exception('Video URL was classified incorrectly');
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    await controller.pause();

    final chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
      fullScreenByDefault: false,
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFA500),
          ),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );

    if (mounted) {
      setState(() {
        _videoController = controller;
        _chewieController = chewieController;
        _isYoutubeVideo = false;
        _isVideoInitialized = true;
        _videoError = null;
      });
    } else {
      await controller.dispose();
      chewieController.dispose();
    }
  }

  bool _isYouTubeUrl(String url) {
    if (url.isEmpty) return false;
    final sanitized = url.toLowerCase();
    return sanitized.contains('youtube.com') ||
        sanitized.contains('youtu.be') ||
        sanitized.contains('m.youtube.com') ||
        sanitized.contains('youtube.com/shorts/') ||
        sanitized.contains('youtube.com/live/') ||
        sanitized.contains('youtube.com/embed/');
  }

  String? _extractYouTubeId(String url) {
    final sanitized = url.replaceAll(r'\/', '/').trim();
    final converted = YoutubePlayer.convertUrlToId(sanitized);
    if (converted != null && converted.isNotEmpty) {
      return converted;
    }

    final uri = Uri.tryParse(sanitized);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    }

    if (uri.host.contains('youtube.com') || uri.host.contains('m.youtube.com')) {
      final vParam = uri.queryParameters['v'];
      if (vParam != null && vParam.isNotEmpty) return vParam;
      final segments = uri.pathSegments;
      final idx = segments.indexWhere(
        (s) => s == 'shorts' || s == 'embed' || s == 'live' || s == 'v',
      );
      if (idx != -1 && segments.length > idx + 1) {
        return segments[idx + 1];
      }
    }

    return null;
  }

  Future<void> _disposeControllers() async {
    final youtubeController = _youtubeController;
    final videoController = _videoController;
    final chewieController = _chewieController;

    _youtubeController = null;
    _videoController = null;
    _chewieController = null;

    youtubeController?.dispose();
    chewieController?.dispose();
    await videoController?.dispose();
  }

  Widget _buildImageFallback() {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFFA500),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoError != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Video Error',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                _videoError!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  _lastInitializedUrl = null;
                  _initializeVideo(widget.videoUrl);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isYoutubeVideo && _youtubeController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayerBuilder(
          key: ValueKey(_youtubeController!.initialVideoId),
          player: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFFFFA500),
            progressColors: const ProgressBarColors(
              playedColor: Color(0xFFFFA500),
              handleColor: Color(0xFFFFA500),
              backgroundColor: Colors.grey,
              bufferedColor: Colors.grey,
            ),
          ),
          builder: (context, player) => player,
        ),
      );
    }

    if (!_isYoutubeVideo && _chewieController != null && _isVideoInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        key: ValueKey(_videoController.hashCode),
        child: Chewie(controller: _chewieController!),
      );
    }

    if (_isInitializing) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFA500),
            ),
          ),
        ),
      );
    }

    return _buildImageFallback();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildVideoPlayer();
  }
}




class _EnrollmentButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isPrimary;

  const _EnrollmentButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isPrimary
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? _LoadingIndicator()
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFA500)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFA500),
                ),
              ),
            ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
        SizedBox(width: 10),
        Text(
          'Processing...',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}






