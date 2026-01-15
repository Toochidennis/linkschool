import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_students_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/home/students_metrica.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/model/admin/home/student_metrics.dart';

class StudentStatisticsScreen extends StatefulWidget {
  const StudentStatisticsScreen({super.key});

  @override
  State<StudentStatisticsScreen> createState() =>
      _StudentStatisticsScreenState();
}

class _StudentStatisticsScreenState extends State<StudentStatisticsScreen> {
  late StudentMetricsProvider _metricsProvider;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _metricsProvider = locator<StudentMetricsProvider>();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _metricsProvider.loadMetrics();
      if (_metricsProvider.errorMessage != null) {
        setState(() {
          _errorMessage = _metricsProvider.errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Student Statistics',
          style: TextStyle(
            fontFamily: 'Urbanist',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.text2Light,
        elevation: 0,
      
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: AppTextStyles.normal600(
                          fontSize: 18,
                          color: AppColors.text3Light,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.normal400(
                            fontSize: 14,
                            color: Colors.grey[600]!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadMetrics,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.text2Light,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: Colors.white,
                  child: RefreshIndicator(
                    onRefresh: _loadMetrics,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Statistics Cards Row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.person_outline,
                                    iconColor: Colors.green,
                                    count: _metricsProvider.totalStudents.toString(),
                                    label: 'Total\nStudents',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.male,
                                    iconColor: AppColors.text2Light,
                                    count: _metricsProvider.maleStudents.toString(),
                                    label: 'Male\nStudents',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.female,
                                    iconColor: Colors.pink,
                                    count: _metricsProvider.femaleStudents.toString(),
                                    label: 'Female\nStudents',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Chart Section
                            if (_metricsProvider.charts.isNotEmpty) ...[
                              Center(
                                child: Text(
                                  'Students Admissions by Level',
                                  style: AppTextStyles.normal600(
                                    fontSize: 16,
                                    color: AppColors.text3Light,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 200,
                                child: _buildBarChart(),
                              ),
                              const SizedBox(height: 40),
                            ],

                            // Level Distribution Section
                            if (_metricsProvider.levels.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Level sections
                                  ..._metricsProvider.levels.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final level = entry.value;
                                    return Column(
                                      children: [
                                        if (index > 0) const SizedBox(height: 16),
                                        InkWell(
                                          onTap: () {
                                            // Navigate to ManageStudentsScreen for this level
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ManageStudentsScreen(
                                                  levelId: level.levelId,
                                                ),
                                              ),
                                            );
                                          },
                                          child: _buildLevelSection(
                                            level: level,
                                            levelNumber: index + 1,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget f({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon Circle
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),

          // Count
          Text(
            count,
            style: AppTextStyles.normal600(
              fontSize: 24,
              color: AppColors.text3Light,
            ),
          ),
          const SizedBox(height: 4),

          // Label
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.normal400(
              fontSize: 12,
              color: Colors.grey[600]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon Circle
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),

          // Count
          Text(
            count,
            style: AppTextStyles.normal600(
              fontSize: 24,
              color: AppColors.text3Light,
            ),
          ),
          const SizedBox(height: 4),

          // Label
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.normal400(
              fontSize: 12,
              color: Colors.grey[600]!,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildBarChart() {
    final charts = _metricsProvider.charts;
    if (charts.isEmpty) return const SizedBox.shrink();
    
    // Find max value for chart scale
    final maxStudents = charts.map((c) => c.y).reduce((a, b) => a > b ? a : b);
    
    // Handle edge case where maxStudents is 0
    if (maxStudents == 0) {
      return Center(
        child: Text(
          'No student data available',
          style: AppTextStyles.normal400(
            fontSize: 14,
            color: Colors.grey[600]!,
          ),
        ),
      );
    }
    
    final chartMaxY = (maxStudents * 1.2).ceilToDouble(); // Add 20% padding
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.text2Light.withOpacity(0.8),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} students',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: 'Urbanist',
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final charts = _metricsProvider.charts;
                if (value.toInt() >= 0 && value.toInt() < charts.length) {
                  final chartLabel = charts[value.toInt()].x;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      chartLabel,
                      style: AppTextStyles.normal500(
                        fontSize: 12,
                        color: AppColors.text3Light,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                // Only show whole numbers
                if (value % 1 == 0) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTextStyles.normal500(
                      fontSize: 12,
                      color: Colors.grey[600]!,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            left: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        barGroups: _buildBarGroups(),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final charts = _metricsProvider.charts;
    return List.generate(charts.length, (index) {
      final chartData = charts[index];
      final value = chartData.y.toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: AppColors.text2Light,
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: false,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLevelSection({
    required LevelModel level,
    required int levelNumber,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(45, 99, 255, 1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  levelNumber.toString(),
                  style: TextStyle(
                    color: AppColors.text2Light,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  level.levelName,
                  style: AppTextStyles.normal600(
                    fontSize: 15,
                    color: AppColors.text3Light,
                  ),
                ),
              ),
              Text(
                '${level.totalStudents} students',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: AppColors.text2Light,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Class rows
          ...level.classes.asMap().entries.map((entry) {
            final index = entry.key;
            final classItem = entry.value;
            final letter = String.fromCharCode(65 + index); // A, B, C, D, E
            final maxCount = level.classes.map((c) => c.totalStudents).reduce((a, b) => a > b ? a : b);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                 
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                    onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageStudentsScreen(
                        classId: classItem.classId,
                        ),
                      ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: _buildClassRow(
                      letter: letter,
                      className: classItem.className,
                      count: classItem.totalStudents,
                      maxCount: maxCount,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildClassRow({
    required String letter,
    required String className,
    required int count,
    required int maxCount,
  }) {
    // Handle edge case where maxCount is 0
    final progress = maxCount > 0 ? count / maxCount : 0.0;

    return Row(
      children: [
        // Letter badge - Circular
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          
        ),
        const SizedBox(width: 12),

        // Class name
        Text(
          className,
          style: AppTextStyles.normal500(
            fontSize: 14,
            color: AppColors.text3Light,
          ),
        ),
        
        const Spacer(),

        // Count
        Text(
          count.toString(),
          style: AppTextStyles.normal600(
            fontSize: 14,
            color: AppColors.text3Light,
          ),
        ),
        const SizedBox(width: 12),

        // Progress bar
        SizedBox(
          width: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.text2Light),
            ),
          ),
        ),
      ],
    );
  }
}
