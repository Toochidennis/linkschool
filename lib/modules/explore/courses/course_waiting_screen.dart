import 'dart:async';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/courses/course_content_screen.dart';
import 'package:linkschool/modules/model/explore/cohorts/upcoming_cohort_model.dart';
import 'package:linkschool/modules/providers/explore/courses/upcoming_cohort_provider.dart';
import 'package:linkschool/modules/services/explore/courses/upcoming_cohort_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

class _C {
  static const bg = Color(0xFFFFFBF5);
  static const accent = Color(0xFFFFA500);
  static const accentDeep = Color(0xFFE8954A);
  static const accentSoft = Color(0xFFFFF3E0);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFF0E4D4);
  static const text = Color(0xFF1A1A2E);
  static const textSub = Color(0xFF6B6B80);
  static const textMut = Color(0xFFAFAFBF);
  static const green = Color(0xFF25D366);
  static const stepDone = Color(0xFF10B981);
}

class OnboardingStep {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const OnboardingStep({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.actionLabel,
    this.onAction,
  });
}

class CourseWaitingScreen extends StatefulWidget {
  final String slug;
  final String providerSubtitle;
  final String category;
  final Color categoryColor;
  final int categoryId;
  final bool isFree;
  final String? trialExpiryDate;
  final int? profileId;
  final String? trialType;
  final int trialValue;
  final int? lessonsTaken;
  final int? cohortCost;
  final List<OnboardingStep>? extraSteps;
  final VoidCallback? onBack;

  const CourseWaitingScreen({
    super.key,
    required this.slug,
    required this.categoryId,
    required this.isFree,
    this.extraSteps,
    this.onBack,
    this.trialExpiryDate,
    this.providerSubtitle = 'Powered By Digital Dreams',
    this.category = 'COURSE',
    this.categoryColor = const Color(0xFF6366F1),
    this.profileId,
    this.trialType,
    this.trialValue = 0,
    this.lessonsTaken,
    this.cohortCost,
  });

  @override
  State<CourseWaitingScreen> createState() => _CourseWaitingScreenState();
}

class _CourseWaitingScreenState extends State<CourseWaitingScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  DateTime? _startDate;
  bool _startDateReady = false;
  UpcomingCohortDataModel? _cohortData;
  String? _localError;
  late UpcomingCohortProvider _upcomingProvider;

  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _upcomingProvider = UpcomingCohortProvider(UpcomingCohortService());
    final profileId = widget.profileId;
    final slug = widget.slug.trim();
    if (profileId != null && slug.isNotEmpty) {
      _upcomingProvider.loadUpcomingCohort(profileId: profileId, slug: slug);
    } else {
      _localError = 'Missing profile or course slug.';
    }

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(_updateRemaining);
      }
    });
  }

  void _updateRemaining() {
    if (!_startDateReady || _startDate == null) {
      _remaining = Duration.zero;
      return;
    }
    final diff = _startDate!.difference(DateTime.now());
    final wasPositive = _remaining.inSeconds > 0;
    _remaining = diff.isNegative ? Duration.zero : diff;

    if (wasPositive && _remaining.inSeconds <= 0) {
      if (_cohortData == null) return;
      _timer.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final data = _cohortData!;
        final cohortId = data.cohort.cohortId;
        final courseId = data.course.courseId;
        if (cohortId == 0 || courseId == 0) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CourseContentScreen(
              courseTitle: _resolveCourseTitle(data),
              courseDescription: data.course.description,
              provider: _resolveProvider(data),
              courseId: courseId,
              categoryId: widget.categoryId,
              cohortId: cohortId.toString(),
              isFree: widget.isFree,
              providerSubtitle: widget.providerSubtitle,
              category: widget.category,
              categoryColor: widget.categoryColor,
              trialExpiryDate: widget.trialExpiryDate,
              profileId: widget.profileId,
              courseName: data.course.courseName,
              lessonImage: _resolveLessonImage(data),
              trialType: widget.trialType,
              trialValue: widget.trialValue,
              lessonsTaken: widget.lessonsTaken,
              cohortCost: widget.cohortCost,
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _upcomingProvider.dispose();
    _heroCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  void _maybeSyncData(UpcomingCohortDataModel data) {
    final incomingId = data.cohort.cohortId;
    final currentId = _cohortData?.cohort.cohortId;
    if (currentId == incomingId && _startDateReady) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final parsedStart = _parseDateTime(data.cohort.startDate);
      setState(() {
        _cohortData = data;
        _startDate = parsedStart;
        _startDateReady = parsedStart != null;
        _updateRemaining();
      });
    });
  }

  DateTime? _parseDateTime(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      try {
        return DateTime.parse(value.replaceFirst(' ', 'T')).toLocal();
      } catch (_) {
        return null;
      }
    }
  }

  String _normalizeMediaUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'https://linkskool.net/$value';
  }

  String _resolveProvider(UpcomingCohortDataModel data) {
    final name = data.program.name.trim();
    if (name.isNotEmpty) return name;
    final fallback = data.course.courseName.trim();
    return fallback.isNotEmpty ? fallback : 'Program';
  }

  String _resolveCourseTitle(UpcomingCohortDataModel data) {
    final title = data.course.courseName.trim();
    return title.isNotEmpty ? title : 'Course';
  }

  String _resolveLessonImage(UpcomingCohortDataModel data) {
    final raw = data.course.imageUrl.isNotEmpty
        ? data.course.imageUrl
        : (data.cohort.imageUrl ?? '');
    return _normalizeMediaUrl(raw);
  }

  String _resolveDescription(UpcomingCohortDataModel data) {
    final courseDesc = data.course.description.trim();
    if (courseDesc.isNotEmpty) return courseDesc;
    final cohortDesc = data.cohort.description.trim();
    return cohortDesc;
  }

  String _resolveOnboardingStepsHtml(UpcomingCohortDataModel data) {
    final raw = (data.program.onboardingSteps ?? '').trim();
    return raw;
  }

  bool _hasValidWhatsappLink(String? raw) {
    if (raw == null) return false;
    final value = raw.trim();
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.hasScheme && uri.hasAuthority;
  }

  String _resolveHeaderImage(UpcomingCohortDataModel data) {
    final raw = (data.cohort.imageUrl ?? '').trim();
    if (raw.isNotEmpty) return raw;
    return data.course.imageUrl;
  }

  String? _resolveVideoUrl(UpcomingCohortDataModel data) {
    final raw = (data.cohort.videoUrl ?? '').trim();
    if (raw.isNotEmpty) return raw;
    final program = (data.program.videoUrl ?? '').trim();
    return program.isNotEmpty ? program : null;
  }

  String? _resolveWhatsappUrl(UpcomingCohortDataModel? data) {
    if (data == null) return null;
    final raw = (data.cohort.whatsappGroupLink ?? '').trim();
    if (raw.isNotEmpty) return raw;
    final program = (data.program.whatsappGroupLink ?? '').trim();
    return program.isNotEmpty ? program : null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpcomingCohortProvider>.value(
      value: _upcomingProvider,
      child: Consumer<UpcomingCohortProvider>(
        builder: (context, provider, child) {
          if (_localError != null) {
            return _ErrorScaffold(
              message: _localError!,
              onRetry: null,
            );
          }

          if (provider.isLoading && _cohortData == null) {
            return const _LoadingScaffold();
          }

          if (provider.error != null && _cohortData == null) {
            return _ErrorScaffold(
              message: provider.error!,
              onRetry: () {
                final profileId = widget.profileId;
                final slug = widget.slug.trim();
                if (profileId != null && slug.isNotEmpty) {
                  provider.loadUpcomingCohort(profileId: profileId, slug: slug);
                }
              },
            );
          }

          if (provider.data != null) {
            _maybeSyncData(provider.data!);
          }

          final data = _cohortData;
          if (data == null) {
            return const _LoadingScaffold();
          }

          final days = _remaining.inDays;
          final hours = _remaining.inHours % 24;
          final minutes = _remaining.inMinutes % 60;
          final seconds = _remaining.inSeconds % 60;
          final hasStarted = _startDateReady && _remaining.inSeconds <= 0;

          final headerImageUrl = _resolveHeaderImage(data);
          final headerVideoUrl = _resolveVideoUrl(data);
          final courseName = data.course.courseName.isNotEmpty
              ? data.course.courseName
              : 'Course';
          final providerName = _resolveProvider(data);
          final onboardingHtml = _resolveOnboardingStepsHtml(data);
          final whatsappUrl = _resolveWhatsappUrl(data);
          final hasOnboardingHtml = onboardingHtml.isNotEmpty;
          final hasWhatsappLink = _hasValidWhatsappLink(whatsappUrl);

          return Scaffold(
            backgroundColor: _C.bg,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: false,
                  floating: true,
                  leading: IconButton(
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: _C.text,
                      ),
                    ),
                    onPressed: widget.onBack ?? () => Navigator.pop(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _heroFade,
                    child: _MediaHeader(
                      imageUrl: headerImageUrl,
                      videoUrl: headerVideoUrl,
                      courseName: courseName,
                      provider: providerName,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: !_startDateReady
                        ? const _LoadingCountdownCard()
                        : hasStarted
                            ? _StartedBanner()
                            : _CountdownCard(
                                days: days,
                                hours: hours,
                                minutes: minutes,
                                seconds: seconds,
                                startDate: _startDate!,
                                pulse: _pulse,
                              ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About this course',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _C.text,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _resolveDescription(data),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasOnboardingHtml)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _C.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'While you wait',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _C.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Html(
                        data: onboardingHtml,
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
                                        extensionContext.innerHtml
                                            .replaceAll(RegExp(r'<[^>]*>'), ''),
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
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                if (hasWhatsappLink)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(whatsappUrl!.trim());
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.chat_rounded, size: 18),
                          label: const Text(
                            'Join WhatsApp group',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _C.bg,
      body: Center(
        child: CircularProgressIndicator(
          color: _C.accent,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorScaffold({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to load cohort',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: _C.textSub,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCountdownCard extends StatelessWidget {
  const _LoadingCountdownCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.accent.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: _C.accent,
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Loading schedule...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _C.textSub,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaHeader extends StatelessWidget {
  final String? imageUrl;
  final String? videoUrl;
  final String courseName;
  final String provider;

  const _MediaHeader({
    required this.imageUrl,
    required this.videoUrl,
    required this.courseName,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          child: SizedBox(
            height: 240,
            width: double.infinity,
            child: _buildMedia(),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  provider.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                courseName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedia() {
    final url = imageUrl ?? '';
    if (url.isEmpty) {
      return Container(
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: Icon(
            Icons.play_circle_outline,
            size: 64,
            color: Colors.white24,
          ),
        ),
      );
    }
    return Image.network(
      url.startsWith('http') ? url : 'https://linkskool.net/$url',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: Icon(Icons.school_rounded, size: 64, color: Colors.white24),
        ),
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFF1A1A2E),
          child: const Center(
            child: CircularProgressIndicator(
              color: _C.accent,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final int days, hours, minutes, seconds;
  final DateTime startDate;
  final Animation<double> pulse;

  const _CountdownCard({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.startDate,
    required this.pulse,
  });

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _formatStartDate() {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = startDate;
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month]} ${d.year} \u00b7 $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.accent.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: pulse,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _C.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: _C.accent,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course starts in',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _C.text,
                    ),
                  ),
                  Text(
                    _formatStartDate(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _C.textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _Tile(value: _pad(days), label: 'DAYS')),
              _Separator(),
              Expanded(child: _Tile(value: _pad(hours), label: 'HRS')),
              _Separator(),
              Expanded(child: _Tile(value: _pad(minutes), label: 'MIN')),
              _Separator(),
              Expanded(child: _Tile(value: _pad(seconds), label: 'SEC')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String value;
  final String label;
  const _Tile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _C.textMut,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 18),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: _C.textMut,
        ),
      ),
    );
  }
}

class _StartedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course is now live!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF065F46),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Pull down to refresh and access your lessons.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF059669),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalListItem extends StatelessWidget {
  final OnboardingStep step;
  final bool isLast;

  const _GoalListItem({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                if (step.actionLabel != null && step.onAction != null) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: step.onAction,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      step.actionLabel!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
