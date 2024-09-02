import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Correct import path for SvgPicture
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class TopicScreen extends StatefulWidget {
  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  List<String> topics = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Topic',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CustomSaveElevatedButton(onPressed: () {}, text: 'Save'),
          ),
        ],
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding( // Removed `const` keyword here
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TopicsList(
                topics: topics,
                onEdit: _editTopic,
                onDelete: _deleteTopic,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomInputField(
                hintText: 'Add new Topic',
                onSubmitted: _addTopic,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTopic(String skill) {
    setState(() {
      topics.add(skill);
    });
  }

  void _editTopic(int index, String newSkill) {
    setState(() {
      topics[index] = newSkill;
    });
  }

  void _deleteTopic(int index) {
    setState(() {
      topics.removeAt(index);
    });
  }
}

class TopicsList extends StatelessWidget {
  final List<String> topics;
  final Function(int, String) onEdit;
  final Function(int) onDelete;

  const TopicsList({
    super.key,
    required this.topics,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: topics.length, // Ensure itemCount is specified
      shrinkWrap: true, // This is useful if inside a Column
      itemBuilder: (context, index) {
        return TopicItem(
          topic: topics[index],
          onEdit: (newSkill) => onEdit(index, newSkill),
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}


class TopicItem extends StatefulWidget {
  final String topic;
  final Function(String) onEdit;
  final VoidCallback onDelete;

  const TopicItem({
    Key? key,
    required this.topic,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  _TopicItemState createState() => _TopicItemState();
}

class _TopicItemState extends State<TopicItem> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.topic);
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
        // width: 351,
        padding: const EdgeInsets.only(
            bottom: 10), // Match the width of the input field
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
                  // ignore: deprecated_member_use
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
                  : Text(widget.topic),
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

  void _submitTopic() {
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
            color:
                _isFocused ? AppColors.primaryLight : const Color(0xFFB2B2B2),
            width: _isFocused ? 2 : 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _submitTopic,
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
                _submitTopic();
              },
            ),
          ),
        ],
      ),
    );
  }
}
