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

  List<Map<String, String>> gradingList = [
    {'grade': 'A', 'range': '80 - 100', 'remark': 'Excellent'}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(child: Text('Grade Settings')),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: ListView(
          children: [
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
                  offset: const Offset(3, 5)
                ), 
              ]
            ),
            child: const Icon(Icons.save, color: AppColors.backgroundLight, ),
          ),
        ),
      ),
    );
  }

  Widget buildFirstCard(Map<String, String> item) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MouseRegion(
                  onEnter: (_) => setState(() => isHoveringEdit = true),
                  onExit: (_) => setState(() => isHoveringEdit = false),
                  child: GestureDetector(
                    onTap: () => editItem(item),
                    child: Icon(Icons.edit, color: isHoveringEdit ? Colors.blueGrey : Colors.black),
                  ),
                ),
                const SizedBox(width: Constants.gap),
                MouseRegion(
                  onEnter: (_) => setState(() => isHoveringDelete = true),
                  onExit: (_) => setState(() => isHoveringDelete = false),
                  child: GestureDetector(
                    onTap: () => deleteItem(item),
                    child: Icon(Icons.delete, color: isHoveringDelete ? Colors.redAccent : AppColors.deleteIcon),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.gap),
            buildCardTextRow('Grade: ${item['grade']}'),
            buildCardTextRow('Range: ${item['range']} marks'),
            buildCardTextRow('Remark: ${item['remark']}'),
          ],
        ),
      ),
    );
  }

  void editItem(Map<String, String> item) {
    setState(() {
      selectedGrade = item['grade'];
      selectedRange = item['range'];
      selectedRemark = item['remark'];
      gradingList.remove(item);
    });
  }

  void deleteItem(Map<String, String> item) {
    setState(() {
      gradingList.remove(item);
    });
  }

  Widget buildCardTextRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.gap),
      child: Text(
        text,
        style: AppTextStyles.cardText,
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
            buildInputRow('Grade', ['A', 'B', 'C', 'D', 'F'], selectedGrade, (value) {
              setState(() {
                selectedGrade = value;
              });
            }),
            buildInputRow('Range', ['80 - 100', '60 - 79', '50 - 69', '40 - 49', '0 - 39'], selectedRange, (value) {
              setState(() {
                selectedRange = value;
              });
            }),
            buildInputRow('Remark', ['Excellent', 'Good', 'Fair', 'Poor'], selectedRemark, (value) {
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
                    if (selectedGrade != null && selectedRange != null && selectedRemark != null) {
                      setState(() {
                        gradingList.add({
                          'grade': selectedGrade!,
                          'range': selectedRange!,
                          'remark': selectedRemark!
                        });
                        selectedGrade = null;
                        selectedRange = null;
                        selectedRemark = null;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHoveringAdd ? Colors.blueGrey : AppColors.secondaryLight,
                    fixedSize: const Size(100, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Constants.borderRadius),
                    ),
                  ),
                  child: const Text('Add +', style: AppTextStyles.normal5Light,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputRow(String label, List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.gap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.cardText,
          ),
          Container(
            width: 208,
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: Constants.padding),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cardBorder),
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
