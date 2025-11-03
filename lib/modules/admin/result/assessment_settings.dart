import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/model/admin/assessment_model.dart';
import 'package:linkschool/modules/model/admin/level_model.dart';
import 'package:linkschool/modules/providers/admin/assessment_provider.dart';
import 'package:linkschool/modules/providers/admin/level_provider.dart';
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
  // Default level ID is 0 for "General"
  String _selectedLevelId = "0";
  String? _selectedAssessmentType;
  final _assessmentNameController = TextEditingController();
  final _assessmentScoreController = TextEditingController();
  bool _isEditingCard = false;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
    final levelProvider = Provider.of<LevelProvider>(context, listen: false);
    
    try {
      // Verify we have a token
      final userBox = Hive.box('userData');
      final token = userBox.get('token');
      
      if (token == null) {
        throw Exception('User not authenticated');
      }

      await assessmentProvider.fetchAssessments();
      
      // Load levels from local storage
      final levels = userBox.get('levels');
      if (levels != null && levels is List) {
        levelProvider.updateLevels(levels.map((level) => Level.fromJson(level)).toList());
      }
    } catch (e) {
      debugPrint('Initialization error: ${e.toString()}');
      // Error loading initial data, but removing toast as per requirement
    }
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
          onPressed: () => Navigator.of(context).pop(),
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error message display
                if (assessmentProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      assessmentProvider.errorMessage!,
                      style: AppTextStyles.normal600(
                        fontSize: 14.0,
                        color: Colors.red,
                      ),
                    ),
                  ),

                // Level selector - changed to use a button that opens a bottom sheet
                Text(
                  'Level',
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () => _showLevelSelectionBottomSheet(levelProvider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                          _getLevelName(levelProvider),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            color: AppColors.primaryLight),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),

                // Assessments list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => assessmentProvider.fetchAssessments(),
                    child: ListView(
                      children: [
                        ...assessmentProvider.assessments
                            .where((assessment) => assessment.levelId.toString() == _selectedLevelId)
                            .toList()
                            .asMap()
                            .entries
                            .map(
                              (entry) => buildAssessmentCard(
                                  entry.value, entry.key, assessmentProvider),
                            )
                            .toList(),
                        const SizedBox(height: 24.0),
                        if (!_isEditingCard) buildInputCard(assessmentProvider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (assessmentProvider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: CustomFloatingSaveButton(
        onPressed: () async {
          try {
            await assessmentProvider.saveAssessments(context, _selectedLevelId);
            // Show toast only for the floating save button action
            CustomToaster.toastSuccess(context, 'Success', 'Assessments saved successfully');
          } catch (e) {
            CustomToaster.toastError(context, 'Error', 'Failed to save assessments');
          }
        },
      ),
    );
  }

  String _getLevelName(LevelProvider levelProvider) {
    if (_selectedLevelId == "0") {
      return "General (All Levels)";
    }
    
    final selectedLevel = levelProvider.levels.firstWhere(
      (level) => level.id == _selectedLevelId,
      orElse: () => Level(id: '', levelName: 'Select Level'),
    );
    
    return selectedLevel.levelName ?? 'Select Level';
  }

  void _showLevelSelectionBottomSheet(LevelProvider levelProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Select Level',
                  style: AppTextStyles.normal600(
                    fontSize: 18.0,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              Divider(thickness: 1, color: Colors.grey[300]),
              // Add "General" option as first item
              ListTile(
                title: Text(
                  'General (All Levels)',
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: AppColors.textGray,
                  ),
                ),
                tileColor: _selectedLevelId == "0" ? Colors.grey[100] : null,
                onTap: () {
                  setState(() => _selectedLevelId = "0");
                  Navigator.pop(context);
                },
              ),
              Divider(thickness: 1, color: Colors.grey[300]),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: levelProvider.levels.length,
                  separatorBuilder: (context, index) => Divider(
                    thickness: 1,
                    color: Colors.grey[300],
                  ),
                  itemBuilder: (context, index) {
                    final level = levelProvider.levels[index];
                    return ListTile(
                      title: Text(
                        level.levelName ?? 'N/A',
                        style: AppTextStyles.normal600(
                          fontSize: 16.0,
                          color: AppColors.textGray,
                        ),
                      ),
                      tileColor: _selectedLevelId == level.id ? Colors.grey[100] : null,
                      onTap: () {
                        setState(() => _selectedLevelId = level.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
                DropdownMenuItem(value: '0', child: Text('Assessment')),
                DropdownMenuItem(value: '1', child: Text('Sub Assessment')),
              ],
              onChanged: (value) =>
                  setState(() => _selectedAssessmentType = value),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _handleAddAssessment(assessmentProvider),
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

  void _handleAddAssessment(AssessmentProvider assessmentProvider) {
    if (_assessmentNameController.text.isEmpty ||
        _assessmentScoreController.text.isEmpty ||
        _selectedAssessmentType == null) {
      // Removed toast as per requirement - Let the UI indication be enough
      return;
    }

    // Parse the level ID (default to 0 if General is selected)
    final levelId = int.parse(_selectedLevelId);

    try {
      assessmentProvider.addAssessment(
        Assessment(
          assessmentName: _assessmentNameController.text,
          assessmentScore: int.parse(_assessmentScoreController.text),
          assessmentType: int.parse(_selectedAssessmentType!),
          levelId: levelId,
        ),
      );

      // Clear inputs
      _assessmentNameController.clear();
      _assessmentScoreController.clear();
      _selectedAssessmentType = null;
      
      // Removed toast as per requirement
    } catch (e) {
      // Removed toast as per requirement
    }
  }

  Widget buildAssessmentCard(
      Assessment assessment, int index, AssessmentProvider provider) {
    final nameController =
        TextEditingController(text: assessment.assessmentName);
    final scoreController =
        TextEditingController(text: assessment.assessmentScore.toString());
    String selectedType = assessment.assessmentType.toString();

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
                  icon: Icon(
                    _isEditingCard && _editingIndex == index ? Icons.save : Icons.edit,
                    color: AppColors.primaryDark,
                  ),
                  onPressed: () => _handleEditAssessment(index, provider, assessment, nameController, scoreController, selectedType),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.primaryDark),
                  onPressed: () => _handleDeleteAssessment(assessment, provider),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isEditingCard && _editingIndex == index) ...[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Assessment name',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.assessmentColor1),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  hintText: 'Assessment type',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.assessmentColor1),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: '0', child: Text('Assessment')),
                  DropdownMenuItem(value: '1', child: Text('Sub Assessment')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
              ),
            ] else ...[
              _buildAssessmentDetail(
                  'Assessment name:', assessment.assessmentName),
              const SizedBox(height: 15.0),
              _buildAssessmentDetail(
                  'Assessment score:', assessment.assessmentScore.toString()),
              _buildAssessmentDetail(
                  'Type:',
                  assessment.assessmentType == 0
                      ? 'Assessment'
                      : 'Sub Assessment'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentDetail(String label, String value) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            label,
            style: AppTextStyles.normal600(
              fontSize: 12.0,
              color: AppColors.textGray,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.normal600(
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _handleEditAssessment(int index, AssessmentProvider provider, Assessment assessment, 
      TextEditingController nameController, TextEditingController scoreController, String selectedType) async {
    if (_isEditingCard && _editingIndex == index) {
      // Save changes - check if this is a newly added assessment or an existing one
      final isNewlyAdded = provider.newlyAddedAssessments.contains(assessment);
      bool success = false;
      
      if (isNewlyAdded) {
        // Update locally for newly added assessment
        success = await provider.editAssessment(assessment, nameController.text, 
            int.tryParse(scoreController.text) ?? assessment.assessmentScore, 
            int.tryParse(selectedType) ?? assessment.assessmentType);
        
        if (success) {
          CustomToaster.toastSuccess(context, 'Success', 'Assessment updated successfully');
        } else {
          CustomToaster.toastError(context, 'Error', 'Failed to update assessment');
        }
      } else {
        // Update using API for existing assessment
        success = await provider.editAssessment(assessment, nameController.text, 
            int.tryParse(scoreController.text) ?? assessment.assessmentScore, 
            int.tryParse(selectedType) ?? assessment.assessmentType);
        
        if (success) {
          CustomToaster.toastSuccess(context, 'Success', 'Assessment updated successfully');
        } else {
          CustomToaster.toastError(context, 'Error', provider.errorMessage ?? 'Failed to update assessment');
        }
      }
      
      setState(() {
        _isEditingCard = false;
        _editingIndex = null;
      });
    } else {
      // Start editing
      setState(() {
        _isEditingCard = true;
        _editingIndex = index;
      });
    }
  }

  void _updateLocalAssessment(AssessmentProvider provider, Assessment assessment, 
      TextEditingController nameController, TextEditingController scoreController, String selectedType) {
    final filteredAssessments = provider.assessments
        .where((a) => a.levelId.toString() == _selectedLevelId)
        .toList();
    
    final originalIndex = provider.assessments.indexOf(assessment);
    
    if (originalIndex != -1) {
      // Update the assessment in both lists
      final updatedAssessment = Assessment(
        id: assessment.id,
        assessmentName: nameController.text,
        assessmentScore: int.tryParse(scoreController.text) ?? assessment.assessmentScore,
        assessmentType: int.tryParse(selectedType) ?? assessment.assessmentType,
        levelId: assessment.levelId,
      );
      
      provider.assessments[originalIndex] = updatedAssessment;
      
      // Update in newly added list as well
      final newlyAddedIndex = provider.newlyAddedAssessments.indexOf(assessment);
      if (newlyAddedIndex != -1) {
        provider.newlyAddedAssessments[newlyAddedIndex] = updatedAssessment;
      }
      
      provider.notifyListeners();
    }
  }

  void _updateExistingAssessment(AssessmentProvider provider, Assessment assessment, 
      TextEditingController nameController, TextEditingController scoreController, String selectedType) {
    // Call the edit API for existing assessments
    provider.editAssessment(
      assessment,
      nameController.text,
      int.tryParse(scoreController.text) ?? assessment.assessmentScore,
      int.tryParse(selectedType) ?? assessment.assessmentType,
    );
  }

  void _handleDeleteAssessment(Assessment assessment, AssessmentProvider provider) async {
    // Check if this is a newly added assessment or an existing one
    final isNewlyAdded = provider.newlyAddedAssessments.contains(assessment);
    
    if (isNewlyAdded) {
      // Delete locally for newly added assessment
      provider.removeAssessment(assessment);
      CustomToaster.toastSuccess(context, 'Success', 'Assessment deleted successfully');
    } else {
      // Delete using API for existing assessment
      final success = await provider.deleteAssessment(assessment);
      if (success) {
        CustomToaster.toastSuccess(context, 'Success', 'Assessment deleted successfully');
      } else {
        CustomToaster.toastError(context, 'Error', provider.errorMessage ?? 'Failed to delete assessment');
      }
    }
  }
}



