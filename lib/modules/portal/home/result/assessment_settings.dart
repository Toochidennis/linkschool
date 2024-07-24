// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/constants.dart';
import '../../../common/app_colors.dart';
import '../../../common/text_styles.dart';

class AssessmentSettingScreen extends StatefulWidget {
  const AssessmentSettingScreen({super.key});

  @override
  State<AssessmentSettingScreen> createState() =>
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
        title: Text(
          'Assessment Settings',
          style: AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Level',
              style: AppTextStyles.normal600(
                  fontSize: 16.0, color: AppColors.primaryLight),
            ),
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLevel,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: AppColors.primaryLight),
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLevel = newValue;
                    });
                  },
                  items: levels.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(child: Text(value)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            Expanded(
              child: ListView(
                children: [
                  ..._assessments
                      .map((assessment) => buildAssessmentCard(assessment)),
                  const SizedBox(height: 24.0), // Increased space between cards
                  buildInputCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
                offset: const Offset(3, 5),
              )
            ],
          ),
          child: const Icon(
            Icons.save,
            color: AppColors.backgroundLight,
          ),
        ),
      ),
    );
  }

  Widget buildInputCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowColor,
                  offset: Offset(1, 2),
                  blurRadius: 0.3,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Assessment name:',
                          style: AppTextStyles.normal600(
                            fontSize: 14.0,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _assessmentNameController,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.assessmentColor1),
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
                      Text(
                        'Assessment score:',
                        style: AppTextStyles.normal600(
                          fontSize: 14.0,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _assessmentScoreController,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.assessmentColor1),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16), // Space between input card and + button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
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
          ),
        ),
      ],
    );
  }

Widget buildAssessmentCard(Map<String, String> assessment) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
    elevation: 3,
    color: Colors.white,
    child: Container(
      height: 150, // Reduced height since we're using less vertical space
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Row(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/result/edit.svg',
                    color: AppColors.primaryDark,
                    width: 16,
                    height: 16,
                  ),
                  onPressed: () {
                    editAssessment(assessment);
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(Size(24, 24)),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/result/delete.svg',
                    color: AppColors.primaryDark,
                    width: 16,
                    height: 16,
                  ),
                  onPressed: () {
                    deleteAssessment(assessment);
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(Size(24, 24)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right:8.0),
                      child: Text(
                        'Assessment name: ',
                        style: AppTextStyles.normal600(
                          fontSize: 12.0,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        assessment['name']!,
                        style: AppTextStyles.normal600(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right:8.0),
                    child: Text(
                      'Assessment score: ',
                      style: AppTextStyles.normal600(
                        fontSize: 12.0,
                        color: AppColors.textGray,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      assessment['score']!,
                      style: AppTextStyles.normal600(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
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
