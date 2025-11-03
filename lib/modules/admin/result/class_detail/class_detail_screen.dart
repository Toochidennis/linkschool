import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
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
  final String levelId;

  const ClassDetailScreen({
    super.key,
    required this.className,
    required this.classId,
    required this.levelId,
  });

  @override
  _ClassDetailScreenState createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  late TermProvider _termProvider;
  List<dynamic> classNames = [];
  List<dynamic> levelNames = [];  

  @override
  void initState() {
    super.initState();
    _termProvider = Provider.of<TermProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTerms();
      _loadUserData();
    });
    _debugHiveContents();

    // Store the level ID
    _storeLevelId();
  }

  void _storeLevelId() async {
    final userBox = Hive.box('userData');
    await userBox.put('currentLevelId', widget.levelId);
    print('Stored level ID: ${widget.levelId}');
    print('Hive currentLevelId after store: ${userBox.get('currentLevelId')}');
  }

  void _debugHiveContents() {
    final userBox = Hive.box('userData');
    print('Hive box keys: ${userBox.keys.toList()}');
    print('Current Level ID: ${widget.levelId}');
    for (var key in userBox.keys) {
      print('Hive key $key: ${userBox.get(key)}');
    }
  }

  Future<void> _loadTerms() async {
    print('Loading terms for classId: ${widget.classId}, levelId: ${widget.levelId}');
    try {
      await _termProvider.fetchTerms(widget.classId);
    } catch (e) {
      print('Error loading terms: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userBox = Hive.box('userData');

      // Get stored user data (same logic as in ResultDashboardScreen)
      final storedUserData = userBox.get('userData');
      final storedLoginResponse = userBox.get('loginResponse');

      dynamic dataToProcess;
      if (storedUserData != null) {
        dataToProcess = storedUserData;
      } else if (storedLoginResponse != null) {
        dataToProcess = storedLoginResponse;
      }

      if (dataToProcess != null) {
        Map<String, dynamic> processedData = dataToProcess is String
            ? json.decode(dataToProcess)
            : dataToProcess;

        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;

        final levels = data['levels'] ?? [];
        final classes = data['classes'] ?? [];

        setState(() {
          // Transform levels to match the format [id, level_name]
          levelNames = levels.map((level) => [
            (level['id'] ?? '').toString(),
            level['level_name'] ?? ''
          ]).toList();

          // Transform classes to match the format [id, class_name, level_id]
          classNames = classes.map((cls) => [
            (cls['id'] ?? '').toString(),
            cls['class_name'] ?? '',
            (cls['level_id'] ?? '').toString()
          ]).toList();

          print('Loaded Level Names: $levelNames');
          print('Loaded Class Names: $classNames');
        });
      }
    } catch (e) {
      print('Error loading user data for class selection: $e');
    }
  }

  void _showClassSelectionDialog() {
    // Filter classes that match the current level
    final filteredClasses = classNames
        .where((cls) => cls[2] == widget.levelId && cls[1].toString().isNotEmpty)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Select Class',
                  style: AppTextStyles.normal600(
                      fontSize: 24, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: filteredClasses.isEmpty
                      ? _buildEmptyState('No classes available for this level')
                      : ListView.builder(
                          itemCount: filteredClasses.length,
                          itemBuilder: (context, index) {
                            final cls = filteredClasses[index];
                            final isCurrentClass = cls[0] == widget.classId;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: _buildSelectionButton(
                                cls[1], // class name
                                isCurrentClass,
                                () {
                                  if (!isCurrentClass) {
                                    Navigator.of(context).pop();
                                    _navigateToClassDetail(cls[0], cls[1]); // class ID, class name
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          style: AppTextStyles.normal600(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButton(String text, bool isCurrentClass, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: isCurrentClass ? AppColors.primaryLight.withOpacity(0.1) : AppColors.dialogBtnColor,
        child: InkWell(
          onTap: isCurrentClass ? null : onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Ink(
            decoration: BoxDecoration(
                color: isCurrentClass ? AppColors.primaryLight.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: isCurrentClass ? Border.all(color: AppColors.primaryLight, width: 2) : null,
            ),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: isCurrentClass ? AppColors.primaryLight : AppColors.backgroundDark),
                  ),
                  if (isCurrentClass) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToClassDetail(String classId, String className) async {
    final userBox = Hive.box('userData');
    await userBox.put('selectedClassId', classId);
    await userBox.put('selectedLevelId', widget.levelId);

    // Replace current route with new class detail screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ClassDetailScreen(
          classId: classId,
          className: className,
          levelId: widget.levelId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final termProvider = Provider.of<TermProvider>(context);

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
            onPressed: _showClassSelectionDialog,
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
                                      showStudentResultOverlay(
                                        context,
                                        classId: widget.classId,
                                        className: widget.className,
                                        isFromResultScreen: false,
                                      ),
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
                            children: [],
                          ),
                          const SizedBox(height: 10),
                          if (termProvider.terms.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(634),
                              child: Text(
                                'No terms available for this class.',
                                style: AppTextStyles.normal600(
                                    fontSize: 16,
                                    color: AppColors.primaryLight),
                              ),
                            ),
                          if (termProvider.terms.isNotEmpty)
                            ..._buildTermRows(termProvider.terms),
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
              child: CircularProgressIndicator(),
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
  final groupedTerms = <String, List<Map<String, dynamic>>>{};

  // Group terms by year
  for (final term in terms) {
    final year = term['year'].toString();
    if (!groupedTerms.containsKey(year)) {
      groupedTerms[year] = [];
    }
    groupedTerms[year]!.add(term);
  }

  // Determine the current year and term
  final currentYear = groupedTerms.keys.map(int.parse).reduce((a, b) => a > b ? a : b).toString();
  final currentTerms = groupedTerms[currentYear] ?? [];
  final currentTermId = currentTerms.isNotEmpty
      ? currentTerms.reduce((a, b) => (a['termId'] > b['termId']) ? a : b)['termId']
      : 0;

  return groupedTerms.entries.map((entry) {
    final year = entry.key;
    final yearTerms = entry.value;
    // Display session as (year-1)/year
    final sessionYear = int.parse(year);
    final header = '${sessionYear - 1}/$year Session';

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
          String formattedTerm = term['termName'] ?? 'Unknown Term';
          double percent = (term['averageScore'] ?? 0.0) / 100.0; // Normalize to 0.0-1.0
          // Check if this is the current term
          bool isCurrentTerm = year == currentYear && term['termId'] == currentTermId;
          return TermRow(
            term: formattedTerm,
            percent: percent.clamp(0.0, 1.0), // Ensure percent is between 0 and 1
            indicatorColor: AppColors.primaryLight,
            onTap: () => showTermOverlay(
              context,
              classId: widget.classId,
              levelId: widget.levelId,
              year: term['year'],
              termId: term['termId'],
              termName: formattedTerm,
              isCurrentTerm: isCurrentTerm,
            ),
          );
        }).toList(),
        const SizedBox(height: 10),
      ],
    );
  }).toList();
}
}

