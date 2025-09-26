import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';


class AmountSettingScreen extends StatefulWidget {
  final String levelName;
  final int levelId;

  const AmountSettingScreen({
    super.key,
    required this.levelName,
    required this.levelId,
  });

  @override
  State<AmountSettingScreen> createState() => AmounteSettingScreenState();
}

class AmounteSettingScreenState extends State<AmountSettingScreen> {
  String selectedLevel = '';
  late double opacity;
  List<Map<String, dynamic>> feeItems = [];
  bool isLoading = true;
  String? errorMessage;
  final Map<String, bool> _fieldFocusState = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, TextEditingController> _amountControllers = {};

  @override
  void initState() {
    super.initState();
    selectedLevel = widget.levelName;
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final settings = authProvider.getSettings();
      final year = settings['year']?.toString() ?? '2024';
      final term = settings['term']?.toString() ?? '3';
      final db = Hive.box('userData').get('_db')?.toString() ?? '';

      final apiService = locator<ApiService>();
      final response = await apiService.get<List<Map<String, dynamic>>>(
        endpoint: 'portal/payments/invoices',
        queryParams: {
          'year': year,
          'term': term,
          'level_id': widget.levelId.toString(),
          '_db': db,
        },
        fromJson: (json) => List<Map<String, dynamic>>.from(json['response']),
        addDatabaseParam: false,
      );

      if (response.success && response.data != null) {
        setState(() {
          feeItems = response.data!
              .where((fee) => fee['fee_name'] != null && fee['fee_name'].toString().isNotEmpty)
              .toList();
          isLoading = false;

          // Initialize focus nodes and controllers for each fee item
          for (var i = 0; i < feeItems.length; i++) {
            _focusNodes['amount_$i'] = FocusNode();
            _fieldFocusState['amount_$i'] = false;
            _amountControllers['amount_$i'] = TextEditingController(
              text: feeItems[i]['amount'].toString(),
            );
            _focusNodes['amount_$i']!.addListener(() {
              setState(() {
                _fieldFocusState['amount_$i'] = _focusNodes['amount_$i']!.hasFocus;
              });
            });
          }
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to fetch fees: $e';
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    for (var controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showLevelSelectionBottomSheet() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final levels = authProvider.getLevels();
    final classes = authProvider.getClasses();

    final availableLevels = levels.where((level) {
      return classes.any((classItem) =>
          classItem['level_id'] == level['id'] &&
          classItem['class_name'] != null &&
          classItem['class_name'].toString().isNotEmpty);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight,
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
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Select Levels',
                      style: AppTextStyles.normal600(
                        fontSize: 20,
                        color: AppColors.eLearningBtnColor1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: availableLevels.isEmpty
                        ? Center(
                            child: Text(
                              'No levels available',
                              style: AppTextStyles.normal500(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: availableLevels.length,
                            itemBuilder: (context, index) {
                              final level = availableLevels[index];
                              final levelName = level['level_name'] ?? 'Unknown Level';
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedLevel = levelName;
                                    });
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AmountSettingScreen(
                                          levelName: levelName,
                                          levelId: level['id'],
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        levelName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (selectedLevel == levelName)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.eLearningBtnColor1,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double get totalAmount {
    return feeItems.fold(0, (sum, item) {
      final amount = double.tryParse(_amountControllers['amount_${feeItems.indexOf(item)}']?.text ?? '0') ?? 0;
      return sum + amount;
    });
  }

  Future<void> _submitFees() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final settings = authProvider.getSettings();
      final year = settings['year']?.toString() ?? '2024';
      final term = settings['term']?.toString() ?? '3';
      final db = Hive.box('userData').get('_db')?.toString() ?? '';

      final apiService = locator<ApiService>();
      final payload = {
        'fees': feeItems.asMap().entries.map((entry) {
          final index = entry.key;
          final fee = entry.value;
          return {
            'fee_id': fee['fee_id'],
            'fee_name': fee['fee_name'],
            'is_mandatory': fee['is_mandatory'],
            'amount': double.tryParse(_amountControllers['amount_$index']?.text ?? '0') ?? 0,
          };
        }).toList(),
        'level_id': widget.levelId,
        'term': int.parse(term),
        'year': year,
        '_db': db,
      };

      final response = await apiService.post(
        endpoint: 'portal/payments/invoices',
        body: payload,
        addDatabaseParam: false,
      );

      if (response.success) {
        CustomToaster.toastSuccess(
          context,
          'Success',
          response.message ?? 'Fees saved successfully',
        );
      } else {
        CustomToaster.toastError(
          context,
          'Error',
          response.message ?? 'Failed to save fees',
        );
      }
    } catch (e) {
      CustomToaster.toastError(
        context,
        'Error',
        'Failed to submit fees: $e',
      );
    }
  }

  String _getTermText(int termValue) {
    switch (termValue) {
      case 1:
        return 'First';
      case 2:
        return 'Second';
      case 3:
        return 'Third';
      default:
        return 'Third';
    }
  }

  String _getSessionText(String yearValue) {
    final year = int.tryParse(yearValue) ?? 2025;
    final previousYear = year - 1;
    return '$previousYear/$year';
  }

  String _getCurrentSession() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settings = authProvider.getSettings();
    final year = settings['year']?.toString() ?? '2025';
    final term = settings['term'] ?? 3;
    
    final termText = _getTermText(term);
    final sessionText = _getSessionText(year);
    
    return '$termText Term $sessionText Session';
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
          'Amount Settings',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.eLearningBtnColor1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _submitFees,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.eLearningBtnColor1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                'Save',
                style: AppTextStyles.normal600(
                    fontSize: 16, color: AppColors.backgroundLight),
              ),
            ),
          ),
        ],
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
        child: Stack(
          children: [
            Column(
              children: [
                // Current Session Display
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _getCurrentSession(),
                      style: AppTextStyles.normal500(
                        fontSize: 16,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                  ),
                ),
                
                // Level Selection Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InkWell(
                    onTap: _showLevelSelectionBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedLevel,
                            style: AppTextStyles.normal500(
                              fontSize: 16,
                              color: AppColors.backgroundDark,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Scrollable Fee Items (excluding Total Amount)
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null && feeItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _fetchInvoices,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                top: 16.0,
                                bottom: 80.0, // Space for fixed total amount
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ...feeItems.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final fee = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: fee['fee_name'],
                                                      style: AppTextStyles.normal600(
                                                        fontSize: 14,
                                                        color: AppColors.paymentTxtColor5,
                                                      ),
                                                    ),
                                                    if (fee['is_mandatory'] == 1)
                                                      TextSpan(
                                                        text: '*',
                                                        style: AppTextStyles.normal600(
                                                          fontSize: 14,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                              width: _fieldFocusState['amount_$index'] == true ? 106.5 : 71,
                                              child: TextField(
                                                focusNode: _focusNodes['amount_$index'],
                                                controller: _amountControllers['amount_$index'],
                                                style: AppTextStyles.normal600(
                                                    fontSize: 14, color: AppColors.paymentTxtColor5),
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.right,
                                                decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 0),
                                                  border: UnderlineInputBorder(
                                                    borderSide:
                                                        BorderSide(color: Colors.grey.shade300),
                                                  ),
                                                  enabledBorder: UnderlineInputBorder(
                                                    borderSide:
                                                        BorderSide(color: Colors.grey.shade300),
                                                  ),
                                                  focusedBorder: const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors.eLearningBtnColor1, width: 2),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            ),
            
            // Fixed Total Amount at Bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total amount",
                      style: AppTextStyles.normal600(
                          fontSize: 16, color: AppColors.backgroundDark),
                    ),
                    Row(
                      children: [
                        NairaSvgIcon(color: AppColors.backgroundDark),
                        const SizedBox(width: 4),
                        Text(
                          "${totalAmount.toStringAsFixed(2)}",
                          style: AppTextStyles.normal600(
                              fontSize: 18, color: AppColors.backgroundDark),
                        ),
                      ],
                    ),
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
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:hive/hive.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/custom_toaster.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:provider/provider.dart';

// class FeeSettingDetailsScreen extends StatefulWidget {
//   final String levelName;
//   final int levelId;

//   const FeeSettingDetailsScreen({
//     super.key,
//     required this.levelName,
//     required this.levelId,
//   });

//   @override
//   State<FeeSettingDetailsScreen> createState() => _FeeSettingDetailsScreenState();
// }

// class _FeeSettingDetailsScreenState extends State<FeeSettingDetailsScreen> {
//   String selectedLevel = '';
//   late double opacity;
//   List<Map<String, dynamic>> feeItems = [];
//   bool isLoading = true;
//   String? errorMessage;
//   final Map<String, bool> _fieldFocusState = {};
//   final Map<String, FocusNode> _focusNodes = {};
//   final Map<String, TextEditingController> _amountControllers = {};

//   @override
//   void initState() {
//     super.initState();
//     selectedLevel = widget.levelName;
//     _fetchNextTermFees();
//   }

//   Future<void> _fetchNextTermFees() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final settings = authProvider.getSettings();
//       final year = settings['year']?.toString() ?? '2024';
//       final term = settings['term']?.toString() ?? '3';
//       final db = Hive.box('userData').get('_db')?.toString() ?? '';

//       final apiService = locator<ApiService>();
//       final response = await apiService.get<List<Map<String, dynamic>>>(
//         endpoint: 'portal/payments/next-term-fees',
//         queryParams: {
//           'year': year,
//           'term': term,
//           'level_id': widget.levelId.toString(),
//           '_db': db,
//         },
//         fromJson: (json) => List<Map<String, dynamic>>.from(json['response']),
//         addDatabaseParam: false,
//       );

//       if (response.success && response.data != null) {
//         setState(() {
//           feeItems = response.data!
//               .where((fee) => fee['fee_name'] != null && fee['fee_name'].toString().isNotEmpty)
//               .toList();
//           isLoading = false;

//           // Initialize focus nodes and controllers for each fee item
//           for (var i = 0; i < feeItems.length; i++) {
//             _focusNodes['amount_$i'] = FocusNode();
//             _fieldFocusState['amount_$i'] = false;
//             _amountControllers['amount_$i'] = TextEditingController(
//               text: feeItems[i]['amount'].toString(),
//             );
//             _focusNodes['amount_$i']!.addListener(() {
//               setState(() {
//                 _fieldFocusState['amount_$i'] = _focusNodes['amount_$i']!.hasFocus;
//               });
//             });
//           }
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           errorMessage = response.message;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage = 'Failed to fetch fees: $e';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     for (var node in _focusNodes.values) {
//       node.dispose();
//     }
//     for (var controller in _amountControllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   void _showLevelSelectionBottomSheet() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final levels = authProvider.getLevels();
//     final classes = authProvider.getClasses();

//     final availableLevels = levels.where((level) {
//       return classes.any((classItem) =>
//           classItem['level_id'] == level['id'] &&
//           classItem['class_name'] != null &&
//           classItem['class_name'].toString().isNotEmpty);
//     }).toList();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.backgroundLight,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.4,
//             ),
//             child: Padding(
//               padding: const EdgeInsets.only(top: 16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Text(
//                       'Select Levels',
//                       style: AppTextStyles.normal600(
//                         fontSize: 20,
//                         color: AppColors.eLearningBtnColor1,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Flexible(
//                     child: availableLevels.isEmpty
//                         ? Center(
//                             child: Text(
//                               'No levels available',
//                               style: AppTextStyles.normal500(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           )
//                         : ListView.builder(
//                             itemCount: availableLevels.length,
//                             itemBuilder: (context, index) {
//                               final level = availableLevels[index];
//                               final levelName = level['level_name'] ?? 'Unknown Level';
//                               return Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 24,
//                                   vertical: 8,
//                                 ),
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       selectedLevel = levelName;
//                                     });
//                                     Navigator.pop(context);
//                                     Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => FeeSettingDetailsScreen(
//                                           levelName: levelName,
//                                           levelId: level['id'],
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.white,
//                                     elevation: 4,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(vertical: 16),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         levelName,
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                       if (selectedLevel == levelName)
//                                         const Icon(
//                                           Icons.check_circle,
//                                           color: AppColors.eLearningBtnColor1,
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   double get totalAmount {
//     return feeItems.fold(0, (sum, item) {
//       final amount = double.tryParse(_amountControllers['amount_${feeItems.indexOf(item)}']?.text ?? '0') ?? 0;
//       return sum + amount;
//     });
//   }

//   Future<void> _submitFees() async {
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final settings = authProvider.getSettings();
//       final year = settings['year']?.toString() ?? '2024';
//       final term = settings['term']?.toString() ?? '3';
//       final db = Hive.box('userData').get('_db')?.toString() ?? '';

//       final apiService = locator<ApiService>();
//       final payload = {
//         'fees': feeItems.asMap().entries.map((entry) {
//           final index = entry.key;
//           final fee = entry.value;
//           return {
//             'fee_id': fee['fee_id'],
//             'fee_name': fee['fee_name'],
//             'is_mandatory': fee['is_mandatory'],
//             'amount': double.tryParse(_amountControllers['amount_$index']?.text ?? '0') ?? 0,
//           };
//         }).toList(),
//         'level_id': widget.levelId,
//         'term': int.parse(term),
//         'year': year,
//         '_db': db,
//       };

//       final response = await apiService.post(
//         endpoint: 'portal/payments/next-term-fees',
//         body: payload,
//         addDatabaseParam: false,
//       );

//       if (response.success) {
//         CustomToaster.toastSuccess(
//           context,
//           'Success',
//           response.message ?? 'Fees added successfully',
//         );
//       } else {
//         CustomToaster.toastError(
//           context,
//           'Error',
//           response.message ?? 'Failed to add fees',
//         );
//       }
//     } catch (e) {
//       CustomToaster.toastError(
//         context,
//         'Error',
//         'Failed to submit fees: $e',
//       );
//     }
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
//           selectedLevel,
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
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: InkWell(
//                 onTap: _showLevelSelectionBottomSheet,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         selectedLevel,
//                         style: AppTextStyles.normal500(
//                           fontSize: 16,
//                           color: AppColors.backgroundDark,
//                         ),
//                       ),
//                       Icon(
//                         Icons.keyboard_arrow_down,
//                         color: Colors.grey.shade600,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : errorMessage != null && feeItems.isEmpty
//                       ? Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 errorMessage!,
//                                 style: const TextStyle(color: Colors.red),
//                                 textAlign: TextAlign.center,
//                               ),
//                               const SizedBox(height: 16),
//                               ElevatedButton(
//                                 onPressed: _fetchNextTermFees,
//                                 child: const Text('Retry'),
//                               ),
//                             ],
//                           ),
//                         )
//                       : SingleChildScrollView(
//                           child: Card(
//                             margin: const EdgeInsets.all(16),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 children: [
//                                   SvgPicture.asset(
//                                     'assets/icons/profile/success_receipt_icon.svg',
//                                     width: 64,
//                                     height: 64,
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Text(
//                                     'Term ${Provider.of<AuthProvider>(context).getSettings()['term']} Fee Charges for ${Provider.of<AuthProvider>(context).getSettings()['year']} Session',
//                                     style: AppTextStyles.normal600(
//                                         fontSize: 18, color: AppColors.backgroundDark),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   const SizedBox(height: 24),
//                                   ...feeItems.asMap().entries.map((entry) {
//                                     final index = entry.key;
//                                     final fee = entry.value;
//                                     return Padding(
//                                       padding: const EdgeInsets.only(bottom: 16),
//                                       child: Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               '${fee['fee_name']}${fee['is_mandatory'] == 1 ? '*' : ''}',
//                                               style: AppTextStyles.normal400(
//                                                 fontSize: 12,
//                                                 color: AppColors.paymentTxtColor5,
//                                               ),
//                                             ),
//                                           ),
//                                           AnimatedContainer(
//                                             duration: const Duration(milliseconds: 300),
//                                             curve: Curves.easeInOut,
//                                             width: _fieldFocusState['amount_$index'] == true ? 106.5 : 71,
//                                             child: TextField(
//                                               focusNode: _focusNodes['amount_$index'],
//                                               controller: _amountControllers['amount_$index'],
//                                               style: AppTextStyles.normal400(
//                                                   fontSize: 12, color: AppColors.paymentTxtColor5),
//                                               keyboardType: TextInputType.number,
//                                               decoration: InputDecoration(
//                                                 contentPadding: const EdgeInsets.symmetric(
//                                                     horizontal: 8, vertical: 0),
//                                                 border: UnderlineInputBorder(
//                                                   borderSide:
//                                                       BorderSide(color: Colors.grey.shade300),
//                                                 ),
//                                                 enabledBorder: UnderlineInputBorder(
//                                                   borderSide:
//                                                       BorderSide(color: Colors.grey.shade300),
//                                                 ),
//                                                 focusedBorder: const UnderlineInputBorder(
//                                                   borderSide: BorderSide(
//                                                       color: AppColors.eLearningBtnColor1, width: 2),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   }),
//                                   const SizedBox(height: 16),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                     children: [
//                                       Text(
//                                         "Total amount to pay",
//                                         style: AppTextStyles.normal400(
//                                             fontSize: 14, color: AppColors.paymentTxtColor5),
//                                       ),
//                                       Text(
//                                         totalAmount.toStringAsFixed(2),
//                                         style: AppTextStyles.normal600(
//                                             fontSize: 18, color: AppColors.backgroundDark),
//                                       )
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _submitFees,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.eLearningBtnColor1,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     'Proceed to pay',
//                     style: AppTextStyles.normal600(
//                         fontSize: 16, color: AppColors.backgroundLight),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }