import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import '../../common/text_styles.dart';

class BehaviourSettingScreen extends StatefulWidget {
  const BehaviourSettingScreen({super.key});

  @override
  State<BehaviourSettingScreen> createState() => _BehaviourSettingScreenState();
}

class _BehaviourSettingScreenState extends State<BehaviourSettingScreen> {
  List<String> skills = [];

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
          'Skills and Behaviour ',
          style: AppTextStyles.normal600(
            fontSize: 18.0,
            color: AppColors.primaryLight,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
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
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
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
                                      Navigator.pop(context);
                                    },
                                    child: const ListTile(
                                      title: Center(child: Text('Class 1')),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
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
                                      Navigator.of(context);
                                    },
                                    child: const ListTile(
                                      title: Center(child: Text('Class 2')),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
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
                                      Navigator.pop(context);
                                    },
                                    child: const ListTile(
                                      title: Center(child: Text('Class 3')),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      const Text('Select Level'),
                      const Icon(Icons.arrow_drop_down,
                          color: AppColors.primaryLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SkillsList(
                  skills: skills,
                  onEdit: _editSkill,
                  onDelete: _deleteSkill,
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

  void _addSkill(String skill) {
    setState(() {
      skills.add(skill); // Add the new skill to the list
    });
  }

  void _editSkill(int index, String newSkill) {
    setState(() {
      skills[index] = newSkill; // Update the skill at the given index
    });
  }

  void _deleteSkill(int index) {
    setState(() {
      skills.removeAt(index); // Remove the skill at the given index
    });
  }

  void _showAddSkills(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddSkillBottomSheet(
          onAddSkill: _addSkill,
        );
      },
    );
  }
}

class SkillsList extends StatelessWidget {
  final List<String> skills;
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
        return SkillItem(
          skill: skills[index],
          onEdit: (newSkill) => onEdit(index, newSkill),
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}

class SkillItem extends StatefulWidget {
  final String skill;
  final Function(String) onEdit;
  final VoidCallback onDelete;

  const SkillItem({
    super.key,
    required this.skill,
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
    _controller = TextEditingController(
        text: widget.skill); // Initialize with the current skill
  }

  @override
  void didUpdateWidget(covariant SkillItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.skill != widget.skill) {
      _controller.text =
          widget.skill; // Update the controller if the skill changes
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
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      onSubmitted: (value) {
                        widget.onEdit(value);
                        setState(() {
                          _isEditing = false;
                        });
                      },
                    )
                  : Text(widget.skill),
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

class AddSkillBottomSheet extends StatefulWidget {
  final Function(String) onAddSkill;

  const AddSkillBottomSheet({Key? key, required this.onAddSkill})
      : super(key: key);

  @override
  _AddSkillBottomSheetState createState() => _AddSkillBottomSheetState();
}

class _AddSkillBottomSheetState extends State<AddSkillBottomSheet> {
  final TextEditingController _skillController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  List<String> levels = ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'];
  List<String> types = ['Skills', 'Behaviour'];
  String? selectedLevel;
  String? selectedType;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _submitSkill() {
    if (_skillController.text.isNotEmpty &&
        selectedLevel != null &&
        selectedType != null) {
      widget.onAddSkill('${_skillController.text}\n -$selectedType');
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
                icon:
                    SvgPicture.asset('assets/icons/profile/cancel_receipt.svg'),
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
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              _submitSkill();
            },
          ),
          const SizedBox(height: 16),
          CustomDropdown<String>(
            hintText: 'Select Level',
            items: levels,
            onChanged: (value) {
              selectedLevel = value;
            },
          ),
          const SizedBox(height: 16),
          CustomDropdown<String>(
            hintText: 'Select Type',
            items: types,
            onChanged: (value) {
              selectedType = value;
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
