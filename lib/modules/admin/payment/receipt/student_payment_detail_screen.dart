import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/app_colors.dart';
import '../../../common/constants.dart';
import '../../../common/custom_toaster.dart';
import '../../../common/text_styles.dart';
import '../../../common/widgets/portal/profile/naira_icon.dart';
import '../../../model/admin/payment_models.dart';
import '../../../services/admin/payment/payment_service.dart';
import '../../../services/api/api_service.dart';
// import '../models/payment_models.dart';
// import '../services/payment_service.dart';
// import '../services/api_service.dart';
// import '../common/app_colors.dart';
// import '../common/constants.dart';
// import '../common/text_styles.dart';
// import '../common/widgets/portal/profile/naira_icon.dart';
// import '../utils/custom_toaster.dart';

class StudentPaymentDetailScreen extends StatefulWidget {
  final UnpaidStudent student;
  final UnpaidInvoice invoice;

  const StudentPaymentDetailScreen({
    super.key,
    required this.student,
    required this.invoice,
  });

  @override
  State<StudentPaymentDetailScreen> createState() => _StudentPaymentDetailScreenState();
}

class _StudentPaymentDetailScreenState extends State<StudentPaymentDetailScreen> {
  late double opacity;
  late PaymentService _paymentService;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(ApiService());
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    
    // Filter out fees with zero amount
    final activeFees = widget.invoice.invoiceDetails.where((fee) => fee.amount > 0).toList();
    final totalAmount = activeFees.fold(0.0, (sum, fee) => sum + fee.amount);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Payment Details',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/profile/payment_icon.svg',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.name,
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.backgroundDark,
                            ),
                          ),
                          Text(
                            'Reg No: ${widget.student.regNo}',
                            style: AppTextStyles.normal400(
                              fontSize: 14,
                              color: Colors.grey[600]!,
                            ),
                          ),
                          Text(
                            _paymentService.getClassName(widget.student.classId) ?? 'Unknown Class',
                            style: AppTextStyles.normal400(
                              fontSize: 14,
                              color: Colors.grey[600]!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Payment Title
              Text(
                '${widget.invoice.termText} ${widget.invoice.sessionText}',
                style: AppTextStyles.normal600(
                  fontSize: 20,
                  color: const Color.fromRGBO(47, 85, 221, 1),
                ),
              ),
              const SizedBox(height: 16),
              
              // Fee Breakdown
              Text(
                'Fee Breakdown',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.backgroundDark,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: activeFees.map((fee) => _buildFeeItem(fee)).toList(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Total Amount
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(47, 85, 221, 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color.fromRGBO(47, 85, 221, 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total amount to pay',
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                    Row(
                      children: [
                        const NairaSvgIcon(color: Color.fromRGBO(47, 85, 221, 1)),
                        const SizedBox(width: 4),
                        Text(
                          totalAmount.toStringAsFixed(2),
                          style: AppTextStyles.normal700(
                            fontSize: 20,
                            color: const Color.fromRGBO(47, 85, 221, 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Proceed to Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessingPayment ? null : () => _showPaymentBottomSheet(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: _isProcessingPayment
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Proceed to pay',
                          style: AppTextStyles.normal500(
                            fontSize: 18,
                            color: AppColors.backgroundLight,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeItem(InvoiceDetail fee) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              fee.feeName,
              style: AppTextStyles.normal500(
                fontSize: 16,
                color: AppColors.backgroundDark,
              ),
            ),
          ),
          Row(
            children: [
              const NairaSvgIcon(color: AppColors.paymentTxtColor3),
              const SizedBox(width: 4),
              Text(
                fee.amount.toStringAsFixed(2),
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.paymentTxtColor3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentBottomSheet() {
    final activeFees = widget.invoice.invoiceDetails.where((fee) => fee.amount > 0).toList();
    final totalAmount = activeFees.fold(0.0, (sum, fee) => sum + fee.amount);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _PaymentBottomSheet(
          student: widget.student,
          invoice: widget.invoice,
          fees: activeFees,
          totalAmount: totalAmount,
          onPaymentSuccess: () {
            Navigator.pop(context); // Close bottom sheet
            Navigator.pop(context); // Go back to previous screen
            CustomToaster.toastSuccess(
              context,
              'Payment Successful',
              'Payment has been processed successfully',
            );
          },
          onPaymentError: (error) {
            Navigator.pop(context); // Close bottom sheet
            CustomToaster.toastError(
              context,
              'Payment Failed',
              error,
            );
          },
        );
      },
    );
  }
}

class _PaymentBottomSheet extends StatefulWidget {
  final UnpaidStudent student;
  final UnpaidInvoice invoice;
  final List<InvoiceDetail> fees;
  final double totalAmount;
  final VoidCallback onPaymentSuccess;
  final Function(String) onPaymentError;

  const _PaymentBottomSheet({
    required this.student,
    required this.invoice,
    required this.fees,
    required this.totalAmount,
    required this.onPaymentSuccess,
    required this.onPaymentError,
  });

  @override
  State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  bool _isProcessing = false;
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(ApiService());
    _amountController.text = widget.totalAmount.toStringAsFixed(2);
    _selectedDate = DateTime.now();
    _dateController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
    
    // Generate a reference number
    _referenceController.text = 'REF${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _processPayment() async {
    if (_referenceController.text.isEmpty) {
      widget.onPaymentError('Please enter a payment reference');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final success = await _paymentService.makePayment(
        invoiceId: widget.invoice.id.toString(),
        reference: _referenceController.text,
        regNo: widget.student.regNo,
        name: widget.student.name,
        fees: widget.fees,
        amount: widget.totalAmount,
        classId: widget.student.classId,
        levelId: widget.student.levelId,
        year: widget.invoice.year,
        term: widget.invoice.term,
      );

      if (success) {
        widget.onPaymentSuccess();
      } else {
        widget.onPaymentError('Payment processing failed. Please try again.');
      }
    } catch (e) {
      widget.onPaymentError('An error occurred: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Details',
                style: AppTextStyles.normal600(
                  fontSize: 20,
                  color: const Color.fromRGBO(47, 85, 221, 1),
                ),
              ),
              IconButton(
                icon: SvgPicture.asset('assets/icons/profile/cancel_receipt.svg'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField('Student name', widget.student.name, enabled: false),
          const SizedBox(height: 16),
          _buildInputField('Amount', '₦${widget.totalAmount.toStringAsFixed(2)}', controller: _amountController),
          const SizedBox(height: 16),
          _buildInputField('Reference', 'Enter payment reference', controller: _referenceController),
          const SizedBox(height: 16),
          _buildDateInputField(context, 'Payment Date'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Process Payment',
                      style: AppTextStyles.normal500(
                        fontSize: 18,
                        color: AppColors.backgroundLight,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {bool enabled = true, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.normal500(
            fontSize: 16.0,
            color: AppColors.backgroundDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: enabled,
          controller: enabled ? controller : TextEditingController(text: hint),
          decoration: InputDecoration(
            hintText: enabled ? hint : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInputField(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.normal500(
            fontSize: 16,
            color: AppColors.backgroundDark,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_dateController.text.isEmpty ? 'Select date' : _dateController.text),
                SvgPicture.asset('assets/icons/profile/calendar_icon.svg'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
// import 'package:linkschool/modules/model/profile/student_model.dart';
// import 'package:linkschool/modules/model/profile/vendor_transaction_model.dart';
// import 'package:linkschool/modules/admin/payment/settings/vendor/vendor_transaction_receipts_screen.dart';

// import '../../../model/admin/vendor/vendor_transaction_year.dart';

// class StudentPaymentDetailsScreen extends StatefulWidget {
//   final StudentPayment student;

//   const StudentPaymentDetailsScreen({super.key, required this.student});

//   @override
//   State<StudentPaymentDetailsScreen> createState() => _StudentPaymentDetailsScreenState();
// }

// class _StudentPaymentDetailsScreenState extends State<StudentPaymentDetailsScreen> {
//   late double opacity;

//   // Helper method to create VendorTransaction from StudentPayment
//   VendorTransaction _createVendorTransaction() {
//     // Convert the amount string to double, removing the ₦ symbol and any commas
//     String cleanAmount = widget.student.amount.replaceAll('₦', '').replaceAll(',', '');
//     double amount = double.tryParse(cleanAmount) ?? 0.0;
    

//     return VendorTransaction(
//       amount: amount,
//       dateTime: DateTime.now().toString(), // Current date/time
//       name: widget.student.name,
//       phoneNumber: widget.student.phoneNumber ?? '', // Assuming this exists in StudentPayment
//       session: '2023/2024', // You might want to make this dynamic
//       reference: 'REF-${DateTime.now().millisecondsSinceEpoch}', // Generate unique reference
//       description: 'Second Term Fee Charges', 
//       period: '',
//     );
//   }

//   // Method to show payment bottom sheet
//   void _showPaymentBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return _PaymentBottomSheet(
//           studentName: widget.student.name,
//           totalAmount: '356,870.00',
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;

//     // Extract the numeric part of the amount string (remove the ₦ symbol)
//     String amountValue = widget.student.amount.replaceAll('₦', '');
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           widget.student.name,
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.paymentTxtColor1,
//           ),
//         ),
//         centerTitle: true,
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
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // Card with dynamic content and shadow
//                 Card(
//                   elevation: 4.0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // First section: Centralized SVG icon
//                         Center(
//                             child: SvgPicture.asset(
//                                 'assets/icons/profile/success_receipt_icon.svg',
//                                 height: 60)),
        
//                         const SizedBox(height: 16),
        
//                         // Second section: Text description
//                         Center(
//                           child: Text(
//                             'Second Term Fee Charges for 2017/2018 Session',
//                             textAlign: TextAlign.center,
//                             style: AppTextStyles.normal500(
//                                 fontSize: 18, color: AppColors.backgroundDark),
//                           ),
//                         ),
        
//                         const SizedBox(height: 16),
        
//                         // Divider between sections
//                         const Divider(),
        
//                         // Third section: Fee rows
//                         ListView.builder(
//                           shrinkWrap: true, // Allows ListView inside a Column
//                           itemCount: 10, // Number of fee items (dummy data)
//                           itemBuilder: (context, index) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 8.0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text('Bus fee',
//                                       style: AppTextStyles.normal400(
//                                           fontSize: 14,
//                                           color: AppColors.paymentTxtColor5)),
//                                   Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const NairaSvgIcon(
//                                           color: AppColors.paymentTxtColor5),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         amountValue,
//                                         style: AppTextStyles.normal500(
//                                           fontSize: 14,
//                                           color: AppColors.paymentTxtColor5,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
        
//                         const Divider(),
        
//                         // Fourth section: Total Amount
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('Total amount to pay',
//                                 style: AppTextStyles.normal400(
//                                     fontSize: 14,
//                                     color: AppColors.paymentTxtColor5)),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 NairaSvgIcon(color: AppColors.backgroundDark),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   '356,870.00',
//                                   style: AppTextStyles.normal500(
//                                       fontSize: 18,
//                                       color: AppColors.backgroundDark),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         color: const Color.fromRGBO(47, 85, 221, 1),
//         height: 85,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Total amount to pay',
//                     style: AppTextStyles.normal500(
//                         fontSize: 16, color: AppColors.backgroundLight)),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const NairaSvgIcon(color: Colors.white),
//                     const SizedBox(width: 4),
//                     Text(
//                       '356,870.00',
//                       style: AppTextStyles.normal600(
//                           fontSize: 26, color: AppColors.backgroundLight),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: _showPaymentBottomSheet, // Changed to show bottom sheet
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 backgroundColor: Colors.white,
//                 foregroundColor: const Color.fromRGBO(47, 85, 221, 1),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 'Proceed to pay',
//                 style: AppTextStyles.normal500(
//                     fontSize: 16, color: AppColors.paymentTxtColor1),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Payment Bottom Sheet similar to AddReceiptBottomSheet
// class _PaymentBottomSheet extends StatefulWidget {
//   final String studentName;
//   final String totalAmount;

//   const _PaymentBottomSheet({
//     required this.studentName,
//     required this.totalAmount,
//   });

//   @override
//   State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
// }

// class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _referenceController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();
//   DateTime? _selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill the amount field with the total amount
//     _amountController.text = widget.totalAmount;
//     // Set today's date as default
//     _selectedDate = DateTime.now();
//     _dateController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _referenceController.dispose();
//     _dateController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2025),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//         _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
//       });
//     }
//   }

//   void _processPayment() {
//     // Handle payment processing logic here
//     // You can validate the form fields and proceed with payment
//     Navigator.pop(context);
    
//     // Show success message or navigate to payment gateway
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Processing payment...'),
//         backgroundColor: Color.fromRGBO(47, 85, 221, 1),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//         left: 16,
//         right: 16,
//         top: 16,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Payment Details',
//                 style: AppTextStyles.normal600(
//                   fontSize: 20,
//                   color: const Color.fromRGBO(47, 85, 221, 1),
//                 ),
//               ),
//               IconButton(
//                 icon: SvgPicture.asset('assets/icons/profile/cancel_receipt.svg'),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildInputField('Student name', widget.studentName, enabled: false),
//           const SizedBox(height: 16),
//           _buildInputField('Amount', '₦${widget.totalAmount}', controller: _amountController),
//           const SizedBox(height: 16),
//           _buildInputField('Reference', 'Enter payment reference', controller: _referenceController),
//           const SizedBox(height: 16),
//           _buildDateInputField(context, 'Payment Date'),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _processPayment,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromRGBO(47, 85, 221, 1),
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//               ),
//               child: Text(
//                 'Process Payment',
//                 style: AppTextStyles.normal500(
//                   fontSize: 18,
//                   color: AppColors.backgroundLight,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputField(String label, String hint, {bool enabled = true, TextEditingController? controller}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.normal500(
//             fontSize: 16.0,
//             color: AppColors.backgroundDark,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           enabled: enabled,
//           controller: enabled ? controller : TextEditingController(text: hint),
//           decoration: InputDecoration(
//             hintText: enabled ? hint : null,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateInputField(BuildContext context, String label) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.normal500(
//             fontSize: 16,
//             color: AppColors.backgroundDark,
//           ),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: () => _selectDate(context),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(_dateController.text.isEmpty ? 'Select date' : _dateController.text),
//                 SvgPicture.asset('assets/icons/profile/calendar_icon.svg'),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }