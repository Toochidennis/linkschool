import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/admin/payment/settings/fee_setting/amount_setting_success_screen.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
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
              .where((fee) =>
                  fee['fee_name'] != null &&
                  fee['fee_name'].toString().isNotEmpty)
              .toList();
          isLoading = false;

          // Initialize focus nodes and controllers for each fee item
          for (var i = 0; i < feeItems.length; i++) {
            _focusNodes['amount_$i'] = FocusNode();
            _fieldFocusState['amount_$i'] = false;

            // Set initial value, but handle zero values specially
            final initialAmount = feeItems[i]['amount']?.toString() ?? '0';
            _amountControllers['amount_$i'] = TextEditingController(
              text: initialAmount == '0' ? '0' : initialAmount,
            );

            // Add focus listener for smart zero removal and real-time updates
            _focusNodes['amount_$i']!.addListener(() {
              final hasFocus = _focusNodes['amount_$i']!.hasFocus;
              setState(() {
                _fieldFocusState['amount_$i'] = hasFocus;
              });

              if (hasFocus) {
                // Remove zero when field gets focus
                final controller = _amountControllers['amount_$i']!;
                if (controller.text == '0') {
                  controller.clear();
                }
              } else {
                // Set to 0 if empty when losing focus
                final controller = _amountControllers['amount_$i']!;
                if (controller.text.isEmpty) {
                  controller.text = '0';
                }
              }
            });

            // Add text change listener for real-time total updates
            _amountControllers['amount_$i']!.addListener(() {
              setState(() {
                // This will trigger a rebuild and update the total amount
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
                              final levelName =
                                  level['level_name'] ?? 'Unknown Level';
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
                                        builder: (context) =>
                                            AmountSettingScreen(
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
      final index = feeItems.indexOf(item);
      final amountText = _amountControllers['amount_$index']?.text ?? '0';
      final amount =
          double.tryParse(amountText.isEmpty ? '0' : amountText) ?? 0;
      return sum + amount;
    });
  }

  void _printFeesDetails() {
    print('=== SAVED FEES DETAILS ===');
    print('Level: $selectedLevel (ID: ${widget.levelId})');
    print('Session: ${_getCurrentSession()}');
    print('Total Amount: ${totalAmount.toStringAsFixed(2)}');
    print('Individual Fees:');

    for (var i = 0; i < feeItems.length; i++) {
      final fee = feeItems[i];
      final amount =
          double.tryParse(_amountControllers['amount_$i']?.text ?? '0') ?? 0;
      final mandatory = fee['is_mandatory'] == 1 ? '(Mandatory)' : '(Optional)';

      print('  - ${fee['fee_name']} $mandatory: ${amount.toStringAsFixed(2)}');
    }

    print('========================');
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
          final amountText = _amountControllers['amount_$index']?.text ?? '0';
          return {
            'fee_id': fee['fee_id'],
            'fee_name': fee['fee_name'],
            'is_mandatory': fee['is_mandatory'],
            'amount':
                double.tryParse(amountText.isEmpty ? '0' : amountText) ?? 0,
          };
        }).toList(),
        'level_id': widget.levelId,
        'term': int.parse(term),
        'year': year,
        '_db': db,
      };

      // Print fees details to terminal before saving
      _printFeesDetails();

      final response = await apiService.post(
        endpoint: 'portal/payments/invoices',
        body: payload,
        addDatabaseParam: false,
      );

      if (response.success) {
        // Navigate to success screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmountSettingSuccessScreen(
              levelName: selectedLevel,
              levelId: widget.levelId,
              totalAmount: totalAmount,
            ),
          ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        color: Colors.white,
        //decoration: Constants.customBoxDecoration(context),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: fee['fee_name'],
                                                      style: AppTextStyles
                                                          .normal600(
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .paymentTxtColor5,
                                                      ),
                                                    ),
                                                    if (fee['is_mandatory'] ==
                                                        1)
                                                      TextSpan(
                                                        text: '*',
                                                        style: AppTextStyles
                                                            .normal600(
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
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeInOut,
                                              width: _fieldFocusState[
                                                          'amount_$index'] ==
                                                      true
                                                  ? 106.5
                                                  : 71,
                                              child: TextField(
                                                focusNode: _focusNodes[
                                                    'amount_$index'],
                                                controller: _amountControllers[
                                                    'amount_$index'],
                                                style: AppTextStyles.normal600(
                                                    fontSize: 14,
                                                    color: AppColors
                                                        .paymentTxtColor5),
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.right,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 0),
                                                  border: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  focusedBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: AppColors
                                                            .eLearningBtnColor1,
                                                        width: 2),
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
                          totalAmount.toStringAsFixed(2),
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
