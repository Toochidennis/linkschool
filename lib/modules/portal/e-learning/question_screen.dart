import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_save_outline_button..dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/e-learning/topic_selection_screen.dart';

class QuestionScreen extends StatefulWidget {
  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
    String _selectedClass = 'Select classes';
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    String _attachmentText = 'Add Attachment';
    DateTime _selectedDateTime = DateTime.now();
    String _selectedTopic = 'Rule of BODMAS';


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
          'Question',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adding some padding for better alignment
            child: CustomSaveElevatedButton(
              onPressed: () {
                
                // Navigator.of(context).pop({
                //   'title': _titleController.text,
                //   'backgroundImagePath': _backgroundImagePath,
                //   'description': _descriptionController.text,
                //   'selectedClass': _selectedClass,
                //   'selectedTeacher': _selectedTeacher,
                // });
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
              'Title:',
              style:
                  AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Why is egg white?',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.all(12.0),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Description:',
              style:
                  AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'List out the characteristics of an egg',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.all(12.0),
              ),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Select the learners : *',
              style:
                  AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
            ),
            const SizedBox(height: 16.0),
            _buildGroupRow(
              context,
              iconPath: 'assets/icons/e_learning/people.svg',
              text: _selectedClass,
              onTap: () {}
            ),
            // _buildGroupRow(
            //   context, 
            //   iconPath: 'assets/icons/e_learning/link.svg', 
            //   text: _attachmentText, 
            //   isSelected: true,
            //   onTap: _showAttachmentOptions
            // ),
            _buildGroupRow(
              context, 
              iconPath: 'assets/icons/e_learning/mark.svg', 
              text: '200 marks', 
              showEditButton: true,
              onTap: () {}
            ),
            _buildGroupRow(
              context, 
              iconPath: 'assets/icons/e_learning/calender.svg', 
              text: 'Due : Thurs, 25 July', 
              showEditButton: true,
              isSelected: true,
              onTap: _showDateTimePicker
            ),
            _buildGroupRow(
              context, 
              iconPath: 'assets/icons/e_learning/clock.svg', 
              text: '60 minutes', 
              showEditButton: true,
              onTap: _showDateTimePicker
            ),
            _buildGroupRow(
              context, 
              iconPath: 'assets/icons/e_learning/clipboard.svg', 
              text: 'No Topic', 
              showEditButton: true,
              isSelected: true,
              onTap: () => _showTopicSelectionScreen()
            ),
          ],
        ),
      )
    );
  }

Widget _buildGroupRow(
  BuildContext context, {
  required String iconPath,
  required String text,
  required VoidCallback onTap,
  bool showEditButton = false,
  bool isSelected = false, 
}) {
  return Column(
    children: [
      GestureDetector( // Wrapping the entire row in GestureDetector
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                iconPath,
                width: 32.0,
                height: 32.0,
              ),
            ),
            const SizedBox(width: 8.0),
            IntrinsicWidth(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.transparent : AppColors.eLearningBtnColor2,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      text,
                      style: AppTextStyles.normal600(
                        fontSize: 16.0,
                        color: AppColors.eLearningBtnColor1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (showEditButton)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: OutlinedButton(
                  onPressed: onTap,
                  child: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    textStyle: AppTextStyles.normal600(fontSize: 14.0, color: AppColors.backgroundLight),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8.0),
      Divider(color: Colors.grey.withOpacity(0.5)),
      const SizedBox(height: 8.0),
    ],
  );
}




void _showDateTimePicker() {
  showDatePicker(
    context: context,
    initialDate: _selectedDateTime,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  ).then((date) {
    if (date != null) {
      showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: Theme(
              data: ThemeData.light().copyWith(
                timePickerTheme: const TimePickerThemeData(
                  dialHandColor: Colors.transparent,
                  hourMinuteTextColor: Colors.black,
                  dayPeriodTextColor: Colors.black,
                  dialBackgroundColor: Colors.transparent,
                  dialTextColor: Colors.transparent,
                ),
              ),
              child: child!,
            ),
          );
        },
      ).then((time) {
        if (time != null) {
          setState(() {
            _selectedDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          });
        }
      });
    }
  });
}

  void _showTopicSelectionScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopicSelectionScreen(
          initialTopic: _selectedTopic,
          onSave: (topic) {
            setState(() {
              _selectedTopic = topic;
            });
          },
        ),
      ),
    );
  }
}