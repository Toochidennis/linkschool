// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../common/app_colors.dart';
import '../../../common/constants.dart';
import '../../../common/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradingSettingsScreen extends StatefulWidget {
  const GradingSettingsScreen({super.key});

  @override
  _GradingSettingsScreenState createState() => _GradingSettingsScreenState();
}

class _GradingSettingsScreenState extends State<GradingSettingsScreen> {
  String? selectedGrade;
  String? selectedRange;
  String? selectedRemark;
  String? focusedField;

  bool isHoveringEdit = false;
  bool isHoveringDelete = false;
  bool isHoveringAdd = false;
  bool isHoveringSave = false;
  

  Map<String, bool> editingStates = {};
  Map<String, TextEditingController> editingControllers = {};

  @override
  void initState() {
    super.initState();
    initializeControllers();
  }

  void initializeControllers() {
    for (var item in gradingList) {
      String itemId = item['id'] ?? '';
      if (itemId.isNotEmpty) {
        editingControllers['$itemId-Grade'] =
            TextEditingController(text: item['grade']);
        editingControllers['$itemId-Range'] =
            TextEditingController(text: item['range']);
        editingControllers['$itemId-Remark'] =
            TextEditingController(text: item['remark']);
      }
    }
  }

  @override
  void dispose() {
    // Dispose of controllers
    editingControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  List<Map<String, String>> gradingList = [
    {'id': '1', 'grade': 'A', 'range': '80 - 100', 'remark': 'Excellent'}
  ];

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
          'Grade Settings',
          style: AppTextStyles.normal600(
              fontSize: 24.0, color: Colors.black), // Increased font size
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: ListView(
          children: [
            const Text(
              'Add and update grade details',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Added margin
            ...gradingList.map((item) => buildFirstCard(item)).toList(),
            const SizedBox(height: Constants.gap),
            buildSecondCard(),
          ],
        ),
      ),
      floatingActionButton: MouseRegion(
        onEnter: (_) => setState(() => isHoveringSave = true),
        onExit: (_) => setState(() => isHoveringSave = false),
        child: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Grade settings saved successfully')),
            );
          },
          backgroundColor:
              isHoveringSave ? Colors.blueGrey : AppColors.primaryLight,
          shape: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 7,
                      spreadRadius: 7,
                      offset: const Offset(3, 5)),
                ]),
            child: const Icon(
              Icons.save,
              color: AppColors.backgroundLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFirstCard(Map<String, String> item) {
    String itemId = item['id']!;
    bool isEditing = editingStates[itemId] ?? false;

    if (itemId.isEmpty) {
      return const SizedBox(); // Return an empty widget if id is missing
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MouseRegion(
                  onEnter: (_) => setState(() => isHoveringEdit = true),
                  onExit: (_) => setState(() => isHoveringEdit = false),
                  child: GestureDetector(
                    onTap: () =>
                        isEditing ? saveItem(itemId) : editItem(itemId),
                    child: SvgPicture.asset(
                      isEditing
                          ? 'assets/icons/result/check.svg'
                          : 'assets/icons/result/edit.svg',
                      color: isHoveringEdit ? Colors.blueGrey : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: Constants.gap),
                MouseRegion(
                  onEnter: (_) => setState(() => isHoveringDelete = true),
                  onExit: (_) => setState(() => isHoveringDelete = false),
                  child: GestureDetector(
                    onTap: () => deleteItem(item),
                    child: SvgPicture.asset(
                      'assets/icons/result/delete.svg',
                      color: isHoveringDelete ? Colors.blueGrey : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.gap),
            buildEditableRow('Grade:', itemId, isEditing),
            buildEditableRow('Range:', itemId, isEditing),
            buildEditableRow('Remark:', itemId, isEditing),
          ],
        ),
      ),
    );
  }

  Widget buildEditableRow(String title, String itemId, bool isEditing) {
    String key = '$itemId-${title.replaceAll(':', '')}';
    TextEditingController? controller = editingControllers[key];

    if (controller == null) {
      return const SizedBox(); // Return an empty widget if controller is missing
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.gap),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.normal500(
              fontSize: 12.0,
              color: AppColors.assessmentColor2,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    style: AppTextStyles.normal500(
                      fontSize: 16.0,
                      color: AppColors.backgroundDark,
                    ),
                  )
                : Text(
                    controller.text,
                    style: AppTextStyles.normal500(
                      fontSize: 16.0,
                      color: AppColors.backgroundDark,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void editItem(String itemId) {
    setState(() {
      editingStates[itemId] = true;
    });
  }

  void deleteItem(Map<String, String> item) {
    setState(() {
      gradingList.remove(item);
      String itemId = item['id']!;
      editingControllers.remove('$itemId-Grade');
      editingControllers.remove('$itemId-Range');
      editingControllers.remove('$itemId-Remark');
      editingStates.remove(itemId);
    });
  }

  void saveItem(String itemId) {
    setState(() {
      editingStates[itemId] = false;
      int index = gradingList.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        gradingList[index]['grade'] = editingControllers['$itemId-Grade']!.text;
        gradingList[index]['range'] = editingControllers['$itemId-Range']!.text;
        gradingList[index]['remark'] =
            editingControllers['$itemId-Remark']!.text;
      }
    });
  }

  Widget buildCardTextRow({required String title, required String score}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.gap),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: title,
              style: AppTextStyles.normal500(
                fontSize: 12.0,
                color: AppColors.assessmentColor2,
              ),
            ),
            TextSpan(
              text: '  $score',
              style: AppTextStyles.normal500(
                fontSize: 16.0,
                color: AppColors.backgroundDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSecondCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInputField('Grade', selectedGrade, (value) {
              setState(() {
                selectedGrade = value;
              });
            }),
            buildInputField('Range', selectedRange, (value) {
              setState(() {
                selectedRange = value;
              });
            }),
            buildInputField('Remark', selectedRemark, (value) {
              setState(() {
                selectedRemark = value;
              });
            }),
            const SizedBox(height: Constants.gap),
            Align(
              alignment: Alignment.bottomRight,
              child: MouseRegion(
                onEnter: (_) => setState(() => isHoveringAdd = true),
                onExit: (_) => setState(() => isHoveringAdd = false),
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedGrade != null &&
                        selectedRange != null &&
                        selectedRemark != null) {
                      setState(() {
                        String newId = (gradingList.length + 1).toString();
                        Map<String, String> newItem = {
                          'id': newId,
                          'grade': selectedGrade!,
                          'range': selectedRange!,
                          'remark': selectedRemark!
                        };
                        gradingList.add(newItem);

                        // Initialize controllers for the new item
                        editingControllers['$newId-Grade'] =
                            TextEditingController(text: selectedGrade);
                        editingControllers['$newId-Range'] =
                            TextEditingController(text: selectedRange);
                        editingControllers['$newId-Remark'] =
                            TextEditingController(text: selectedRemark);

                        selectedGrade = null;
                        selectedRange = null;
                        selectedRemark = null;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHoveringAdd
                        ? Colors.blueGrey
                        : AppColors.secondaryLight,
                    fixedSize: const Size(100, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Constants.borderRadius),
                    ),
                  ),
                  child: const Text(
                    'Add +',
                    style: AppTextStyles.normal5Light,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(
      String label, String? value, ValueChanged<String> onChanged) {
        final FocusNode focusNode = FocusNode();
          focusNode.addListener(() {
    setState(() {
      focusedField = focusNode.hasFocus ? label : null;
    });
  });
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.gap),
      child: Row(
        children: [
          SizedBox(
            width: 50, // Adjust this width as needed
            child: Text(
              label,
              style: AppTextStyles.normal600(fontSize: 12, color: Colors.black),
            ),
          ),
          const SizedBox(
              width: 16), // Horizontal margin between label and input field
          Expanded(
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                focusNode: focusNode,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                controller: TextEditingController(text: value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
