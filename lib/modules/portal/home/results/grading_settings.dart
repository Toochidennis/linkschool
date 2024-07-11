import 'package:flutter/material.dart';
import '../../../common/app_colors.dart';
import '../../../common/constants.dart';
import '../../../common/text_styles.dart';

class GradingSettingsScreen extends StatefulWidget {
  const GradingSettingsScreen({super.key});

  @override
  _GradingSettingsScreenState createState() => _GradingSettingsScreenState();
}

class _GradingSettingsScreenState extends State<GradingSettingsScreen> {
  String? selectedGrade;
  String? selectedRange;
  String? selectedRemark;

  bool isHoveringEdit = false;
  bool isHoveringDelete = false;
  bool isHoveringAdd = false;
  bool isHoveringSave = false;
  bool showDropdownCard = true;

  List<Map<String, String>> gradingList = [];
  int? editingIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Grade Settings',
          style: AppTextStyles.normal600(fontSize: 18.0, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: ListView(
          children: [
            // const SizedBox(height: 100),
            ...gradingList.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, String> item = entry.value;
              return buildFirstCard(item, index);
            }),
            if (showDropdownCard) buildSecondCard(),
          ],
        ),
      ),
      floatingActionButton: MouseRegion(
        onEnter: (_) => setState(() => isHoveringSave = true),
        onExit: (_) => setState(() => isHoveringSave = false),
        child: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Grade settings saved successfully')),
            );
          },
          backgroundColor: isHoveringSave ? Colors.blueGrey : AppColors.primaryLight,
          shape: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 7,
                  spreadRadius: 7,
                  offset: const Offset(3, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.save,
              color: AppColors.backgroundLight,
            ),
          ),
        ),
      ),
    );
  }

Widget buildFirstCard(Map<String, String> item, int index) {
  bool isEditing = editingIndex == index;
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
          if (!isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MouseRegion(
                  onEnter: (_) => setState(() => isHoveringEdit = true),
                  onExit: (_) => setState(() => isHoveringEdit = false),
                  child: GestureDetector(
                    onTap: () => editItem(item, index),
                    child: Icon(
                      Icons.edit,
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
                    child: Icon(
                      Icons.delete,
                      color: isHoveringDelete ? Colors.blueGrey : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: Constants.gap),
                MouseRegion(
                  onEnter: (_) => setState(() => isHoveringAdd = true),
                  onExit: (_) => setState(() => isHoveringAdd = false),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showDropdownCard = true;
                      });
                    },
                    child: Icon(
                      Icons.add,
                      color: isHoveringAdd ? Colors.blueGrey : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: Constants.gap),
          if (isEditing) ...[
            buildInputRow('Grade', ['A', 'B', 'C', 'D', 'F'], item['grade'], (value) {
              setState(() {
                item['grade'] = value!;
              });
            }),
            buildInputRow('Range', ['80 - 100', '60 - 79', '50 - 69', '40 - 49', '0 - 39'], item['range'], (value) {
              setState(() {
                item['range'] = value!;
              });
            }),
            buildInputRow('Remark', ['Excellent', 'Good', 'Fair', 'Poor'], item['remark'], (value) {
              setState(() {
                item['remark'] = value!;
              });
            }),
            const SizedBox(height: Constants.gap),
            Padding(
              padding: const EdgeInsets.only(right: 32.0, bottom: 10.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: MouseRegion(
                  onEnter: (_) => setState(() => isHoveringSave = true),
                  onExit: (_) => setState(() => isHoveringSave = false),
                  child: ElevatedButton(
                    onPressed: () => saveItem(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHoveringSave ? Colors.blueGrey : AppColors.secondaryLight,
                      fixedSize: const Size(100, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: AppTextStyles.normal5Light,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            buildCardTextRow(title: 'Grade:', score: '${item['grade']}'),
            buildCardTextRow(title: 'Range:', score: '${item['range']} marks'),
            buildCardTextRow(title: 'Remark:', score: '${item['remark']}'),
          ],
        ],
      ),
    ),
  );
}

  void editItem(Map<String, String> item, int index) {
    setState(() {
      editingIndex = index;
    });
  }

void deleteItem(Map<String, String> item) {
  setState(() {
    gradingList.remove(item);
    if (gradingList.isEmpty) {
      showDropdownCard = true;
      selectedGrade = null;
      selectedRange = null;
      selectedRemark = null;
    }
  });
}

  void saveItem(int index) {
    setState(() {
      editingIndex = null;
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
            const WidgetSpan(child: SizedBox(width: 10,)),
            TextSpan(
              text: score,
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
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 11.0,
          right: 0,
          bottom: 39.0,
          left: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInputRow('Grade', ['A', 'B', 'C', 'D', 'F'], selectedGrade,
                (value) {
              setState(() {
                selectedGrade = value;
              });
            }),
            buildInputRow(
                'Range',
                ['80 - 100', '60 - 79', '50 - 69', '40 - 49', '0 - 39'],
                selectedRange, (value) {
              setState(() {
                selectedRange = value;
              });
            }),
            buildInputRow(
                'Remark', ['Excellent', 'Good', 'Fair', 'Poor'], selectedRemark,
                (value) {
              setState(() {
                selectedRemark = value;
              });
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
              child: Align(
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
                          gradingList.add({
                            'grade': selectedGrade!,
                            'range': selectedRange!,
                            'remark': selectedRemark!,
                          });
                          selectedGrade = null;
                          selectedRange = null;
                          selectedRemark = null;
                          showDropdownCard = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHoveringAdd
                          ? Colors.blueGrey
                          : AppColors.secondaryLight,
                      fixedSize: const Size(100, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: AppTextStyles.normal5Light,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputRow(String label, List<String> options,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.gap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            label,
            style: AppTextStyles.normal600(fontSize: 12, color: AppColors.text2Light),
          ),
          Container(
            width: 208,
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: Constants.padding),
            decoration: BoxDecoration(
              color: AppColors.assessmentColor1,
              border: Border.all(color: AppColors.assessmentColor3, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                items: options
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: onChanged,
                isExpanded: true,
                hint: const Text('Select'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}