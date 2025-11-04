import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class MonthlyAssessmentScreen extends StatefulWidget {
  final String classId;
  final String year;
  final int term;
  final String termName;
  final String subject;
  final Map<String, dynamic> courseData;

  const MonthlyAssessmentScreen({
    super.key,
    required this.classId,
    required this.year,
    required this.term,
    required this.termName,
    required this.subject,
    required this.courseData,
  });

  @override
  State<MonthlyAssessmentScreen> createState() =>
      _MonthlyAssessmentScreenState();
}

class _MonthlyAssessmentScreenState extends State<MonthlyAssessmentScreen> {
  String selectedMonth = 'January';
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  Widget build(BuildContext context) {
    final nextYear = (int.parse(widget.year) + 1).toString();
    final sessionTitle = '${widget.year}/$nextYear ${widget.termName}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          'Monthly Assessment - ${widget.subject}',
          style: AppTextStyles.normal500(
            fontSize: 18.0,
            color: AppColors.primaryLight,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            height: 34.0,
            width: 34.0,
            color: AppColors.primaryLight,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgColor1,
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assessment Overview',
                    style: AppTextStyles.normal600(
                      fontSize: 18,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard('Session', sessionTitle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard('Subject', widget.subject),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Month Selector
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        isExpanded: true,
                        hint: Text(
                          'Select Month',
                          style: AppTextStyles.normal400(
                            fontSize: 14,
                            color: Colors.grey[600]!,
                          ),
                        ),
                        items: months.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(
                              month,
                              style: AppTextStyles.normal500(
                                fontSize: 14,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMonth = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 1),

            // Statistics Cards
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Total Students', '32', Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Completed', '28', Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Pending', '4', Colors.orange),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Assessment List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Monthly Assessments - $selectedMonth',
                            style: AppTextStyles.normal600(
                              fontSize: 16,
                              color: AppColors.primaryLight,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _showAddAssessmentDialog();
                            },
                            icon: const Icon(
                              Icons.add_circle,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: 5, // Dummy assessment count
                        itemBuilder: (context, index) {
                          return _buildAssessmentCard(index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.normal400(
              fontSize: 12,
              color: Colors.grey[600]!,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.normal600(
              fontSize: 14,
              color: AppColors.backgroundDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.normal600(
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.normal500(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(int index) {
    final dummyAssessments = [
      {
        'title': 'Weekly Quiz 1',
        'date': '2024-01-05',
        'type': 'Quiz',
        'status': 'Completed'
      },
      {
        'title': 'Assignment 1',
        'date': '2024-01-12',
        'type': 'Assignment',
        'status': 'Completed'
      },
      {
        'title': 'Mid-Month Test',
        'date': '2024-01-15',
        'type': 'Test',
        'status': 'Pending'
      },
      {
        'title': 'Project Submission',
        'date': '2024-01-22',
        'type': 'Project',
        'status': 'In Progress'
      },
      {
        'title': 'Final Assessment',
        'date': '2024-01-30',
        'type': 'Exam',
        'status': 'Scheduled'
      },
    ];

    final assessment = dummyAssessments[index % dummyAssessments.length];
    final statusColor = _getStatusColor(assessment['status']!);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment['title']!,
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${assessment['date']}',
                      style: AppTextStyles.normal400(
                        fontSize: 12,
                        color: Colors.grey[600]!,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  assessment['status']!,
                  style: AppTextStyles.normal600(
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  assessment['type']!,
                  style: AppTextStyles.normal500(
                    fontSize: 10,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showAssessmentDetails(assessment);
                },
                child: Text(
                  'View Details',
                  style: AppTextStyles.normal500(
                    fontSize: 12,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'scheduled':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showAddAssessmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add New Assessment',
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: AppColors.primaryLight,
            ),
          ),
          content: const Text(
              'This feature will allow you to add new monthly assessments.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Add Assessment feature coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAssessmentDetails(Map<String, String> assessment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            assessment['title']!,
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: AppColors.primaryLight,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${assessment['type']}'),
              const SizedBox(height: 8),
              Text('Date: ${assessment['date']}'),
              const SizedBox(height: 8),
              Text('Status: ${assessment['status']}'),
              const SizedBox(height: 8),
              Text('Subject: ${widget.subject}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Edit Assessment feature coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
              ),
              child: const Text('Edit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
