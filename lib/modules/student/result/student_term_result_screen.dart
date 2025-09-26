import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/student/student_result_model.dart';
import 'package:linkschool/modules/providers/student/student_result_provider.dart';
import 'package:provider/provider.dart';

class TermResultScreen extends StatefulWidget {
  final String termTitle;
  final int termInt;

  const TermResultScreen({super.key, required this.termTitle, required this.termInt});

  @override
  State<TermResultScreen> createState() => _TermResultScreenState();
}

class _TermResultScreenState extends State<TermResultScreen> {
  StudentResultModel? result;

  bool isLoading = true;
  late double opacity;

  getuserdata(){
    final userBox = Hive.box('userData');
    final storedUserData =
        userBox.get('userData') ?? userBox.get('loginResponse');
    final processedData = storedUserData is String
        ? json.decode(storedUserData)
        : storedUserData;
    final response = processedData['response'] ?? processedData;
    final data = response['data'] ?? response;
    return data;
  }
  Future<void> fetchResult() async {
    final provider = Provider.of<StudentResultProvider>(context, listen: false);
    final data = await provider.fetchStudentResult(
      getuserdata()['profile']['level_id'],
      getuserdata()['profile']['class_id'],
        getuserdata()['settings']['year'].toString(),
       getuserdata()['settings']['term'],
    );
    setState(() {
      result = data;
      isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    fetchResult();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || result == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return  Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Result',
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
        actions: [
          TextButton.icon(
            onPressed: () {
              // Implement download functionality
            },
            icon:
            const Icon(Icons.download, color: AppColors.eLearningBtnColor1),
            label: const Text(
              'Download',
              style: TextStyle(color: AppColors.eLearningBtnColor1),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTermSection('${widget.termTitle} Result'),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 32.0,
                ),
                child: const Divider(),
              ),
              _buildSubjectsTable(),
            ],
          ),
        ),
      ),
    );


}

  List<DataRow> _buildRows(StudentResultModel result) {
    final rows = <DataRow>[];

    for (final subject in result.subjects) {
      // Add each assessment as a separate row under the subject
      for (int i = 0; i < subject.assessments.length; i++) {
        final assessment = subject.assessments[i];
        rows.add(
          DataRow(
            cells: [
              DataCell(Text(i == 0 ? subject.courseName : "")), // only show subject once
              DataCell(Text(assessment.assessmentName)),
              DataCell(Text(assessment.score.toString())),
              DataCell(Text(i == 0 ? subject.total : "")),
              DataCell(Text(i == 0 ? subject.grade : "")),
              DataCell(Text(i == 0 ? subject.remark : "")),
            ],
          ),
        );
      }
    }

    return rows;
  }


  Widget _buildTermSection(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.orange, width: 2),
                bottom: BorderSide(color: Colors.orange, width: 2),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange),
              ),
            ),
          ),
          Column(
            children: [
              _buildInfoRow('Student average', result!.average),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, int value) {
    return Container(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Add this
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            "${value}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.paymentTxtColor1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTable() {

    final List<String> subjects = [

    ];
    for (SubjectResult i in result!.subjects){
        subjects.add(i.courseName);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildSubjectColumn(subjects),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:
                Row(
                  children: subjects.expand((subject) {
                    // Find the result for this subject
                    final subjectResult = result!.subjects.firstWhere(
                          (s) => s.courseName == subject,
                    );

                    if (subjectResult == null) return <Widget>[]; // no match → return empty

                    // Loop through assessments inside subjectResult
                    return subjectResult.assessments.map((assessment) {
                      return _buildScrollableColumn(
                        assessment.assessmentName,         // use assessment name
                        double.tryParse(assessment.score.toString()) ?? 0.0, // score
                        subjects,
                      );
                    }).toList();
                  }).toList(),
                ),

              ),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectColumn(List<String> subjects) {
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
              'Subject',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...subjects.map((subject) {
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
                  subject,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrollableColumn(
      String title, double width, List<String> subjects) {
    return Container(
      width: 120,
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
              textAlign: TextAlign.center,
            ),
          ),
          ...subjects.map((_) {
            return Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                '80', // Sample Data
                style: const TextStyle(fontSize: 14),
              ),
            );
          }),
        ],
      ),
    );
  }
}