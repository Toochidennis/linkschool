import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/custom_dropdown_utils.dart';
import 'package:linkschool/modules/model/admin/course_registration_history.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';

class TopContainer extends StatefulWidget {
  final String selectedTerm;
  final Function(String?) onTermChanged;
  final String classId;
  final ApiService apiService;
  final AuthProvider authProvider;

  const TopContainer({
    super.key,
    required this.selectedTerm,
    required this.onTermChanged,
    required this.classId,
    required this.apiService,
    required this.authProvider,
  });

  @override
  State<TopContainer> createState() => _TopContainerState();
}

class _TopContainerState extends State<TopContainer> {
  String _academicSession = '';
  Map<String, dynamic> _settings = {};
  late String _selectedTerm; // ✅ Remove initialization here

  @override
  void initState() {
    super.initState();
    _selectedTerm = widget.selectedTerm; // ✅ Initialize from widget
    _loadSettingsFromHive();
  }

  void _loadSettingsFromHive() {
    final userBox = Hive.box('userData');
    final userData = userBox.get('userData');

    if (userData != null && userData['data'] != null && userData['data']['settings'] != null) {
      setState(() {
        _settings = Map<String, dynamic>.from(userData['data']['settings']);

        int termNumber = _settings['term'] ?? 1;
        _selectedTerm = termNumber == 1
            ? 'First term'
            : termNumber == 2
                ? 'Second term'
                : 'Third term';

        _academicSession = "${int.parse(_settings['year'] ?? '2023') - 1}/${_settings['year'] ?? '2023'} academic session";
      });
    }
  }

  Future<int> _fetchTotalStudents() async {
    final response = await widget.apiService.get<CourseRegistrationHistory>(
      endpoint: 'portal/classes/${widget.classId}/course-registrations/history',
      queryParams: {'_db': EnvConfig.dbName},
      fromJson: (json) => CourseRegistrationHistory.fromJson(json['data']),
    );

    if (response.success && response.data != null) {
      return response.data!.totalStudents;
    } else {
      throw Exception(response.message);
    }
  }

  // ✅ Handle term change locally AND notify parent
  void _handleTermChange(String? newTerm) {
    if (newTerm != null) {
      setState(() {
        _selectedTerm = newTerm;
      });
      widget.onTermChanged(newTerm); // Notify parent widget
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: SvgPicture.asset(
                'assets/images/result/top_container.svg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.regBtnColor1,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _academicSession,
                          style: AppTextStyles.normal600(
                              fontSize: 12, color: AppColors.backgroundDark),
                        ),
                        CustomDropdown(
                          items: const [
                            'First term',
                            'Second term',
                            'Third term'
                          ],
                          value: _selectedTerm, // ✅ Use local state
                          onChanged: _handleTermChange, // ✅ Use local handler
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.regAvatarColor,
                        child: Icon(Icons.person, color: AppColors.primaryLight),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Registered students',
                        style: AppTextStyles.normal500(
                            fontSize: 14, color: AppColors.backgroundLight),
                      ),
                      const SizedBox(width: 18),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.backgroundLight,
                      ),
                      const SizedBox(width: 18),
                      FutureBuilder<int>(
                        future: _fetchTotalStudents(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error',
                              style: AppTextStyles.normal700(
                                  fontSize: 24,
                                  color: AppColors.backgroundLight),
                            );
                          } else if (snapshot.hasData) {
                            return Text(
                              snapshot.data!.toString(),
                              style: AppTextStyles.normal700(
                                  fontSize: 24,
                                  color: AppColors.backgroundLight),
                            );
                          } else {
                            return Text(
                              'N/A',
                              style: AppTextStyles.normal700(
                                  fontSize: 24,
                                  color: AppColors.backgroundLight),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}