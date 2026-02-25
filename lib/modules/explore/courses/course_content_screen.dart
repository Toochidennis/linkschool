import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'course_detail_screen.dart';
import 'package:linkschool/modules/model/explore/courses/lesson_model.dart';
import 'reading_lesson_screen.dart';
import 'package:linkschool/modules/providers/explore/courses/lesson_provider.dart';
import 'package:linkschool/modules/providers/explore/courses/enrollment_provider.dart';
import 'package:linkschool/modules/providers/explore/courses/lesson_performance_provider.dart';
import 'package:linkschool/modules/model/explore/courses/lesson_performance_model.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform, Directory, File;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'course_payment_dialog.dart';

class CourseContentScreen extends StatefulWidget {
  final String courseTitle;
  final String courseDescription;
  final String provider;
  final String providerSubtitle;
  final String category;
  final Color categoryColor;
  final int courseId;
  final int categoryId;
  final String cohortId;
  final bool isFree;
  final String? trialExpiryDate;
  final int? profileId;
  final String courseName;
  final String lessonImage;
  final String? trialType;
  final int trialValue;
  final int? lessonsTaken;
  final int? cohortCost;

  const CourseContentScreen({
    super.key,
    required this.courseTitle,
    required this.courseDescription,
    required this.provider,
    required this.courseId,
    required this.categoryId,
    required this.cohortId,
    required this.isFree,
    this.trialExpiryDate,
    this.providerSubtitle = 'Powered By Digital Dreams',
    this.category = 'COURSE',
    this.categoryColor = const Color(0xFF6366F1),
    this.profileId,
    required this.courseName,
    required this.lessonImage,
    this.trialType,
    this.trialValue = 0,
    this.lessonsTaken,
    this.cohortCost,
  });

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _localLessonsTaken = 0;
  bool _hasPaid = false;
  final Set<int> _completedLessonIds = {};
  int _resolvedCohortCost() {
    final cost = widget.cohortCost ?? 0;
    return cost;
  }

  bool _isTrialDaysExpired() {
    final expiry = widget.trialExpiryDate;
    if (expiry == null || expiry.trim().isEmpty) {
      return false;
    }
    try {
      final expiryDate = DateTime.parse(expiry).toLocal();
      return expiryDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  bool _isViewsTrialExhausted() {
    return (widget.trialType?.toLowerCase() == 'views') &&
        widget.trialValue > 0 &&
        _localLessonsTaken >= widget.trialValue;
  }

  void _showPaymentDialog({
    required LessonModel lesson,
    required List<LessonModel> lessons,
    required int index,
    bool navigateOnSuccess = true,
  }) {
    if (!mounted) return;
    final amount = _resolvedCohortCost();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CoursePaymentDialog(
        amount: amount,
        onPaymentSuccess: () {
          Navigator.of(dialogContext).pop();
          if (navigateOnSuccess && lesson.videoUrl.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailScreen(
                  courseTitle: lesson.title,
                  courseName: widget.courseTitle,
                  courseId: widget.courseId,
                  courseDescription: lesson.description,
                  provider: widget.provider,
                  videoUrl: lesson.videoUrl,
                  assignmentUrl: null,
                  assignmentDescription: null,
                  materialUrl: null,
                  zoomUrl: null,
                  recordedUrl: null,
                  classDate: null,
                  profileId: widget.profileId,
                  lessonId: lesson.id,
                  cohortId: widget.cohortId,
                  lessons: lessons,
                  lessonIndex: index,
                  onLessonCompleted: _markLessonCompleted,
                ),
              ),
            );
          }
        },
        onPaymentCompleted: (reference, amountPaid) async {
          final paid = await _refreshPaymentStatus();
          if (!paid && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment not confirmed yet. Please try again.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return paid;
        },
      ),
    );
  }

  String _trialViewsKey() {
    final profileId = widget.profileId;
    return "trial_views_${profileId ?? 'guest'}_${widget.courseId}";
  }

  Future<void> _initTrialViewsCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final int? stored = prefs.getInt(_trialViewsKey());

    int effective = stored ?? 0;
    final serverTaken = widget.lessonsTaken ?? 0;
    if (serverTaken > effective) {
      effective = serverTaken;
    }
    await prefs.setInt(_trialViewsKey(), effective);

    if (mounted) {
      setState(() {
        _localLessonsTaken = effective;
      });
    }
  }

  Future<bool> _refreshPaymentStatus() async {
    if (widget.isFree || widget.profileId == null) {
      _hasPaid = true;
      return true;
    }

    try {
      final paid = await context.read<EnrollmentProvider>().checkPaymentStatus(
            cohortId: widget.cohortId,
            profileId: widget.profileId!,
          );
      if (mounted) {
        setState(() {
          _hasPaid = paid;
        });
      } else {
        _hasPaid = paid;
      }
      return paid;
    } catch (e) {
      return false;
    }
  }

  String _completedLessonsKey() {
    final profileId = widget.profileId;
    return "completed_lessons_${profileId ?? 'guest'}_${widget.courseId}";
  }

  Future<void> _loadCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_completedLessonsKey()) ?? [];
    if (mounted) {
      setState(() {
        _completedLessonIds
          ..clear()
          ..addAll(stored.map(int.parse));
      });
    }
  }

  Future<void> _saveCompletedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _completedLessonsKey(),
      _completedLessonIds.map((id) => id.toString()).toList(),
    );
  }

  void _markLessonCompleted(int lessonId) {
    if (_completedLessonIds.add(lessonId)) {
      _saveCompletedLessons();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadCompletionStatus();
    _localLessonsTaken = 0;
    _initTrialViewsCounter();
    _loadCompletedLessons();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadLessons(
            cohortId: widget.cohortId,
          );
      final profileId = widget.profileId;
      if (profileId != null) {
        context.read<LessonPerformanceProvider>().loadLessonPerformance(
              cohortId: widget.cohortId,
              profileId: profileId,
              silent: true,
            );
      }
      _refreshPaymentStatus();
    });
  }

  Future<void> _loadCompletionStatus() async {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _refreshPerformanceSilent() {
    final profileId = widget.profileId;
    if (profileId != null) {
      context.read<LessonPerformanceProvider>().loadLessonPerformance(
            cohortId: widget.cohortId,
            profileId: profileId,
            silent: true,
          );
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && _tabController.index == 1) {
      _refreshPerformanceSilent();
    }
  }

  @override
  Widget build(BuildContext context) {
    const imageHeight = 240.0;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<LessonProvider>().loadLessons(
                cohortId: widget.cohortId,
              );
          final profileId = widget.profileId;
          if (profileId != null) {
            await context.read<LessonPerformanceProvider>().loadLessonPerformance(
                  cohortId: widget.cohortId,
                  profileId: profileId,
                  silent: false,
                );
          }
        },
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Image.network(
                    widget.lessonImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 48, color: Colors.grey),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(
                    widget.courseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (index) {
                        if (index == 1) {
                          _refreshPerformanceSilent();
                        }
                      },
                      labelColor: const Color(0xFFFFA500),
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: const Color(0xFFFFA500),
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Lessons'),
                        Tab(text: 'Performance'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLessonsTab(),
                  _buildPerformanceTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsTab() {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (lessonProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFA500),
            ),
          );
        }

        if (lessonProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  lessonProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => lessonProvider.refreshLessons(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final lessons = lessonProvider.lessons;

        if (lessons.isEmpty) {
          return const Center(
            child: Text(
              'No lessons available for this course',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            final isCompleted = _completedLessonIds.contains(lesson.id);
            final isVideo = lesson.videoUrl.isNotEmpty;
            const hasReading = false;
            return GestureDetector(
              onTap: () async {
                final trialType = widget.trialType?.toLowerCase();
                if (!widget.isFree && !_hasPaid) {
                  if ((trialType == 'days' || trialType == 'day') &&
                      _isTrialDaysExpired()) {
                    _showPaymentDialog(
                      lesson: lesson,
                      lessons: lessons,
                      index: index,
                    );
                    return;
                  }
                  if (trialType == 'views' && _isViewsTrialExhausted()) {
                    _showPaymentDialog(
                      lesson: lesson,
                      lessons: lessons,
                      index: index,
                    );
                    return;
                  }
                }

                if (!isVideo) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No content available for this lesson'),
                    ),
                  );
                  return;
                }

                final isTrialCourse = !widget.isFree &&
                    !_hasPaid &&
                    trialType == 'views' &&
                    widget.trialValue > 0;
                final currentLessonsTaken = _localLessonsTaken;
                bool shouldPromptAfterView = false;

                if (isTrialCourse) {
                  try {
                    final enrollmentProvider =
                        context.read<EnrollmentProvider>();
                    final prefs = await SharedPreferences.getInstance();
                    final savedPrefs = prefs.getInt(_trialViewsKey()) ?? 0;

                    if (currentLessonsTaken >= widget.trialValue) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Your trial views have been exhausted. Please complete payment to continue.',
                            ),
                          ),
                        );
                        _showPaymentDialog(
                          lesson: lesson,
                          lessons: lessons,
                          index: index,
                        );
                      }
                      return;
                    }

                    final newLessonsTaken = currentLessonsTaken + 1;
                    shouldPromptAfterView =
                        newLessonsTaken > widget.trialValue;

                    setState(() {
                      _localLessonsTaken = newLessonsTaken;
                    });
                    if (savedPrefs < newLessonsTaken) {
                      await prefs.setInt(_trialViewsKey(), newLessonsTaken);
                    }

                    if (widget.profileId != null) {
                      enrollmentProvider.updateTrialViewsSilently({
                        'profile_id': widget.profileId,
                        'course_id': widget.courseId,
                        'lessons_taken': newLessonsTaken,
                      }, widget.courseId);
                    }
                  } catch (e) {
                    // Continue to lesson if update fails
                  }
                }

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(
                      courseTitle: lesson.title,
                      courseName: widget.courseTitle,
                      courseId: widget.courseId,
                      courseDescription: lesson.description,
                      provider: widget.provider,
                      videoUrl: lesson.videoUrl,
                      assignmentUrl: null,
                      assignmentDescription: null,
                      materialUrl: null,
                      zoomUrl: null,
                      recordedUrl: null,
                      classDate: null,
                      profileId: widget.profileId,
                      lessonId: lesson.id,
                      cohortId: widget.cohortId,
                      lessons: lessons,
                      lessonIndex: index,
                      onLessonCompleted: _markLessonCompleted,
                    ),
                  ),
                );

                await _loadCompletionStatus();
                if (shouldPromptAfterView && mounted) {
                  _showPaymentDialog(
                    lesson: lesson,
                    lessons: lessons,
                    index: index,
                    navigateOnSuccess: false,
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? const Color(0xFF10B981)
                            : Colors.white,
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lesson ${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lesson.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lesson.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                isVideo
                                    ? Icons.play_circle_outline
                                    : hasReading
                                        ? Icons.article_outlined
                                        : Icons.description_outlined,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isVideo ? 'Video lesson' : 'Lesson content',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // PERFORMANCE TAB
  // ─────────────────────────────────────────────
  Widget _buildPerformanceTab() {
    return Consumer<LessonPerformanceProvider>(
      builder: (context, performanceProvider, child) {
        final performance = performanceProvider.performance;
        final lessons = performance?.lessons ?? const <LessonPerformanceItem>[];

        if (performanceProvider.isLoading && performance == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFA500)),
          );
        }

        if (performanceProvider.error != null && performance == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  performanceProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => performanceProvider.refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // -- Overview Summary Cards --
            _buildPerformanceOverviewCards(performance),
            const SizedBox(height: 28),

            // -- Performance Breakdown header --
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA500),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Performance Breakdown',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Per-lesson performance details',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),

            // -- Per-lesson cards --
            if (lessons.isEmpty)
              _buildEmptyPerformanceState()
            else
              ...lessons.asMap().entries.map(
                    (entry) => _buildLessonPerformanceCard(
                      entry.key,
                      entry.value,
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildPerformanceOverviewCards(LessonPerformanceData? performance) {
    final resultValue = performance == null
        ? '--'
        : '${performance.overallScorePercentage}%';
    final attendanceValue = performance == null
        ? '--/--'
        : '${performance.attendance.taken}/${performance.attendance.supposed}';
    final quizValue = performance == null
        ? '--/--'
        : '${performance.quizzes.taken}/${performance.quizzes.supposed}';
    final assignmentValue = performance == null
        ? '--/--'
        : '${performance.assignments.taken}/${performance.assignments.supposed}';

    final cards = [
      _OverviewCardData(
        title: 'Result',
        value: resultValue,
        icon: Icons.emoji_events_rounded,
        gradient: [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
        bgLight: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF4F46E5),
      ),
      _OverviewCardData(
        title: 'Attendance',
        value: attendanceValue,
        icon: Icons.how_to_reg_rounded,
        gradient: [const Color(0xFF059669), const Color(0xFF10B981)],
        bgLight: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
      ),
      _OverviewCardData(
        title: 'Quiz',
        value: quizValue,
        icon: Icons.quiz_rounded,
        gradient: [const Color(0xFFD97706), const Color(0xFFFBBF24)],
        bgLight: const Color(0xFFFFFBEB),
        iconColor: const Color(0xFFD97706),
      ),
      _OverviewCardData(
        title: 'Assignment',
        value: assignmentValue,
        icon: Icons.assignment_turned_in_rounded,
        gradient: [const Color(0xFFDB2777), const Color(0xFFF472B6)],
        bgLight: const Color(0xFFFDF2F8),
        iconColor: const Color(0xFFDB2777),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: cards.map((card) => _buildOverviewCard(card)).toList(),
    );
  }

 Widget _buildOverviewCard(_OverviewCardData card) {
  return Container(
    decoration: BoxDecoration(
      color: card.bgLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: card.iconColor.withOpacity(0.15),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: card.iconColor.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal:10 , vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icon at top right
        Align(
          alignment: Alignment.topRight,
          child: Container(
  padding: const EdgeInsets.all(5), // was 7
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: card.gradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(8), // was 10
  ),
  child: Icon(card.icon, color: Colors.white, size: 14), // was 18
),
        ),

        // Value + Title left aligned
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
  card.value,
  style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
    color: card.iconColor,
    height: 1.1,
  ),
),
const SizedBox(height: 2),
Text(
  card.title,
  style: TextStyle(
    fontSize: 11, // was 12
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade600,
  ),
),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildLessonPerformanceCard(
    int index,
    LessonPerformanceItem lesson,
  ) {
    final int displayIndex =
        lesson.displayOrder > 0 ? lesson.displayOrder : index + 1;
    final badgeGradients = [
      const [Color(0xFF2563EB), Color(0xFF38BDF8)],
      const [Color(0xFF059669), Color(0xFF34D399)],
      const [Color(0xFFEA580C), Color(0xFFF97316)],
      const [Color(0xFFDB2777), Color(0xFFF472B6)],
    ];
    final badgeGradient = badgeGradients[index % badgeGradients.length];
    final double quizPct =
        ((lesson.quizScore ?? 0).clamp(0, 100)) / 100.0;
    final double assignmentPct =
        ((lesson.assignmentScore ?? 0).clamp(0, 100)) / 100.0;
//  card colors 



    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
         Padding(
  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Lesson number badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: badgeGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '$displayIndex',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lesson $displayIndex',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.3,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: lesson.attendanceTaken
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        lesson.attendanceTaken
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 11,
                        color: lesson.attendanceTaken
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lesson.attendanceTaken ? 'Attended' : 'Absent',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: lesson.attendanceTaken
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                      
                    ],
                  ),
                ),

              ],
            ),
            SizedBox(height: 8),
            Text(
              lesson.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            // Badge on its own line
           
          ],
        ),
      ),
    ],
  ),
),

          // Divider
          // Divider
Divider(height: 1, color: Colors.grey.shade100),

// Metrics
Padding(
  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
  child: Column(
    children: [
      // Individual quiz + assignment first
      Row(
        children: [
          Expanded(
            child: _buildMiniMetric(
              label: 'Quiz',
              percent: quizPct,
              color: const Color(0xFFD97706),
              icon: Icons.quiz_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade100,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: _buildMiniMetric(
              label: 'Assignment',
              percent: assignmentPct,
              color: const Color(0xFFDB2777),
              icon: Icons.assignment_turned_in_rounded,
            ),
          ),
        ],
      ),

     const SizedBox(height: 14),
Divider(height: 1, color: Colors.grey.shade100),
const SizedBox(height: 14),

// Overall circular progress at the bottom
Row(
  children: [
    const Text(
      'Total Score',
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
      ),
    ),
    const Spacer(),
    SizedBox(
      width: 45,
      height: 45,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: (quizPct + assignmentPct) / 2,
            backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF4F46E5),
            ),
            strokeWidth: 6,
          ),
          Center(
            child: Text(
              '${(((quizPct + assignmentPct) / 2) * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),
    ],
  ),
),
        ],
      ),
    );
  }

  Widget _buildMiniMetric({
    required String label,
    required double percent,
    required Color color,
    required IconData icon,
  }) {
    final pct = (percent * 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPerformanceState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: Color(0xFFFFA500),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Performance Data Yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start attending lessons to track your progress here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Helper data class for overview cards
// ─────────────────────────────────────────────
class _OverviewCardData {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final Color bgLight;
  final Color iconColor;

  const _OverviewCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.bgLight,
    required this.iconColor,
  });
}



