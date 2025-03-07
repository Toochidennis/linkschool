import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/assessment_model.dart';
import 'package:linkschool/modules/model/admin/level_model.dart';
import 'package:linkschool/modules/providers/admin/assessment_provider.dart';
import 'package:linkschool/modules/providers/admin/level_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/buttons/custom_floating_save_button.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/providers/assessment_provider.dart';
// import 'package:linkschool/modules/providers/level_provider.dart';
// import 'package:linkschool/modules/models/assessment_model.dart';
// import 'package:linkschool/modules/models/level_model.dart';

class AssessmentSettingScreen extends StatefulWidget {
  const AssessmentSettingScreen({super.key});

  @override
  State<AssessmentSettingScreen> createState() =>
      _AssessmentSettingScreenState();
}

class _AssessmentSettingScreenState extends State<AssessmentSettingScreen> {
  String? _selectedLevelId;
  String? _selectedAssessmentType;
  final _assessmentNameController = TextEditingController();
  final _assessmentScoreController = TextEditingController();
  bool isEditing = false;
  int? editingIndex;
  bool isEditingAnyCard = false;

  @override
  void initState() {
    super.initState();
    // Fetch levels when the screen is initialized
    Provider.of<LevelProvider>(context, listen: false).fetchLevels();
  }

  @override
  Widget build(BuildContext context) {
    final assessmentProvider = Provider.of<AssessmentProvider>(context);
    final levelProvider = Provider.of<LevelProvider>(context);

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
                fontSize: 16.0,
                color: AppColors.primaryLight,
              ),
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
                          children: levelProvider.levels.map((Level level) {
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
                                  title: Center(child: Text(level.levelName ?? 'N/A')),
                                  onTap: () {
                                    setState(() {
                                      _selectedLevelId = level.id; // Store the level ID
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
                    Text(
                      levelProvider.levels
                          .firstWhere(
                            (level) => level.id == _selectedLevelId,
                            orElse: () => Level(id: '', levelName: 'Select Level'),
                          )
                          .levelName ??
                          'Select Level',
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primaryLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            Expanded(
              child: ListView(
                children: [
                  ...assessmentProvider.assessments.asMap().entries.map(
                      (entry) => buildAssessmentCard(entry.value, entry.key, assessmentProvider)),
                  const SizedBox(height: 24.0),
                  if (!isEditingAnyCard) buildInputCard(assessmentProvider),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingSaveButton(
        onPressed: () async {
          if (assessmentProvider.assessments.isEmpty) {
            showToast('No assessments to save');
            return;
          }

          try {
            await assessmentProvider.saveAssessments();
            showToast('Assessments saved successfully');
          } catch (e) {
            showToast('Failed to save assessments: $e');
          }
        },
      ),
    );
  }

  Widget buildInputCard(AssessmentProvider assessmentProvider) {
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
          ),
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
            DropdownButtonFormField<String>(
              value: _selectedAssessmentType,
              decoration: const InputDecoration(
                hintText: 'Assessment type',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.assessmentColor1),
                ),
              ),
              items: const [
                DropdownMenuItem(value: '0', child: Text('0')),
                DropdownMenuItem(value: '1', child: Text('1')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAssessmentType = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_selectedLevelId == null) {
                  showToast('Please select a level');
                  return;
                }
                if (_assessmentNameController.text.isEmpty ||
                    _assessmentScoreController.text.isEmpty ||
                    _selectedAssessmentType == null) {
                  showToast('Please fill all fields');
                  return;
                }
                assessmentProvider.addAssessment(
                  Assessment(
                    assessmentName: _assessmentNameController.text,
                    assessmentScore: int.parse(_assessmentScoreController.text),
                    assessmentType: int.parse(_selectedAssessmentType!),
                    levelId: int.parse(_selectedLevelId!),
                  ),
                );
                _assessmentNameController.clear();
                _assessmentScoreController.clear();
                _selectedAssessmentType = null;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Add',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: AppColors.backgroundLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAssessmentCard(Assessment assessment, int index, AssessmentProvider assessmentProvider) {
    TextEditingController nameController = TextEditingController(text: assessment.assessmentName);
    TextEditingController scoreController = TextEditingController(text: assessment.assessmentScore.toString());

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
                  icon: const Icon(Icons.edit, color: AppColors.primaryDark),
                  onPressed: () {
                    setState(() {
                      if (isEditing && editingIndex == index) {
                        assessmentProvider.assessments[index] = Assessment(
                          assessmentName: nameController.text,
                          assessmentScore: int.parse(scoreController.text),
                          assessmentType: assessment.assessmentType,
                          levelId: assessment.levelId,
                        );
                        isEditing = false;
                        editingIndex = null;
                      } else {
                        isEditing = true;
                        editingIndex = index;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.primaryDark),
                  onPressed: () {
                    assessmentProvider.removeAssessment(assessment);
                  },
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
                      assessment.assessmentName,
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
                      assessment.assessmentScore.toString(),
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

  void showToast(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }
}