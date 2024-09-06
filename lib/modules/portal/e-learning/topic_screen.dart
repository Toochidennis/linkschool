import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/e-learning/objetive_screen.dart';
import 'package:linkschool/modules/portal/result/behaviour_settings_screen.dart';
// import 'package:linkschool/modules/portal/e-learning/objective_screen.dart'; // New import

class TopicScreen extends StatefulWidget {
  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  List<String> topics = [];
  String? selectedTopic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Select topic',
      //     style: AppTextStyles.normal600(
      //       fontSize: 24.0,
      //       color: AppColors.primaryLight,
      //     ),
      //   ),
      //   backgroundColor: AppColors.backgroundLight,
      //   actions: [
      //    Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //       child: CustomSaveElevatedButton(
      //         onPressed: () {
      //           // Save the selected topic and return to AssignmentScreen
      //           Navigator.pop(context, selectedTopic ?? 'No Topic');
      //         },
      //         text: 'Save',
      //       ),
      //     ),
      //   ],
      // ),
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
          'Select topic',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        actions: [
         Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CustomSaveElevatedButton(
              onPressed: () {
                // Save the selected topic and return to AssignmentScreen
                Navigator.pop(context, selectedTopic ?? 'No Topic');
              },
              text: 'Save',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomInputField(
                hintText: 'Add new Topic',
                onSubmitted: _addTopic,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TopicsList(
                  topics: topics,
                  selectedTopic: selectedTopic,
                  onEdit: _editTopic,
                  onDelete: _deleteTopic,
                  onTap: _navigateToObjectiveScreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTopic(String topic) {
    setState(() {
      topics.add(topic);
      selectedTopic = topic;
    });
  }

 void _editTopic(int index, String newTopic) {
    setState(() {
      topics[index] = newTopic;
      if (selectedTopic == topics[index]) {
        selectedTopic = newTopic;
      }
    });
  }

  void _deleteTopic(int index) {
    setState(() {
      if (selectedTopic == topics[index]) {
        selectedTopic = null;
      }
      topics.removeAt(index);
    });
  }

  void _selectTopic(String topic) {
    setState(() {
      selectedTopic = topic;
    });
  }

 void _navigateToObjectiveScreen(String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObjectiveScreen(topic: topic),
      ),
    );
  }
}

class TopicsList extends StatelessWidget {
  final List<String> topics;
  final String? selectedTopic;
  final Function(int, String) onEdit;
  final Function(int) onDelete;
  final Function(String) onTap;

  const TopicsList({
    Key? key,
    required this.topics,
    required this.selectedTopic,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return TopicItem(
          topic: topics[index],
          isSelected: topics[index] == selectedTopic,
          onEdit: (newTopic) => onEdit(index, newTopic),
          onDelete: () => onDelete(index),
          onTap: () => onTap(topics[index]),
        );
      },
    );
  }
}

class TopicItem extends StatefulWidget {
  final String topic;
  final bool isSelected;
  final Function(String) onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TopicItem({
    Key? key,
    required this.topic,
    required this.isSelected,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
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
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
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
      ),
    );
  }
}