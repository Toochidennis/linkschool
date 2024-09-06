// ignore_for_file: deprecated_member_use
// import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
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
  final List<String> _classes = [
    'Basic 1A',
    'Basic 1B',
    'Basic 1C',
    'Basic 1D'
  ];
  // final Set<String> _selectedClasses = {};
  List<bool> _selectedClasses = List.generate(4, (_) => false);
  bool _selectAll = false;
  List<int> _selectedRowIndices = [];

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      // Ensure _selectedClasses always matches the number of available classes
      _selectedClasses = List.generate(_classes.length, (_) => _selectAll);

      if (_selectAll) {
        // Set indices to match the length of classes
        _selectedRowIndices = List.generate(_classes.length, (index) => index);
      } else {
        _selectedRowIndices.clear();
      }
    });
  }

  void _toggleRowSelection(int index) {
    setState(() {
      _selectedClasses[index] = !_selectedClasses[index];
      _selectAll = _selectedClasses.every((element) => element);
      if (_selectedClasses[index]) {
        _selectedRowIndices.add(index);
      } else {
        _selectedRowIndices.remove(index);
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
          style: AppTextStyles.normal600(
              fontSize: 20.0, color: AppColors.primaryLight),
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
          Expanded(child: _buildClassList()),
        ],
      ),
    );
  }

  Widget _buildSelectAllRow() {
    return InkWell(
      onTap: _toggleSelectAll,
      child: Container(
        // color: AppColors.bgGray.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
            color: _selectedRowIndices.contains(0)
                ? const Color.fromRGBO(239, 227, 255, 1)
                : AppColors.attBgColor1,
            border: Border.all(color: AppColors.attBorderColor1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select all classes',
              style: AppTextStyles.normal700(
                  fontSize: 16.0, color: AppColors.backgroundDark),
            ),
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  color: _selectAll
                      ? AppColors.attCheckColor1
                      : AppColors.attBgColor1,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.attCheckColor1)),
              child: Icon(
                Icons.check,
                color: _selectAll ? Colors.white : AppColors.attCheckColor1,
                size: 16,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildClassList() {
    return ListView.separated(
      // itemCount: _classes.length,
      itemCount: 4,
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[300],
        height: 1,
      ),
      itemBuilder: (context, index) {
        return ListTile(
          tileColor: _selectedRowIndices.contains(index)
              ? const Color.fromRGBO(239, 227, 255, 1)
              : Colors.transparent,
          title: Text(_classes[index]),
          trailing: _selectedClasses[index]
              ? const Icon(Icons.check_circle, color: AppColors.attCheckColor2)
              : null,
          onTap: () => _toggleRowSelection(index),
        );
      },
    );
  }
}
