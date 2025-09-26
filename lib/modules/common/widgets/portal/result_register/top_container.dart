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
// import 'course_registration_history.dart';

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
   String _selectedTerm = 'First term';

    @override
  void initState() {
    super.initState();
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

  // Helper method to get term text from term number
  String _getTermText(int termNumber) {
    switch (termNumber) {
      case 1:
        return 'First term';
      case 2:
        return 'Second term';
      case 3:
        return 'Third term';
      default:
        return 'First term';
    }
  }

  @override
  Widget build(BuildContext context) {
    // // Get settings data from AuthProvider
    // final settings = widget.authProvider.getSettings();
    // final yearFromServer = settings['year'] ?? '2016';
    // final termNumber = settings['term'] ?? 1;
    // final termText = _getTermText(termNumber);
    
    // // Format year as current/next year (e.g., 2025/2026)
    // final currentYear = int.tryParse(yearFromServer.toString()) ?? 2016;
    // final nextYear = currentYear + 1;
    // final academicYear = '$currentYear/$nextYear';

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
                          '$_academicSession',
                          style: AppTextStyles.normal600(
                              fontSize: 12, color: AppColors.backgroundDark),
                        ),
                        CustomDropdown(
                          items: const [
                            'First term',
                            'Second term',
                            'Third term'
                          ],
                          value: _selectedTerm,
                          onChanged: widget.onTermChanged,
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



// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/utils/custom_dropdown_utils.dart';
// import 'package:linkschool/modules/model/admin/course_registration_history.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// // import 'course_registration_history.dart';

// class TopContainer extends StatelessWidget {
//   final String selectedTerm;
//   final Function(String?) onTermChanged;
//   final String classId;
//   final ApiService apiService;
//   final AuthProvider authProvider;

//   const TopContainer({
//     super.key,
//     required this.selectedTerm,
//     required this.onTermChanged,
//     required this.classId,
//     required this.apiService,
//     required this.authProvider,
//   });

//   Future<int> _fetchTotalStudents() async {
//     final response = await apiService.get<CourseRegistrationHistory>(
//       endpoint: 'portal/classes/$classId/course-registrations/history',
//       queryParams: {'_db': 'aalmgzmy_linkskoo_practice'},
//       fromJson: (json) => CourseRegistrationHistory.fromJson(json['data']),
//     );

//     if (response.success && response.data != null) {
//       return response.data!.totalStudents;
//     } else {
//       throw Exception(response.message);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Container(
//         height: 165,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12.0),
//         ),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12.0),
//               child: SvgPicture.asset(
//                 'assets/images/result/top_container.svg',
//                 fit: BoxFit.cover,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: 42,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: AppColors.regBtnColor1,
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '2016/2017 academic session',
//                           style: AppTextStyles.normal600(
//                               fontSize: 12, color: AppColors.backgroundDark),
//                         ),
//                         CustomDropdown(
//                           items: const [
//                             'First term',
//                             'Second term',
//                             'Third term'
//                           ],
//                           value: selectedTerm,
//                           onChanged: onTermChanged,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 34),
//                   Row(
//                     children: [
//                       const CircleAvatar(
//                         backgroundColor: AppColors.regAvatarColor,
//                         child: Icon(Icons.person, color: AppColors.primaryLight),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Registered students',
//                         style: AppTextStyles.normal500(
//                             fontSize: 14, color: AppColors.backgroundLight),
//                       ),
//                       const SizedBox(width: 18),
//                       Container(
//                         width: 1,
//                         height: 40,
//                         color: AppColors.backgroundLight,
//                       ),
//                       const SizedBox(width: 18),
//                       FutureBuilder<int>(
//                         future: _fetchTotalStudents(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                               ),
//                             );
//                           } else if (snapshot.hasError) {
//                             return Text(
//                               'Error',
//                               style: AppTextStyles.normal700(
//                                   fontSize: 24,
//                                   color: AppColors.backgroundLight),
//                             );
//                           } else if (snapshot.hasData) {
//                             return Text(
//                               snapshot.data!.toString(),
//                               style: AppTextStyles.normal700(
//                                   fontSize: 24,
//                                   color: AppColors.backgroundLight),
//                             );
//                           } else {
//                             return Text(
//                               'N/A',
//                               style: AppTextStyles.normal700(
//                                   fontSize: 24,
//                                   color: AppColors.backgroundLight),
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }