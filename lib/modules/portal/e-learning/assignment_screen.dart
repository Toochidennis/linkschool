import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';

import 'package:linkschool/modules/portal/e-learning/select_topic_screen.dart';
// import 'package:linkschool/modules/common/buttons/custom_outline_button.dart';
// import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';



class AssignmentScreen extends StatefulWidget {
   final Function(Assignment) onSave;

  const AssignmentScreen({Key? key, required this.onSave}) : super(key: key);
  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  String _selectedClass = 'Select classes';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  List<AttachmentItem> _attachments = [];
  DateTime _selectedDateTime = DateTime.now();
  String _selectedTopic = 'No Topic';
  String _marks = '200 marks';

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
              onPressed: _saveAssignment,
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
                style: AppTextStyles.normal600(
                    fontSize: 16.0, color: Colors.black),
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
                style: AppTextStyles.normal600(
                    fontSize: 16.0, color: Colors.black),
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
                style: AppTextStyles.normal600(
                    fontSize: 16.0, color: Colors.black),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildAttachmentsSection(),
              ),
              Divider(color: Colors.grey.withOpacity(0.5)),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildGroupRow(
                  context,
                  iconPath: 'assets/icons/e_learning/mark.svg',
                  text: _marks,
                  showEditButton: true,
                  onTap: _showMarksDialog,
                ),
              ),
              _buildGroupRow(
                context,
                iconPath: 'assets/icons/e_learning/calender.svg',
                text: DateFormat('E, dd MMM (hh:mm a)')
                    .format(_selectedDateTime),
                showEditButton: true,
                onTap: _showDateTimePicker,
              ),
              _buildGroupRow(
                context,
                iconPath: 'assets/icons/e_learning/clipboard.svg',
                text: _selectedTopic,
                showEditButton: true,
                isSelected: true,
                onTap: () => _selectTopic(),
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
                padding: const EdgeInsets.all(4.0),
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
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.eLearningBtnColor2,
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
                    textStyle: AppTextStyles.normal600(
                        fontSize: 14.0, color: AppColors.backgroundLight),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  void _showMarksDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set marks',
                  style:
                      AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _marksController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomOutlineButton(
                      onPressed: () => Navigator.of(context).pop(),
                      text: 'Cancel',
                      borderColor: AppColors.eLearningBtnColor3,
                      textColor: AppColors.eLearningBtnColor3,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _marks = '${_marksController.text} marks';
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.eLearningBtnColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: AppTextStyles.normal600(
                            fontSize: 16.0, color: Colors.white),
                      ),
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

  Widget _buildAttachmentsSection() {
    return GestureDetector(
      onTap: _attachments.isEmpty ? _showAttachmentOptions : null,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_attachments.isEmpty)
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/e_learning/link.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Add Attachment',
                    style: AppTextStyles.normal600(
                        fontSize: 16.0, color: AppColors.eLearningBtnColor1),
                  ),
                ],
              )
            else
              Column(
                children: [
                  ..._attachments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final attachment = entry.value;
                    return _buildAttachmentItem(attachment,
                        isFirst: index == 0);
                  }).toList(),
                  const SizedBox(height: 8.0),
                  _buildAddMoreButton(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(AttachmentItem attachment, {bool isFirst = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isFirst ? 0 : 8.0),
      child: Row(
        children: [
          SvgPicture.asset(
            attachment.iconPath,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              attachment.content,
              style: AppTextStyles.normal400(
                  fontSize: 14.0, color: AppColors.primaryLight),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.red),
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

  Widget _buildAddMoreButton() {
    return GestureDetector(
      onTap: _showAttachmentOptions,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spacer(),
          OutlinedButton(
            onPressed: _showAttachmentOptions,
            child: const Text('+ Add'),
            style: OutlinedButton.styleFrom(
              textStyle: AppTextStyles.normal600(
                  fontSize: 14.0, color: AppColors.backgroundLight),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: const BorderSide(color: AppColors.eLearningBtnColor1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
                style: AppTextStyles.normal600(
                    fontSize: 20, color: AppColors.backgroundDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildAttachmentOption(
                  'Insert link',
                  'assets/icons/e_learning/insert_link.svg',
                  _showInsertLinkDialog),
              _buildAttachmentOption(
                  'Upload file', 'assets/icons/e_learning/upload_file.svg', _uploadFile),
              _buildAttachmentOption(
                  'Take photo', 'assets/icons/e_learning/take_photo.svg', _takePhoto),
              _buildAttachmentOption(
                  'Record Video', 'assets/icons/e_learning/record_video.svg', _recordVideo),
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
            Text(text,
                style: AppTextStyles.normal400(
                    fontSize: 16, color: AppColors.backgroundDark)),
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
            style: AppTextStyles.normal600(
                fontSize: 20, color: AppColors.backgroundDark),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: linkController,
            decoration: InputDecoration(
              fillColor: Colors.grey[100],
              filled: true,
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
                  _addAttachment(
                      linkController.text, 'assets/icons/e_learning/link3.svg');
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

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String fileName = result.files.single.name;
      _addAttachment(fileName, 'assets/icons/e_learning/upload.svg');
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      _addAttachment('Photo: ${photo.name}', 'assets/icons/e_learning/camera.svg');
    }
  }

  Future<void> _recordVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      _addAttachment('Video: ${video.name}', 'assets/icons/e_learning/video.svg');
    }
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

  void _selectTopic() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SelectTopicScreen(
                callingScreen: '',
              )),
    );
    if (result != null && result is String) {
      setState(() {
        _selectedTopic = result;
      });
    }
  }

void _saveAssignment() {
  final assignment = Assignment(
    title: _titleController.text,
    description: _descriptionController.text,
    selectedClass: _selectedClass,
    attachments: _attachments,
    dueDate: _selectedDateTime,
    topic: _selectedTopic,
    marks: _marks,
  );
  widget.onSave(assignment);
  Navigator.of(context).pop();
}

}

class AttachmentItem {
  final String content;
  final String iconPath;

  AttachmentItem({required this.content, required this.iconPath});
}


class Assignment {
  final String title;
  final String description;
  final String selectedClass;
  final List<AttachmentItem> attachments;
  final DateTime dueDate;
  final String topic;
  final String marks;
  final DateTime createdAt;

  Assignment({
    required this.title,
    required this.description,
    required this.selectedClass,
    required this.attachments,
    required this.dueDate,
    required this.topic,
    required this.marks,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();
}