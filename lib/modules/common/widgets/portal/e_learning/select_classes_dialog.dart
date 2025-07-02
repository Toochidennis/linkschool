import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_save_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class SelectClassesDialog extends StatefulWidget {
  final Function(String) onSave;
  final String? levelId; // Changed from 'leveId' to 'levelId'

  const SelectClassesDialog({super.key, required this.onSave, this.levelId});

  @override
  _SelectClassesDialogState createState() => _SelectClassesDialogState();
}

class _SelectClassesDialogState extends State<SelectClassesDialog> {
  List<dynamic> _classes = [];
  List<bool> _selectedClasses = [];
  bool _selectAll = false;
  List<int> _selectedRowIndices = [];
  late double opacity;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
  try {
    final userBox = Hive.box('userData');
    final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
    final selectedClassIds = userBox.get('selectedClassIds') as List? ?? [];
    
    if (storedUserData != null) {
      final processedData = storedUserData is String
          ? json.decode(storedUserData)
          : storedUserData;
      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      final classes = data['classes'] ?? [];

      setState(() {
        _classes = classes
            .where((cls) => 
                cls['class_name'] != null && 
                cls['class_name'].toString().trim().isNotEmpty &&
                (widget.levelId == null || cls['level_id']?.toString() == widget.levelId))
            .map((cls) => [
                  cls['id'].toString(),
                  cls['class_name'].toString().trim(),
                ])
            .toList();
            
        // Preselect classes that were previously selected
        _selectedClasses = _classes.map((cls) {
          return selectedClassIds.contains(cls[0]);
        }).toList();
        
        _selectAll = _selectedClasses.every((isSelected) => isSelected);
        if (_selectAll) {
          _selectedRowIndices = List.generate(_classes.length, (index) => index);
        } else {
          _selectedRowIndices = [];
          for (int i = 0; i < _selectedClasses.length; i++) {
            if (_selectedClasses[i]) {
              _selectedRowIndices.add(i);
            }
          }
        }
      });
    }
  } catch (e) {
    print('Error loading classes: $e');
  }
}
  // Rest of the methods remain exactly the same
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

  void _handleSave() async {
    final userBox = Hive.box('userData');
    if (_selectAll) {
      // Store all class IDs in Hive
      final classIds = _classes.map((cls) => cls[0]).toList();
      await userBox.put('selectedClassIds', classIds);
      widget.onSave('All classes selected');
    } else if (_selectedRowIndices.isNotEmpty) {
      final selectedClasses = _selectedRowIndices.map((index) => _classes[index][1]).toList();
      final selectedClassIds = _selectedRowIndices.map((index) => _classes[index][0]).toList();
      await userBox.put('selectedClassIds', selectedClassIds);
      final selectedClassesString = _selectedRowIndices.length > 1
          ? '${_selectedRowIndices.length} classes selected'
          : _classes[_selectedRowIndices[0]][1];
      widget.onSave(selectedClassesString);
    } else {
      await userBox.put('selectedClassIds', []);
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
          onPressed: () => Navigator.of(context).pop(),
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
              ),
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
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            opacity: opacity,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _classes.isEmpty
              ? const Center(child: Text('No classes available'))
              : Column(
                  children: [
                    _buildSelectAllRow(),
                    const SizedBox(height: 16.0),
                    Expanded(child: _buildClassList()),
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
          color: _selectAll ? AppColors.eLearningBtnColor2 : AppColors.backgroundLight,
          border: Border.all(color: AppColors.attBorderColor1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select all classes',
              style: AppTextStyles.normal600(
                fontSize: 16.0,
                color: AppColors.backgroundDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: _selectAll ? AppColors.attCheckColor1 : AppColors.attBgColor1,
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
          tileColor: _selectedClasses[index] ? AppColors.eLearningBtnColor2 : Colors.transparent,
          title: Text(
            _classes[index][1],
            style: AppTextStyles.normal500(
              fontSize: 16.0,
              color: AppColors.textGray,
            ),
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
              : Container(width: 24.0),
          onTap: () => _toggleRowSelection(index),
        );
      },
    );
  }
}