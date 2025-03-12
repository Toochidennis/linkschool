import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:provider/provider.dart';
import '../../common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
import 'package:linkschool/modules/model/admin/behaviour_model.dart';

class BehaviourSettingScreen extends StatefulWidget {
  const BehaviourSettingScreen({super.key});

  @override
  State<BehaviourSettingScreen> createState() => _BehaviourSettingScreenState();
}

class _BehaviourSettingScreenState extends State<BehaviourSettingScreen> {
  // Map display names to API values
  final Map<String, String> levelMap = {
    'Class 1': '0',
    'Class 2': '1',
    'Class 3': '2',
    'Class 4': '3',
    'Class 5': '4',
  };

  // Track the selected level for display
  String selectedLevelDisplay = 'Select Level';
  // Store the API value
  String selectedLevelValue = '';

  @override
  void initState() {
    super.initState();
    // Fetch skills when the screen loads
    Provider.of<SkillsProvider>(context, listen: false).fetchSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text(
          'Skills and Behaviour',
          style: AppTextStyles.normal600(
            fontSize: 18.0,
            color: AppColors.primaryLight,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Level Selection Button
              GestureDetector(
                onTap: () {
                  _showLevelSelectionDialog(context);
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
                      Text(selectedLevelDisplay),
                      const Icon(Icons.arrow_drop_down, color: AppColors.primaryLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Skills List
              Expanded(
                child: Consumer<SkillsProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.error.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${provider.error}')),
                        );
                      });
                    }
                    return SkillsList(
                      skills: provider.skills,
                      onEdit: (index, newSkill) {
                        final skill = provider.skills[index];
                        provider.editSkillLocally(
                          skill.id,
                          newSkill,
                          skill.type == "0" ? "Skills" : "Behaviour",
                          skill.level ?? '',
                        );
                      },
                      onDelete: (index) async {
                        final skill = provider.skills[index];
                        await provider.deleteSkill(skill.id);
                        if (provider.error.isEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Skill deleted successfully')),
                            );
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button to Add Skill
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSkills(context),
        shape: const CircleBorder(),
        backgroundColor: AppColors.primaryLight,
        child: const Icon(
          Icons.add,
          color: AppColors.backgroundLight,
        ),
      ),
    );
  }

  // Show Level Selection Dialog
  void _showLevelSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Level'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: levelMap.length,
              itemBuilder: (context, index) {
                final levelEntry = levelMap.entries.elementAt(index);
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
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLevelDisplay = levelEntry.key;
                          selectedLevelValue = levelEntry.value;
                        });
                        Navigator.pop(context);
                      },
                      child: ListTile(
                        title: Center(child: Text(levelEntry.key)),
                      ),
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

  // Show Add Skills Bottom Sheet
  void _showAddSkills(BuildContext context) {
    if (selectedLevelValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a level first')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddSkillBottomSheet(
          onAddSkill: (skillName, type, level) {
            Provider.of<SkillsProvider>(context, listen: false)
                .addSkill(skillName, type, level);
          },
          selectedLevelValue: selectedLevelValue,
        );
      },
    );
  }
}

// Skills List Widget
class SkillsList extends StatelessWidget {
  final List<Skills> skills;
  final Function(int, String) onEdit;
  final Function(int) onDelete;

  const SkillsList({
    Key? key,
    required this.skills,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        final typeDisplay = skill.type == "0" ? "Skills" : "Behaviour";
        return SkillItem(
          skill: skill.skillName ?? '',
          type: typeDisplay,
          onEdit: (newSkill) => onEdit(index, newSkill),
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}

// Skill Item Widget
class SkillItem extends StatefulWidget {
  final String skill;
  final String type;
  final Function(String) onEdit;
  final VoidCallback onDelete;

  const SkillItem({
    super.key,
    required this.skill,
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _SkillItemState createState() => _SkillItemState();
}

class _SkillItemState extends State<SkillItem> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.skill);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Skill Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgGrayLight2,
                border: Border.all(color: AppColors.bgBorder, width: 1),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/result/skill.svg',
                  color: AppColors.bgBorder,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
            const SizedBox(width: 18),
            // Skill Name and Type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isEditing
                      ? TextField(
                          controller: _controller,
                          onSubmitted: (value) {
                            widget.onEdit(value);
                            setState(() {
                              _isEditing = false;
                            });
                          },
                        )
                      : Text(
                          widget.skill,
                          style: AppTextStyles.normal400(fontSize: 16, color: AppColors.primaryDark),
                        ),
                  const SizedBox(height: 4),
                  Text(
                    widget.type,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Edit Button
            GestureDetector(
              onTap: () {
                if (_isEditing) {
                  widget.onEdit(_controller.text);
                }
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              child: SvgPicture.asset(
                _isEditing
                    ? 'assets/icons/result/check.svg'
                    : 'assets/icons/result/edit.svg',
                width: 24,
                height: 24,
              ),  
            ),
            const SizedBox(width: 8),
            // Delete Button
            GestureDetector(
              onTap: widget.onDelete,
              child: SvgPicture.asset(
                'assets/icons/result/delete.svg',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add Skill Bottom Sheet
class AddSkillBottomSheet extends StatefulWidget {
  final Function(String, String, String) onAddSkill;
  final String selectedLevelValue;

  const AddSkillBottomSheet({
    Key? key,
    required this.onAddSkill,
    required this.selectedLevelValue,
  }) : super(key: key);

  @override
  _AddSkillBottomSheetState createState() => _AddSkillBottomSheetState();
}

class _AddSkillBottomSheetState extends State<AddSkillBottomSheet> {
  final TextEditingController _skillController = TextEditingController();
  final Map<String, String> typeMap = {
    'Skills': '0',
    'Behaviour': '1',
  };
  String? selectedTypeDisplay;
  String? _skillNameError;
  String? _typeError;

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  void _submitSkill() {
    // Reset errors
    setState(() {
      _skillNameError = null;
      _typeError = null;
    });

    // Validation checks
    if (_skillController.text.isEmpty) {
      setState(() {
        _skillNameError = 'Please enter a skill name';
      });
    }
    if (selectedTypeDisplay == null) {
      setState(() {
        _typeError = 'Please select a type';
      });
    }

    // If all fields are valid, proceed
    if (_skillController.text.isNotEmpty && selectedTypeDisplay != null) {
      final typeValue = typeMap[selectedTypeDisplay!] ?? '0';
      widget.onAddSkill(_skillController.text, typeValue, widget.selectedLevelValue);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Skill',
                style: AppTextStyles.normal600(
                  fontSize: 20,
                  color: const Color.fromRGBO(47, 85, 221, 1),
                ),
              ),
              IconButton(
                icon: SvgPicture.asset('assets/icons/profile/cancel_receipt.svg'),
                color: AppColors.bgGray,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Skill Name Input
          TextField(
            controller: _skillController,
            decoration: InputDecoration(
              hintText: 'Enter a skill',
              border: const OutlineInputBorder(),
              errorText: _skillNameError,
            ),
          ),
          const SizedBox(height: 16),
          // Type Selection Error
          if (_typeError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _typeError!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          // Type Dropdown
          CustomDropdown<String>(
            hintText: 'Select Type',
            items: typeMap.keys.toList(),
            onChanged: (value) {
              setState(() {
                selectedTypeDisplay = value;
                _typeError = null; // Clear error when a type is selected
              });
            },
          ),
          const SizedBox(height: 24),
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitSkill,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Add Skill',
                style: AppTextStyles.normal500(
                  fontSize: 18,
                  color: AppColors.backgroundLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}