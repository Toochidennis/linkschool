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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(child: Text('Grading Settings')),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: ListView(
          children: [
            buildFirstCard(),
            const SizedBox(height: Constants.gap),
            buildSecondCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryLight,
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
    );
  }

  Widget buildFirstCard() {
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
              children: const [
                Icon(Icons.edit),
                SizedBox(width: Constants.gap),
                Icon(Icons.delete, color: AppColors.deleteIcon),
              ],
            ),
            const SizedBox(height: Constants.gap),
            buildCardTextRow('Grade: A'),
            buildCardTextRow('Range: 80 - 100 marks'),
            buildCardTextRow('Remark: Excellent'),
          ],
        ),
      ),
    );
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
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  fixedSize: const Size(100, 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.borderRadius),
                  ),
                ),
                child: const Text('Add +'),
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
