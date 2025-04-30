import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  String? _selectedLevelId;
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
    // _loadInitialData();
  }

  // Future<void> _loadInitialData() async {
  //   final assessmentProvider =
  //       Provider.of<AssessmentProvider>(context, listen: false);
  //   await assessmentProvider.fetchAssessments();

  //   // Load levels from local storage
  //   final userBox = Hive.box('userData');
  //   final levels = userBox.get('levels');
  //   if (levels != null && levels is List) {
  //     final levelProvider = Provider.of<LevelProvider>(context, listen: false);
  //     levelProvider
  //         .updateLevels(levels.map((level) => Level.fromJson(level)).toList());
  //     // levelProvider.levels = levels.map((level) => Level.fromJson(level)).toList();
  //   }
  // }


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

                // Level dropdown
                Text(
                  'Level',
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () => _showLevelSelectionDialog(levelProvider),
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
                          levelProvider.levels
                                  .firstWhere(
                                    (level) => level.id == _selectedLevelId,
                                    orElse: () => Level(
                                        id: '', levelName: 'Select Level'),
                                  )
                                  .levelName ??
                              'Select Level',
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
                            .asMap()
                            .entries
                            .map(
                              (entry) => buildAssessmentCard(
                                  entry.value, entry.key, assessmentProvider),
                            )
                            .toList(), // Added closing parenthesis and .toList()
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
    await assessmentProvider.saveAssessments(context);  // Pass context here
  },
),
    );
  }

  void _showLevelSelectionDialog(LevelProvider levelProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Level'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: levelProvider.levels.length,
              itemBuilder: (context, index) {
                final level = levelProvider.levels[index];
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
                        setState(() => _selectedLevelId = level.id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 24,
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

    // Clear inputs
    _assessmentNameController.clear();
    _assessmentScoreController.clear();
    _selectedAssessmentType = null;
  }

  Widget buildAssessmentCard(
      Assessment assessment, int index, AssessmentProvider provider) {
    final nameController =
        TextEditingController(text: assessment.assessmentName);
    final scoreController =
        TextEditingController(text: assessment.assessmentScore.toString());

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
                  onPressed: () => _handleEditAssessment(index, provider),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.primaryDark),
                  onPressed: () => provider.removeAssessment(assessment),
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

  void _handleEditAssessment(int index, AssessmentProvider provider) {
    setState(() {
      if (_isEditingCard && _editingIndex == index) {
        // Save changes
        provider.assessments[index] = Assessment(
          id: provider.assessments[index].id,
          assessmentName: provider.assessments[index].assessmentName,
          assessmentScore: provider.assessments[index].assessmentScore,
          assessmentType: provider.assessments[index].assessmentType,
          levelId: provider.assessments[index].levelId,
        );
        _isEditingCard = false;
        _editingIndex = null;
      } else {
        // Start editing
        _isEditingCard = true;
        _editingIndex = index;
      }
    });
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