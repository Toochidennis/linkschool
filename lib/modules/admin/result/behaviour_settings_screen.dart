import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
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
              GestureDetector(
                onTap: () {
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
                                      // Fetch skills for the selected level
                                      Provider.of<SkillsProvider>(context, listen: false)
                                          .fetchSkillsByLevel(selectedLevelValue);
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
                    if (provider.skills.isEmpty) {
                      return const Center(
                        child: Text('No skills found. Select a level or add new skills.'),
                      );
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

  void _showAddSkills(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddSkillBottomSheet(
          onAddSkill: (skillName, type, level) async {
            // Type and level are already in numeric format
            await Provider.of<SkillsProvider>(context, listen: false)
                .addSkill(skillName, type, level);
            
            // Check if there was an error during add
            final provider = Provider.of<SkillsProvider>(context, listen: false);
            if (provider.error.isEmpty) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Skill added successfully')),
              );
              // Refresh the skills list for the current level
              if (selectedLevelValue.isNotEmpty) {
                provider.fetchSkillsByLevel(selectedLevelValue);
              } else {
                provider.fetchSkills();
              }
            }
          },
          currentLevel: selectedLevelValue,
          levelMap: levelMap,
        );
      },
    );
  }
}

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
        // Convert type from "0" or "1" to "Skills" or "Behaviour" for display only
        final typeDisplay = skill.type == "0" ? "Skills" : "Behaviour";
        // Get level display name if available
        String levelDisplay = '';
        if (skill.level != null) {
          // Find the display name for the level value
          for (var entry in {
            'Class 1': '0',
            'Class 2': '1',
            'Class 3': '2',
            'Class 4': '3',
            'Class 5': '4',
          }.entries) {
            if (entry.value == skill.level) {
              levelDisplay = entry.key;
              break;
            }
          }
        }
        
        return SkillItem(
          skill: skill.skillName ?? '',
          type: typeDisplay, // Pass the display type
          level: levelDisplay, // Pass the level display name
          onEdit: (newSkill) => onEdit(index, newSkill),
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}

class SkillItem extends StatefulWidget {
  final String skill;
  final String type; // Display type (Skills/Behaviour)
  final String level; // Optional level display
  final Function(String) onEdit;
  final VoidCallback onDelete;

  const SkillItem({
    super.key,
    required this.skill,
    required this.type,
    this.level = '',
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
  void didUpdateWidget(covariant SkillItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.skill != widget.skill) {
      _controller.text = widget.skill;
    }
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
                          decoration: InputDecoration(
                            hintText: 'Enter skill name',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () {
                                widget.onEdit(_controller.text);
                                setState(() {
                                  _isEditing = false;
                                });
                              },
                            ),
                          ),
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
                  const SizedBox(height: 4), // Add spacing between skill and type
                  Row(
                    children: [
                      Text(
                        widget.type, // Display the type
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (widget.level.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Text(
                          '•',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.level, // Display the level
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
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
            GestureDetector(
              onTap: () {
                // Show confirmation dialog before deleting
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Skill'),
                    content: Text('Are you sure you want to delete "${widget.skill}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDelete();
                        },
                        child: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
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
  final String currentLevel;
  final Map<String, String> levelMap;

  const AddSkillBottomSheet({
    Key? key, 
    required this.onAddSkill,
    required this.currentLevel,
    required this.levelMap,
  }) : super(key: key);

  @override
  _AddSkillBottomSheetState createState() => _AddSkillBottomSheetState();
}

class _AddSkillBottomSheetState extends State<AddSkillBottomSheet> {
  final TextEditingController _skillController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  
  // Map type display names to API values
  final Map<String, String> typeMap = {
    'Skills': '0',
    'Behaviour': '1',
  };
  
  late List<String> levelDisplays;
  List<String> typeDisplays = ['Skills', 'Behaviour'];
  
  String? selectedLevelDisplay;
  String? selectedTypeDisplay;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    
    // Initialize level displays from the provided map
    levelDisplays = widget.levelMap.keys.toList();
    
    // Pre-select the current level if available
    if (widget.currentLevel.isNotEmpty) {
      // Find the display name for the current level value
      for (var entry in widget.levelMap.entries) {
        if (entry.value == widget.currentLevel) {
          selectedLevelDisplay = entry.key;
          break;
        }
      }
    }
    
    // Set Skills as the default selected type
    selectedTypeDisplay = 'Skills';
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _submitSkill() {
    if (_skillController.text.isNotEmpty &&
        selectedTypeDisplay != null && 
        selectedLevelDisplay != null) {
      // Convert display values to API values
      final levelValue = widget.levelMap[selectedLevelDisplay!] ?? '0';
      final typeValue = typeMap[selectedTypeDisplay!] ?? '0';
      
      // Pass numeric values to the onAddSkill callback
      widget.onAddSkill(_skillController.text, typeValue, levelValue);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
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
          TextField(
            controller: _skillController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Enter a skill',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: 12,
              ),
              filled: _isFocused,
              fillColor: _isFocused ? Colors.blue.withOpacity(0.1) : null,
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty && 
                  selectedTypeDisplay != null && 
                  selectedLevelDisplay != null) {
                _submitSkill();
              }
            },
          ),
          const SizedBox(height: 16),
          CustomDropdown<String>(
            hintText: 'Select Type',
            items: typeDisplays,
            initialItem: selectedTypeDisplay,
            onChanged: (value) {
              setState(() {
                selectedTypeDisplay = value;
              });
            },
          ),
          const SizedBox(height: 16),
          CustomDropdown<String>(
            hintText: 'Select Level',
            items: levelDisplays,
            initialItem: selectedLevelDisplay,
            onChanged: (value) {
              setState(() {
                selectedLevelDisplay = value;
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

// Add this extension method to SkillsProvider class
// Extension for SkillsProvider
extension SkillsProviderExtension on SkillsProvider {
  Future<void> fetchSkillsByLevel(String level) async {
    // Implement this method in your SkillsProvider class
    // It should filter skills by the selected level
    await fetchSkills(); // First fetch all skills
    
    // Then filter by level if level is provided
    if (level.isNotEmpty) {
      // This is just a placeholder - implement the actual filtering
      // in your SkillsProvider class
      // skills = skills.where((skill) => skill.level == level).toList();
    }
  }
}