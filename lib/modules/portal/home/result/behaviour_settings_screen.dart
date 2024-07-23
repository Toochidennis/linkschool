import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart'; // Import the constants file

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
      appBar: Constants.customAppBar(context: context, title: 'Skills and Behaviour',),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SkillsList(skills: skills, onEdit: _editSkill, onDelete: _deleteSkill),
              const SizedBox(height: 10,),
              CustomInputField(
                hintText: 'Add new skill or behaviour',
                onSubmitted: _addSkill,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
                    offset: const Offset(3, 5))
              ]),
          child: const Icon(
            Icons.save,
            color: AppColors.backgroundLight,
          ),
        ),
      ),
    );
  }

  void _addSkill(String skill) {
    setState(() {
      skills.add(skill);
    });
  }

  void _editSkill(int index, String newSkill) {
    setState(() {
      skills[index] = newSkill;
    });
  }

  void _deleteSkill(int index) {
    setState(() {
      skills.removeAt(index);
    });
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
    Key? key,
    required this.skill,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

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
    return Container(
      width: 351, // Match the width of the input field
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
              color: Colors.white,
              border: Border.all(color: AppColors.bgGray, width: 2),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/result/skill.svg',
                // ignore: deprecated_member_use
                color: AppColors.bgGray,
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
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                widget.onEdit(_controller.text);
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

class CustomInputField extends StatefulWidget {
  final String hintText;
  final Function(String) onSubmitted;

  const CustomInputField({
    Key? key,
    required this.hintText,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;

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
    _controller.dispose();
    super.dispose();
  }

  void _submitSkill() {
    if (_controller.text.isNotEmpty) {
      widget.onSubmitted(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 351,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _isFocused ? AppColors.primaryLight : const Color(0xFFB2B2B2),
            width: _isFocused ? 2 : 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _submitSkill,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.bgGray,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.bgGray,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: AppColors.bgGrayLight),
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                _submitSkill();
              },
            ),
          ),
        ],
      ),
    );
  }
}