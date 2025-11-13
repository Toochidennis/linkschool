import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/cbt_history_model.dart';
import 'package:linkschool/modules/services/cbt_history_service.dart';
import 'package:linkschool/modules/explore/e_library/test_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';

class AllTestHistoryScreen extends StatefulWidget {
  const AllTestHistoryScreen({super.key});

  @override
  State<AllTestHistoryScreen> createState() => _AllTestHistoryScreenState();
}

class _AllTestHistoryScreenState extends State<AllTestHistoryScreen> {
  final CbtHistoryService _historyService = CbtHistoryService();
  List<CbtHistoryModel> _allHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllHistory();
  }

  Future<void> _loadAllHistory() async {
    setState(() => _isLoading = true);
    final history = await _historyService.getTestHistory();
    
    // Sort by timestamp (most recent first)
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    setState(() {
      _allHistory = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(
        context: context,
        showBackButton: true,
        title: 'All Test History',
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _allHistory.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _allHistory.length,
                    itemBuilder: (context, index) {
                      final history = _allHistory[index];
                      return _buildHistoryCard(history, index);
                    },
                  ),
      ),
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
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    
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
}
