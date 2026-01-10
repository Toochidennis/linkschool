import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class StaffInputResultScreen extends StatefulWidget {
  const StaffInputResultScreen({super.key});

  @override
  State<StaffInputResultScreen> createState() => _StaffInputResultScreenState();
}

class _StaffInputResultScreenState extends State<StaffInputResultScreen> {
  late double opacity;

  // Sample data for rows
  final List<Map<String, dynamic>> studentData = [
    {
      "name": "Toochi Dennis",
      "attendance": "90",
      "assessment": "85",
      "exam": "75",
      "total": "250",
      "grade": "A"
    },
    {
      "name": "Toochi Joe",
      "attendance": "88",
      "assessment": "80",
      "exam": "78",
      "total": "246",
      "grade": "B"
    },
    {
      "name": "Ifeanyi Dennis",
      "attendance": "92",
      "assessment": "83",
      "exam": "88",
      "total": "263",
      "grade": "A"
    },
    {
      "name": "Johnson Kenny",
      "attendance": "80",
      "assessment": "75",
      "exam": "70",
      "total": "225",
      "grade": "C"
    },
    // Add more students as needed
  ];

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Civic Education Result',
          style: AppTextStyles.normal600(
            fontSize: 18.0,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
          ),
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
      ),
      body: Container(
        decoration:
            Constants.customBoxDecoration(context), // Full screen decoration
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _buildSubjectsTable(),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsTable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildSubjectColumn(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildEditableColumn('Attendance', 'attendance'),
                    _buildEditableColumn('Assessments', 'assessment'),
                    _buildEditableColumn('Examination', 'exam'),
                    _buildEditableColumn('Total', 'total'),
                    _buildGradeColumn(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectColumn() {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              'Student Name',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...studentData.map((data) {
            return Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  data["name"],
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEditableColumn(String title, String key) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.eLearningBtnColor1,
              border: Border(
                left: const BorderSide(color: Colors.white),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...studentData.map((data) {
            return Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: TextEditingController(text: data[key].toString()),
                onChanged: (value) {
                  data[key] = value; // Update the value dynamically
                },
                textAlign: TextAlign.center,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGradeColumn() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.eLearningBtnColor1,
              border: Border(
                left: const BorderSide(color: Colors.white),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: const Text(
              'Grade',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...studentData.map((data) {
            return Container(
              height: 50,
              alignment: Alignment.center,
              child: DropdownButton<String>(
                value: data["grade"],
                onChanged: (value) {
                  setState(() {
                    data["grade"] = value!;
                  });
                },
                items: const ['A', 'B', 'C', 'D', 'F']
                    .map((grade) => DropdownMenuItem(
                          value: grade,
                          child: Text(grade),
                        ))
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Implement save logic here
            print(studentData);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.eLearningBtnColor1,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: AppColors.backgroundLight),
          ),
        ),
      ),
    );
  }
}
