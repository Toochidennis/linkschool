// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin/payment/settings/fee_setting/fee_setting_details_screen.dart';
// import 'package:linkschool/modules/common/widgets/custom_toaster.dart';
// import 'package:linkschool/modules/admin/payment/settings/fee_setting/widgets/add_fee_overlay.dart';
// import 'package:linkschool/modules/admin/payment/settings/fee_setting/widgets/level_selection_overlay.dart';
// import 'package:linkschool/modules/admin/payment/settings/fee_setting/widgets/fee_action_overlay.dart';
import 'package:linkschool/modules/providers/admin/payment/fee_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/add_fee_overlay.dart';
import '../widgets/fee_action_overlay.dart';
import '../widgets/level_selection_overlay.dart';

class FeeSettingScreen extends StatefulWidget {
  const FeeSettingScreen({super.key});

  @override
  State<FeeSettingScreen> createState() => _FeeSettingScreenState();
}

class _FeeSettingScreenState extends State<FeeSettingScreen> {
  late double opacity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeeProvider>(context, listen: false).fetchFeeNames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Fee Settings',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.eLearningBtnColor1,
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
        decoration: Constants.customBoxDecoration(context),
        child: Consumer<FeeProvider>(
          builder: (context, feeProvider, child) {
            if (feeProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (feeProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${feeProvider.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        feeProvider.fetchFeeNames();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: feeProvider.feeNames.length,
                itemBuilder: (context, index) {
                  final feeName = feeProvider.feeNames[index];
                  return _buildFeeRow(
                    feeName.feeName,
                    isRequired: feeName.isMandatory,
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFeeActionOverlay(context),
        backgroundColor: AppColors.videoColor4,
        child: Icon(
          Icons.add,
          color: AppColors.backgroundLight,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFeeRow(String title, {required bool isRequired}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.eLearningBtnColor1,
          child: SvgPicture.asset('assets/icons/profile/fee.svg',
              color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(
          isRequired ? 'Required' : 'Not Required',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  void _showFeeActionOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FeeActionOverlay(
          onSetFeeName: () => _showAddFeeOverlay(context),
          onSetFeeAmount: () => _showLevelSelectionOverlay(context),
        );
      },
    );
  }

  void _showAddFeeOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddFeeOverlay(
            onConfirm: (feeName, isMandatory) async {
              final feeProvider = Provider.of<FeeProvider>(context, listen: false);
              final success = await feeProvider.addFeeName(feeName, isMandatory);
              
              if (success) {
                CustomToaster.toastSuccess(
                  context,
                  'Success',
                  'Fee name added successfully',
                );
              } else {
                CustomToaster.toastError(
                  context,
                  'Error',
                  feeProvider.error ?? 'Failed to add fee name',
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showLevelSelectionOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return LevelSelectionOverlay(
          onLevelSelected: (levelName) {
            _navigateToFeeDetailsScreen(context, levelName);
          },
        );
      },
    );
  }

  void _navigateToFeeDetailsScreen(BuildContext context, String levelName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeeSettingDetailsScreen(levelName: levelName),
      ),
    );
  }
}






// // ignore_for_file: prefer_const_constructors
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/admin/payment/settings/fee_setting/fee_setting_details_screen.dart';


// class FeeSettingScreen extends StatefulWidget {
//   const FeeSettingScreen({super.key});

//   @override
//   State<FeeSettingScreen> createState() => _FeeSettingScreenState();
// }

// class _FeeSettingScreenState extends State<FeeSettingScreen> {
//   late double opacity;
//   bool isRequired = false;
//   String selectedClass = '';

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.eLearningBtnColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Fee Settings',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.eLearningBtnColor1,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         flexibleSpace: FlexibleSpaceBar(
//           background: Stack(
//             children: [
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Image.asset(
//                     'assets/images/background.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: Constants.customBoxDecoration(context),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: ListView(
//             children: [
//               _buildFeeRow('Bus Fee', isRequired: true),
//               _buildFeeRow('Development Fee', isRequired: false),
//               _buildFeeRow('Examination Fee', isRequired: true),
//               _buildFeeRow('T-Fair Fee', isRequired: false),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddFeeOverlay(context),
//         backgroundColor: AppColors.videoColor4,
//         child: Icon(
//           Icons.add,
//           color: AppColors.backgroundLight,
//           size: 24,
//         ),
//       ),
//     );
//   }

//   Widget _buildFeeRow(String title, {required bool isRequired}) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: AppColors.eLearningBtnColor1,
//           child: SvgPicture.asset('assets/icons/profile/fee.svg',
//               color: Colors.white),
//         ),
//         title: Text(title),
//         subtitle: Text(
//           isRequired ? 'Required' : 'Not Required',
//           style: TextStyle(color: Colors.grey),
//         ),
//       ),
//     );
//   }

//   void _showAddFeeOverlay(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return Container(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('Add Fee',
//                       style: AppTextStyles.normal600(
//                           fontSize: 18, color: AppColors.eLearningBtnColor1)),
//                   SizedBox(height: 16),
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Enter fee name',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Switch(
//                         value: isRequired,
//                         onChanged: (value) {
//                           setState(() {
//                             isRequired = value;
//                           });
//                         },
//                         activeColor: Colors.green,
//                       ),
//                       Text('Required'),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: OutlinedButton.styleFrom(
//                             side: const BorderSide(
//                                 color: AppColors.eLearningRedBtnColor),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(vertical: 12),
//                             child: Text('Cancel',
//                                 style: AppTextStyles.normal500(
//                                     fontSize: 18,
//                                     color: AppColors.eLearningRedBtnColor)),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () => _showLevelSelectionOverlay(context),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.eLearningBtnColor5,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(vertical: 12),
//                             child: Text('Confirm',
//                                 style: AppTextStyles.normal600(
//                                     fontSize: 16.0,
//                                     color: AppColors.backgroundLight)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

// void _showLevelSelectionOverlay(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: AppColors.backgroundLight,
//     builder: (BuildContext context) {
//       return Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.4,
//           ),
//           child: Padding(
//             padding: const EdgeInsets.only(top: 16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Select Level',
//                   style: AppTextStyles.normal600(
//                     fontSize: 20,
//                     color: const Color.fromRGBO(47, 85, 221, 1),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Flexible(
//                   child: ListView.builder(
//                     itemCount: 3, // Replace with your actual class list length
//                     itemBuilder: (context, index) {
//                       // Replace with your actual class list data
//                       List<String> levels = ['Basic One ', 'Basic Two', 'Basic Three'];
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 8,
//                         ),
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             Navigator.pop(context);
//                             _navigateToFeeDetailsScreen(context, levels[index]);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             elevation: 4,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: Text(
//                             levels[index],
//                             style: const TextStyle(fontSize: 16),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

//   void _navigateToFeeDetailsScreen(BuildContext context, String levelName) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FeeSettingDetailsScreen(levelName: levelName),
//       ),
//     );
//   }
// }