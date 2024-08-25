import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_save_outline_button..dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/e-learning/topic_selection_screen.dart';

class AssignmentScreen extends StatefulWidget {
  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
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
          'Assignment',
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
        padding: EdgeInsets.all(16.0),
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
                hintText: 'e.g. Dying and bleaching',
                hintStyle: TextStyle(color: Colors.grey),
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
                hintText: 'Type here...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.all(12.0),
              ),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Select the learning group for this syllabus: *',
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
            _buildGroupRow(
              context, 
              iconPath: 'assets/icons/e_learning/link.svg', 
              text: _attachmentText, 
              isSelected: true,
              onTap: _showAttachmentOptions
            ),
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
              text: '${_selectedDateTime.toString().split(' ')[0]} (${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')})', 
              showEditButton: true,
              onTap: _showDateTimePicker
            ),
            _buildGroupRow(
              context, 
              iconPath: 'assets/icons/e_learning/clipboard.svg', 
              text: 'Rule of BODMAS', 
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
            Spacer(),
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


  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Add attachment',
                style: AppTextStyles.normal600(fontSize: 20, color: AppColors.backgroundDark),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              _buildAttachmentOption('Insert link', 'assets/icons/e_learning/link3.svg', _showInsertLinkDialog),
              _buildAttachmentOption('Upload file', 'assets/icons/e_learning/upload.svg', () {}),
              _buildAttachmentOption('Take photo', 'assets/icons/e_learning/camera.svg', () {}),
              _buildAttachmentOption('Record Video', 'assets/icons/e_learning/video.svg', () {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(String text, String iconPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        color: AppColors.backgroundLight,
        child: Row(
          children: [
            SvgPicture.asset(iconPath, width: 24, height: 24),
            SizedBox(width: 16),
            Text(text, style: AppTextStyles.normal400(fontSize: 16, color: AppColors.backgroundDark)),
          ],
        ),
      ),
    );
  }

  void _showInsertLinkDialog() {
    TextEditingController linkController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insert Link',
                  style: AppTextStyles.normal600(fontSize: 20, color: AppColors.backgroundDark),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: linkController,
                  decoration: InputDecoration(
                    hintText: 'Enter link here',
                    prefixIcon: SvgPicture.asset(
                      'assets/icons/e_learning/link3.svg',
                      width: 24,
                      height: 24,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // TextButton(
                    //   child: Text('Cancel'),
                    //   onPressed: () => Navigator.of(context).pop(),
                    // ),
                    CustomOutlineButton(onPressed: () => Navigator.of(context).pop(), text: 'Cancel', borderColor: AppColors.eLearningBtnColor3, textColor: AppColors.eLearningBtnColor3),
                    CustomSaveElevatedButton(
                      onPressed: () {
                        setState(() {
                          _attachmentText = linkController.text.isNotEmpty 
                            ? 'Link: ${linkController.text}' 
                            : 'Add Attachment';
                        });
                        Navigator.of(context).pop();
                      }, 
                      text: 'Save',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

void _showDateTimePicker() {
  showDatePicker(
    context: context,
    initialDate: _selectedDateTime,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 365)),
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
                timePickerTheme: TimePickerThemeData(
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