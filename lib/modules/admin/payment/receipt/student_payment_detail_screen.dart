import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

import '../../../common/app_colors.dart';
import '../../../common/constants.dart';
import '../../../common/custom_toaster.dart';
import '../../../common/text_styles.dart';
import '../../../common/widgets/portal/profile/naira_icon.dart';
import '../../../model/admin/payment_model.dart';
import '../../../services/admin/payment/payment_service.dart';
import '../../../services/api/api_service.dart';

class StudentPaymentDetailScreen extends StatefulWidget {
  final UnpaidStudent student;
  final UnpaidInvoice invoice;

  const StudentPaymentDetailScreen({
    super.key,
    required this.student,
    required this.invoice,
  });

  @override
  State<StudentPaymentDetailScreen> createState() =>
      _StudentPaymentDetailScreenState();
}

class _StudentPaymentDetailScreenState
    extends State<StudentPaymentDetailScreen> {
  late double opacity;
  late PaymentService _paymentService;
  final bool _isProcessingPayment = false;
  final Map<String, bool> _selectedFees = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeCheckboxStates();
  }

  void _initializeServices() {
    try {
      final userBox = Hive.box('userData');
      final token = userBox.get('token');

      if (token == null || token.toString().isEmpty) {
        print('No authentication token found. User needs to login again.');
        return;
      }

      final apiService = ApiService();
      apiService.setAuthToken(token.toString());
      _paymentService = PaymentService(apiService);

      print('ApiService initialized with authentication token');
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  void _initializeCheckboxStates() {
    final activeFees =
        widget.invoice.invoiceDetails.where((fee) => fee.amount > 0).toList();
    for (var fee in activeFees) {
      _selectedFees[fee.feeId] = true; // All selected by default
    }
    _selectAll = true;
  }

  double get _calculateSelectedTotal {
    final activeFees =
        widget.invoice.invoiceDetails.where((fee) => fee.amount > 0).toList();
    return activeFees
        .where((fee) => _selectedFees[fee.feeId] == true)
        .fold(0.0, (sum, fee) => sum + fee.amount);
  }

  List<InvoiceDetail> get _getSelectedFees {
    final activeFees =
        widget.invoice.invoiceDetails.where((fee) => fee.amount > 0).toList();
    return activeFees.where((fee) => _selectedFees[fee.feeId] == true).toList();
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      final activeFees =
          widget.invoice.invoiceDetails.where((fee) => fee.amount > 0).toList();
      for (var fee in activeFees) {
        _selectedFees[fee.feeId] = _selectAll;
      }
    });
  }

  void _toggleFeeSelection(String feeId, bool? value) {
    setState(() {
      _selectedFees[feeId] = value ?? false;

      // Update select all state
      final activeFees =
          widget.invoice.invoiceDetails.where((fee) => fee.amount > 0).toList();
      _selectAll = activeFees.every((fee) => _selectedFees[fee.feeId] == true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;

    // Filter out fees with zero amount
    final activeFees =
        widget.invoice.invoiceDetails.where((fee) => fee.amount > 0).toList();
    final selectedTotal = _calculateSelectedTotal;

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
        child: Column(
          children: [
            Expanded(
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
                                  _paymentService.getClassName(
                                          widget.student.classId) ??
                                      'Unknown Class',
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

                    // Fee Breakdown Header with Select All
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fee Breakdown',
                          style: AppTextStyles.normal600(
                            fontSize: 18,
                            color: AppColors.backgroundDark,
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _selectAll,
                              onChanged: _toggleSelectAll,
                              activeColor: const Color.fromRGBO(47, 85, 221, 1),
                            ),
                            Text(
                              'Select All',
                              style: AppTextStyles.normal500(
                                fontSize: 14,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: activeFees
                            .map((fee) => _buildFeeItem(fee))
                            .toList(),
                      ),
                    ),

                    const SizedBox(
                        height: 100), // Added space for fixed bottom section
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Total Amount
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(47, 85, 221, 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color.fromRGBO(47, 85, 221, 0.3)),
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
                            const NairaSvgIcon(
                                color: Color.fromRGBO(47, 85, 221, 1)),
                            const SizedBox(width: 4),
                            Text(
                              selectedTotal.toStringAsFixed(2),
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

                  const SizedBox(height: 16),

                  // Proceed to Pay Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isProcessingPayment || selectedTotal == 0)
                          ? null
                          : () => _showPaymentBottomSheet(),
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
          ],
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
        children: [
          Checkbox(
            value: _selectedFees[fee.feeId] ?? false,
            onChanged: (value) => _toggleFeeSelection(fee.feeId, value),
            activeColor: const Color.fromRGBO(47, 85, 221, 1),
          ),
          const SizedBox(width: 8),
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
    final selectedFees = _getSelectedFees;
    final selectedTotal = _calculateSelectedTotal;

    if (selectedFees.isEmpty) {
      CustomToaster.toastError(
        context,
        'No Fees Selected',
        'Please select at least one fee to proceed with payment',
      );
      return;
    }

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
          fees: selectedFees, // Pass only selected fees
          totalAmount: selectedTotal, // Pass calculated total
          paymentService: _paymentService,
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
  final PaymentService paymentService;
  final VoidCallback onPaymentSuccess;
  final Function(String) onPaymentError;

  const _PaymentBottomSheet({
    required this.student,
    required this.invoice,
    required this.fees,
    required this.totalAmount,
    required this.paymentService,
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

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.totalAmount.toStringAsFixed(2);
    _selectedDate = DateTime.now();
    _dateController.text =
        "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";

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
      final success = await widget.paymentService.makePayment(
        invoiceId: widget.invoice.id.toString(),
        reference: _referenceController.text,
        studentId: widget.student.studentId,
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
                icon:
                    SvgPicture.asset('assets/icons/profile/cancel_receipt.svg'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField('Student name', widget.student.name, enabled: false),
          const SizedBox(height: 16),
          _buildInputField(
              'Amount', '₦${widget.totalAmount.toStringAsFixed(2)}',
              controller: _amountController),
          const SizedBox(height: 16),
          _buildInputField('Reference', 'Enter payment reference',
              controller: _referenceController),
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

  Widget _buildInputField(String label, String hint,
      {bool enabled = true, TextEditingController? controller}) {
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
                Text(_dateController.text.isEmpty
                    ? 'Select date'
                    : _dateController.text),
                SvgPicture.asset('assets/icons/profile/calendar_icon.svg'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
