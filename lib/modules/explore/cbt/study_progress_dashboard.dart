import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/services/study_history_service.dart';

/// Model to track study progress per topic
class TopicProgress {
  final String topicName;
  final int topicId;
  final int questionsAnswered;
  final int correctAnswers;
  final int wrongAnswers;
  final Duration timeSpent;

  TopicProgress({
    required this.topicName,
    required this.topicId,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeSpent,
  });

  double get accuracy =>
      questionsAnswered > 0 ? (correctAnswers / questionsAnswered) * 100 : 0.0;

  String get formattedTime {
    final minutes = timeSpent.inMinutes;
    final seconds = timeSpent.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

/// Model for overall study session stats
class StudySessionStats {
  final String subject;
  final List<TopicProgress> topicProgressList;
  final Duration totalTimeSpent;
  final DateTime sessionDate;

  StudySessionStats({
    required this.subject,
    required this.topicProgressList,
    required this.totalTimeSpent,
    required this.sessionDate,
  });

  int get totalQuestionsAnswered =>
      topicProgressList.fold(0, (sum, topic) => sum + topic.questionsAnswered);

  int get totalCorrectAnswers =>
      topicProgressList.fold(0, (sum, topic) => sum + topic.correctAnswers);

  int get totalWrongAnswers =>
      topicProgressList.fold(0, (sum, topic) => sum + topic.wrongAnswers);

  int get topicsStudied => topicProgressList.length;

  double get overallAccuracy => totalQuestionsAnswered > 0
      ? (totalCorrectAnswers / totalQuestionsAnswered) * 100
      : 0.0;

  String get formattedTotalTime {
    final hours = totalTimeSpent.inHours;
    final minutes = totalTimeSpent.inMinutes % 60;
    final seconds = totalTimeSpent.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }
}

class StudyProgressDashboard extends StatefulWidget {
  final StudySessionStats sessionStats;

  const StudyProgressDashboard({
    super.key,
    required this.sessionStats,
  });

  @override
  State<StudyProgressDashboard> createState() => _StudyProgressDashboardState();
}

class _StudyProgressDashboardState extends State<StudyProgressDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // Save study session to history
    _saveStudySession();
  }

  Future<void> _saveStudySession() async {
    final studyHistoryService = StudyHistoryService();
    await studyHistoryService.saveStudySession(widget.sessionStats);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return WillPopScope(
      onWillPop: () async {
        // Pop twice to go back to study selection screen
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Study Progress'),
          centerTitle: true,
          backgroundColor: AppColors.backgroundLight,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.eLearningBtnColor1.withOpacity(opacity),
                        AppColors.backgroundLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: Constants.customBoxDecoration(context),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: child,
                ),
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with celebration
                  // _buildCelebrationHeader(),
                  const SizedBox(height: 24),

                  // Overall Stats Card
                  _buildOverallStatsCard(),
                  const SizedBox(height: 24),

                  // Performance Overview
                  // _buildPerformanceOverview(),
                  // const SizedBox(height: 24),

                  // Topics Progress Section
                  _buildTopicsProgressSection(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  // _buildActionButtons(),
                  // const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.eLearningBtnColor1,
            AppColors.eLearningBtnColor1.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.eLearningBtnColor1.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Study Session Complete!',
            style: AppTextStyles.normal700(
              fontSize: 22,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.sessionStats.subject,
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Completed on ${_formatDate(widget.sessionStats.sessionDate)}',
            style: AppTextStyles.normal400(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatsCard() {
    final stats = widget.sessionStats;
    final accuracy = stats.overallAccuracy;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.eLearningBtnColor1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics,
                  color: AppColors.eLearningBtnColor1,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Overall Performance',
                style: AppTextStyles.normal700(
                  fontSize: 18,
                  color: AppColors.text4Light,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Circular Progress Indicator with Accuracy
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: accuracy / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getAccuracyColor(accuracy),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${accuracy.toStringAsFixed(1)}%',
                      style: AppTextStyles.normal700(
                        fontSize: 28,
                        color: _getAccuracyColor(accuracy),
                      ),
                    ),
                    Text(
                      'Accuracy',
                      style: AppTextStyles.normal500(
                        fontSize: 14,
                        color: AppColors.text7Light,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Questions',
                stats.totalQuestionsAnswered.toString(),
                Icons.quiz,
                Colors.blue,
              ),
              _buildStatItem(
                'Correct',
                stats.totalCorrectAnswers.toString(),
                Icons.check_circle,
                AppColors.attCheckColor2,
              ),
              _buildStatItem(
                'Wrong',
                stats.totalWrongAnswers.toString(),
                Icons.cancel,
                AppColors.eLearningRedBtnColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 16),

          // Time and Topics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // _buildInfoItem(
              //   Icons.access_time,
              //   'Time Spent',
              //   stats.formattedTotalTime,
              //   AppColors.eLearningBtnColor1,
              // ),
              // Container(
              //   width: 1,
              //   height: 40,
              //   color: Colors.grey.shade300,
              // ),
              _buildInfoItem(
                Icons.topic,
                'Topics Studied',
                '${stats.topicsStudied}',
                AppColors.eLearningBtnColor1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.eLearningBtnColor1,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Performance Breakdown',
                style: AppTextStyles.normal700(
                  fontSize: 18,
                  color: AppColors.text4Light,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Bar with Labels
          _buildProgressBar(
            'Correct Answers',
            widget.sessionStats.totalCorrectAnswers,
            widget.sessionStats.totalQuestionsAnswered,
            AppColors.attCheckColor2,
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Wrong Answers',
            widget.sessionStats.totalWrongAnswers,
            widget.sessionStats.totalQuestionsAnswered,
            AppColors.eLearningRedBtnColor,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.normal600(
                fontSize: 15,
                color: AppColors.text4Light,
              ),
            ),
            Text(
              '$value / $total (${percentage.toStringAsFixed(1)}%)',
              style: AppTextStyles.normal600(
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: total > 0 ? value / total : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.library_books,
              color: AppColors.eLearningBtnColor1,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Topics Breakdown',
              style: AppTextStyles.normal700(
                fontSize: 18,
                color: AppColors.text4Light,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Topic Cards
        ...widget.sessionStats.topicProgressList.asMap().entries.map((entry) {
          final index = entry.key;
          final topic = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTopicCard(topic, index + 1),
          );
        }),
      ],
    );
  }

  Widget _buildTopicCard(TopicProgress topic, int index) {
    final accuracy = topic.accuracy;
    final accuracyColor = _getAccuracyColor(accuracy);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accuracyColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Topic Number Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.eLearningBtnColor1,
                      AppColors.eLearningBtnColor1.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: AppTextStyles.normal700(
                      fontSize: 16,
                      color: Colors.white,
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
                      topic.topicName,
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.text4Light,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Icon(
                        //   Icons.access_time,
                        //   size: 14,
                        //   color: AppColors.text7Light,
                        // ),
                        // const SizedBox(width: 4),
                        // Text(
                        //   topic.formattedTime,
                        //   style: AppTextStyles.normal400(
                        //     fontSize: 13,
                        //     color: AppColors.text7Light,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              // Accuracy Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accuracyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: AppTextStyles.normal700(
                    fontSize: 14,
                    color: accuracyColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTopicStat(
                'Answered',
                topic.questionsAnswered,
                Colors.blue,
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.shade300,
              ),
              _buildTopicStat(
                'Correct',
                topic.correctAnswers,
                AppColors.attCheckColor2,
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.shade300,
              ),
              _buildTopicStat(
                'Wrong',
                topic.wrongAnswers,
                AppColors.eLearningRedBtnColor,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: topic.questionsAnswered > 0
                  ? topic.correctAnswers / topic.questionsAnswered
                  : 0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(accuracyColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: AppTextStyles.normal700(
            fontSize: 18,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.normal400(
            fontSize: 12,
            color: AppColors.text7Light,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Study Again Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.eLearningBtnColor1,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Study Again',
                  style: AppTextStyles.normal600(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Back to Dashboard Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Pop until we reach the main screen or dashboard
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: AppColors.eLearningBtnColor1,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home,
                  color: AppColors.eLearningBtnColor1,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Dashboard',
                  style: AppTextStyles.normal600(
                    fontSize: 16,
                    color: AppColors.eLearningBtnColor1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.normal700(
            fontSize: 20,
            color: AppColors.text4Light,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.normal400(
            fontSize: 13,
            color: AppColors.text7Light,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
      IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.normal400(
            fontSize: 12,
            color: AppColors.text7Light,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.normal700(
            fontSize: 16,
            color: AppColors.text4Light,
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) {
      return AppColors.attCheckColor2;
    } else if (accuracy >= 60) {
      return Colors.orange;
    } else {
      return AppColors.eLearningRedBtnColor;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
