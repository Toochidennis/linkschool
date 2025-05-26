import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/result/class_detail/registration/bulk_registration.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/registration/registration_utils.dart';

class ButtonSection extends StatelessWidget {
  final String classId;
  
  const ButtonSection({super.key, required this.classId});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomLongElevatedButton(
            text: 'Register Student',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BulkRegistrationScreen(classId: classId))),
            backgroundColor: AppColors.videoColor4,
            textStyle: AppTextStyles.normal600(
                fontSize: 16, color: AppColors.backgroundLight),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.regBtnColor2,
                    side: const BorderSide(color: AppColors.videoColor4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    '+ Copy registration',
                    style: AppTextStyles.normal600(
                        fontSize: 12, color: AppColors.videoColor4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.regBtnColor2,
                    side: const BorderSide(color: Color.fromRGBO(251, 146, 60, 1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text('+ Bulk registration',
                      style: AppTextStyles.normal600(
                          fontSize: 12, color: AppColors.videoColor4)),
                  onPressed: () {
                    // Pass classId directly to the showRegistrationDialog function
                    print('ButtonSection: Calling showRegistrationDialog with classId: $classId');
                    showRegistrationDialog(context, classId: classId);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/admin/result/class_detail/registration/bulk_registration.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/utils/registration/registration_utils.dart';



// class ButtonSection extends StatelessWidget {
//   final String classId;
//   const ButtonSection({super.key, required this.classId});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           CustomLongElevatedButton(
//             text: 'Register Student',
//             onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => BulkRegistrationScreen(classId: classId,))),
//             backgroundColor: AppColors.videoColor4,
//             textStyle: AppTextStyles.normal600(
//                 fontSize: 16, color: AppColors.backgroundLight),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     backgroundColor: AppColors.regBtnColor2,
//                     side: const BorderSide(color: AppColors.videoColor4),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   onPressed: () {},
//                   child: Text(
//                     '+ Copy registration',
//                     style: AppTextStyles.normal600(
//                         fontSize: 12, color: AppColors.videoColor4),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     backgroundColor: AppColors.regBtnColor2,
//                     side: const BorderSide(color: AppColors.videoColor4),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   child: Text('+ Bulk registration',
//                       style: AppTextStyles.normal600(
//                           fontSize: 12, color: AppColors.videoColor4)),
//                   onPressed: () => showRegistrationDialog(context),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
