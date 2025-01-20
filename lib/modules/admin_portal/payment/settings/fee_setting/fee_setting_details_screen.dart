import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';

import 'package:linkschool/modules/common/text_styles.dart';

class FeeSettingDetailsScreen extends StatefulWidget {
  final String className;

  const FeeSettingDetailsScreen({super.key, required this.className});

  @override
  State<FeeSettingDetailsScreen> createState() =>
      _FeeSettingDetailsScreenState();
}

class _FeeSettingDetailsScreenState extends State<FeeSettingDetailsScreen> {
  String selectedClass = '';
  late double opacity;

  final List<Map<String, dynamic>> feeItems = [
    {'name': 'Bus Fee', 'amount': 3000},
    {'name': 'Development Fee', 'amount': 5000},
    {'name': 'Examination Fee', 'amount': 2500},
    {'name': 'Library Fee', 'amount': 1500},
    {'name': 'Sports Fee', 'amount': 2000},
  ];

  // Map to track focus state of each text field
  final Map<String, bool> _fieldFocusState = {};
  final Map<String, FocusNode> _focusNodes = {};



  @override
  void initState() {
    super.initState();
    selectedClass = widget.className;
    
    // Initialize focus nodes and states for each fee item
    for (var i = 0; i < feeItems.length; i++) {
      _focusNodes['name_$i'] = FocusNode();
      _focusNodes['amount_$i'] = FocusNode();
      _fieldFocusState['name_$i'] = false;
      _fieldFocusState['amount_$i'] = false;

      // Add listeners to focus nodes
      _focusNodes['name_$i']!.addListener(() {
        setState(() {
          _fieldFocusState['name_$i'] = _focusNodes['name_$i']!.hasFocus;
        });
      });
      _focusNodes['amount_$i']!.addListener(() {
        setState(() {
          _fieldFocusState['amount_$i'] = _focusNodes['amount_$i']!.hasFocus;
        });
      });
    }
  }

  @override
  void dispose() {
    // Dispose of focus nodes
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

void _showClassSelectionBottomSheet() {
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
                      'Select Class',
                      style: AppTextStyles.normal600(
                        fontSize: 20,
                        color: AppColors.eLearningBtnColor1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: ListView.builder(
                      itemCount: ['Basic One A', 'Basic One B', 'Basic Two A'].length,
                      itemBuilder: (context, index) {
                        String className = ['Basic One A', 'Basic One B', 'Basic Two A'][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedClass = className;
                              });
                              Navigator.pop(context);
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
                                  className,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                if (selectedClass == className)
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
    return feeItems.fold(0, (sum, item) => sum + (item['amount'] as int));
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
          selectedClass,
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
        child: Column(
          children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: _showClassSelectionBottomSheet,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedClass,
                      style: AppTextStyles.normal500(fontSize: 16, color: AppColors.backgroundDark),
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
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/profile/success_receipt_icon.svg',
                          width: 64,
                          height: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Second Term Fee Charges for 2017/2018 Session',
                          style: AppTextStyles.normal600(
                              fontSize: 18, color: AppColors.backgroundDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ...feeItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final fee = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAnimatedTextField(
                                initialValue: fee['name'],
                                fieldKey: 'name_$index',
                                isAmount: false,
                                baseWidth: 71,
                              ),
                              _buildAnimatedTextField(
                                initialValue: fee['amount'].toString(),
                                fieldKey: 'amount_$index',
                                isAmount: true,
                                baseWidth: 71,
                              ),
                            ],
                          ),
                        );
                      }),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Total amount to pay",
                              style: AppTextStyles.normal400(
                                  fontSize: 14,
                                  color: AppColors.paymentTxtColor5),
                            ),
                            Text(
                              totalAmount.toStringAsFixed(2),
                              style: AppTextStyles.normal600(
                                  fontSize: 18,
                                  color: AppColors.backgroundDark),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Implement payment logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.eLearningBtnColor1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Proceed to pay',
                      style: AppTextStyles.normal600(
                          fontSize: 16, color: AppColors.backgroundLight)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required String initialValue,
    required String fieldKey,
    required bool isAmount,
    required double baseWidth,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _fieldFocusState[fieldKey] == true ? baseWidth * 1.5 : baseWidth,
      child: TextField(
        focusNode: _focusNodes[fieldKey],
        controller: TextEditingController(text: initialValue,),
        style: AppTextStyles.normal400(fontSize: 12, color: AppColors.paymentTxtColor5),
        keyboardType: isAmount ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.eLearningBtnColor1, width: 2),
          ),
        ),
      ),
    );
  }
}