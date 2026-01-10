import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/admin/e_learning/select_topic_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/duration_picker_dialog.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/staff/e_learning/view/staffview_question.dart';

class StaffQuestionScreen extends StatefulWidget {
  final Function(Question) onSave;
  final List<Map<String, dynamic>>? questions;
  final List<Map<String, dynamic>>? classes;
  final bool isEditing;
  final Question? question;
  final String? classId;
  final String? courseId;
  final String? levelId;
  final String? courseName;
  final int? syllabusId;
  final syllabusClasses;

  final bool editMode;
  final Question? questionToEdit;

  const StaffQuestionScreen(
      {super.key,
      required this.onSave,
      this.question,
      this.isEditing = false,
      this.classId,
      this.courseId,
      this.levelId,
      this.courseName,
      this.syllabusId,
      this.syllabusClasses,
      this.questions,
      this.classes,
      this.editMode = false,
      this.questionToEdit});

  @override
  State<StaffQuestionScreen> createState() => _StaffQuestionScreenState();
}

class _StaffQuestionScreenState extends State<StaffQuestionScreen> {
  String _selectedClass = 'Select classes';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTopic = 'No Topic';
  int? _selectedTopicId;
  Duration _selectedDuration = const Duration(seconds: 0);
  String _marks = '0 marks';
  late double opacity;
  bool isLoading = false;
  int? creatorId;
  String? creatorRole;
  String? academicYear;
  String? creatorName;
  int? academicTerm;
  final _formKey = GlobalKey<FormState>();

  // Validation states
  //bool _isMarksValid = true;
  bool _isDurationValid = true;
  bool _isDateValid = true;
  final bool _isClassValid = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _populateFormForEdit();
    if (widget.question != null) {
      _titleController.text = widget.question!.title;
      _descriptionController.text = widget.question!.description;
      _selectedClass = widget.question!.selectedClass;
      _startDate = widget.question!.startDate;
      _endDate = widget.question!.endDate;
      _selectedTopic = widget.question!.topic;
      _selectedTopicId = widget.question!.topicId;
      _selectedDuration = widget.question!.duration;
      _marks = widget.question!.marks;
    }
  }

  void _populateFormForEdit() {
    if (widget.editMode && widget.questionToEdit != null) {
      final question = widget.questionToEdit!;
      _titleController.text = question.title;
      _descriptionController.text = question.description;
      _marksController.text = question.marks;
      _endDate = question.endDate;
      _startDate = question.startDate;
      _selectedDuration = question.duration;
      _selectedTopic = question.topic;
      //  _attachments = question.attachments;
      _selectedClass = question.selectedClass;
    }
  }

  // Validation methods
  // bool _validateMarks() {
  //   final isValid = _marks != ' marks' &&
  //                  _marks.isNotEmpty &&
  //                  _marks != 'Select marks' &&
  //                  int.tryParse(_marks.replaceAll(' marks', '')) != null;
  //   setState(() => _isMarksValid = isValid);
  //   return isValid;
  // }

  bool _validateDuration() {
    final isValid = _selectedDuration.inMinutes > 0;
    setState(() => _isDurationValid = isValid);
    return isValid;
  }

  bool _validateDates() {
    final isValid = _endDate.isAfter(_startDate);
    setState(() => _isDateValid = isValid);
    return isValid;
  }

  bool _validateAll() {
    //  final marksValid = _validateMarks();
    final durationValid = _validateDuration();
    final datesValid = _validateDates();

    //  return marksValid && durationValid && datesValid && classValid;
    return durationValid && datesValid;
  }

  Future<void> _loadUserData() async {
    print('selected levellllllllllllllllllllllllllId: ${widget.levelId}');

    try {
      final userBox = Hive.box('userData');
      final storedUserData =
          userBox.get('userData') ?? userBox.get('loginResponse');
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
          creatorRole = profile['role']?.toString();
          creatorName = profile['name']?.toString();
          academicYear = settings['year']?.toString();
          academicTerm = settings['term'] as int?;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _saveQuestionAndNavigate() async {
    if (_formKey.currentState!.validate()) {
      if (!_validateAll()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please check all fields for validation errors',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (isLoading) return;
      setState(() => isLoading = true);

      try {
        final userBox = Hive.box('userData');
        final storedCourseId = userBox.get('selectedCourseId');
        final storedLevelId = userBox.get('selectedLevelId');
        final selectedClassIds = userBox.get('selectedClassIds') ?? [];
        print('Selected Class IDs: $selectedClassIds');

        final courseId = widget.courseId ??
            storedCourseId?.toString() ??
            'course_not_selected';
        final levelId =
            widget.levelId ?? storedLevelId?.toString() ?? 'level_not_selected';

        final storedUserData =
            userBox.get('userData') ?? userBox.get('loginResponse');
        if (storedUserData == null) {
          print('Error: No user data found in Hive');
          return;
        }
        final processedData = storedUserData is String
            ? json.decode(storedUserData)
            : storedUserData;
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final classes = data['classes'] ?? [];
        print(
            'Classes Data: ${const JsonEncoder.withIndent('  ').convert(classes)}');

        final classIdList =
            selectedClassIds.map<Map<String, String>>((classId) {
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
        print(
            'Class ID List: ${const JsonEncoder.withIndent('  ').convert(classIdList)}');

        final question = Question(
          topicId: _selectedTopicId ?? 0,
          title: _titleController.text,
          description: _descriptionController.text,
          selectedClass: _selectedClass,
          startDate: _startDate,
          endDate: _endDate,
          topic: _selectedTopic,
          duration: _selectedDuration,
          marks: _marks,
        );

        final questionData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'selected_class': widget.classes,
          'start_date': _startDate.toIso8601String(),
          'end_date': _endDate.toIso8601String(),
          'topic': _selectedTopic,
          "topic_id": _selectedTopicId ?? 0,
          'duration': _selectedDuration.inMinutes,
          // or .inMinutes
          'marks': int.tryParse(_marks.replaceAll(' marks', '')),
          'course_id': courseId,
          "course_name": widget.courseName!,
          'syllabus_id': widget.syllabusId!,
          'level_id': levelId,
          'class_ids': widget.classes,
          'creator_name': creatorName!,
          'term': academicTerm!,
          'creator_id': creatorId ?? 0,
        };

        print(
            'Complete Question Data: ${const JsonEncoder.withIndent('  ').convert(questionData)}');

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          widget.onSave(question);
          print('SSSSSSSSSSSSSSSSSSSSSSSSSSSSSS $_selectedDuration');

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StaffViewQuestionScreen(
                  onSaveFlag: () {
                    widget.onSave.call(question);
                  },
                  onCreation: () {
                    widget.onSave.call(question);
                  },
                  questiondata: questionData,
                  questions: widget.questions,
                  class_ids: widget.classes,
                  question: question),
            ),
          );
        }
      } catch (e) {
        print('Error saving question: $e');
        if (mounted) {
          CustomToaster.toastError(
            context,
            'Error',
            'Failed to save question: ${e.toString()}',
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } else {
      CustomToaster.toastError(
        context,
        'Validation Error',
        'Please fill all required fields',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (widget.isEditing) {
              Navigator.of(context).pop();
              return;
            }
            if (widget.editMode) {
              Navigator.of(context).pop();
              return;
            }
            if (widget.questions != null && widget.questions!.isNotEmpty) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context)
                .popUntil(ModalRoute.withName('/empty_subject'));
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          widget.isEditing ? 'Edit Question' : 'Question',
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
              onPressed: _saveQuestionAndNavigate,
              text: widget.isEditing ? 'Save' : 'Next',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title :',
                    style: AppTextStyles.normal600(
                        fontSize: 16.0, color: Colors.black),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Why is egg white?',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.all(12.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Instruction :',
                    style: AppTextStyles.normal600(
                        fontSize: 16.0, color: Colors.black),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an instruction';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32.0),
                  Text(
                    'Quiz Settings *',
                    style: AppTextStyles.normal600(
                        fontSize: 16.0, color: Colors.black),
                  ),
                  const SizedBox(height: 16.0),
                  _buildGroupRow(
                    context,
                    iconPath: 'assets/icons/e_learning/mark.svg',
                    text: _marks,
                    // isValid: _isMarksValid,
                    showEditButton: true,
                    onTap: _showMarksDialog,
                  ),
                  _buildGroupRow(
                    context,
                    iconPath: 'assets/icons/e_learning/calender.svg',
                    text:
                        'Start: ${_formatDate(_startDate)}\nDue: ${_formatDate(_endDate)}',
                    isValid: _isDateValid,
                    showEditButton: true,
                    isSelected: true,
                    onTap: _showDateRangePicker,
                  ),
                  _buildGroupRow(
                    context,
                    iconPath: 'assets/icons/e_learning/clock.svg',
                    text: _formatDuration(_selectedDuration),
                    isValid: _isDurationValid,
                    showEditButton: true,
                    onTap: _showDurationPicker,
                  ),
                  _buildGroupRow(
                    context,
                    iconPath: 'assets/icons/e_learning/clipboard.svg',
                    text: _selectedTopic,
                    showEditButton: true,
                    isSelected:
                        _selectedTopic != 'No Topic', // Add this condition
                    onTap: () => _selectTopic(),
                  ),
                ],
              ),
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
    bool isValid = true,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.transparent
                        : isValid
                            ? AppColors.eLearningBtnColor2
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                    border: isValid
                        ? null
                        : Border.all(color: Colors.red, width: 1),
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.normal600(
                      fontSize: 16.0,
                      color:
                          isValid ? AppColors.eLearningBtnColor1 : Colors.red,
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
                    style: OutlinedButton.styleFrom(
                      textStyle: AppTextStyles.normal600(
                          fontSize: 14.0, color: AppColors.backgroundLight),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      side: BorderSide(
                        color:
                            isValid ? AppColors.eLearningBtnColor1 : Colors.red,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color:
                            isValid ? AppColors.eLearningBtnColor1 : Colors.red,
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

  void _showMarksDialog() {
    _marksController.text = _marks.replaceAll(' marks', '');
    _marksController.selection = TextSelection.fromPosition(
      TextPosition(offset: _marksController.text.length),
    );
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
                  style: AppTextStyles.normal600(
                      fontSize: 18.0, color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _marksController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
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
                        if (_marksController.text.isNotEmpty &&
                            int.tryParse(_marksController.text) != null) {
                          setState(() {
                            _marks = '${_marksController.text} marks';
                            //_validateMarks();
                          });
                          Navigator.of(context).pop();
                        } else {
                          CustomToaster.toastError(
                            context,
                            'Invalid Input',
                            'Please enter a valid number',
                          );
                        }
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

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DateRangePickerDialog(
          initialStartDate: _startDate,
          initialEndDate: _endDate,
          onSave: (startDate, endDate) {
            setState(() {
              _startDate = startDate;
              _endDate = endDate;
              _validateDates();
            });
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${_getDayOfWeek(date.weekday)}, ${date.day} ${_getMonth(date.month)}';
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

  String _formatDuration(Duration duration) {
    if (duration.inHours == 0) {
      return '${duration.inMinutes} min';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    }
  }

  void _showDurationPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DurationPickerDialog(
          initialDuration: _selectedDuration,
          onSave: (duration) {
            setState(() {
              _selectedDuration = duration;
              _validateDuration();
            });
          },
        );
      },
    );
  }

  void _selectTopic() async {
    if (widget.levelId == null) {
      CustomToaster.toastError(context, 'Error', 'Level ID is missing');
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectTopicScreen(
          callingScreen: '',
          syllabusId: widget.syllabusId,
          levelId: widget.levelId, // no '!'
        ),
      ),
    );
    print(
        "Selected ${widget.syllabusId!} Class: ${widget.levelId}, Syllabus ID: ${widget.syllabusId}");
    if (result != null && result is Map) {
      setState(() {
        _selectedTopic = result['topicName'] ?? 'No Topic'; // Update topic name
        _selectedTopicId = result['topicId']; // Store topic ID
      });
    }
  }
}

class DateRangePickerDialog extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime, DateTime) onSave;

  const DateRangePickerDialog({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onSave,
  });

  @override
  _DateRangePickerDialogState createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<DateRangePickerDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isDateValid = true;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _startTime = TimeOfDay.fromDateTime(_startDate);
    _endTime = TimeOfDay.fromDateTime(_endDate);
    _validateDates();
  }

  bool _validateDates() {
    final isValid = _endDate.isAfter(_startDate) ||
        (_endDate == _startDate && _endTime.hour > _startTime.hour) ||
        (_endDate == _startDate &&
            _endTime.hour == _startTime.hour &&
            _endTime.minute > _startTime.minute);
    setState(() => _isDateValid = isValid);
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDateTimeRow('Start date', _startDate, _startTime, (date) {
              setState(() {
                _startDate = date;
                _validateDates();
              });
            }, (time) {
              setState(() {
                _startTime = time;
                _validateDates();
              });
            }),
            SizedBox(height: 16),
            _buildDateTimeRow('End date', _endDate, _endTime, (date) {
              setState(() {
                _endDate = date;
                _validateDates();
              });
            }, (time) {
              setState(() {
                _endTime = time;
                _validateDates();
              });
            }),
            if (!_isDateValid)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'End date must be after start date',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: _isDateValid ? 16 : 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomOutlineButton(
                  onPressed: () => Navigator.of(context).pop(),
                  text: 'Cancel',
                  borderColor: AppColors.eLearningBtnColor3,
                  textColor: AppColors.eLearningBtnColor3,
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isDateValid
                      ? () {
                          final startDateTime = DateTime(
                            _startDate.year,
                            _startDate.month,
                            _startDate.day,
                            _startTime.hour,
                            _startTime.minute,
                          );
                          final endDateTime = DateTime(
                            _endDate.year,
                            _endDate.month,
                            _endDate.day,
                            _endTime.hour,
                            _endTime.minute,
                          );
                          widget.onSave(startDateTime, endDateTime);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDateValid
                        ? AppColors.eLearningBtnColor1
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    'Save',
                    style: AppTextStyles.normal600(
                        fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow(
    String label,
    DateTime date,
    TimeOfDay time,
    Function(DateTime) onDateChanged,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.normal600(fontSize: 16, color: Colors.black)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null) {
                    onDateChanged(picked);
                    _validateDates();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${date.day} ${_getMonth(date.month)} ${date.year}',
                    style: AppTextStyles.normal400(
                        fontSize: 14, color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (picked != null) {
                    onTimeChanged(picked);
                    _validateDates();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    time.format(context),
                    style: AppTextStyles.normal400(
                        fontSize: 14, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
