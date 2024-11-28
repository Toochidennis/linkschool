import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_app_bar.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_history_header.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_history_list.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/header_container.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/info_card.dart';
import 'package:linkschool/modules/common/widgets/portal/result_attendance/take_attendance_button.dart';
import 'package:linkschool/modules/staff_portal/home/staff_take_attandance_screen.dart';


class FormClassesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        title: Text('Attendance',
            style: AppTextStyles.normal600(
                fontSize: 20, color: AppColors.backgroundLight)),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset('assets/icons/arrow_back.png',
              color: AppColors.backgroundLight, width: 34.0, height: 34.0),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset('assets/icons/result/search.svg',
                color: AppColors.backgroundLight),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28)),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -MediaQuery.of(context).size.height * 0.15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    InfoCard(),
                    const SizedBox(height: 20),
                    CustomLongElevatedButton(
                      text: 'Take attendance',
                    onPressed: () {
                      // Navigate to TakeAttendanceScreen when button is clicked
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StaffTakeAttendanceScreen(),
                        ),
                      );
                    },
                      backgroundColor: AppColors.videoColor4,
                      textStyle: AppTextStyles.normal600(
                          fontSize: 16, color: AppColors.backgroundLight),
                    ),
                    const SizedBox(height: 44),
                    AttendanceHistoryHeader(),
                    const SizedBox(height: 16),
                    AttendanceHistoryList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_attendance/attendance_history_header.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_attendance/info_card.dart';
// import 'package:linkschool/modules/staff_portal/home/staff_attendance_history.dart';
// import 'package:linkschool/modules/staff_portal/home/staff_take_attandance_screen.dart';

// class FormClassesScreen extends StatefulWidget {
//   @override
//   State<FormClassesScreen> createState() => _FormClassesScreenState();
// }

// class _FormClassesScreenState extends State<FormClassesScreen> {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryLight,
//         elevation: 0,
//         title: Text('Attendance',
//             style: AppTextStyles.normal600(
//                 fontSize: 20, color: AppColors.backgroundLight)),
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset('assets/icons/arrow_back.png',
//               color: AppColors.backgroundLight, width: 34.0, height: 34.0),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: SvgPicture.asset('assets/icons/result/search.svg',
//                 color: AppColors.backgroundLight),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.height * 0.20,
//               decoration: const BoxDecoration(
//                 color: AppColors.primaryLight,
//                 borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(28),
//                     bottomRight: Radius.circular(28)),
//               ),
//             ),
//             Transform.translate(
//               offset: Offset(0, -MediaQuery.of(context).size.height * 0.15),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   children: [
//                     InfoCard(),
//                     const SizedBox(height: 20),
//                     CustomLongElevatedButton(
//                       text: 'Take attendance',
//                     onPressed: () {
//                       // Navigate to TakeAttendanceScreen when button is clicked
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => StaffTakeAttendanceScreen(),
//                         ),
//                       );
//                     },
//                       backgroundColor: AppColors.videoColor4,
//                       textStyle: AppTextStyles.normal600(
//                           fontSize: 16, color: AppColors.backgroundLight),
//                     ),
//                     const SizedBox(height: 44),
//                     AttendanceHistoryHeader(),
//                     const SizedBox(height: 16),
//                     StaffAttendanceHistoryList(date: 'June',),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

// class FormClassesScreen extends StatelessWidget {
//   const FormClassesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Form Classes',
//           style: AppTextStyles.normal600(
//             fontSize: 20,
//             color: AppColors.primaryLight,
//           ),
//         ),
//       ),
//       body: const Center(
//         child: Text('Form Classes Management Screen'),
//       ),
//     );
//   }
// }


                      // onPressed: () {
                      //   // Navigate to TakeAttendanceScreen when button is clicked
                      //   Navigator.of(context).push(
                      //     MaterialPageRoute(
                      //       builder: (context) => StaffTakeAttendanceScreen(),
                      //     ),
                      //   );
                      // },