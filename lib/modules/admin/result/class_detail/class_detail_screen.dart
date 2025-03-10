import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/class_detail/explore_button_item_utils.dart';
import 'package:linkschool/modules/common/utils/class_detail/term_row_utils.dart';
import 'package:linkschool/modules/common/widgets/portal/class_detail/class_detail_barchart.dart';
import 'package:linkschool/modules/common/widgets/portal/class_detail/overlays.dart';
import 'package:linkschool/modules/admin/result/class_detail/attendance/attendance.dart';
import 'package:linkschool/modules/admin/result/class_detail/registration/registration.dart';
import 'package:linkschool/modules/common/buttons/custom_elevated_appbar_button.dart';
import 'package:linkschool/modules/providers/admin/term_provider.dart';
import 'package:provider/provider.dart';

class ClassDetailScreen extends StatefulWidget {
  final String className;
  final String classId;

  const ClassDetailScreen({
    super.key,
    required this.className,
    required this.classId,
  });

  @override
  _ClassDetailScreenState createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  late TermProvider _termProvider;

  @override
  void initState() {
    super.initState();
    _termProvider = Provider.of<TermProvider>(context, listen: false);
    _loadTerms();
  }

  void _loadTerms() async {
    print('Loading terms for classId: ${widget.classId}');
    await _termProvider.fetchTerms(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    final termProvider = Provider.of<TermProvider>(context);

    // Debugging: Print the current state of terms
    print('Current Terms: ${termProvider.terms}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.className,
          style: AppTextStyles.normal600(
              fontSize: 18.0, color: AppColors.primaryLight),
        ),
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
        actions: [
          CustomElevatedAppbarButton(
            text: 'See class list',
            onPressed: () {
              // Add your button action here
            },
            backgroundColor: AppColors.videoColor4,
            textColor: Colors.white,
            fontSize: 14,
            borderRadius: 4.0,
          ),
        ],
        backgroundColor: AppColors.bgColor1,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.bgColor1,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 15.0)),
                const SliverToBoxAdapter(child: ClassDetailBarChart()),
                SliverToBoxAdapter(
                  child: Container(
                    width: 360,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, -1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ExploreButtonItem(
                                  backgroundColor: AppColors.bgXplore1,
                                  label: 'Student Result',
                                  iconPath:
                                      'assets/icons/result/assessment_icon.svg',
                                  onTap: () =>
                                      showStudentResultOverlay(context),
                                ),
                              ),
                              Expanded(
                                child: ExploreButtonItem(
                                  backgroundColor: AppColors.bgXplore2,
                                  label: 'Registration',
                                  iconPath:
                                      'assets/icons/result/registration_icon.svg',
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegistrationScreen()));
                                  },
                                ),
                              ),
                              Expanded(
                                child: ExploreButtonItem(
                                  backgroundColor: AppColors.bgXplore3,
                                  label: 'Attendance',
                                  iconPath:
                                      'assets/icons/result/attendance_icon.svg',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AttendanceScreen(
                                          className: widget.className,
                                          classId: widget.classId,
                                        ),
                                      ),
                                    );
                                  },
                                  // onTap: () {
                                  //   Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //           builder: (contex) =>
                                  //               AttendanceScreen()));
                                  // },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Terms',
                                style: AppTextStyles.normal700(
                                    fontSize: 18,
                                    color: AppColors.primaryLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (termProvider.terms.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No terms available for this class.',
                                style: AppTextStyles.normal600(
                                    fontSize: 16,
                                    color: AppColors.primaryLight),
                              ),
                            ),
                          if (termProvider.terms.isNotEmpty)
                            ..._buildTermRows(termProvider
                                .terms), // Build term rows dynamically
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          if (termProvider.isLoading)
            const Center(
              child: CircularProgressIndicator(), // Show loading indicator
            ),
          if (termProvider.error != null)
            Center(
              child: Text(
                termProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildTermRows(List<Map<String, dynamic>> terms) {
    print('Building Term Rows: $terms');

    // Group terms by year
    Map<String, List<Map<String, dynamic>>> groupedTerms = {};
    for (var term in terms) {
      String year = term['year'];
      if (!groupedTerms.containsKey(year)) {
        groupedTerms[year] = [];
      }
      groupedTerms[year]!.add(term);
    }

    // Build widgets for each year group
    return groupedTerms.entries.map((entry) {
      String year = entry.key;
      List<Map<String, dynamic>> yearTerms = entry.value;

      // Interpolate the succeeding year
      String nextYear = (int.parse(year) + 1).toString();
      String header = '$year/$nextYear Session';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              header,
              style: AppTextStyles.normal700(
                fontSize: 18,
                color: AppColors.primaryLight,
              ),
            ),
          ),
          ...yearTerms.map((term) {
            return TermRow(
              term: term['termName'], // Use the term name
              percent: 0.75, // Example progress value
              indicatorColor: AppColors.primaryLight,
              onTap: () => showTermOverlay(context),
            );
          }).toList(),
        ],
      );
    }).toList();
  }

  // // Build term rows dynamically
  // List<Widget> _buildTermRows(List<Map<String, dynamic>> terms) {
  //   print('Building Term Rows: $terms');
  //   return terms.map((term) {
  //     return TermRow(
  //       term: term['termName'], // Use the term name
  //       percent: 0.75, // Example progress value
  //       indicatorColor: AppColors.primaryLight,
  //       onTap: () => showTermOverlay(context),
  //     );
  //   }).toList();
  // }
}
