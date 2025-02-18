import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/admin/e_learning/select_topic_screen.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/duration_picker_dialog.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/staff/e_learning/sub_screens/staff_preview_question_screen.dart';


class StaffQuestionScreen extends StatefulWidget {
  final Function(Question) onSave;
  final bool isEditing;
  final Question? question;

  const StaffQuestionScreen({
    super.key,
    required this.onSave,
    this.question,
    this.isEditing = false,
  });

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
  Duration _selectedDuration = const Duration(hours: 1);
  String _marks = '200 marks';
  late double opacity;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.question != null) {
      _titleController.text = widget.question!.title;
      _descriptionController.text = widget.question!.description;
      _selectedClass = widget.question!.selectedClass;
      _startDate = widget.question!.startDate;
      _endDate = widget.question!.endDate;
      _selectedTopic = widget.question!.topic;
      _selectedDuration = widget.question!.duration;
      _marks = widget.question!.marks;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title :',
                  style: AppTextStyles.normal600(
                      fontSize: 16.0, color: Colors.black),
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
                  'Instruction :',
                  style: AppTextStyles.normal600(
                      fontSize: 16.0, color: Colors.black),
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
                _buildGroupRow(
                  context,
                  iconPath: 'assets/icons/e_learning/mark.svg',
                  text: _marks,
                  showEditButton: true,
                  onTap: _showMarksDialog,
                ),
                _buildGroupRow(
                  context,
                  iconPath: 'assets/icons/e_learning/calender.svg',
                  text: 'Start: ${_formatDate(_startDate)}\nDue: ${_formatDate(_endDate)}',
                  showEditButton: true,
                  isSelected: true,
                  onTap: _showDateRangePicker,
                ),
                _buildGroupRow(
                  context,
                  iconPath: 'assets/icons/e_learning/clock.svg',
                  text: _formatDuration(_selectedDuration),
                  showEditButton: true,
                  onTap: _showDurationPicker,
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: (isSelected || (iconPath == 'assets/icons/e_learning/clipboard.svg' && text == _selectedTopic))
                        ? Colors.transparent
                        : AppColors.eLearningBtnColor2,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.normal600(
                      fontSize: 16.0,
                      color: AppColors.eLearningBtnColor1,
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
                      side:
                          const BorderSide(color: AppColors.eLearningBtnColor1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Edit'),
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
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
            });
          },
        );
      },
    );
  }

  void _selectTopic() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectTopicScreen(
          onTopicCreated: () {
            setState(() {
              _selectedTopic = 'No Topic';
            });
          },
          callingScreen: '',
        ),
      ),
    );
    if (result != null && result is String) {
      setState(() {
        _selectedTopic = result;
      });
    }
  }

void _saveQuestionAndNavigate() {
  final question = Question(
    title: _titleController.text,
    description: _descriptionController.text,
    selectedClass: _selectedClass,
    startDate: _startDate,
    endDate: _endDate,
    topic: _selectedTopic,
    duration: _selectedDuration,
    marks: _marks,
  );
  widget.onSave(question);
  
  // Navigate to the new preview screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StaffQuestionPreviewScreen(question: question),
    ),
  );
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

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _startTime = TimeOfDay.fromDateTime(_startDate);
    _endTime = TimeOfDay.fromDateTime(_endDate);
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
              setState(() => _startDate = date);
            }, (time) {
              setState(() => _startTime = time);
            }),
            const SizedBox(height: 16),
            _buildDateTimeRow('End date', _endDate, _endTime, (date) {
              setState(() => _endDate = date);
            }, (time) {
              setState(() => _endTime = time);
            }),
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.eLearningBtnColor1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    'Save',
                    style: AppTextStyles.normal600(fontSize: 16, color: Colors.white),
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
        Text(label, style: AppTextStyles.normal600(fontSize: 16, color: Colors.black)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) onDateChanged(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${date.day} ${_getMonth(date.month)} ${date.year}',
                    style: AppTextStyles.normal400(fontSize: 14, color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (picked != null) onTimeChanged(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    time.format(context),
                    style: AppTextStyles.normal400(fontSize: 14, color: Colors.black),
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}