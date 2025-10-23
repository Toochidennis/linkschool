import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../../common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/behaviour_provider.dart';
import 'package:linkschool/modules/model/admin/behaviour_model.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';

class BehaviourSettingScreen extends StatefulWidget {
  const BehaviourSettingScreen({super.key});

  @override
  State<BehaviourSettingScreen> createState() => _BehaviourSettingScreenState();
}

class _BehaviourSettingScreenState extends State<BehaviourSettingScreen> {
  String selectedLevelDisplay = 'General (All Levels)';
  String selectedLevelValue = '0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn && authProvider.token != null) {
        final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
        // ✅ Set initial level and fetch
        skillsProvider.setSelectedLevel('0');
        skillsProvider.fetchSkills();
      } else {
        CustomToaster.toastError(
            context, 'Error', 'Please log in to view skills');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
              GestureDetector(
                onTap: () => _showLevelSelectionBottomSheet(context),
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
              Expanded(
                child: Consumer<SkillsProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // ✅ FIXED: Sort skills in descending order by id
                    final sortedSkills = List<Skills>.from(provider.skills)
                      ..sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));
                    
                    return sortedSkills.isEmpty
                        ? const Center(
                            child: Text(
                              'No skills or behaviors available',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : SkillsList(
                            skills: sortedSkills,
                            // ✅ FIXED: Pass the actual skill object, not index
                            onEdit: (skill, newSkillName) {
                              provider.editSkill(
                                skill.id,
                                newSkillName,
                                skill.type ?? '0',
                                skill.level ?? '0',
                                context: context,
                              );
                            },
                            onDelete: (skill) async {
                              await provider.deleteSkill(skill.id, context: context);
                            },
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSkills(context),
        shape: const CircleBorder(),
        backgroundColor: AppColors.primaryLight,
        child: const Icon(Icons.add, color: AppColors.backgroundLight),
      ),
    );
  }

  void _showLevelSelectionBottomSheet(BuildContext context) {
    final userBox = Hive.box('userData');
    final levels = List<Map<String, dynamic>>.from(userBox.get('levels') ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Select Level',
                  style: AppTextStyles.normal600(fontSize: 24, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildSelectionButton(
                          'General (All Levels)',
                          () {
                            setState(() {
                              selectedLevelDisplay = 'General (All Levels)';
                              selectedLevelValue = '0';
                            });
                            // ✅ FIXED: Set level in provider
                            Provider.of<SkillsProvider>(context, listen: false)
                                .setSelectedLevel('0');
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ...levels.map((level) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: _buildSelectionButton(
                              level['level_name'],
                              () {
                                setState(() {
                                  selectedLevelDisplay = level['level_name'];
                                  selectedLevelValue = level['id'].toString();
                                });
                                // ✅ FIXED: Set level in provider
                                Provider.of<SkillsProvider>(context, listen: false)
                                    .setSelectedLevel(level['id'].toString());
                                Navigator.pop(context);
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.dialogBtnColor,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                text,
                style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSkills(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext modalContext) {
        return AddSkillBottomSheet(
          onAddSkill: (skillName, type, level) async {
            Navigator.pop(modalContext);
            await Provider.of<SkillsProvider>(context, listen: false).addSkill(
              skillName,
              type,
              level,
              context: context,
            );
          },
          selectedLevelValue: selectedLevelValue,
        );
      },
    );
  }
}

// ✅ FIXED: Updated callback signatures to pass skill objects
class SkillsList extends StatelessWidget {
  final List<Skills> skills;
  final Function(Skills, String) onEdit;  // ✅ Changed to pass Skills object
  final Function(Skills) onDelete;        // ✅ Changed to pass Skills object

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
        final levelDisplay = skill.level == null || skill.level == '0'
            ? 'General (All level)'
            : skill.levelName ?? 'Unknown';
        
        return SkillItem(
          skill: skill.skillName ?? '',
          type: typeDisplay,
          level: levelDisplay,
          onEdit: (newSkill) => onEdit(skill, newSkill), // ✅ Pass skill object
          onDelete: () => onDelete(skill),                // ✅ Pass skill object
        );
      },
    );
  }
}

class SkillItem extends StatefulWidget {
  final String skill;
  final String type;
  final String level;
  final Function(String) onEdit;
  final VoidCallback onDelete;

  const SkillItem({
    super.key,
    required this.skill,
    required this.type,
    required this.level,
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
            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isEditing
                      ? TextField(
                          controller: _controller,
                          autofocus: true,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              widget.onEdit(value.trim());
                            }
                            setState(() => _isEditing = false);
                          },
                        )
                      : Text(
                          widget.skill,
                          style: AppTextStyles.normal400(
                            fontSize: 16,
                            color: AppColors.primaryDark,
                          ),
                        ),
                  const SizedBox(height: 4),
                  Text(
                    widget.type,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    widget.level,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_isEditing) {
                  if (_controller.text.trim().isNotEmpty) {
                    widget.onEdit(_controller.text.trim());
                  }
                }
                setState(() => _isEditing = !_isEditing);
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
            GestureDetector(
              onTap: () {
                // ✅ Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Skill'),
                    content: Text('Are you sure you want to delete "${widget.skill}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onDelete();
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
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
    setState(() {
      _skillNameError = null;
      _typeError = null;
    });

    if (_skillController.text.trim().isEmpty) {
      setState(() => _skillNameError = 'Please enter a skill name');
      return;
    }
    if (selectedTypeDisplay == null) {
      setState(() => _typeError = 'Please select a type');
      return;
    }

    final typeValue = typeMap[selectedTypeDisplay!] ?? '0';
    widget.onAddSkill(
      _skillController.text.trim(),
      typeValue,
      widget.selectedLevelValue,
    );
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
          TextField(
            controller: _skillController,
            decoration: InputDecoration(
              hintText: 'Enter a skill',
              border: const OutlineInputBorder(),
              errorText: _skillNameError,
            ),
          ),
          const SizedBox(height: 16),
          if (_typeError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _typeError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          CustomDropdown<String>(
            hintText: 'Select Type',
            items: typeMap.keys.toList(),
            onChanged: (value) {
              setState(() {
                selectedTypeDisplay = value;
                _typeError = null;
              });
            },
          ),
          const SizedBox(height: 24),
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