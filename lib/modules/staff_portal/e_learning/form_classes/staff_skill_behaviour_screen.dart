import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class StaffSkillsBehaviourScreen extends StatefulWidget {
  const StaffSkillsBehaviourScreen({Key? key}) : super(key: key);

  @override
  State<StaffSkillsBehaviourScreen> createState() => _StaffSkillsBehaviourScreenState();
}

class _StaffSkillsBehaviourScreenState extends State<StaffSkillsBehaviourScreen> {
  late double opacity;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skill and Behaviour',
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
              'Save',
              style: TextStyle(color: AppColors.eLearningBtnColor1),
            ),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: Constants.customBoxDecoration(context),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSubjectsTable(),
              ],
            ),
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
        ],
      ),
    );
  }

  Widget _buildSubjectsTable() {
    final List<String> subjects = [
      'Toochi Dennis',
      'Toochi Joe',
      'Ifeanyi Dennis',
      'Johnson Kenny',
      'Toochi Dennis',
      'Toochi Dennis',
      'Toochi Dennis',
      'Toochi Dennis',
      'Toochi Dennis',
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
                    _buildScrollableColumn('Punctuality', 100, subjects),
                    _buildScrollableColumn('Neatness', 100, subjects),
                    _buildScrollableColumn('Neatness', 100, subjects),
                    _buildScrollableColumn('Humility', 100, subjects),
                    _buildScrollableColumn('Kindness', 100, subjects),
                    // _buildScrollableColumn('Grade', 80, subjects),
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
              'Student Name',
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
              child: const Text(
                '80', // Sample Data
                style: TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}