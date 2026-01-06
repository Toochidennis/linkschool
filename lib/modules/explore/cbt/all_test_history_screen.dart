import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/cbt_history_model.dart';
import 'package:linkschool/modules/services/cbt_history_service.dart';
import 'package:linkschool/modules/services/study_history_service.dart';
import 'package:linkschool/modules/explore/cbt/study_progress_dashboard.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';

class AllTestHistoryScreen extends StatefulWidget {
  const AllTestHistoryScreen({super.key});

  @override
  State<AllTestHistoryScreen> createState() => _AllTestHistoryScreenState();
}

class _AllTestHistoryScreenState extends State<AllTestHistoryScreen>
    with SingleTickerProviderStateMixin {
  final CbtHistoryService _historyService = CbtHistoryService();
  final StudyHistoryService _studyHistoryService = StudyHistoryService();
  List<CbtHistoryModel> _allHistory = [];
  List<StudySessionStats> _studyHistory = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllHistory() async {
    setState(() => _isLoading = true);

    // Load test history
    final history = await _historyService.getTestHistory();
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Load study history
    final studyHistory = await _studyHistoryService.getStudyHistory();
    studyHistory.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));

    setState(() {
      _allHistory = history;
      _studyHistory = studyHistory;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(
        context: context,
        showBackButton: true,
        title: 'History',
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                 // color: AppColors.eLearningBtnColor1,
                  borderRadius: BorderRadius.circular(12),
                ),

                labelColor: AppColors.eLearningBtnColor1,
                unselectedLabelColor: AppColors.text7Light,
                labelStyle: AppTextStyles.normal600(fontSize: 14),
                tabs: const [
                  Tab(text: 'Test History'),
                  Tab(text: 'Study History'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTestHistoryTab(),
                        _buildStudyHistoryTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestHistoryTab() {
    if (_allHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No test history yet',
              style: AppTextStyles.normal600(
                fontSize: 18,
                color: AppColors.text7Light,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a test to see your history here',
              style: AppTextStyles.normal400(
                fontSize: 14,
                color: AppColors.text7Light,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allHistory.length,
      itemBuilder: (context, index) {
        final history = _allHistory[index];
        return _buildHistoryCard(history, index);
      },
    );
  }

  Widget _buildStudyHistoryTab() {
    if (_studyHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No study sessions yet',
              style: AppTextStyles.normal600(
                fontSize: 18,
                color: AppColors.text7Light,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a study session to see your history here',
              style: AppTextStyles.normal400(
                fontSize: 14,
                color: AppColors.text7Light,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _studyHistory.length,
      itemBuilder: (context, index) {
        final session = _studyHistory[index];
        return _buildStudySessionCard(session, index);
      },
    );
  }

  Widget _buildHistoryCard(CbtHistoryModel history, int index) {
    final colors = [
      AppColors.cbtColor3,
      AppColors.cbtColor4,
      AppColors.cbtColor1,
      AppColors.cbtColor2,
      AppColors.cbtColor5,
    ];

    final borderColor = colors[index % colors.length];
    final percentage = history.percentage;

    // Format timestamp
    final timestamp = history.timestamp;
    final dateStr = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        // Navigate to retake test
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
        ).then((_) {
          // Refresh history when coming back
          _loadAllHistory();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: history.isFullyCompleted
                ? AppColors.attCheckColor2 // Green border for completed
                : borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: CircularProgressIndicator(
                    color: history.isFullyCompleted
                        ? AppColors.attCheckColor2 // Green for completed
                        : borderColor,
                    value: percentage / 100,
                    strokeWidth: 7.5,
                    backgroundColor: history.isFullyCompleted
                        ? AppColors.attCheckColor2.withOpacity(0.2)
                        : borderColor.withOpacity(0.2),
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: AppTextStyles.normal600(
                    fontSize: 16,
                    color: AppColors.text4Light,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.subject,
                    style: AppTextStyles.normal600(
                      fontSize: 16,
                      color: AppColors.text4Light,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${history.examType} (${history.year})',
                    style: AppTextStyles.normal400(
                      fontSize: 14,
                      color: AppColors.text7Light,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        history.isFullyCompleted
                            ? Icons.check_circle
                            : history.isFullyCompleted
                                ? Icons.cancel
                                : Icons.warning_amber_rounded,
                        size: 14,
                        color: history.isFullyCompleted
                            ? AppColors.attCheckColor2
                            : history.isFullyCompleted
                                ? AppColors.eLearningRedBtnColor
                                : AppColors.text7Light,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        history.isFullyCompleted
                            ? 'Completed'
                            : ' not completed',
                        style: AppTextStyles.normal400(
                          fontSize: 12,
                          color: history.isFullyCompleted
                              ? AppColors.attCheckColor2
                              : history.isFullyCompleted
                                  ? AppColors.eLearningRedBtnColor
                                  : AppColors.text7Light,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$dateStr $timeStr',
                        style: AppTextStyles.normal400(
                          fontSize: 11,
                          color: AppColors.text7Light,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score: ${history.score}/${history.totalQuestions}',
                    style: AppTextStyles.normal500(
                      fontSize: 12,
                      color: AppColors.text7Light,
                    ),
                  ),
                ],
              ),
            ),

            // Retake icon
            Icon(
              Icons.refresh,
              color: history.isFullyCompleted
                  ? AppColors.attCheckColor2 // Green for completed
                  : borderColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudySessionCard(StudySessionStats session, int index) {
    final colors = [
      AppColors.cbtColor3,
      AppColors.cbtColor4,
      AppColors.cbtColor1,
      AppColors.cbtColor2,
      AppColors.cbtColor5,
    ];

    final borderColor = colors[index % colors.length];
    final accuracy = session.overallAccuracy;

    // Format date
    final timestamp = session.sessionDate;
    final dateStr = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        // Navigate to detailed view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudyProgressDashboard(
              sessionStats: session,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: CircularProgressIndicator(
                    color: borderColor,
                    value: accuracy / 100,
                    strokeWidth: 7.5,
                    backgroundColor: borderColor.withOpacity(0.2),
                  ),
                ),
                Text(
                  '${accuracy.toStringAsFixed(0)}%',
                  style: AppTextStyles.normal600(
                    fontSize: 16,
                    color: AppColors.text4Light,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.subject,
                    style: AppTextStyles.normal600(
                      fontSize: 16,
                      color: AppColors.text4Light,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.topicsStudied} topic${session.topicsStudied > 1 ? 's' : ''} studied',
                    style: AppTextStyles.normal400(
                      fontSize: 14,
                      color: AppColors.text7Light,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.attCheckColor2,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${session.totalCorrectAnswers}',
                        style: AppTextStyles.normal400(
                          fontSize: 12,
                          color: AppColors.attCheckColor2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.cancel,
                        size: 14,
                        color: AppColors.eLearningRedBtnColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${session.totalWrongAnswers}',
                        style: AppTextStyles.normal400(
                          fontSize: 12,
                          color: AppColors.eLearningRedBtnColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$dateStr $timeStr',
                        style: AppTextStyles.normal400(
                          fontSize: 11,
                          color: AppColors.text7Light,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Questions: ${session.totalQuestionsAnswered}',
                    style: AppTextStyles.normal500(
                      fontSize: 12,
                      color: AppColors.text7Light,
                    ),
                  ),
                ],
              ),
            ),

            // View details icon
            Icon(
              Icons.arrow_forward_ios,
              color: borderColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
