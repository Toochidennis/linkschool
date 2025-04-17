import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTerms();
    });
    _debugHiveContents();
    // _loadTerms();
  }

void _debugHiveContents() {
  final userBox = Hive.box('userData');
  print('Hive box keys: ${userBox.keys.toList()}');
  for (var key in userBox.keys) {
    print('Hive key $key: ${userBox.get(key)}');
  }
}

  Future<void> _loadTerms() async {
    print('Loading terms for classId: ${widget.classId}');
    try {
      await _termProvider.fetchTerms(widget.classId);
    } catch (e) {
      print('Error loading terms: $e');
    }
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
                                                RegistrationScreen(classId: widget.classId)));
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
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Terms',
                              //   style: AppTextStyles.normal700(
                              //       fontSize: 18,
                              //       color: AppColors.primaryLight),
                              // ),
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
           if (termProvider.error != null && !termProvider.isLoading)
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
  // Group terms by year
  final groupedTerms = <String, List<Map<String, dynamic>>>{};
  
  for (final term in terms) {
    final year = term['year'];
    groupedTerms.putIfAbsent(year, () => []).add(term);
  }

  return groupedTerms.entries.map((entry) {
    final year = entry.key;
    final yearTerms = entry.value;
    final nextYear = (int.parse(year) + 1).toString();
    final header = '$year/$nextYear Session';

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
          // Format term display according to requirements
          String formattedTerm;
          final termId = term['termId'];
          
          if (termId == 1) {
            formattedTerm = 'First term';
          } else if (termId == 2) {
            formattedTerm = 'Second term';
          } else if (termId == 3) {
            formattedTerm = 'Third term';
          } else {
            formattedTerm = 'No term available for this session';
          }
          
          return TermRow(
            term: formattedTerm,
            percent: 0.75,
            indicatorColor: AppColors.primaryLight,
            onTap: () => showTermOverlay(context),
          );
        }),
      ],
    );
  }).toList();
}
}