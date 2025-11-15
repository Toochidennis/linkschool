import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_students_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class StudentStatisticsScreen extends StatefulWidget {
  const StudentStatisticsScreen({super.key});

  @override
  State<StudentStatisticsScreen> createState() =>
      _StudentStatisticsScreenState();
}

class _StudentStatisticsScreenState extends State<StudentStatisticsScreen> {
  // Sample data - replace with actual data from your provider
  final int totalStudents = 1116;
  final int maleStudents = 580;
  final int femaleStudents = 536;

  // Admissions data by year
  final Map<String, double> admissionsData = {
    '2020': 250,
    '2021': 300,
    '2022': 400,
    '2023': 480,
    '2024': 550,
  };

  // Level distribution data
  final Map<String, List<Map<String, dynamic>>> levelDistribution = {
    'JSS 1': [
      {'name': 'JSS 1A', 'count': 32},
      {'name': 'JSS 1B', 'count': 28},
      {'name': 'JSS 1C', 'count': 31},
      {'name': 'JSS 1D', 'count': 29},
      {'name': 'JSS 1E', 'count': 30},
    ],
    'JSS 2': [
      {'name': 'JSS 2A', 'count': 35},
      {'name': 'JSS 2B', 'count': 33},
      {'name': 'JSS 2C', 'count': 29},
      {'name': 'JSS 2D', 'count': 31},
      {'name': 'JSS 2E', 'count': 27},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Students',
          style: TextStyle(
            fontFamily: 'Urbanist',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.text2Light,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
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
                        iconColor: AppColors.text2Light,
                        count: totalStudents.toString(),
                        label: 'Total\nStudents',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.male,
                        iconColor: AppColors.text2Light,
                        count: maleStudents.toString(),
                        label: 'Male\nStudents',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.female,
                        iconColor: Colors.pink,
                        count: femaleStudents.toString(),
                        label: 'Female\nStudents',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Admission Trends Section
                Row(
                  children: [
                    Icon(
                      Icons.show_chart,
                      color: AppColors.text2Light,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Admission Trends',
                      style: AppTextStyles.normal600(
                        fontSize: 14,
                        color: AppColors.text3Light.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Chart Title
                Center(
                  child: Text(
                    'Student Admissions by Year',
                    style: AppTextStyles.normal600(
                      fontSize: 16,
                      color: AppColors.text3Light,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bar Chart
                SizedBox(
                  height:250,
                  child: _buildBarChart(),
                ),
                const SizedBox(height: 40),

                // Level Distribution Section
                Container(
                 padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level Distribution',
                            style: AppTextStyles.normal600(
                              fontSize: 16,
                              color: AppColors.text3Light,
                            ),
                          ),
                          Text(
                            '$totalStudents Students',
                            style: AppTextStyles.normal500(
                              fontSize: 14,
                              color: Colors.grey[600]!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Level sections
                      ...levelDistribution.entries.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final levelEntry = entry.value;
                        return Column(
                          children: [
                            if (index > 0) const SizedBox(height: 16),
                            _buildLevelSection(
                              levelName: levelEntry.key,
                              classes: levelEntry.value,
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
            width: 48,
            height: 48,
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
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 600,
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
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final years = admissionsData.keys.toList();
                if (value.toInt() >= 0 && value.toInt() < years.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      years[value.toInt()],
                      style: AppTextStyles.normal500(
                        fontSize: 14,
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
              interval: 100,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.normal500(
                    fontSize: 12,
                    color: Colors.grey[600]!,
                  ),
                );
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
          horizontalInterval: 100,
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
    final years = admissionsData.keys.toList();
    return List.generate(years.length, (index) {
      final year = years[index];
      final value = admissionsData[year]!;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: AppColors.text2Light,
            width: 32,
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
    required String levelName,
    required List<Map<String, dynamic>> classes,
  }) {
    // Calculate total students in this level
    final levelTotal = classes.fold<int>(
      0,
      (sum, classData) => sum + (classData['count'] as int),
    );

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
                  levelName.split(' ')[1][0], // Get first character (1 or 2)
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
                  levelName,
                  style: AppTextStyles.normal600(
                    fontSize: 15,
                    color: AppColors.text3Light,
                  ),
                ),
              ),
              Text(
                '$levelTotal students',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: AppColors.text2Light,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Class rows
          ...classes.asMap().entries.map((entry) {
            final index = entry.key;
            final classData = entry.value;
            final className = classData['name'] as String;
            final count = classData['count'] as int;
            final letter = String.fromCharCode(65 + index); // A, B, C, D, E

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                 
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageStudentsScreen(
                           
                          ),
                        ),
                      );
                    },
                    child: _buildClassRow(
                      letter: letter,
                      className: className,
                      count: count,
                      maxCount: 40, // Max for progress bar scale
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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
    final progress = count / maxCount;

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
          child: Text(
            letter,
            style: AppTextStyles.normal500(
              fontSize: 14,
              color: AppColors.text3Light,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Class name
        SizedBox(
          width: 60,
          child: Text(
            className,
            style: AppTextStyles.normal500(
              fontSize: 14,
              color: AppColors.text3Light,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Count
        SizedBox(
          width: 30,
          child: Text(
            count.toString(),
            style: AppTextStyles.normal600(
              fontSize: 14,
              color: AppColors.text3Light,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Progress bar
        Expanded(
          child: ClipRRect(

            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 80,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.text2Light),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
