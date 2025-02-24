// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/buttons/custom_floating_save_button.dart';

import '../../common/app_colors.dart';
import '../../common/text_styles.dart';

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
  bool isEditing = false;
  int? editingIndex;
  bool isEditingAnyCard = false;

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
        style: AppTextStyles.normal600(
          fontSize: 18.0,
          color: AppColors.primaryLight,
        ),
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
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Select Level'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView(
                          shrinkWrap: true,
                          children: levels.map((String value) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Container(
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
                                child: ListTile(
                                  title: Center(child: Text(value)),
                                  onTap: () {
                                    setState(() {
                                      _selectedLevel = value;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 24,
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedLevel ?? 'Select Level'),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primaryLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            Expanded(
              child: ListView(
                children: [
                  ..._assessments.asMap().entries.map(
                      (entry) => buildAssessmentCard(entry.value, entry.key)),
                  const SizedBox(height: 24.0), // Increased space between cards
                  if (!isEditingAnyCard) buildInputCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingSaveButton(
        onPressed: () {
          log('Save settings button pressed');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assessment settings saved successfully'),
            ),
          );
        },
      ),
    );
  }

Widget buildInputCard() {
  return Container(
    width: 300, 
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
          TextField(
            controller: _assessmentNameController,
            decoration: const InputDecoration(
              hintText: 'Assessment name',
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.assessmentColor1),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _assessmentScoreController,
            decoration: const InputDecoration(
              hintText: 'Assessment score',
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.assessmentColor1),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child:  Text('Add', style: AppTextStyles.normal600(fontSize: 14, color: AppColors.backgroundLight),),
          ),
        ],
      ),
    ),
  );
}

Widget buildAssessmentCard(Map<String, String> assessment, int index) {
  TextEditingController nameController = TextEditingController(text: assessment['name']);
  TextEditingController scoreController = TextEditingController(text: assessment['score']);

  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
    elevation: 3,
    color: Colors.white,
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  isEditing && editingIndex == index
                      ? 'assets/icons/result/check.svg'
                      : 'assets/icons/result/edit.svg',
                  color: AppColors.primaryDark,
                  width: 16,
                  height: 16,
                ),
                onPressed: () {
                  setState(() {
                    if (isEditing && editingIndex == index) {
                      _assessments[index] = {
                        'name': nameController.text,
                        'score': scoreController.text,
                      };
                      isEditing = false;
                      editingIndex = null;
                    } else {
                      isEditing = true;
                      editingIndex = index;
                    }
                  });
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tight(const Size(24, 24)),
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
                constraints: BoxConstraints.tight(const Size(24, 24)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isEditing && editingIndex == index) ...[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Assessment name',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.assessmentColor1),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: scoreController,
              decoration: const InputDecoration(
                hintText: 'Assessment score',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.assessmentColor1),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
              keyboardType: TextInputType.number,
            ),
          ] else ...[
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
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
            const SizedBox(height: 15.0),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
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
        ],
      ),
    ),
  );
}

  void saveEditedAssessment(int index) {
    setState(() {
      _assessments[index] = {
        'name': _assessmentNameController.text,
        'score': _assessmentScoreController.text,
      };
      isEditing = false;
      editingIndex = null;
      _assessmentNameController.clear();
      _assessmentScoreController.clear();
    });
  }

  void deleteAssessment(Map<String, String> assessment) {
    setState(() {
      _assessments.remove(assessment);
    });
  }
}
