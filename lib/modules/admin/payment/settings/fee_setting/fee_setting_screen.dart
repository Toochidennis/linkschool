import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/admin/payment/settings/widgets/add_fee_overlay.dart';
import 'package:linkschool/modules/admin/payment/settings/widgets/edit_fee_overlay.dart';
// import 'package:linkschool/modules/admin/payment/settings/widgets/edit_fee_overlay.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/admin/payment/fee_provider.dart';
import 'package:provider/provider.dart';

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
            if (feeProvider.isLoading && feeProvider.feeNames.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (feeProvider.error != null && feeProvider.feeNames.isEmpty) {
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

            return RefreshIndicator(
              onRefresh: () async {
                await feeProvider.fetchFeeNames();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Show loading indicator at top when processing
                    if (feeProvider.isLoading && feeProvider.feeNames.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Fee names list
                    Expanded(
                      child: ListView.builder(
                        itemCount: feeProvider.feeNames.length,
                        itemBuilder: (context, index) {
                          final feeName = feeProvider.feeNames[index];
                          return _buildFeeRow(
                            feeName,
                            isNewlyAdded: index == 0 && feeProvider.isLoading,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFeeOverlay(context),
        backgroundColor: AppColors.videoColor4,
        child: Icon(
          Icons.add,
          color: AppColors.backgroundLight,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFeeRow(dynamic feeName, {bool isNewlyAdded = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isNewlyAdded ? AppColors.eLearningBtnColor1 : Colors.grey.shade300,
          width: isNewlyAdded ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isNewlyAdded ? AppColors.eLearningBtnColor1.withOpacity(0.05) : null,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNewlyAdded ? AppColors.eLearningBtnColor1 : AppColors.eLearningBtnColor1,
          child: SvgPicture.asset('assets/icons/profile/fee.svg',
              color: Colors.white),
        ),
        title: Text(
          feeName.feeName,
          style: TextStyle(
            fontWeight: isNewlyAdded ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          feeName.isMandatory ? 'Required' : 'Not Required',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: isNewlyAdded ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: isNewlyAdded
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.eLearningBtnColor1,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditFeeOverlay(context, feeName);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, feeName);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
      ),
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

  void _showEditFeeOverlay(BuildContext context, dynamic feeName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditFeeOverlay(
            initialFeeName: feeName.feeName,
            initialIsMandatory: feeName.isMandatory,
            onConfirm: (newFeeName, newIsMandatory) async {
              final feeProvider = Provider.of<FeeProvider>(context, listen: false);
              final success = await feeProvider.updateFeeName(
                feeName.id.toString(),
                newFeeName,
                newIsMandatory,
              );
              
              if (success) {
                CustomToaster.toastSuccess(
                  context,
                  'Success',
                  'Fee name updated successfully',
                );
              } else {
                CustomToaster.toastError(
                  context,
                  'Error',
                  feeProvider.error ?? 'Failed to update fee name',
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic feeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Fee Name',
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: AppColors.eLearningBtnColor1,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${feeName.feeName}"? This action cannot be undone.',
            style: AppTextStyles.normal400(fontSize: 16, color: AppColors.backgroundDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.normal500(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final feeProvider = Provider.of<FeeProvider>(context, listen: false);
                final success = await feeProvider.deleteFeeName(feeName.id.toString());
                
                if (success) {
                  CustomToaster.toastSuccess(
                    context,
                    'Success',
                    'Fee name deleted successfully',
                  );
                } else {
                  CustomToaster.toastError(
                    context,
                    'Error',
                    feeProvider.error ?? 'Failed to delete fee name',
                  );
                }
              },
              child: Text(
                'Delete',
                style: AppTextStyles.normal500(
                  fontSize: 16,
                  color: AppColors.eLearningRedBtnColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:linkschool/modules/admin/payment/settings/widgets/add_fee_overlay.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/custom_toaster.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/providers/admin/payment/fee_provider.dart';
// import 'package:provider/provider.dart';

// class FeeSettingScreen extends StatefulWidget {
//   const FeeSettingScreen({super.key});

//   @override
//   State<FeeSettingScreen> createState() => _FeeSettingScreenState();
// }

// class _FeeSettingScreenState extends State<FeeSettingScreen> {
//   late double opacity;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<FeeProvider>(context, listen: false).fetchFeeNames();
//     });
//   }

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
//         child: Consumer<FeeProvider>(
//           builder: (context, feeProvider, child) {
//             if (feeProvider.isLoading && feeProvider.feeNames.isEmpty) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }

//             if (feeProvider.error != null && feeProvider.feeNames.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Error: ${feeProvider.error}',
//                       style: const TextStyle(color: Colors.red),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         feeProvider.fetchFeeNames();
//                       },
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return RefreshIndicator(
//               onRefresh: () async {
//                 await feeProvider.fetchFeeNames();
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     // Show loading indicator at top when adding new fee
//                     if (feeProvider.isLoading && feeProvider.feeNames.isNotEmpty)
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Adding fee name...',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     // Fee names list
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: feeProvider.feeNames.length,
//                         itemBuilder: (context, index) {
//                           final feeName = feeProvider.feeNames[index];
//                           return _buildFeeRow(
//                             feeName.feeName,
//                             isRequired: feeName.isMandatory,
//                             isNewlyAdded: index == 0 && feeProvider.isLoading,
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
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

//   Widget _buildFeeRow(String title, {required bool isRequired, bool isNewlyAdded = false}) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: isNewlyAdded ? AppColors.eLearningBtnColor1 : Colors.grey.shade300,
//           width: isNewlyAdded ? 2 : 1,
//         ),
//         borderRadius: BorderRadius.circular(8),
//         color: isNewlyAdded ? AppColors.eLearningBtnColor1.withOpacity(0.05) : null,
//       ),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: isNewlyAdded ? AppColors.eLearningBtnColor1 : AppColors.eLearningBtnColor1,
//           child: SvgPicture.asset('assets/icons/profile/fee.svg',
//               color: Colors.white),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: isNewlyAdded ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         subtitle: Text(
//           isRequired ? 'Required' : 'Not Required',
//           style: TextStyle(
//             color: Colors.grey,
//             fontWeight: isNewlyAdded ? FontWeight.w500 : FontWeight.normal,
//           ),
//         ),
//         trailing: isNewlyAdded
//             ? Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppColors.eLearningBtnColor1,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   'NEW',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               )
//             : null,
//       ),
//     );
//   }

//   void _showAddFeeOverlay(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: AddFeeOverlay(
//             onConfirm: (feeName, isMandatory) async {
//               final feeProvider = Provider.of<FeeProvider>(context, listen: false);
//               final success = await feeProvider.addFeeName(feeName, isMandatory);
              
//               if (success) {
//                 CustomToaster.toastSuccess(
//                   context,
//                   'Success',
//                   'Fee name added successfully',
//                 );
//               } else {
//                 CustomToaster.toastError(
//                   context,
//                   'Error',
//                   feeProvider.error ?? 'Failed to add fee name',
//                 );
//               }
//             },
//           ),
//         );
//       },
//     );
//   }
// }