import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/constants.dart';
import '../../../common/app_colors.dart';
import '../../../common/text_styles.dart';

class AssessmentSettingScreen extends StatefulWidget {
  const AssessmentSettingScreen({super.key});

  @override
  _AssessmentSettingScreenState createState() =>
      _AssessmentSettingScreenState();
}

class _AssessmentSettingScreenState extends State<AssessmentSettingScreen> {
  String? _selectedLevel;
  final _assessmentNameController = TextEditingController();
  final _assessmentScoreController = TextEditingController();
  final List<Map<String, String>> _assessments = [];
  bool isHoveringSave = false;

  final List<String> levels = [
    'Primary One',
    'Junior Secondary School One (JSS1)',
    'Junior Secondary School Two (JSS2)',
    'Junior Secondary School Three (JSS3)',
    'Senior Secondary School One (SS1)',
    'Senior Secondary School Two (SS2)',
    'Senior Secondary School Three (SS3)'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child:
                Text('Assessment Settings', style: AppTextStyles.appBarTitle)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 1.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Level', style: AppTextStyles.label),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    offset: Offset(0, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                ),
                items: levels.map((String level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLevel = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: [
                  ..._assessments
                      .map((assessment) => buildAssessmentCard(assessment)),
                  const SizedBox(height: 16.0),
                  buildInputCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Save settings functionality
          log('Save settings button pressed');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Assessment settings saved successfully')),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: AppColors.primaryLight,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 7,
                    spreadRadius: 7,
                    offset: const Offset(3, 5))
              ]),
          child: const Icon(
            Icons.save,
            color: AppColors.backgroundLight,
          ),
        ),
      ),
    );
  }

  Widget buildInputCard() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowColor,
                offset: Offset(1, 2),
                blurRadius: 0.3)
          ]),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Assessment name:',
                    style: AppTextStyles.inputLabel,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _assessmentNameController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Text('Assessment score:',
                    style: AppTextStyles.inputLabel),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _assessmentScoreController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _assessments.add({
                      'name': _assessmentNameController.text,
                      'score': _assessmentScoreController.text,
                    });
                    _assessmentNameController.clear();
                    _assessmentScoreController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  fixedSize: const Size(100, 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: const Text(
                  'Add +',
                  style: AppTextStyles.normal6Light,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAssessmentCard(Map<String, String> assessment) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primaryDark),
                  onPressed: () {
                    editAssessment(assessment);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.primaryDark),
                  onPressed: () {
                    deleteAssessment(assessment);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                        text: TextSpan(
                            text: 'Assessment name:  ',
                            style: AppTextStyles.normal3Light,
                            children: <TextSpan>[
                          TextSpan(
                            text: '${assessment['name']}',
                            style: AppTextStyles.textInput,
                          )
                        ])),
                    // Text(
                    //   'Assessment name: ${assessment['name']}',
                    //   style: AppTextStyles.normalLight,
                    // ),
                    const SizedBox(height: 20.0),
                    RichText(
                        text: TextSpan(
                            text: 'Assessment score:  ',
                            style: AppTextStyles.normal3Light,
                            children: <TextSpan>[
                          TextSpan(
                            text: '${assessment['score']}',
                            style: AppTextStyles.textInput,
                          )
                        ])),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void editAssessment(Map<String, String> assessment) {
    setState(() {
      _assessmentNameController.text = assessment['name']!;
      _assessmentScoreController.text = assessment['score']!;
      _assessments.remove(assessment);
    });
  }

  void deleteAssessment(Map<String, String> assessment) {
    setState(() {
      _assessments.remove(assessment);
    });
  }
}
