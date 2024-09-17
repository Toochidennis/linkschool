import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/text_styles.dart';

// Add this new DurationPickerDialog class after the _QuestionScreenState class
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
      backgroundColor: Colors.white,
      content: Container(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set Duration',
              style: AppTextStyles.normal600(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeInput('Hours', _hours, (value) {
                  setState(() => _hours = value < 0 ? 0 : value);
                }),
                _buildTimeInput('Minutes', _minutes, (value) {
                  setState(() => _minutes = value >= 60 ? 59 : (value < 0 ? 0 : value));
                }),
              ],
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
                    final duration = Duration(hours: _hours, minutes: _minutes);
                    widget.onSave(duration);
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

  Widget _buildTimeInput(String label, int value, Function(int) onChanged) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.normal600(fontSize: 14, color: Colors.black)),
        const SizedBox(height: 8),
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextFormField(
            initialValue: value.toString().padLeft(2, '0'),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTextStyles.normal400(fontSize: 16, color: Colors.black),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (newValue) {
              int? parsedValue = int.tryParse(newValue);
              if (parsedValue != null) {
                onChanged(parsedValue);
              }
            },
          ),
        ),
      ],
    );
  }
}