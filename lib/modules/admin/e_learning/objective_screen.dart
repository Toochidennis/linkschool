// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:intl/intl.dart';

class ObjectiveScreen extends StatefulWidget {
  final String topic;

  const ObjectiveScreen({super.key, required this.topic});

  @override
  _ObjectiveScreenState createState() => _ObjectiveScreenState();
}

class _ObjectiveScreenState extends State<ObjectiveScreen> {
  final bool _isFocused = false;
  List<Objective> objectives = [
    Objective("Learn about the concept of punctuality", DateTime.now(), false),
    Objective("Understand the importance of time management", DateTime.now().subtract(Duration(days: 1)), true),
    Objective("Practice being on time for appointments", DateTime.now().add(Duration(days: 1)), false),
    Objective("Analyze the effects of tardiness on productivity", DateTime.now().add(Duration(days: 2)), false),
    Objective("Develop strategies for improving punctuality", DateTime.now().add(Duration(days: 3)), false),
    Objective("Create a personal schedule to enhance time management", DateTime.now().add(Duration(days: 4)), false),
    Objective("Evaluate progress in punctuality improvement", DateTime.now().add(Duration(days: 5)), false),
  ];

  final TextEditingController _objectiveController = TextEditingController();

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
          widget.topic,
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
                // Save functionality
              },
              text: 'Save',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic Objectives',
              style: AppTextStyles.normal600(fontSize: 24.0, color: Colors.black),
            ),
            SizedBox(height: 16.0),
            _buildObjectiveInput(),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: objectives.length,
                itemBuilder: (context, index) {
                  return _buildObjectiveItem(objectives[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildObjectiveInput() {
  return Container(
    width: 351,
    height: 48,
    padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
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
          onTap: _addObjective,
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
        SizedBox(width: 18),
        Expanded(
          child: TextField(
            controller: _objectiveController,
            decoration: InputDecoration(
              hintText: 'Add new Objective',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildObjectiveItem(Objective objective) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: objective.isCompleted,
            onChanged: (bool? value) {
              setState(() {
                objective.isCompleted = value ?? false;
              });
            },
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  objective.description,
                  style: AppTextStyles.normal500(fontSize: 16.0, color: Colors.black),
                ),
                SizedBox(height: 4.0),
                Row(
                  children: [
                    Text(
                      _getRelativeDate(objective.date),
                      style: AppTextStyles.normal400(fontSize: 14.0, color: Colors.grey),
                    ),
                    SizedBox(width: 8.0),
                    Container(
                      width: 4.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      DateFormat('dd-MM-yyyy').format(objective.date),
                      style: AppTextStyles.normal400(fontSize: 14.0, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addObjective() {
    if (_objectiveController.text.isNotEmpty) {
      setState(() {
        objectives.add(Objective(_objectiveController.text, DateTime.now(), false));
        _objectiveController.clear();
      });
    }
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else if (difference.inDays > 0 && difference.inDays < 7) {
      return DateFormat('EEEE').format(date); // Returns the day of the week
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }
}

class Objective {
  String description;
  DateTime date;
  bool isCompleted;

  Objective(this.description, this.date, this.isCompleted);
}