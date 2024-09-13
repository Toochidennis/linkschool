import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/buttons/custom_outline_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/e_learning/select_classes_dialog.dart';
import 'package:linkschool/modules/portal/e-learning/select_topic_screen.dart';

class QuestionScreen extends StatefulWidget {
  final Function(Question) onSave;

  const QuestionScreen({Key? key, required this.onSave}) : super(key: key);
  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
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
          'Question',
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
              onPressed: _saveQuestion,
              text: 'Save',
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
                  'Title:',
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
                  'Description:',
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

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.eLearningBtnColor1,
            colorScheme: ColorScheme.light(primary: AppColors.eLearningBtnColor1),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
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

  void _saveQuestion() {
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
    Navigator.of(context).pop();
  }
}

class DurationPickerDialog extends StatefulWidget {
  final Duration initialDuration;
  final Function(Duration) onSave;

  const DurationPickerDialog({
    Key? key,
    required this.initialDuration,
    required this.onSave,
  }) : super(key: key);

  @override
  _DurationPickerDialogState createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialDuration.inHours;
    _minutes = widget.initialDuration.inMinutes % 60;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 328,
        height: 256,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ENTER TIME',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeInput(
                      'Hour',
                      _hours,
                      (value) => setState(() =>
                          _hours = value < 0 ? 0 : value)),
                  _buildTimeInput(
                      'Minute',
                      _minutes,
                      (value) => setState(() => _minutes =
                          value >= 60 ? 59 : (value < 0 ? 0 : value))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomOutlineButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Cancel',
                    borderColor: AppColors.eLearningBtnColor3,
                    textColor: AppColors.eLearningBtnColor3
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final duration = Duration(
                        hours: _hours,
                        minutes: _minutes,
                      );
                      widget.onSave(duration);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eLearningBtnColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0
                      )
                    ),
                    child: Text(
                      'Save',
                      style: AppTextStyles.normal600(fontSize: 16.0, color: AppColors.backgroundLight),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInput(String label, int value, Function(int) onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: TextFormField(
              initialValue: value.toString().padLeft(2, '0'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (newValue) {
                int? parsedValue = int.tryParse(newValue);
                if (parsedValue != null) {
                  onChanged(parsedValue);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}


class Question {
  final String title;
  final String description;
  final String selectedClass;
  final DateTime startDate;
  final DateTime endDate;
  final String topic;
  final Duration duration;
  final String marks;
  final DateTime createdAt;

  Question({
    required this.title,
    required this.description,
    required this.selectedClass,
    required this.startDate,
    required this.endDate,
    required this.topic,
    required this.duration,
    required this.marks,

    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();
}