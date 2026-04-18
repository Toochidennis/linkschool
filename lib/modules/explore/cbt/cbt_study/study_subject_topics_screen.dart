import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/ads/cbt_scoped_ad_manager.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study/cbt_study_screen.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study/study_ad_manager.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study/study_topic_actions_screen.dart';
import 'package:linkschool/modules/explore/cbt/cbt_study/models/study_session_stats.dart';
import 'package:linkschool/modules/model/explore/home/subject_model.dart';
import 'package:linkschool/modules/model/explore/study/topic_model.dart';
import 'package:linkschool/modules/providers/explore/subject_topic_provider.dart';
import 'package:linkschool/modules/services/study_history_service.dart';
import 'package:linkschool/modules/widgets/network_dialog.dart';
import 'package:provider/provider.dart';

class StudySubjectTopicsScreen extends StatefulWidget {
  final SubjectModel subject;
  final int examTypeId;

  const StudySubjectTopicsScreen({
    super.key,
    required this.subject,
    required this.examTypeId,
  });

  @override
  State<StudySubjectTopicsScreen> createState() =>
      _StudySubjectTopicsScreenState();
}

class _StudySubjectTopicsScreenState extends State<StudySubjectTopicsScreen>
    with WidgetsBindingObserver {
  final StudyHistoryService _historyService = StudyHistoryService();

  int? _selectedSyllabusId;
  final Map<int, double> _syllabusCompletion = <int, double>{};
  bool _historyLoaded = false;
  bool _initialTopicsLoadPending = true;
  bool _isNavigatingAway = false;
  bool _shouldShowAdOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StudyAdManager.instance.warmUpStudyAds(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadTopics();
      _loadHistory();
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
    }
  }

  Future<void> _loadTopics() async {
    final canUseNetwork = await NetworkDialog.ensureOnline(context);
    if (!canUseNetwork || !mounted) {
      if (mounted) {
        setState(() {
          _initialTopicsLoadPending = false;
        });
      }
      return;
    }

    final provider = context.read<SubjectTopicsProvider>();
    try {
      await provider.loadTopics(
        courseId: int.tryParse(widget.subject.id) ?? 0,
        examTypeId: widget.examTypeId,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _initialTopicsLoadPending = false;
      });
    }

    if (!mounted) return;
    _recalculateCompletion();
  }

  Future<void> _loadHistory() async {
    await _historyService.getStudyHistory();
    if (!mounted) return;

    setState(() {
      _historyLoaded = true;
    });
    _recalculateCompletion();
  }

  Future<void> _refreshTopics() async {
    await Future.wait<void>([
      _loadTopics(),
      _loadHistory(),
    ]);
  }

  Future<List<StudySessionStats>> _subjectHistory() async {
    final history = await _historyService.getStudyHistory();
    final normalizedSubject = normalizeStudySubject(widget.subject.name);
    return history
        .where((session) =>
            normalizeStudySubject(session.subject) == normalizedSubject)
        .toList(growable: false);
  }

  Future<void> _recalculateCompletion() async {
    final topicsProvider = context.read<SubjectTopicsProvider>();
    final syllabuses = topicsProvider.topicsData?.data ?? const <Syllabus>[];
    if (syllabuses.isEmpty) return;

    final history = await _subjectHistory();
    final completionByTopic = _computeTopicCompletion(history);

    final syllabusCompletion = <int, double>{};
    for (final syllabus in syllabuses) {
      if (syllabus.topics.isEmpty) {
        syllabusCompletion[syllabus.syllabusId] = 0;
        continue;
      }

      final percentages = syllabus.topics.map((topic) {
        final keyById = _topicKey(topicId: topic.topicId);
        final keyByName = _topicKey(topicName: topic.topicName);
        return completionByTopic[keyById] ?? completionByTopic[keyByName] ?? 0;
      }).toList(growable: false);

      final total = percentages.fold<double>(0, (sum, value) => sum + value);
      syllabusCompletion[syllabus.syllabusId] = total / percentages.length;
    }

    if (!mounted) return;
    setState(() {
      _syllabusCompletion
        ..clear()
        ..addAll(syllabusCompletion);
    });
  }

  Map<String, double> _computeTopicCompletion(
      List<StudySessionStats> sessions) {
    final answeredByTopic = <String, int>{};
    final correctByTopic = <String, int>{};

    for (final session in sessions) {
      for (final topic in session.topicProgressList) {
        final byIdKey = _topicKey(topicId: topic.topicId);
        answeredByTopic[byIdKey] =
            (answeredByTopic[byIdKey] ?? 0) + topic.questionsAnswered;
        correctByTopic[byIdKey] =
            (correctByTopic[byIdKey] ?? 0) + topic.correctAnswers;

        final byNameKey = _topicKey(topicName: topic.topicName);
        answeredByTopic[byNameKey] =
            (answeredByTopic[byNameKey] ?? 0) + topic.questionsAnswered;
        correctByTopic[byNameKey] =
            (correctByTopic[byNameKey] ?? 0) + topic.correctAnswers;
      }
    }

    final completion = <String, double>{};
    for (final key in answeredByTopic.keys) {
      final answered = answeredByTopic[key] ?? 0;
      final correct = correctByTopic[key] ?? 0;
      if (answered <= 0) {
        completion[key] = 0;
        continue;
      }

      final accuracy = correct / answered;
      final coverage = (answered / 20).clamp(0, 1).toDouble();
      final score = ((coverage * 0.6) + (accuracy * 0.4)) * 100;
      completion[key] = score.clamp(0, 100);
    }

    return completion;
  }

  String _topicKey({int? topicId, String? topicName}) {
    if (topicId != null && topicId > 0) {
      return 'id:$topicId';
    }

    return 'name:${(topicName ?? '').trim().toUpperCase()}';
  }

  int get _completedTopicsCount {
    return _syllabusCompletion.values.where((value) => value >= 80).length;
  }

  Future<void> _startPracticeForSyllabus(Syllabus syllabus) async {
    final topicIds = <int>[];
    for (final topic in syllabus.topics) {
      if (!topicIds.contains(topic.topicId)) {
        topicIds.add(topic.topicId);
      }
    }

    final topicNames = <String>[syllabus.syllabusName];

    await StudyAdManager.instance.showIfEligible(
      context: context,
      trigger: CbtScopedAdTrigger.topicStart,
    );
    if (!mounted) return;

    _isNavigatingAway = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CBTStudyScreen(
          subject: widget.subject.name,
          topics: topicNames,
          topicIds: topicIds,
          courseId: int.tryParse(widget.subject.id) ?? 0,
          examTypeId: widget.examTypeId,
        ),
      ),
    ).then((_) {
      _isNavigatingAway = false;
    });
  }

  void _openTopicActions(Syllabus syllabus) {
    setState(() {
      _selectedSyllabusId = syllabus.syllabusId;
    });

    _isNavigatingAway = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudyTopicActionsScreen(
          topicTitle: syllabus.syllabusName,
          subject: widget.subject.name,
          topics: <String>[syllabus.syllabusName],
          topicIds: syllabus.topics
              .map((topic) => topic.topicId)
              .toSet()
              .toList(growable: false),
          courseId: int.tryParse(widget.subject.id) ?? 0,
          examTypeId: widget.examTypeId,
          onPracticeTap: () async {
            Navigator.pop(context);
            await _startPracticeForSyllabus(syllabus);
          },
        ),
      ),
    ).then((_) {
      _isNavigatingAway = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = _titleCase(widget.subject.name);

    return Scaffold(
      appBar: Constants.customAppBar(
        context: context,
        showBackButton: true,
        title: subjectName,
        showBackgroundIllustration: false,
      ),
      body: Container(
        decoration: Constants.customStudyBoxDecoration(context),
        child: Consumer<SubjectTopicsProvider>(
          builder: (context, topicsProvider, _) {
            final syllabuses =
                topicsProvider.topicsData?.data ?? const <Syllabus>[];

            return RefreshIndicator(
              color: AppColors.eLearningBtnColor1,
              onRefresh: _refreshTopics,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  if (_initialTopicsLoadPending ||
                      topicsProvider.loading ||
                      !_historyLoaded)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (topicsProvider.error != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildErrorState(topicsProvider.error!),
                    )
                  else if (syllabuses.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        child: _buildStatsCard(totalTopics: syllabuses.length),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      sliver: SliverList.builder(
                        itemCount: syllabuses.length,
                        itemBuilder: (context, index) {
                          final syllabus = syllabuses[index];
                          final isSelected =
                              _selectedSyllabusId == syllabus.syllabusId;
                          final completion =
                              _syllabusCompletion[syllabus.syllabusId] ?? 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SyllabusTopicTile(
                              title: syllabus.syllabusName,
                              completionPercent: completion,
                              selected: isSelected,
                              onTap: () => _openTopicActions(syllabus),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsCard({required int totalTopics}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.track_changes_rounded,
            color: AppColors.eLearningBtnColor1,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Topics complete: $_completedTopicsCount/$totalTopics',
              style: AppTextStyles.normal600(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text(
              'Could not load topics',
              style: AppTextStyles.normal700(
                fontSize: 18,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.normal400(
                fontSize: 13,
                color: AppColors.text7Light,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _loadTopics,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.eLearningBtnColor1,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No topics available for this subject yet.',
        style: AppTextStyles.normal600(
          fontSize: 14,
          color: AppColors.text7Light,
        ),
      ),
    );
  }

  String _titleCase(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class _SyllabusTopicTile extends StatelessWidget {
  final String title;
  final double completionPercent;
  final bool selected;
  final VoidCallback onTap;

  const _SyllabusTopicTile({
    required this.title,
    required this.completionPercent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = completionPercent.clamp(0, 100);
    final progressValue = percent / 100;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.eLearningBtnColor1.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: selected
                    ? AppColors.eLearningBtnColor1
                    : AppColors.text7Light,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.normal600(
                    fontSize: 15,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progressValue,
                      strokeWidth: 5,
                      backgroundColor:
                          AppColors.eLearningBtnColor1.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.eLearningBtnColor1,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: AppTextStyles.normal600(
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
