import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class SelectTeachersDialog extends StatefulWidget {
  final Function(String) onSave;

  const SelectTeachersDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  _SelectTeachersDialogState createState() => _SelectTeachersDialogState();
}

class _SelectTeachersDialogState extends State<SelectTeachersDialog> {
  final List<String> _teachers = ['John Doe', 'Jane Smith', 'Michael Johnson', 'Emily Davis'];
  final Set<String> _selectedTeachers = {};
  bool _selectAll = false;

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedTeachers.addAll(_teachers);
      } else {
        _selectedTeachers.clear();
      }
    });
  }

  void _toggleSelectTeacher(String teacherName) {
    setState(() {
      if (_selectedTeachers.contains(teacherName)) {
        _selectedTeachers.remove(teacherName);
      } else {
        _selectedTeachers.add(teacherName);
      }
    });
  }

  void _handleSave() {
    if (_selectedTeachers.isNotEmpty) {
      final selectedTeacherString = _selectedTeachers.length > 1
          ? '${_selectedTeachers.length} teachers selected'
          : _selectedTeachers.join(', ');
      widget.onSave(selectedTeacherString);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select teacher',
          style: AppTextStyles.normal600(fontSize: 20.0, color: AppColors.backgroundDark),
        ),
        backgroundColor: AppColors.backgroundLight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text(
              'Save',
              style: AppTextStyles.normal600(fontSize: 16.0, color: AppColors.backgroundDark),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSelectAllRow(),
          Divider(color: Colors.grey.withOpacity(0.5)),
          Expanded(child: _buildTeacherList()),
        ],
      ),
    );
  }

  Widget _buildSelectAllRow() {
    return InkWell(
      onTap: _toggleSelectAll,
      child: Container(
        color: AppColors.eLearningBtnColor2,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select all teachers',
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

  Widget _buildTeacherList() {
    return ListView.separated(
      itemCount: _teachers.length,
      separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.5)),
      itemBuilder: (context, index) {
        final teacherName = _teachers[index];
        final isSelected = _selectedTeachers.contains(teacherName);
        return InkWell(
          onTap: () => _toggleSelectTeacher(teacherName),
          child: Container(
            color: isSelected ? AppColors.eLearningBtnColor2 : null,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  teacherName,
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
