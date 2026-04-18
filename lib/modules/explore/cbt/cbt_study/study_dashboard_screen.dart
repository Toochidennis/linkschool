import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study/study_ad_manager.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study/models/study_session_stats.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study/study_subject_topics_screen.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/providers/explore/cbt_provider.dart';
import 'package:linkschool/modules/services/database/download_service.dart';
import 'package:linkschool/modules/services/study_history_service.dart';
import 'package:linkschool/modules/widgets/network_dialog.dart';

class StudyDashboardScreen extends StatefulWidget {
  const StudyDashboardScreen({super.key});

  @override
  State<StudyDashboardScreen> createState() => _StudyDashboardScreenState();
}

class _StudyDashboardScreenState extends State<StudyDashboardScreen>
    with WidgetsBindingObserver {
  final StudyHistoryService _studyHistoryService = StudyHistoryService();
  final CbtDownloadService _downloadService = CbtDownloadService();

  StudyDashboardStats _dashboardStats = StudyDashboardStats.empty();
  final Map<String, DownloadState> _downloadStates = {};
  Set<String> _downloadedSubjectIds = <String>{};
  bool _isLoading = true;
  bool _contentVisible = false;
  bool _isNavigatingAway = false;
  bool _shouldShowAdOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StudyAdManager.instance.warmUpStudyAds(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDashboardData();
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        setState(() {
          _contentVisible = true;
        });
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

    if (state == AppLifecycleState.paused) {
      if (!_isNavigatingAway && isCurrentRoute) {
        _shouldShowAdOnResume = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldShowAdOnResume) {
        _shouldShowAdOnResume = false;
        if (!isCurrentRoute) return;
        StudyAdManager.instance.showAppOpenIfEligible(context: context);
      }
      _loadDashboardData(showLoader: false);
    }
  }

  Future<void> _loadDashboardData({bool showLoader = true}) async {
    final provider = context.read<CBTProvider>();
    final subjects = provider.currentBoardSubjects;
    final examTypeId = int.tryParse(provider.selectedBoard?.id ?? '0') ?? 0;

    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final subjectNames = subjects.map((subject) => subject.name).toSet();
      final dashboardStats = await _studyHistoryService.getDashboardStats(
        subjectNames: subjectNames,
      );

      Set<String> downloadedSubjectIds = <String>{};
      if (subjects.isNotEmpty && examTypeId > 0) {
        downloadedSubjectIds = await _downloadService.getDownloadedCourseIds(
          examTypeId: examTypeId.toString(),
          courseIds: subjects.map((subject) => subject.id),
        );
      }

      if (!mounted) return;
      setState(() {
        _dashboardStats = dashboardStats;
        _downloadedSubjectIds = downloadedSubjectIds;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await context.read<CBTProvider>().loadBoards();
    await _loadDashboardData(showLoader: false);
  }

  Future<void> _downloadSubject(SubjectModel subject) async {
    final canUseNetwork = await NetworkDialog.ensureOnline(context);
    if (!canUseNetwork || !mounted) return;

    final provider = context.read<CBTProvider>();
    final examTypeId = int.tryParse(provider.selectedBoard?.id ?? '0') ?? 0;
    if (examTypeId <= 0) return;

    setState(() {
      _downloadStates[subject.id] =
          const DownloadState(isDownloading: true, progress: 0.0);
    });

    await _downloadService.downloadSubject(
      examTypeId: examTypeId.toString(),
      courseId: subject.id,
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _downloadStates[subject.id] =
              DownloadState(isDownloading: true, progress: progress);
        });
      },
      onComplete: () {
        if (!mounted) return;
        setState(() {
          _downloadStates[subject.id] = const DownloadState(
            isDownloading: false,
            isDownloaded: true,
            progress: 1.0,
          );
          _downloadedSubjectIds = {..._downloadedSubjectIds, subject.id};
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_titleCase(subject.name)} downloaded!'),
            backgroundColor: AppColors.eLearningBtnColor1,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        unawaited(_refreshDashboard());
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _downloadStates[subject.id] =
              const DownloadState(isDownloading: false);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _openStudySubject(SubjectModel subject) {
    final provider = context.read<CBTProvider>();
    final examTypeId = int.tryParse(provider.selectedBoard?.id ?? '0') ?? 0;
    if (examTypeId <= 0) return;

    _isNavigatingAway = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudySubjectTopicsScreen(
          subject: subject,
          examTypeId: examTypeId,
        ),
      ),
    ).then((_) {
      _isNavigatingAway = false;
      _loadDashboardData(showLoader: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CBTProvider>();
    final subjects = provider.currentBoardSubjects;
    final boardName = provider.selectedBoard?.title ?? 'Study';
    final downloadedCount = subjects.where(_isSubjectDownloaded).length;

    return Scaffold(
      appBar: Constants.customAppBar(
        context: context,
        showBackButton: true,
        title: '$boardName Study',
        showBackgroundIllustration: false,
      ),
      body: Container(
        decoration: Constants.customStudyBoxDecoration(context),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: AppColors.eLearningBtnColor1,
                onRefresh: _refreshDashboard,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: AnimatedOpacity(
                          opacity: _contentVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 420),
                          child: AnimatedSlide(
                            offset: _contentVisible
                                ? Offset.zero
                                : const Offset(0, 0.05),
                            duration: const Duration(milliseconds: 460),
                            curve: Curves.easeOutCubic,
                            child: _buildOverviewCard(
                              downloadedCount: downloadedCount,
                              totalSubjects: subjects.length,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Subjects',
                                style: AppTextStyles.normal700(
                                  fontSize: 18,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.eLearningBtnColor1
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$downloadedCount/${subjects.length} ready',
                                style: AppTextStyles.normal600(
                                  color: AppColors.eLearningBtnColor1,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (subjects.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final subject = subjects[index];
                              return TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 0,
                                  end: _contentVisible ? 1 : 0,
                                ),
                                duration: Duration(
                                  milliseconds: 320 + (index * 45),
                                ),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, (1 - value) * 18),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildSubjectCard(subject),
                                ),
                              );
                            },
                            childCount: subjects.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required int downloadedCount,
    required int totalSubjects,
  }) {
    final statTiles = [
      _StudyStatTile(
        label: 'Subjects Studied',
        value: '${_dashboardStats.subjectsStudied}',
      ),
      _StudyStatTile(
        label: 'Hours Spent',
        value: _formatHours(_dashboardStats.totalTimeSpent),
      ),
      _StudyStatTile(
        label: 'Study Sessions',
        value: '${_dashboardStats.sessionsCount}',
      ),
      _StudyStatTile(
        label: 'Avg Accuracy',
        value: '${_dashboardStats.averageAccuracy.toStringAsFixed(0)}%',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.eLearningBtnColor1,
            AppColors.eLearningBtnColor1.withValues(alpha: 0.88),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.eLearningBtnColor1.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study overview',
            style: AppTextStyles.normal700(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: statTiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 88,
            ),
            itemBuilder: (context, index) => statTiles[index],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInsightChip(
                icon: Icons.menu_book_outlined,
                label: '${_dashboardStats.totalTopicsStudied} topics covered',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.normal500(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(SubjectModel subject) {
    final isDownloaded = _isSubjectDownloaded(subject);
    final downloadState = _downloadStates[subject.id];
    final isDownloading = downloadState?.isDownloading ?? false;
    final downloadedYears = subject.years?.length ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: isDownloaded ? () => _openStudySubject(subject) : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDownloaded
                  ? AppColors.eLearningBtnColor1.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.eLearningBtnColor1.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _subjectInitial(subject.name),
                    style: AppTextStyles.normal700(
                      color: AppColors.eLearningBtnColor1,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleCase(subject.name),
                      style: AppTextStyles.normal700(
                        fontSize: 16,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDownloaded
                          ? downloadedYears > 0
                              ? '$downloadedYears year sets saved offline'
                              : 'Downloaded and ready for study'
                          : 'Download this subject to study offline',
                      style: AppTextStyles.normal400(
                        color: AppColors.text7Light,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildTrailingActionButton(
                isDownloaded: isDownloaded,
                isDownloading: isDownloading,
                onPressed: isDownloading
                    ? null
                    : isDownloaded
                        ? () => _openStudySubject(subject)
                        : () => _downloadSubject(subject),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingActionButton({
    required bool isDownloaded,
    required bool isDownloading,
    required VoidCallback? onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isDownloaded
            ? AppColors.eLearningBtnColor1
            : const Color(0xFF182230),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isDownloading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              isDownloaded ? 'Study' : 'Download',
              style: AppTextStyles.normal600(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.eLearningBtnColor1.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.menu_book_outlined,
                color: AppColors.eLearningBtnColor1,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No subjects available yet',
              style: AppTextStyles.normal700(
                fontSize: 18,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh the board data and load your study subjects.',
              textAlign: TextAlign.center,
              style: AppTextStyles.normal400(
                color: AppColors.text7Light,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSubjectDownloaded(SubjectModel subject) {
    if (_downloadedSubjectIds.contains(subject.id)) {
      return true;
    }

    return subject.years?.isNotEmpty ?? false;
  }

  String _subjectInitial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'S';
    return trimmed.substring(0, 1).toUpperCase();
  }

  String _titleCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    return trimmed
        .split(' ')
        .where((segment) => segment.isNotEmpty)
        .map((segment) =>
            '${segment[0].toUpperCase()}${segment.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _formatHours(Duration duration) {
    final hours = duration.inMinutes / 60;
    if (hours <= 0) return '0h';
    if (hours >= 10) return '${hours.toStringAsFixed(0)}h';
    return '${hours.toStringAsFixed(1)}h';
  }
}

class _StudyStatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StudyStatTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.normal700(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.normal500(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
