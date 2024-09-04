// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class SelectClassesDialog extends StatefulWidget {
  final Function(String) onSave;

  const SelectClassesDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  _SelectClassesDialogState createState() => _SelectClassesDialogState();
}

class _SelectClassesDialogState extends State<SelectClassesDialog> {
  final List<String> _classes = ['Basic 1A', 'Basic 1B', 'Basic 1C', 'Basic 1D'];
  final Set<String> _selectedClasses = {};
  bool _selectAll = false;

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedClasses.addAll(_classes);
      } else {
        _selectedClasses.clear();
      }
    });
  }

  void _toggleSelectClass(String className) {
    setState(() {
      if (_selectedClasses.contains(className)) {
        _selectedClasses.remove(className);
      } else {
        _selectedClasses.add(className);
      }
    });
  }

  void _handleSave() {
    if (_selectedClasses.isNotEmpty) {
      final selectedClassString = _selectedClasses.length > 1
          ? '${_selectedClasses.length} classes selected'
          : _selectedClasses.join(', ');
      widget.onSave(selectedClassString);
    }
    Navigator.of(context).pop();
  }

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
          'Select class',
          style: AppTextStyles.normal600(fontSize: 20.0, color: AppColors.backgroundDark),
        ),
        backgroundColor: AppColors.backgroundLight,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CustomSaveElevatedButton(
              onPressed: _handleSave,
              text: 'Save',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSelectAllRow(),
          Divider(color: Colors.grey.withOpacity(0.5)),
          Expanded(child: _buildClassList()),
        ],
      ),
    );
  }

  Widget _buildSelectAllRow() {
    return InkWell(
      onTap: _toggleSelectAll,
      child: Container(
        color: AppColors.bgGray.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select all classes',
              style: AppTextStyles.normal600(fontSize: 16.0, color: AppColors.backgroundDark),
            ),
            SvgPicture.asset(
              'assets/icons/e_learning/check_icon.svg',
              color: _selectAll ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassList() {
    return ListView.separated(
      itemCount: _classes.length,
      separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.5)),
      itemBuilder: (context, index) {
        final className = _classes[index];
        final isSelected = _selectedClasses.contains(className);
        return InkWell(
          onTap: () => _toggleSelectClass(className),
          child: Container(
            color: isSelected ? AppColors.eLearningBtnColor2 : null,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  className,
                  style: AppTextStyles.normal600(fontSize: 16.0, color: AppColors.backgroundDark),
                ),
                SvgPicture.asset(
                  'assets/icons/e_learning/check_icon.svg',
                  color: isSelected ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
