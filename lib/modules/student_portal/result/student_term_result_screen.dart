import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class TermResultScreen extends StatefulWidget {
  final String termTitle;

  const TermResultScreen({Key? key, required this.termTitle}) : super(key: key);

  @override
  State<TermResultScreen> createState() => _TermResultScreenState();
}

class _TermResultScreenState extends State<TermResultScreen> {
  late double opacity;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Result',
          style: AppTextStyles.normal600(
            fontSize: 18.0,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Implement download functionality
            },
            icon:
                const Icon(Icons.download, color: AppColors.eLearningBtnColor1),
            label: const Text(
              'Download',
              style: TextStyle(color: AppColors.eLearningBtnColor1),
            ),
          ),
        ],
      ),
      body: Container(
         decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTermSection('${widget.termTitle} Result'),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 32.0,
                ),
                child: const Divider(),
              ),
              _buildSubjectsTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermSection(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.orange, width: 2),
                bottom: BorderSide(color: Colors.orange, width: 2),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange),
              ),
            ),
          ),
          Column(
            children: [
              _buildInfoRow('Student average', '76.80%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Add this
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.paymentTxtColor1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTable() {
    final List<String> subjects = [
      'English Language',
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'Geography',
      'Economics',
      'Literature',
      'History',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildSubjectColumn(subjects),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildScrollableColumn('Assessment 1', 80, subjects),
                    _buildScrollableColumn('Assessment 2', 80, subjects),
                    _buildScrollableColumn('Assessment 3', 80, subjects),
                    _buildScrollableColumn('Examination', 100, subjects),
                    _buildScrollableColumn('Total Score', 100, subjects),
                    _buildScrollableColumn('Grade', 80, subjects),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectColumn(List<String> subjects) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              'Subject',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...subjects.map((subject) {
            return Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subject,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildScrollableColumn(
      String title, double width, List<String> subjects) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.eLearningBtnColor1,
              border: Border(
                left: const BorderSide(color: Colors.white),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...subjects.map((_) {
            return Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                '80', // Sample Data
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
