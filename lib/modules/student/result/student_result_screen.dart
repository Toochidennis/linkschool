import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button_2.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
import 'package:linkschool/modules/student/home/new_post_dialog.dart';
import 'package:linkschool/modules/student/result/student_annual_result_screen.dart';
import 'package:linkschool/modules/student/result/student_single_term_result_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/providers/admin/student_provider.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class StudentResultScreen extends StatefulWidget {
  final String studentName;
  final String className;

  const StudentResultScreen({
    super.key,
    required this.studentName,
    required this.className,
  });

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
  late double opacity;
  Map<String, dynamic>? studentData;
  String? studentId;
  String? classId;
  String? levelId;
  String? year;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (studentId != null) {
        _fetchStudentResultTerms();
      }
    });
  }

  void _loadStudentData() {
    final userBox = Hive.box('userData');
    final loginData = userBox.get('userData') ?? userBox.get('loginResponse');
    
    if (loginData != null) {
      Map<String, dynamic> processedData = loginData is String 
          ? json.decode(loginData) 
          : loginData;
      
      final response = processedData['response'] ?? processedData;
      final data = response['data'] ?? response;
      final profile = data['profile'] ?? {};
      final settings = data['settings'] ?? {};
      
      setState(() {
        studentData = data;
        studentId = profile['id']?.toString() ?? profile['staff_id']?.toString();
        classId = profile['class_id']?.toString();
        levelId = profile['level_id']?.toString();
        year = settings['year']?.toString();
      });
      
      print('Loaded student data: studentId=$studentId, classId=$classId, levelId=$levelId, year=$year');
    }
  }

  void _fetchStudentResultTerms() {
    if (studentId != null) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      studentProvider.fetchStudentResultTerms(int.parse(studentId!));
    }
  }

  void _showNewPostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewPostDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: CustomStudentAppBar(
        title: 'Welcome',
        subtitle: widget.studentName,
        showNotification: true,
        onNotificationTap: () {},
      ),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: SingleChildScrollView(
            child: Consumer<StudentProvider>(
              builder: (context, studentProvider, child) {
                if (studentProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (studentProvider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${studentProvider.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final terms = studentProvider.studentTerms;
                final processedTerms = <String, List<Map<String, dynamic>>>{};
                List<Map<String, dynamic>> chartData = [];

                if (terms != null && terms.isNotEmpty) {
                  terms.forEach((year, yearData) {
                    if (yearData is Map && yearData.containsKey('terms')) {
                      processedTerms[year] = [];
                      final termsList = yearData['terms'] as List;
                      for (var termData in termsList) {
                        final term = termData['term'] ?? termData['term_value'];
                        final termName = termData['term_name'] ?? 'Unknown Term';
                        final averageScore = double.tryParse(termData['average_score'].toString()) ?? 0.0;
                        final percent = averageScore / 100.0;

                        processedTerms[year]!.add({
                          'term': term,
                          'termName': termName,
                          'percent': percent,
                          'averageScore': averageScore,
                        });

                        chartData.add({
                          'term': term,
                          'termName': termName,
                          'averageScore': averageScore,
                          'year': year,
                        });
                      }
                    }
                  });
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display all sessions and terms
                      if (processedTerms.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: Text('No academic records available'),
                          ),
                        )
                      else
                        ..._buildAllSessions(processedTerms, context),
                      
                      const SizedBox(height: 30),
                      
                      CustomOutlineButton2(
                        onPressed: () {
                          if (studentId != null && classId != null && levelId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentAnnualResultScreen(
                                  studentId: int.parse(studentId!),
                                  classId: classId!,
                                  levelId: levelId!,
                                ),
                              ),
                            );
                          }
                        },
                        text: 'See annual result',
                        borderColor: AppColors.paymentTxtColor1,
                        textColor: AppColors.paymentTxtColor1,
                        fontSize: 18,
                        borderRadius: 10.0,
                        buttonHeight: 48,
                      ),
                      
                      const SizedBox(height: 60),
                      
                      Text(
                        'Session average chart',
                        style: AppTextStyles.normal700(
                          fontSize: 18,
                          color: AppColors.paymentTxtColor1,
                        ),
                      ),
                      
                      const SizedBox(height: 40.0),
                      
                      _buildChart(chartData),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAllSessions(
      Map<String, List<Map<String, dynamic>>> processedTerms,
      BuildContext context) {
    return processedTerms.entries.map((entry) {
      final year = entry.key;
      final terms = entry.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$year/${int.parse(year) + 1} Session',
            style: AppTextStyles.normal700(
                fontSize: 18, color: AppColors.paymentTxtColor1),
          ),
          const SizedBox(height: 10),
          ...terms.map((termData) {
            Color indicatorColor;
            switch (termData['termName']) {
              case 'First Term':
                indicatorColor = AppColors.paymentTxtColor1;
                break;
              case 'Second Term':
                indicatorColor = AppColors.videoColor4;
                break;
              default:
                indicatorColor = AppColors.exploreButton3Light;
            }

            return GestureDetector(
              onTap: () {
                if (studentId != null && classId != null && levelId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentSingleTermResultScreen(
                        studentId: int.parse(studentId!),
                        termId: termData['term'],
                        classId: classId!,
                        year: year,
                        levelId: levelId!,
                        termName: termData['termName'],
                      ),
                    ),
                  );
                }
              },
              child: _buildTermRow(
                termData['termName'],
                termData['percent'],
                indicatorColor,
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }

  Widget _buildTermRow(String term, double percent, Color indicatorColor) {
    return Container(
      width: double.infinity,
      height: 75,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderGray, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              term,
              style: AppTextStyles.normal700(fontSize: 14, color: Colors.black),
            ),
            CircularPercentIndicator(
              radius: 20.0,
              lineWidth: 4.92,
              percent: percent,
              center: Text(
                "${(percent * 100).toInt()}%",
                style: AppTextStyles.normal600(fontSize: 10, color: Colors.black),
              ),
              progressColor: indicatorColor,
              backgroundColor: Colors.transparent,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) {
      return const Center(
        child: Text('No chart data available'),
      );
    }

    return SizedBox(
      height: 200.0,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTitles,
                reservedSize: 38,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: AppTextStyles.normal400(
                      color: Colors.black, fontSize: 12),
                ),
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.black.withOpacity(0.3),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: chartData
              .map((data) {
                final termValue = data['term'] ?? data['term_value'];
                if (termValue == null) return null;
                final termIndex = (termValue as int) - 1;
                final averageScore = data['averageScore'] as double;
                Color barColor = AppColors.paymentTxtColor1;
                if (termIndex == 1) {
                  barColor = AppColors.videoColor4;
                } else if (termIndex == 2) {
                  barColor = AppColors.exploreButton3Light;
                }

                return BarChartGroupData(
                  x: termIndex,
                  barRods: [
                    BarChartRodData(
                      toY: averageScore,
                      color: barColor,
                      width: 60,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              })
              .where((e) => e != null)
              .cast<BarChartGroupData>()
              .toList(),
          groupsSpace: 0,
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '1st Term';
        break;
      case 1:
        text = '2nd Term';
        break;
      case 2:
        text = '3rd Term';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide, // pass just this instead of `meta`
      space: 4.0,
      child: Text(
        text,
        style: AppTextStyles.normal400(fontSize: 12, color: Colors.black),
      ),
    );

  }
}




// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_outline_button_2.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/widgets/portal/student/student_customized_appbar.dart';
// import 'package:linkschool/modules/student/home/new_post_dialog.dart';
// import 'package:linkschool/modules/student/result/student_annual_result_screen.dart';
// import 'package:linkschool/modules/student/result/student_term_result_screen.dart';

// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:fl_chart/fl_chart.dart';

// class StudentResultScreen extends StatefulWidget {
//   final String studentName;
//   final String className;
//   const StudentResultScreen({
//     super.key,
//     required this.studentName,
//     required this.className,
//   });

//   @override
//   State<StudentResultScreen> createState() => _StudentResultScreenState();
// }

// class _StudentResultScreenState extends State<StudentResultScreen> {
//   late double opacity;

//   void _showNewPostDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return NewPostDialog();
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: CustomStudentAppBar(
//         title: 'Welcome',
//         subtitle: 'Tochukwu',
//         showNotification: true,
//         // showPostInput: true,
//         onNotificationTap: () {},
//         // onPostTap: _showNewPostDialog,
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 100),
//           child: SingleChildScrollView(
//             child: Stack(children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '2015/2016 Session',
//                       style: AppTextStyles.normal700(
//                           fontSize: 18, color: AppColors.paymentTxtColor1),
//                     ),
//                     const SizedBox(height: 10),
//                     _buildTermRow(
//                         'First Term', 0.75, AppColors.paymentTxtColor1),
//                     _buildTermRow('Second Term', 0.75, AppColors.videoColor4),
//                     _buildTermRow(
//                         'Third Term', 0.75, AppColors.exploreButton3Light),
//                     const SizedBox(height: 30),
//                     CustomOutlineButton2(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 const StudentAnnualResultScreen(
//                               studentId: 292, // Use widget.studentId or fallback to student.id
//                               classId: "66", // Fallback for testing
//                               levelId: "",
//                             ),
//                           ),
//                         );
//                       },
//                       text: 'See annual result',
//                       borderColor: AppColors.paymentTxtColor1,
//                       textColor: AppColors.paymentTxtColor1,
//                       fontSize: 18,
//                       borderRadius: 10.0,
//                       buttonHeight: 48,
//                     ),

//                     SizedBox(
//                       height: 60,
//                     ),
//                     Text(
//                       'Session average chart',
//                       style: AppTextStyles.normal700(
//                         fontSize: 18,
//                         color: AppColors.paymentTxtColor1,
//                       ),
//                     ),
//                     const SizedBox(height: 40.0), // Increased from 15.0 to 30.0
//                     SizedBox(
//                       height: 200.0,
//                       child: BarChart(
//                         BarChartData(
//                           alignment: BarChartAlignment.spaceEvenly,
//                           maxY: 100,
//                           barTouchData: BarTouchData(enabled: false),
//                           titlesData: FlTitlesData(
//                             show: true,
//                             bottomTitles: AxisTitles(
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 getTitlesWidget: (double value,
//                                         TitleMeta meta) =>
//                                     getTitles(value, meta), // Pass `meta` here
//                                 reservedSize: 38,
//                               ),
//                             ),
//                             leftTitles: AxisTitles(
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 reservedSize: 40,
//                                 getTitlesWidget:
//                                     (double value, TitleMeta meta) => Text(
//                                   value.toInt().toString(),
//                                   style: AppTextStyles.normal400(
//                                       color: Colors.black, fontSize: 12),
//                                 ),
//                               ),
//                             ),
//                             topTitles: const AxisTitles(
//                                 sideTitles: SideTitles(showTitles: false)),
//                             rightTitles: const AxisTitles(
//                                 sideTitles: SideTitles(showTitles: false)),
//                           ),
//                           gridData: FlGridData(
//                             show: true,
//                             drawVerticalLine: false,
//                             horizontalInterval: 20,
//                             getDrawingHorizontalLine: (value) {
//                               return FlLine(
//                                 color: Colors.black.withOpacity(0.3),
//                                 strokeWidth: 1,
//                                 dashArray: [5, 5],
//                               );
//                             },
//                           ),
//                           borderData: FlBorderData(show: false),
//                           barGroups: [
//                             _buildBarGroup(0, 60, AppColors.paymentTxtColor1),
//                             _buildBarGroup(1, 25, AppColors.videoColor4),
//                             _buildBarGroup(2, 75, AppColors.paymentTxtColor1),
//                           ],
//                           groupsSpace: 0, // Reduced space between bars
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Container(
//       width: double.infinity,
//       height: 50,
//       decoration: const BoxDecoration(
//         border: Border(
//           top: BorderSide(color: AppColors.borderGray, width: 1),
//           bottom: BorderSide(color: AppColors.borderGray, width: 1),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: AppTextStyles.normal700(fontSize: 14, color: Colors.black),
//             ),
//             Text(
//               value,
//               style: AppTextStyles.normal700(
//                   fontSize: 14, color: AppColors.paymentTxtColor1),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTermRow(String term, double percent, Color indicatorColor) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TermResultScreen(termTitle: term),
//           ),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         height: 75,
//         decoration: const BoxDecoration(
//             border: Border(
//           bottom: BorderSide(color: AppColors.borderGray, width: 1),
//         )),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 term,
//                 style:
//                     AppTextStyles.normal700(fontSize: 14, color: Colors.black),
//               ),
//               CircularPercentIndicator(
//                 radius: 20.0,
//                 lineWidth: 4.92,
//                 percent: percent,
//                 center: Text(
//                   "${(percent * 100).toInt()}%",
//                   style: AppTextStyles.normal600(
//                       fontSize: 10, color: Colors.black),
//                 ),
//                 progressColor: indicatorColor,
//                 backgroundColor: Colors.transparent,
//                 circularStrokeCap: CircularStrokeCap.round,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   BarChartGroupData _buildBarGroup(int x, double y, Color color) {
//     return BarChartGroupData(
//       x: x,
//       barRods: [
//         BarChartRodData(
//           toY: y,
//           color: color,
//           width: 60,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(4),
//             topRight: Radius.circular(4),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget getTitles(double value, TitleMeta meta) {
//     String text;
//     switch (value.toInt()) {
//       case 0:
//         text = '1st Term';
//         break;
//       case 1:
//         text = '2nd Term';
//         break;
//       case 2:
//         text = '3rd Term';
//         break;
//       default:
//         text = '';
//         break;
//     }
//     return SideTitleWidget(
//       space: 4.0,
//       meta: meta,
//       child: Text(text,
//           style: AppTextStyles.normal400(fontSize: 12, color: Colors.black)),
//     );
//   }
// }