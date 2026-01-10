import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class EditFeeOverlay extends StatefulWidget {
  final String initialFeeName;
  final bool initialIsMandatory;
  final Function(String feeName, bool isMandatory) onConfirm;

  const EditFeeOverlay({
    super.key,
    required this.initialFeeName,
    required this.initialIsMandatory,
    required this.onConfirm,
  });

  @override
  State<EditFeeOverlay> createState() => _EditFeeOverlayState();
}

class _EditFeeOverlayState extends State<EditFeeOverlay> {
  late TextEditingController _feeNameController;
  late bool _isMandatory;

  @override
  void initState() {
    super.initState();
    _feeNameController = TextEditingController(text: widget.initialFeeName);
    _isMandatory = widget.initialIsMandatory;
  }

  @override
  void dispose() {
    _feeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edit Fee Name',
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: AppColors.eLearningBtnColor1,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _feeNameController,
            decoration: const InputDecoration(
              hintText: 'Enter fee name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Switch(
                value: _isMandatory,
                onChanged: (value) {
                  setState(() {
                    _isMandatory = value;
                  });
                },
                activeColor: Colors.green,
              ),
              const Text('Required'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: AppColors.eLearningRedBtnColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.normal500(
                        fontSize: 18,
                        color: AppColors.eLearningRedBtnColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_feeNameController.text.trim().isNotEmpty) {
                      widget.onConfirm(
                          _feeNameController.text.trim(), _isMandatory);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.eLearningBtnColor5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Confirm',
                      style: AppTextStyles.normal600(
                        fontSize: 16.0,
                        color: AppColors.backgroundLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
