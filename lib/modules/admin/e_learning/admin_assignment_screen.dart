
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/select_topic_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';

import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';

class AdminAssignmentScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final String? classId;
  final String? courseId;
  final String? courseName;
  final String? levelId;
  final int? syllabusId;
  const AdminAssignmentScreen({
    super.key,
    required this.onSave,
    this.classId,
    this.courseId,
    this.courseName,
    this.levelId, 
    this.syllabusId,
  });

  @override
  State<AdminAssignmentScreen> createState() => _AdminAssignmentScreenState();
}

class _AdminAssignmentScreenState extends State<AdminAssignmentScreen> {
  String _selectedClass = 'Select classes';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  final List<AttachmentItem> _attachments = [];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
    String _selectedTopic = 'No Topic';
  int? _selectedTopicId;
  String _marks = ' 0 marks';
  late double opacity;
  int? creatorId;
  String? creatorName;
  String? academicYear;
  int? academicTerm;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
      if (storedUserData != null) {
        final processedData = storedUserData is String
            ? json.decode(storedUserData)
            : storedUserData as Map<String, dynamic>;
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final profile = data['profile'] ?? {};
        final settings = data['settings'] ?? {};

        setState(() {
          creatorId = profile['staff_id'] as int?;
          creatorName = profile['name']?.toString();
          academicYear = settings['year']?.toString();
          academicTerm = settings['term'] as int?;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
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
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                          levelId: widget.levelId,
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
                  text: 'Start: ${_formatDate(_startDate)}',
                  showEditButton: true,
                  isSelected: true,
                  onTap: () => _showDatePicker(true),
                ),
                _buildGroupRow(
                  context,
                  iconPath: 'assets/icons/e_learning/calender.svg',
                  text: 'Due: ${_formatDate(_endDate)}',
                  showEditButton: true,
                  isSelected: true,
                  onTap: () => _showDatePicker(false),
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
                  style: OutlinedButton.styleFrom(
                    textStyle: AppTextStyles.normal600(fontSize: 14.0, color: AppColors.backgroundLight),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: AppColors.eLearningBtnColor1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Edit'),
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
                  style: AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
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
                        style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.white),
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

  void _showDatePicker(bool isStartDate) {
    showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((picked) {
      if (picked != null) {
        setState(() {
          if (isStartDate) {
            _startDate = DateTime(picked.year, picked.month, picked.day);
          } else {
            _endDate = DateTime(picked.year, picked.month, picked.day);
          }
        });
      }
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thur';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
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
                    style: AppTextStyles.normal600(fontSize: 16.0, color: AppColors.eLearningBtnColor1),
                  ),
                ],
              )
            else
              Column(
                children: [
                  ..._attachments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final attachment = entry.value;
                    return _buildAttachmentItem(attachment, isFirst: index == 0);
                  }),
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
              style: AppTextStyles.normal400(fontSize: 14.0, color: AppColors.primaryLight),
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
          const Spacer(),
          OutlinedButton(
            onPressed: _showAttachmentOptions,
            style: OutlinedButton.styleFrom(
              textStyle: AppTextStyles.normal600(fontSize: 14.0, color: AppColors.backgroundLight),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: const BorderSide(color: AppColors.eLearningBtnColor1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('+ Add'),
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
              _buildAttachmentOption('Insert link',
                  'assets/icons/e_learning/link3.svg', _showInsertLinkDialog),
              _buildAttachmentOption('Upload file',
                  'assets/icons/e_learning/upload_file.svg', _uploadFile),
              _buildAttachmentOption('Take photo',
                  'assets/icons/e_learning/take_photo.svg', _takePhoto),
              _buildAttachmentOption('Record Video',
                  'assets/icons/e_learning/record_video.svg', _recordVideo),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(
      String text, String iconPath, VoidCallback onTap) {
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
            Text(
                text,
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
      return StatefulBuilder(
        builder: (context, setState) {
        bool isValidUrl(String url) {
  try {
    
    final uri = Uri.parse(url);

    return uri.isAbsolute && uri.scheme.isNotEmpty;
  } catch (e) {
    return false;
  }
}

          final isValid = isValidUrl(linkController.text);

          return AlertDialog(
            title: Text(
              'Insert Link',
              style: AppTextStyles.normal600(
                fontSize: 20,
                color: AppColors.backgroundDark,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: linkController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    fillColor: Colors.grey[100],
                    filled: true,
                    hintText: 'Enter link here (https://...)',
                    errorText: linkController.text.isNotEmpty && !isValid
                        ? 'Please enter a valid URL'
                        : null,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        'assets/icons/e_learning/link3.svg',
                        width: 24,
                        height: 24,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    border: const UnderlineInputBorder(),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryLight),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              CustomOutlineButton(
                onPressed: () => Navigator.of(context).pop(),
                text: 'Cancel',
                borderColor: AppColors.eLearningBtnColor3.withOpacity(0.4),
                textColor: AppColors.eLearningBtnColor3,
              ),
              CustomSaveElevatedButton(
                onPressed: isValid && linkController.text.isNotEmpty
                    ? () {
                        String fullUrl = linkController.text;

                        _addAttachment(
                          fullUrl, // Use full URL as the display name
                          'assets/icons/e_learning/link3.svg',
                          fullUrl, // Use full URL as the content
                        );

                        Navigator.of(context).pop();
                        Navigator.of(context).pop(); // Close both dialog and bottom sheet
                      }
                    : () {},
                text: 'Save',
              ),
            ],
          );
        },
      );
    },
  );
}


 Future<void> _uploadFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;
      
      // Option 1: Use bytes if available (for small files)
      if (file.bytes != null) {
        String base64String = base64Encode(file.bytes!);
        _addAttachment(fileName, 'assets/icons/e_learning/upload.svg', base64String);
      } 
      // Option 2: Read from path for large files
      else if (file.path != null) {
        // For very large files, consider uploading directly without base64
        Uint8List fileBytes = await File(file.path!).readAsBytes();
        String base64String = base64Encode(fileBytes);
        _addAttachment(fileName, 'assets/icons/e_learning/upload.svg', base64String);
      } 
      // Option 3: Just use the file info
      else {
        _addAttachment(fileName, 'assets/icons/e_learning/upload.svg');
       
      }
       Navigator.of(context).pop();
    }
  } catch (e) {
    print('Error picking file: $e');
    // Show error to user
  }
}

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      Uint8List fileBytes = await photo.readAsBytes();
      final base64String = base64Encode(fileBytes);
      _addAttachment(
          'Photo: ${photo.name}', 'assets/icons/e_learning/camera.svg',base64String);
      Navigator.of(context).pop();
    }
  }

  Future<void> _recordVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.camera);

    if (video != null) {
      Uint8List fileBytes = await video.readAsBytes();
      final base64String =base64Encode(fileBytes);
      _addAttachment(
          'Video: ${video.name}', 'assets/icons/e_learning/video.svg',base64String);
          Navigator.of(context).pop();
    }
  }

  void _addAttachment(String content, String iconPath, [String? base64Content]) {
    setState(() {
      _attachments.add(AttachmentItem(content: content, iconPath: iconPath, base64Content: base64Content));
    });
  }

  void _selectTopic() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>  SelectTopicScreen(
                callingScreen: '',
                syllabusId: widget.syllabusId,
                levelId: widget.levelId!, // Pass the appropriate levelId here
              )),
    );

    if (result != null && result is Map) {
      setState(() {
           _selectedTopic = result['topicName'] ?? 'No Topic'; // Update topic name
        _selectedTopicId = result['topicId']; // Store topic ID

      });
    }
  }

  void _saveAssignment() async {
    try {
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
      final processedData = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData;
      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      final classes = data['classes'] ?? [];
      final selectedClassIds = userBox.get('selectedClassIds') ?? [];

      final classIdList = selectedClassIds.map<Map<String, String>>((classId) {
        final classIdStr = classId.toString();
        final classData = classes.firstWhere(
          (cls) => cls['id'].toString() == classIdStr,
          orElse: () => {'id': classIdStr, 'class_name': 'Unknown'},
        );
        return {
          'id': classIdStr,
          'name': (classData['class_name']?.toString() ?? 'Unknown'),
        };
      }).toList();

      if (classIdList.isEmpty && widget.classId != null) {
        final classIdStr = widget.classId!;
        final classData = classes.firstWhere(
          (cls) => cls['id'].toString() == classIdStr,
          orElse: () => {'id': classIdStr, 'class_name': _selectedClass},
        );
        classIdList.add({
          'id': classIdStr,
          'name': (classData['class_name']?.toString() ?? _selectedClass),
        });
      }

      final assignment = {
        
        'title': _titleController.text,
        'description': _descriptionController.text,
        'topic': _selectedTopic,
        'topic_id': _selectedTopicId!, // Use 0 if no topic is selected
        "syllabus_id":widget.syllabusId!,
         'creator_id': creatorId,
        'creator_name': creatorName,
        'start_date': _formatDate(_startDate),
        'end_date': _formatDate(_endDate),
         'grade': _marks.replaceAll(RegExp(r'[^0-9]'), ''),
         'classes': classIdList.isNotEmpty
            ? classIdList
            : [
                {'id': '', 'name': ''},
              ],
       
        'files': _attachments.map((attachment) => {
              'old_file': '',
              'type': _getAttachmentType(attachment.iconPath, attachment.content),
              'file_name': attachment.content,
              'file': attachment.base64Content
            }).toList(),
       
       // 'Level_id': widget.levelId,
       // 'course_id': widget.courseId,
        //'course_name': widget.courseName,
        
       
       // 'year': academicYear,
        //'term': academicTerm?.toInt(),
      };

      print('Complete Assignment Data:');

        print(const JsonEncoder.withIndent('  ').convert(assignment));
    // debugPrint('Assignment: ${jsonEncode(assignment)}');
    

      widget.onSave(assignment);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving assignment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  String _getAttachmentType(String iconPath, String content) {
    if (iconPath.contains('link')) return 'link';
    if (iconPath.contains('upload')) {
      final extension = content.split('.').last.toLowerCase();
      // Image extensions
      if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return 'photo';
      }
      // Video extensions  
      if (['mp4', 'mov', 'avi', 'wmv', 'flv', 'webm'].contains(extension)) {
      return 'video';
      }
      return 'file'; // Other file types
    }
    if (iconPath.contains('camera')) return 'photo';
    if (iconPath.contains('video')) return 'video';
    return 'other';
  }
}

class AttachmentItem {
  final String content;
  final String iconPath;
  final String? base64Content;
  AttachmentItem({required this.content, required this.iconPath, this.base64Content});
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
  }) : createdAt = createdAt ?? DateTime.now();
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:hive/hive.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:linkschool/modules/admin/e_learning/select_topic_screen.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';

// import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';

// class AdminAssignmentScreen extends StatefulWidget {
//   final Function(Map<String, dynamic>) onSave;
//   final String? classId;
//   final String? courseId;
//   final String? courseName;
//   final String? levelId;

//   const AdminAssignmentScreen({
//     super.key,
//     required this.onSave,
//     this.classId,
//     this.courseId,
//     this.courseName,
//     this.levelId,
//   });

//   @override
//   State<AdminAssignmentScreen> createState() => _AdminAssignmentScreenState();
// }

// class _AdminAssignmentScreenState extends State<AdminAssignmentScreen> {
//   String _selectedClass = 'Select classes';
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _marksController = TextEditingController();
//   final List<AttachmentItem> _attachments = [];
//   DateTime _startDate = DateTime.now();
//   DateTime _endDate = DateTime.now().add(const Duration(days: 1));
//   String _selectedTopic = 'No Topic';
//   String _marks = '200 marks';
//   late double opacity;
//   int? creatorId;
//   String? creatorName;
//   String? academicYear;
//   int? academicTerm;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final userBox = Hive.box('userData');
//       final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
//       if (storedUserData != null) {
//         final processedData = storedUserData is String
//             ? json.decode(storedUserData)
//             : storedUserData as Map<String, dynamic>;
//         final response = processedData['response'] ?? processedData;
//         final data = response['data'] ?? response;
//         final profile = data['profile'] ?? {};
//         final settings = data['settings'] ?? {};

//         setState(() {
//           creatorId = profile['staff_id'] as int?;
//           creatorName = profile['name']?.toString();
//           academicYear = settings['year']?.toString();
//           academicTerm = settings['term'] as int?;
//         });
//       }
//     } catch (e) {
//       print('Error loading user data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.primaryLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Assignment',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.primaryLight,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: CustomSaveElevatedButton(
//               onPressed: _saveAssignment,
//               text: 'Save',
//             ),
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Title:',
//                   style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
//                 ),
//                 const SizedBox(height: 8.0),
//                 TextField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     hintText: 'e.g. Dying and bleaching',
//                     hintStyle: const TextStyle(color: Colors.grey),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     contentPadding: const EdgeInsets.all(12.0),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 Text(
//                   'Description:',
//                   style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
//                 ),
//                 const SizedBox(height: 8.0),
//                 TextField(
//                   controller: _descriptionController,
//                   maxLines: 5,
//                   decoration: InputDecoration(
//                     hintText: 'Type here...',
//                     hintStyle: const TextStyle(color: Colors.grey),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     contentPadding: const EdgeInsets.all(12.0),
//                   ),
//                 ),
//                 const SizedBox(height: 32.0),
//                 Text(
//                   'Select the learning group for this syllabus: *',
//                   style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.black),
//                 ),
//                 const SizedBox(height: 16.0),
//                 _buildGroupRow(
//                   context,
//                   iconPath: 'assets/icons/e_learning/people.svg',
//                   text: _selectedClass,
//                   onTap: () async {
//                     await Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => SelectClassesDialog(
//                           onSave: (selectedClass) {
//                             setState(() {
//                               _selectedClass = selectedClass;
//                             });
//                           },
//                           levelId: widget.levelId,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: _buildAttachmentsSection(),
//                 ),
//                 Divider(color: Colors.grey.withOpacity(0.5)),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: _buildGroupRow(
//                     context,
//                     iconPath: 'assets/icons/e_learning/mark.svg',
//                     text: _marks,
//                     showEditButton: true,
//                     onTap: _showMarksDialog,
//                   ),
//                 ),
//                 _buildGroupRow(
//                   context,
//                   iconPath: 'assets/icons/e_learning/calender.svg',
//                   text: 'Start: ${_formatDate(_startDate)}',
//                   showEditButton: true,
//                   isSelected: true,
//                   onTap: _showDateRangePicker,
//                 ),
//                 _buildGroupRow(
//                   context,
//                   iconPath: 'assets/icons/e_learning/calender.svg',
//                   text: 'Due: ${_formatDate(_endDate)}',
//                   showEditButton: true,
//                   isSelected: true,
//                   onTap: _showDateRangePicker,
//                 ),
//                 _buildGroupRow(
//                   context,
//                   iconPath: 'assets/icons/e_learning/clipboard.svg',
//                   text: _selectedTopic,
//                   showEditButton: true,
//                   isSelected: true,
//                   onTap: () => _selectTopic(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGroupRow(
//     BuildContext context, {
//     required String iconPath,
//     required String text,
//     required VoidCallback onTap,
//     bool showEditButton = false,
//     bool isSelected = false,
//   }) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onTap,
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(4.0),
//                 decoration: BoxDecoration(
//                   color: AppColors.backgroundLight.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: SvgPicture.asset(
//                   iconPath,
//                   width: 32.0,
//                   height: 32.0,
//                 ),
//               ),
//               const SizedBox(width: 8.0),
//               IntrinsicWidth(
//                 child: Container(
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: isSelected ? Colors.transparent : AppColors.eLearningBtnColor2,
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 14.0),
//                       child: Text(
//                         text,
//                         style: AppTextStyles.normal600(
//                           fontSize: 16.0,
//                           color: AppColors.eLearningBtnColor1,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const Spacer(),
//               if (showEditButton)
//                 OutlinedButton(
//                   onPressed: onTap,
//                   style: OutlinedButton.styleFrom(
//                     textStyle: AppTextStyles.normal600(fontSize: 14.0, color: AppColors.backgroundLight),
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     side: const BorderSide(color: AppColors.eLearningBtnColor1),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text('Edit'),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8.0),
//         Divider(color: Colors.grey.withOpacity(0.5)),
//         const SizedBox(height: 8.0),
//       ],
//     );
//   }

//   void _showMarksDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           content: SizedBox(
//             width: 300,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Set marks',
//                   style: AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: _marksController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: 'Enter',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     CustomOutlineButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       text: 'Cancel',
//                       borderColor: AppColors.eLearningBtnColor3,
//                       textColor: AppColors.eLearningBtnColor3,
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _marks = '${_marksController.text} marks';
//                         });
//                         Navigator.of(context).pop();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.eLearningBtnColor1,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4.0),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16.0,
//                           vertical: 10.0,
//                         ),
//                       ),
//                       child: Text(
//                         'Save',
//                         style: AppTextStyles.normal600(fontSize: 16.0, color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showDateRangePicker() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return DateRangePickerDialog(
//           initialStartDate: _startDate,
//           initialEndDate: _endDate,
//           onSave: (startDate, endDate) {
//             setState(() {
//               _startDate = startDate;
//               _endDate = endDate;
//             });
//           },
//         );
//       },
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${_getDayOfWeek(date.weekday)}, ${date.day} ${_getMonth(date.month)}';
//   }

//   String _getDayOfWeek(int day) {
//     switch (day) {
//       case 1:
//         return 'Mon';
//       case 2:
//         return 'Tue';
//       case 3:
//         return 'Wed';
//       case 4:
//         return 'Thur';
//       case 5:
//         return 'Fri';
//       case 6:
//         return 'Sat';
//       case 7:
//         return 'Sun';
//       default:
//         return '';
//     }
//   }

//   String _getMonth(int month) {
//     switch (month) {
//       case 1:
//         return 'Jan';
//       case 2:
//         return 'Feb';
//       case 3:
//         return 'Mar';
//       case 4:
//         return 'Apr';
//       case 5:
//         return 'May';
//       case 6:
//         return 'Jun';
//       case 7:
//         return 'Jul';
//       case 8:
//         return 'Aug';
//       case 9:
//         return 'Sep';
//       case 10:
//         return 'Oct';
//       case 11:
//         return 'Nov';
//       case 12:
//         return 'Dec';
//       default:
//         return '';
//     }
//   }

//   Widget _buildAttachmentsSection() {
//     return GestureDetector(
//       onTap: _attachments.isEmpty ? _showAttachmentOptions : null,
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (_attachments.isEmpty)
//               Row(
//                 children: [
//                   SvgPicture.asset(
//                     'assets/icons/e_learning/link.svg',
//                     width: 24,
//                     height: 24,
//                   ),
//                   const SizedBox(width: 8.0),
//                   Text(
//                     'Add Attachment',
//                     style: AppTextStyles.normal600(fontSize: 16.0, color: AppColors.eLearningBtnColor1),
//                   ),
//                 ],
//               )
//             else
//               Column(
//                 children: [
//                   ..._attachments.asMap().entries.map((entry) {
//                     final index = entry.key;
//                     final attachment = entry.value;
//                     return _buildAttachmentItem(attachment, isFirst: index == 0);
//                   }),
//                   const SizedBox(height: 8.0),
//                   _buildAddMoreButton(),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttachmentItem(AttachmentItem attachment, {bool isFirst = false}) {
//     return Container(
//       margin: EdgeInsets.only(bottom: isFirst ? 0 : 8.0),
//       child: Row(
//         children: [
//           SvgPicture.asset(
//             attachment.iconPath,
//             width: 20,
//             height: 20,
//           ),
//           const SizedBox(width: 8.0),
//           Expanded(
//             child: Text(
//               attachment.content,
//               style: AppTextStyles.normal400(fontSize: 14.0, color: AppColors.primaryLight),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close, size: 20, color: Colors.red),
//             onPressed: () {
//               setState(() {
//                 _attachments.remove(attachment);
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddMoreButton() {
//     return GestureDetector(
//       onTap: _showAttachmentOptions,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Spacer(),
//           OutlinedButton(
//             onPressed: _showAttachmentOptions,
//             style: OutlinedButton.styleFrom(
//               textStyle: AppTextStyles.normal600(fontSize: 14.0, color: AppColors.backgroundLight),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               side: const BorderSide(color: AppColors.eLearningBtnColor1),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text('+ Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAttachmentOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Text(
//                 'Add attachment',
//                 style: AppTextStyles.normal600(
//                     fontSize: 20, color: AppColors.backgroundDark),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               _buildAttachmentOption('Insert link',
//                   'assets/icons/e_learning/link3.svg', _showInsertLinkDialog),
//               _buildAttachmentOption('Upload file',
//                   'assets/icons/e_learning/upload_file.svg', _uploadFile),
//               _buildAttachmentOption('Take photo',
//                   'assets/icons/e_learning/take_photo.svg', _takePhoto),
//               _buildAttachmentOption('Record Video',
//                   'assets/icons/e_learning/record_video.svg', _recordVideo),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAttachmentOption(
//       String text, String iconPath, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         margin: const EdgeInsets.only(bottom: 8),
//         color: AppColors.backgroundLight,
//         child: Row(
//           children: [
//             SvgPicture.asset(iconPath, width: 24, height: 24),
//             const SizedBox(width: 16),
//             Text(
//                 text,
//                 style: AppTextStyles.normal400(
//                     fontSize: 16, color: AppColors.backgroundDark)),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showInsertLinkDialog() {
//     TextEditingController linkController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             'Insert Link',
//             style: AppTextStyles.normal600(
//                 fontSize: 20, color: AppColors.backgroundDark),
//             textAlign: TextAlign.center,
//           ),
//           content: TextField(
//             controller: linkController,
//             decoration: InputDecoration(
//               fillColor: Colors.grey[100],
//               filled: true,
//               hintText: 'Enter link here',
//               prefixIcon: SvgPicture.asset(
//                 'assets/icons/e_learning/link3.svg',
//                 width: 24,
//                 height: 24,
//                 fit: BoxFit.scaleDown,
//               ),
//               border: const UnderlineInputBorder(),
//               focusedBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: AppColors.primaryLight),
//               ),
//             ),
//           ),
//           actions: [
//             CustomOutlineButton(
//               onPressed: () => Navigator.of(context).pop(),
//               text: 'Cancel',
//               borderColor: AppColors.eLearningBtnColor3.withOpacity(0.4),
//               textColor: AppColors.eLearningBtnColor3,
//             ),
//             CustomSaveElevatedButton(
//               onPressed: () {
//                 if (linkController.text.isNotEmpty) {
//                   _addAttachment(
//                       linkController.text, 'assets/icons/e_learning/link3.svg');
//                 }
//                 Navigator.of(context).pop();
//               },
//               text: 'Save',
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _uploadFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();

//     if (result != null) {
//       String fileName = result.files.single.name;
//       _addAttachment(fileName, 'assets/icons/e_learning/upload.svg');
//     }
//   }

//   Future<void> _takePhoto() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? photo = await picker.pickImage(source: ImageSource.camera);

//     if (photo != null) {
//       _addAttachment(
//           'Photo: ${photo.name}', 'assets/icons/e_learning/camera.svg');
//     }
//   }

//   Future<void> _recordVideo() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? video = await picker.pickVideo(source: ImageSource.camera);

//     if (video != null) {
//       _addAttachment(
//           'Video: ${video.name}', 'assets/icons/e_learning/video.svg');
//     }
//   }

//   void _addAttachment(String content, String iconPath) {
//     setState(() {
//       _attachments.add(AttachmentItem(content: content, iconPath: iconPath));
//     });
//   }

//   void _selectTopic() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => const SelectTopicScreen(
//                 callingScreen: '',
//               )),
//     );

//     if (result != null && result is String) {
//       setState(() {
//         _selectedTopic = result;
//       });
//     }
//   }

//   void _saveAssignment() async {
//     try {
//       final userBox = Hive.box('userData');
//       final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
//       final processedData = storedUserData is String
//           ? json.decode(storedUserData)
//           : storedUserData;
//       final response = processedData['response'] ?? processedData;
//       final data = response['data'] ?? response;
//       final classes = data['classes'] ?? [];
//       final selectedClassIds = userBox.get('selectedClassIds') ?? [];

//       final classIdList = selectedClassIds.map<Map<String, String>>((classId) {
//         final classIdStr = classId.toString();
//         final classData = classes.firstWhere(
//           (cls) => cls['id'].toString() == classIdStr,
//           orElse: () => {'id': classIdStr, 'class_name': 'Unknown'},
//         );
//         return {
//           'id': classIdStr,
//           'class_name': (classData['class_name']?.toString() ?? 'Unknown'),
//         };
//       }).toList();

//       if (classIdList.isEmpty && widget.classId != null) {
//         final classIdStr = widget.classId!;
//         final classData = classes.firstWhere(
//           (cls) => cls['id'].toString() == classIdStr,
//           orElse: () => {'id': classIdStr, 'class_name': _selectedClass},
//         );
//         classIdList.add({
//           'id': classIdStr,
//           'class_name': (classData['class_name']?.toString() ?? _selectedClass),
//         });
//       }

//       final assignment = {
//         'id': (DateTime.now().millisecondsSinceEpoch % 100),
//         'title': _titleController.text,
//         'description': _descriptionController.text,
//         'topic': _selectedTopic,
//         'topic_id': '',
//         'grade': _marks,
//         'files': _attachments.map((attachment) => {
//               'old_file': '',
//               'type': _getAttachmentType(attachment.iconPath),
//               'file': attachment.content,
//             }).toList(),
//         'classids': classIdList.isNotEmpty
//             ? classIdList
//             : [
//                 {'id': '', 'class_name': ''},
//               ],
//         'Level_id': widget.levelId,
//         'course_id': widget.courseId,
//         'course_name': widget.courseName,
//         'Start_date': _startDate.toIso8601String(),
//         'End_date': _endDate.toIso8601String(),
//         'creator_id': creatorId,
//         'Creator_name': creatorName,
//         'year': academicYear,
//         'term': academicTerm?.toInt(),
//       };

//       print('Complete Assignment Data:');
//       print(assignment);

//       widget.onSave(assignment);
//       Navigator.of(context).pop();
//     } catch (e) {
//       print('Error saving assignment: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }

//   String _getAttachmentType(String iconPath) {
//     if (iconPath.contains('link')) return 'link';
//     if (iconPath.contains('upload')) return 'file';
//     if (iconPath.contains('camera')) return 'photo';
//     if (iconPath.contains('video')) return 'video';
//     return 'other';
//   }
// }

// class AttachmentItem {
//   final String content;
//   final String iconPath;

//   AttachmentItem({required this.content, required this.iconPath});
// }

// class Assignment {
//   final String title;
//   final String description;
//   final String selectedClass;
//   final List<AttachmentItem> attachments;
//   final DateTime dueDate;
//   final String topic;
//   final String marks;
//   final DateTime createdAt;

//   Assignment({
//     required this.title,
//     required this.description,
//     required this.selectedClass,
//     required this.attachments,
//     required this.dueDate,
//     required this.topic,
//     required this.marks,
//     DateTime? createdAt,
//   }) : createdAt = createdAt ?? DateTime.now();
// }

// class DateRangePickerDialog extends StatefulWidget {
//   final DateTime initialStartDate;
//   final DateTime initialEndDate;
//   final Function(DateTime, DateTime) onSave;

//   const DateRangePickerDialog({
//     super.key,
//     required this.initialStartDate,
//     required this.initialEndDate,
//     required this.onSave,
//   });

//   @override
//   _DateRangePickerDialogState createState() => _DateRangePickerDialogState();
// }

// class _DateRangePickerDialogState extends State<DateRangePickerDialog> {
//   late DateTime _startDate;
//   late DateTime _endDate;
//   late TimeOfDay _startTime;
//   late TimeOfDay _endTime;

//   @override
//   void initState() {
//     super.initState();
//     _startDate = widget.initialStartDate;
//     _endDate = widget.initialEndDate;
//     _startTime = TimeOfDay.fromDateTime(_startDate);
//     _endTime = TimeOfDay.fromDateTime(_endDate);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: Colors.white,
//       content: SizedBox(
//         width: 300,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildDateTimeRow('Start date', _startDate, _startTime, (date) {
//               setState(() => _startDate = date);
//             }, (time) {
//               setState(() => _startTime = time);
//             }),
//             SizedBox(height: 16),
//             _buildDateTimeRow('End date', _endDate, _endTime, (date) {
//               setState(() => _endDate = date);
//             }, (time) {
//               setState(() => _endTime = time);
//             }),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 CustomOutlineButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   text: 'Cancel',
//                   borderColor: AppColors.eLearningBtnColor3,
//                   textColor: AppColors.eLearningBtnColor3,
//                 ),
//                 SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     final startDateTime = DateTime(
//                       _startDate.year,
//                       _startDate.month,
//                       _startDate.day,
//                       _startTime.hour,
//                       _startTime.minute,
//                     );
//                     final endDateTime = DateTime(
//                       _endDate.year,
//                       _endDate.month,
//                       _endDate.day,
//                       _endTime.hour,
//                       _endTime.minute,
//                     );
//                     widget.onSave(startDateTime, endDateTime);
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.eLearningBtnColor1,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4.0),
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   ),
//                   child: Text(
//                     'Save',
//                     style: AppTextStyles.normal600(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDateTimeRow(
//     String label,
//     DateTime date,
//     TimeOfDay time,
//     Function(DateTime) onDateChanged,
//     Function(TimeOfDay) onTimeChanged,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: AppTextStyles.normal600(fontSize: 16, color: Colors.black)),
//         SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: GestureDetector(
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: date,
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime.now().add(Duration(days: 365)),
//                   );
//                   if (picked != null) onDateChanged(picked);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: AppColors.backgroundLight.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     '${date.day} ${_getMonth(date.month)} ${date.year}',
//                     style: AppTextStyles.normal400(fontSize: 14, color: Colors.black),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: GestureDetector(
//                 onTap: () async {
//                   final picked = await showTimePicker(
//                     context: context,
//                     initialTime: time,
//                   );
//                   if (picked != null) onTimeChanged(picked);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: AppColors.backgroundLight.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     time.format(context),
//                     style: AppTextStyles.normal400(fontSize: 14, color: Colors.black),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   String _getMonth(int month) {
//     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return months[month - 1];
//   }
// }