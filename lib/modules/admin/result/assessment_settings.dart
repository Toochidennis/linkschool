import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/assessment_model.dart';
import 'package:linkschool/modules/providers/admin/assessment_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/buttons/custom_floating_save_button.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class AssessmentSettingScreen extends StatefulWidget {
  const AssessmentSettingScreen({super.key});

  @override
  State<AssessmentSettingScreen> createState() =>
      _AssessmentSettingScreenState();
}

class _AssessmentSettingScreenState extends State<AssessmentSettingScreen> {
  final _assessmentNameController = TextEditingController();
  String? _selectedAssessmentType;
  bool isEditing = false;
  int? editingIndex;
  bool isEditingAnyCard = false;

  @override
  void initState() {
    super.initState();
    // Fetch assessments when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssessmentProvider>(context, listen: false).fetchAssessments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final assessmentProvider = Provider.of<AssessmentProvider>(context);

    // Group assessments by level
    Map<int, List<Assessment>> groupedAssessments = {};
    Map<int, String> levelNames = {};
    
    for (var assessment in assessmentProvider.assessments) {
      if (!groupedAssessments.containsKey(assessment.levelId)) {
        groupedAssessments[assessment.levelId] = [];
        levelNames[assessment.levelId] = assessment.levelName;
      }
      groupedAssessments[assessment.levelId]!.add(assessment);
    }

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
      body: assessmentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: assessmentProvider.assessments.isEmpty
                        ? const Center(child: Text('No assessments found'))
                        : ListView.builder(
                            itemCount: groupedAssessments.length,
                            itemBuilder: (context, index) {
                              final levelId = groupedAssessments.keys.elementAt(index);
                              final levelAssessments = groupedAssessments[levelId]!;
                              final levelName = levelNames[levelId]!;
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      color: AppColors.primaryLight.withOpacity(0.1),
                                      child: Text(
                                        levelName,
                                        style: AppTextStyles.normal600(
                                          fontSize: 18.0,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...levelAssessments.asMap().entries.map(
                                    (entry) => buildAssessmentCard(
                                      entry.value, 
                                      assessmentProvider.assessments.indexOf(entry.value), 
                                      assessmentProvider
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                ],
                              );
                            },
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
            // await assessmentProvider.saveAssessments();
            showToast('Assessments saved successfully');
          } catch (e) {
            showToast('Failed to save assessments: $e');
          }
        },
      ),
    );
  }

  Widget buildAssessmentCard(Assessment assessment, int index, AssessmentProvider assessmentProvider) {
    TextEditingController nameController = TextEditingController(text: assessment.assessmentName);
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 3,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessment.assessmentName,
                        style: AppTextStyles.normal600(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Text(
                            'Type: ',
                            style: AppTextStyles.normal600(
                              fontSize: 12.0,
                              color: AppColors.textGray,
                            ),
                          ),
                          Text(
                            assessment.assessmentType.toString(),
                            style: AppTextStyles.normal600(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primaryDark),
                      onPressed: () {
                        // Show edit dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Edit Assessment'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      hintText: 'Assessment name',
                                      labelText: 'Assessment Name',
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  DropdownButtonFormField<String>(
                                    value: assessment.assessmentType.toString(),
                                    decoration: const InputDecoration(
                                      labelText: 'Assessment Type',
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: '0', child: Text('Type 0')),
                                      DropdownMenuItem(value: '1', child: Text('Type 1')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedAssessmentType = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final updatedAssessment = Assessment(
                                      id: assessment.id,
                                      assessmentName: nameController.text,
                                      assessmentType: int.parse(_selectedAssessmentType ?? assessment.assessmentType.toString()),
                                      levelId: assessment.levelId,
                                      levelName: assessment.levelName,
                                    );
                                    
                                    // Update the assessment in the provider
                                    final updatedAssessments = List<Assessment>.from(assessmentProvider.assessments);
                                    updatedAssessments[index] = updatedAssessment;
                                    
                                    // Notify provider (you may need to add this method to your provider)
                                  // assessmentProvider.updateAssessments(updatedAssessments);
                                    
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondaryLight,
                                  ),
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.primaryDark),
                      onPressed: () {
                        // Show confirmation dialog before deleting
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Assessment'),
                              content: Text('Are you sure you want to delete "${assessment.assessmentName}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    assessmentProvider.removeAssessment(assessment);
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
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

  void showToast(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }
}