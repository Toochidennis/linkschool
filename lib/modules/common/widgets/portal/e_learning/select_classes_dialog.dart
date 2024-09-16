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
  List<bool> _selectedClasses = List.generate(4, (_) => false);
  bool _selectAll = false;
  List<int> _selectedRowIndices = [];
  late double opacity;

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedClasses = List.generate(_classes.length, (_) => _selectAll);
      if (_selectAll) {
        _selectedRowIndices = List.generate(_classes.length, (index) => index);
      } else {
        _selectedRowIndices.clear();
      }
    });
  }

  void _toggleRowSelection(int index) {
    setState(() {
      _selectedClasses[index] = !_selectedClasses[index];
      if (_selectedClasses[index]) {
        _selectedRowIndices.add(index);
      } else {
        _selectedRowIndices.remove(index);
      }
      _selectAll = _selectedClasses.every((element) => element);
    });
  }

  void _handleSave() {
    if (_selectAll) {
      widget.onSave('All classes selected');
    } else if (_selectedRowIndices.isNotEmpty) {
      final selectedClassesString = _selectedRowIndices.length > 1
          ? '${_selectedRowIndices.length} classes selected'
          : _classes[_selectedRowIndices[0]];
      widget.onSave(selectedClassesString);
    } else {
      widget.onSave('Select classes');
    }
    Navigator.of(context).pop();
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
          'Select class',
          style: AppTextStyles.normal600(
              fontSize: 20.0, color: AppColors.primaryLight),
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
              onPressed: _handleSave,
              text: 'Save',
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context)
            .size
            .height, 
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            opacity: opacity
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSelectAllRow(),
              const SizedBox(height: 16.0),
              Expanded(
                  child:
                      _buildClassList()), // Ensure ListView takes up remaining space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectAllRow() {
    return InkWell(
      onTap: _toggleSelectAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
            color: _selectAll
                ? AppColors.eLearningBtnColor2
                : AppColors.backgroundLight,
            border: Border.all(color: AppColors.attBorderColor1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select all classes',
              style: AppTextStyles.normal600(
                  fontSize: 16.0, color: AppColors.backgroundDark),
            ),
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: _selectAll
                    ? AppColors.attCheckColor1
                    : AppColors.attBgColor1,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.attCheckColor1),
              ),
              child: Icon(
                Icons.check,
                color: _selectAll ? Colors.white : AppColors.attCheckColor1,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassList() {
    return ListView.separated(
      itemCount: _classes.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[300],
        height: 1,
      ),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          tileColor: _selectedClasses[index]
              ? AppColors.eLearningBtnColor2
              : Colors.transparent,
          title: Text(
            _classes[index],
            style: AppTextStyles.normal500(
                fontSize: 16.0, color: AppColors.textGray),
          ),
          trailing: _selectedClasses[index]
              ? Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12, 
                  ),
                )
              : Container(
                  width: 24.0, 
                ),
          onTap: () => _toggleRowSelection(index),
        );
      },
    );
  }
}
