// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_save_outline_button..dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';
import 'package:linkschool/modules/portal/e-learning/topic_screen.dart';
import 'package:linkschool/modules/portal/e-learning/topic_selection_screen.dart';

class AssignmentScreen extends StatefulWidget {
  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  String _selectedClass = 'Select classes';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<AttachmentItem> _attachments = [];
  DateTime _selectedDateTime = DateTime.now();
  String _selectedTopic = 'No Topic';

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title:',
                style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Dying and bleaching',
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
                style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.all(12.0),
                ),
              ),
              const SizedBox(height: 32.0),
              Text(
                'Select the learning group for this syllabus: *',
                style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
              ),
              const SizedBox(height: 16.0),
              
              _buildGroupRow(
                context,
                iconPath: 'assets/icons/e_learning/people.svg',
                text: _selectedClass,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SelectClassesDialog(
                        onSave: (selectedClass) {
                          setState(() {
                            _selectedClass = selectedClass;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              _buildAttachmentsSection(),
              _buildGroupRow(
                context,
                iconPath: 'assets/icons/e_learning/mark.svg',
                text: '200 marks',
                showEditButton: true,
                onTap: () {},
              ),
              _buildGroupRow(
                context,
                iconPath: 'assets/icons/e_learning/calender.svg',
                text: DateFormat('E, dd MMM (hh:mm a)').format(_selectedDateTime),
                showEditButton: true,
                onTap: _showDateTimePicker,
              ),
              _buildGroupRow(
                context,
                iconPath: 'assets/icons/e_learning/clipboard.svg',
                text: _selectedTopic,
                showEditButton: true,
                isSelected: true,
                onTap: () =>  Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) => TopicScreen())),
              ),
            ],
          ),
        ),
      ),
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
        GestureDetector(
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
              // Expanded(
              //   child: Text(
              //     text,
              //     style: AppTextStyles.normal600(
              //       fontSize: 16.0,
              //       color: isSelected ? AppColors.eLearningBtnColor1 : AppColors.eLearningBtnColor1,
              //     ),
              //   ),
              // ),
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
                OutlinedButton(
                  onPressed: onTap,
                  child: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    textStyle: AppTextStyles.normal600(fontSize: 14.0, color: AppColors.backgroundLight),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: AppColors.eLearningBtnColor1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupRow(
          context,
          iconPath: 'assets/icons/e_learning/link.svg',
          text: 'Add Attachment',
          isSelected: true,
          onTap: _showAttachmentOptions,
        ),
        ..._attachments.map((attachment) => _buildAttachmentRow(attachment)),
        if (_attachments.isNotEmpty)
          OutlinedButton(
            onPressed: _showAttachmentOptions,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.eLearningBtnColor4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('+ Add'),
          ),
      ],
    );
  }

 Widget _buildAttachmentRow(AttachmentItem attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(4.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            attachment.iconPath,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              attachment.content,
              style: AppTextStyles.normal400(fontSize: 14.0, color: AppColors.primaryLight),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/cancel_icon.svg',
              width: 24,
              height: 24,
              color: Colors.red, // Add a color to make it visible
            ),
            onPressed: () {
              setState(() {
                _attachments.remove(attachment);
              });
            },
          ),
        ],
      ),
    );
  }

 void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Add attachment',
                style: AppTextStyles.normal600(fontSize: 20, color: AppColors.backgroundDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildAttachmentOption('Insert link', 'assets/icons/e_learning/link3.svg', _showInsertLinkDialog),
              _buildAttachmentOption('Upload file', 'assets/icons/e_learning/upload.svg', () => _addAttachment('File', 'assets/icons/e_learning/upload.svg')),
              _buildAttachmentOption('Take photo', 'assets/icons/e_learning/camera.svg', () => _addAttachment('Photo', 'assets/icons/e_learning/camera.svg')),
              _buildAttachmentOption('Record Video', 'assets/icons/e_learning/video.svg', () => _addAttachment('Video', 'assets/icons/e_learning/video.svg')),
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
            const SizedBox(width: 16),
            Text(text, style: AppTextStyles.normal400(fontSize: 16, color: AppColors.backgroundDark)),
          ],
        ),
      ),
    );
  }

 void _showInsertLinkDialog() {
    TextEditingController linkController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Insert Link',
            style: AppTextStyles.normal600(fontSize: 20, color: AppColors.backgroundDark),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: linkController,
            decoration: InputDecoration(
              hintText: 'Enter link here',
              prefixIcon: SvgPicture.asset(
                'assets/icons/e_learning/link3.svg',
                width: 24,
                height: 24,
                fit: BoxFit.scaleDown,
              ),
              border: const UnderlineInputBorder(),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryLight),
              ),
            ),
          ),
          actions: [
            CustomOutlineButton(
              onPressed: () => Navigator.of(context).pop(),
              text: 'Cancel',
              borderColor: AppColors.eLearningBtnColor3.withOpacity(0.4),
              textColor: AppColors.eLearningBtnColor3,
            ),
            CustomSaveElevatedButton(
              onPressed: () {
                if (linkController.text.isNotEmpty) {
                  _addAttachment(linkController.text, 'assets/icons/e_learning/link3.svg');
                }
                Navigator.of(context).pop();
              },
              text: 'Save',
            ),
          ],
        );
      },
    );
  }

  void _addAttachment(String content, String iconPath) {
    setState(() {
      _attachments.add(AttachmentItem(content: content, iconPath: iconPath));
    });
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
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!,
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

class AttachmentItem {
  final String content;
  final String iconPath;

  AttachmentItem({required this.content, required this.iconPath});
}