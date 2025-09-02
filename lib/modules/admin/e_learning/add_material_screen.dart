import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/e_learning/select_topic_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';
import 'package:linkschool/modules/model/e-learning/material_model.dart' as custom;
import 'package:linkschool/modules/providers/admin/e_learning/material_provider.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/portal/attachmentItem.dart' show AttachmentItem;

class AddMaterialScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final String? classId;
  final String? courseId;
  final String? courseName;
  final String? levelId;
  final int? syllabusId;
  final List<Map<String, dynamic>>? syllabusClasses;
  final bool editMode;
  final custom.Material? materialToEdit;
  final int? id;
  final int? itemId;

  const AddMaterialScreen({
    super.key,
    required this.onSave,
    this.classId,
    this.courseId,
    this.courseName,
    this.levelId, 
    this.syllabusId, 
    this.syllabusClasses,
    this.editMode = false,
    this.materialToEdit, 
    this.id,
    this.itemId,
  });

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedClass = 'Select classes';
  String _selectedTopic = 'No Topic';
  int? _selectedTopicId;
  List<AttachmentItem> _attachments = [];
  late double opacity;
  int? creatorId;
  String? creatorName;
  String? academicYear;
  int? academicTerm;
  bool _isSaving = false;
  
  // Added these variables to match AdminAssignmentScreen functionality
  String? _replacingServerFileName;
  List<String> _removedServerFileNames = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _populateFormForEdit();
  }

  void _populateFormForEdit() {
    if (widget.editMode && widget.materialToEdit != null) {
      final material = widget.materialToEdit!;
      _titleController.text = material.title;
      _descriptionController.text = material.description;
      _selectedClass = material.selectedClass;
      _selectedTopic = material.topic;
      
      // Updated to match AdminAssignmentScreen structure
      _attachments = material.attachments?.map((attachment) => AttachmentItem(
        fileName: attachment.fileName,
        iconPath: attachment.iconPath,
        fileContent: attachment.fileContent,
        isExisting: true,
        originalServerFileName: attachment.fileName,
      )).toList() ?? [];
    }
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
    final materialProvider = Provider.of<MaterialProvider>(context, listen: false);
    
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
          'Add Material',
          style: AppTextStyles.normal600(
              fontSize: 24.0, color: AppColors.primaryLight),
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
              onPressed: _addMaterial,
              text: 'Save',
              isLoading: _isSaving,
            ),
          ),
        ],
      ),
      body: materialProvider.isLoading
          ? Center(child: CircularProgressIndicator()) 
          : Container(
              height: MediaQuery.of(context).size.height,
              decoration: Constants.customBoxDecoration(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Changed to match AdminAssignmentScreen
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
                          hintText: 'e.g Dying and Bleaching',
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
                        'Select the learners for this outline*:',
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
                                levelId: widget.levelId,
                                syllabusClasses: widget.syllabusClasses,
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

  // Updated to match AdminAssignmentScreen functionality
  Widget _buildAttachmentItem(AttachmentItem attachment, {bool isFirst = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isFirst ? 0 : 8.0),
      child: Row(
        children: [
          SvgPicture.asset(
            attachment.iconPath!,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              attachment.fileName!,
              style: AppTextStyles.normal400(fontSize: 14.0, color: AppColors.primaryLight),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.red),
            onPressed: () {
              setState(() {
                if (attachment.isExisting && attachment.originalServerFileName != null) {
                  _replacingServerFileName = attachment.originalServerFileName;
                  _removedServerFileNames.add(attachment.originalServerFileName!);
                }
                _attachments.remove(attachment);
              });
              if (attachment.isExisting) {
                _showAttachmentOptionsForReplacement();
              }
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
              textStyle: AppTextStyles.normal600(
                  fontSize: 14.0, color: AppColors.backgroundLight),
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
              _buildAttachmentOption(
                  'Insert link',
                  'assets/icons/e_learning/link3.svg',
                  _showInsertLinkDialog),
              _buildAttachmentOption(
                  'Upload file',
                  'assets/icons/e_learning/upload_file.svg',
                  _uploadFile),
              _buildAttachmentOption(
                  'Take photo',
                  'assets/icons/e_learning/take_photo.svg',
                  _takePhoto),
              _buildAttachmentOption(
                  'Record Video',
                  'assets/icons/e_learning/record_video.svg',
                  _recordVideo),
            ],
          ),
        );
      },
    );
  }

  // Added this method from AdminAssignmentScreen
  void _showAttachmentOptionsForReplacement() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Replace attachment',
                style: AppTextStyles.normal600(fontSize: 20, color: AppColors.backgroundDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildAttachmentOption('Upload file', 'assets/icons/e_learning/upload_file.svg', _uploadFile),
              _buildAttachmentOption('Take photo', 'assets/icons/e_learning/take_photo.svg', _takePhoto),
              _buildAttachmentOption('Record Video', 'assets/icons/e_learning/record_video.svg', _recordVideo),
              _buildAttachmentOption('Cancel', 'assets/icons/e_learning/cancel.svg', () {
                setState(() {
                  _replacingServerFileName = null;
                });
                Navigator.of(context).pop();
              }),
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
                          String fullUrl = linkController.text.replaceAll(' ', '');
                          _addAttachment(fullUrl, 'assets/icons/e_learning/link3.svg', fullUrl);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
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
        String? base64String;
        if (file.bytes != null) {
          base64String = base64Encode(file.bytes!);
        } else if (file.path != null) {
          base64String = base64Encode(await File(file.path!).readAsBytes());
        }
        _addAttachment(fileName, 'assets/icons/e_learning/upload_file.svg', base64String);
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error picking file: $e');
      CustomToaster.toastError(context, 'Error', 'Failed to pick file: $e');
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      Uint8List fileBytes = await photo.readAsBytes();
      final base64String = base64Encode(fileBytes);
      _addAttachment('Photo: ${photo.name}', 'assets/icons/e_learning/take_photo.svg', base64String);
      Navigator.of(context).pop();
    }
  }

  Future<void> _recordVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      Uint8List fileBytes = await video.readAsBytes();
      final base64String = base64Encode(fileBytes);
      _addAttachment('Video: ${video.name}', 'assets/icons/e_learning/record_video.svg', base64String);
      Navigator.of(context).pop();
    }
  }

  
  void _addAttachment(String content, String iconPath, [String? base64Content]) {
    setState(() {
      _attachments.add(AttachmentItem(
        fileName: content,
        iconPath: iconPath,
        fileContent: base64Content ?? '',
        isExisting: _replacingServerFileName != null,
        originalServerFileName: _replacingServerFileName,
      ));
      if (_replacingServerFileName != null) {
        _removedServerFileNames.remove(_replacingServerFileName);
      }
      _replacingServerFileName = null;
    });
  }

  void _selectTopic() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectTopicScreen(
          levelId: widget.levelId!,
          syllabusId: widget.syllabusId,
          courseName: widget.courseName,
          courseId: widget.courseId,
          callingScreen: '',
        ),
      ),
    );
    if (result != null && result is Map) {
      setState(() {
        _selectedTopic = result['topicName'] ?? 'No Topic';
        _selectedTopicId = result['topicId'];
      });
    }
  }

  void _addMaterial() async {
    // Validation
    if (_titleController.text.isEmpty) {
      CustomToaster.toastError(context, 'Error', 'Please enter a title');
      return;
    }
    if (_descriptionController.text.isEmpty) {
      CustomToaster.toastError(context, 'Error', 'Please enter a description');
      return;
    }
    if (_selectedClass == 'Select classes') {
      CustomToaster.toastError(context, 'Error', 'Please select at least one class');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final materialProvider = Provider.of<MaterialProvider>(context, listen: false);
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

      final Map<String, dynamic> materialPayload = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'topic': _selectedTopic,
        'topic_id': _selectedTopicId ?? 0,
        'syllabus_id': widget.syllabusId!,
        'course_id': widget.courseId,
        'course_name': widget.courseName,
        'term': academicTerm,
        'level_id': widget.levelId,
        'creator_id': creatorId,
        'creator_name': creatorName,
        'classes': classIdList.isNotEmpty
            ? classIdList
            : [
                {'id': '', 'name': ''},
              ],
        'files': _attachments.map((attachment) {
          return {
            'type': _getAttachmentType(attachment.iconPath!, attachment.fileName!),
            'file_name': attachment.fileName,
           'file': attachment.fileContent != null ? attachment.fileContent : null,
            'old_file_name': attachment.isExisting ? (attachment.originalServerFileName ?? '') : '',
          };
        }).toList(),
        if (widget.editMode) 'removed_files': _removedServerFileNames,
      };

      if (widget.editMode && widget.materialToEdit != null) {
        final id = widget.id ?? widget.itemId;
        print('Updating Material Data:');
        print(const JsonEncoder.withIndent('  ').convert(materialPayload));
        await materialProvider.UpDateMaterial(materialPayload, id!);
      } else {
        print('Creating Material Data:');
        print(const JsonEncoder.withIndent('  ').convert(materialPayload));
       await materialProvider.addMaterial(materialPayload);
      }

      widget.onSave(materialPayload);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving material: $e');
      CustomToaster.toastError(context, 'Error', 'Failed to save material: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String _getAttachmentType(String iconPath, String content) {
    if (iconPath.contains('link')) return 'url';
    if (iconPath.contains('upload')) {
      final extension = content.split('.').last.toLowerCase();
      if (extension == 'pdf') return 'pdf';
      if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) return 'image';
      if (['mp4', 'mov', 'avi', 'wmv', 'flv', 'webm'].contains(extension)) return 'video';
      return 'file'; // Default for other uploaded files
    }
    if (iconPath.contains('camera')) return 'image';
    if (iconPath.contains('video')) return 'video'; // Fixed typo from 'vidoe'
    return 'file type'; // Used for replaced files in edit mode
  }
}