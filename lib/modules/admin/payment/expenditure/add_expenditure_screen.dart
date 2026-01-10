import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/admin/payment/settings/vendor/account_selection_screen.dart';
import 'package:linkschool/modules/admin/payment/settings/widgets/vendor_selection_overlay.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/naira_icon.dart';
import 'package:linkschool/modules/model/admin/account_model.dart';
import 'package:linkschool/modules/model/admin/expenditure_model.dart';
import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';
import 'package:linkschool/modules/providers/admin/payment/account_provider.dart';
import 'package:linkschool/modules/services/admin/payment/expenditure_service.dart';
import 'package:linkschool/modules/services/admin/payment/vendor_service.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:linkschool/modules/admin/payment/settings/widgets/naira_icon.dart';
import 'package:provider/provider.dart';

class AddExpenditureScreen extends StatefulWidget {
  final Vendor vendor;
  final Expenditure? expenditure;

  const AddExpenditureScreen({
    super.key,
    required this.vendor,
    this.expenditure,
  });

  @override
  State<AddExpenditureScreen> createState() => _AddExpenditureScreenState();
}

class _AddExpenditureScreenState extends State<AddExpenditureScreen> {
  late TextEditingController _vendorNameController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _referenceController;
  late TextEditingController _accountTypeController;
  late TextEditingController _descriptionController;

  Vendor? _selectedVendor;
  AccountModel? _selectedAccount;
  List<Vendor> _vendors = [];
  bool _isLoading = false;
  bool _isEditMode = false;

  final VendorService _vendorService = locator<VendorService>();
  final ExpenditureService _expenditureService = locator<ExpenditureService>();

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.expenditure != null;
    _vendorNameController = TextEditingController();
    _amountController = TextEditingController();
    _dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _referenceController = TextEditingController();
    _accountTypeController = TextEditingController();
    _descriptionController = TextEditingController();

    _selectedVendor = widget.vendor;
    _vendorNameController.text = _selectedVendor!.vendorName;
    _referenceController.text = _selectedVendor!.reference ?? '';

    if (_isEditMode) {
      _populateFields();
    }

    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    setState(() => _isLoading = true);
    final response = await _vendorService.fetchVendors();
    if (response.success && response.data != null) {
      _vendors = response.data!;
      if (_isEditMode && _vendors.isNotEmpty) {
        _selectedVendor = _vendors.firstWhere(
          (v) => v.id == widget.expenditure!.customerId,
          orElse: () => widget.vendor,
        );
        _vendorNameController.text = _selectedVendor!.vendorName;
        _referenceController.text = _selectedVendor!.reference ?? '';
      }
    } else {
      CustomToaster.toastError(context, 'Error', response.message);
    }
    setState(() => _isLoading = false);
  }

  void _populateFields() {
    final exp = widget.expenditure!;
    _amountController.text = exp.amount.toStringAsFixed(2);
    _dateController.text = exp.date;
    _referenceController.text = exp.customerReference;
    _descriptionController.text = exp.description;
    _accountTypeController.text = exp.accountName;

    // Fetch accounts and set selected account
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    accountProvider.fetchAccounts().then((_) {
      if (accountProvider.allAccounts.isNotEmpty) {
        setState(() {
          _selectedAccount = accountProvider.allAccounts.firstWhere(
            (acc) => acc.accountNumber == exp.accountNumber,
            orElse: () => AccountModel(
              id: 0,
              accountName: '',
              accountType: 0,
              accountNumber: '',
              inactive: '',
            ),
          );
          _accountTypeController.text = _selectedAccount!.accountName;
        });
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitExpenditure() async {
    // Validate inputs
    if (_selectedVendor == null) {
      CustomToaster.toastWarning(context, 'Warning', 'Please select a vendor');
      return;
    }
    if (_selectedAccount == null) {
      CustomToaster.toastWarning(
          context, 'Warning', 'Please select an account');
      return;
    }
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      CustomToaster.toastWarning(
          context, 'Warning', 'Please enter a valid amount');
      return;
    }
    if (_dateController.text.isEmpty) {
      CustomToaster.toastWarning(context, 'Warning', 'Please select a date');
      return;
    }
    if (_descriptionController.text.isEmpty) {
      CustomToaster.toastWarning(
          context, 'Warning', 'Please enter a description');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settings = authProvider.settings ?? {};
    final year = settings['year'] ?? DateTime.now().year;
    final term = settings['term'] ?? 1;

    final payload = {
      'customer_id': _selectedVendor!.id,
      'customer_reference': _referenceController.text,
      'customer_name': _selectedVendor!.vendorName,
      'description': _descriptionController.text,
      'amount': double.parse(_amountController.text),
      'date': _dateController.text,
      'account_number': _selectedAccount!.accountNumber,
      'account_name': _selectedAccount!.accountName,
      'year': year,
      'term': term,
    };

    setState(() => _isLoading = true);
    ApiResponse<void> response;
    if (_isEditMode) {
      response = await _expenditureService.updateExpenditure(
          widget.expenditure!.id, payload);
    } else {
      response = await _expenditureService.addExpenditure(payload);
    }

    setState(() => _isLoading = false);

    if (response.success) {
      CustomToaster.toastSuccess(
        context,
        'Success',
        _isEditMode
            ? 'Expenditure updated successfully'
            : 'Expenditure added successfully',
      );
      Navigator.pop(context);
    } else {
      CustomToaster.toastError(context, 'Error', response.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          _isEditMode ? 'Edit Expenditure' : 'Add Expenditure',
          style: AppTextStyles.normal600(
              fontSize: 24, color: AppColors.paymentTxtColor1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Vendor Name
                  _buildFormField(
                    label: 'Vendor Name',
                    controller: _vendorNameController,
                    readOnly: true,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => VendorSelectionOverlay(
                          vendors: _vendors,
                          onVendorSelected: (vendor) {
                            setState(() {
                              _selectedVendor = vendor;
                              _vendorNameController.text = vendor.vendorName;
                              _referenceController.text =
                                  vendor.reference ?? '';
                            });
                          },
                        ),
                      );
                    },
                    suffixIcon: Icons.arrow_drop_down,
                  ),
                  const SizedBox(height: 20),

                  // Amount
                  _buildFormField(
                    label: 'Amount',
                    controller: _amountController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: SizedBox(
                      width: 16,
                      height: 16,
                      child: const NairaSvgIcon(
                        color: AppColors.backgroundDark,
                        width: 12.0,
                        height: 12.0,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                      maxWidth: 16,
                      maxHeight: 16,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date
                  _buildFormField(
                    label: 'Date',
                    controller: _dateController,
                    readOnly: true,
                    suffixIcon: Icons.calendar_today,
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 20),

                  // Reference Number
                  _buildFormField(
                    label: 'Reference Number',
                    controller: _referenceController,
                  ),
                  const SizedBox(height: 20),

                  // Account Type
                  _buildFormField(
                    label: 'Account Type',
                    controller: _accountTypeController,
                    readOnly: true,
                    hintText: 'Select account',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AccountSelectionScreen()),
                      );
                      if (result != null && result is AccountModel) {
                        setState(() {
                          _selectedAccount = result;
                          _accountTypeController.text = result.accountName;
                        });
                      }
                    },
                    suffixIcon: Icons.arrow_drop_down,
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildFormField(
                    label: 'Description (required)',
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _submitExpenditure,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.paymentTxtColor1,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _isEditMode ? 'Update Record' : 'Record Expenditure',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    VoidCallback? onSuffixPressed,
    String? prefixText,
    String? hintText,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    BoxConstraints? prefixIconConstraints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.normal500(
              fontSize: 14, color: AppColors.backgroundDark),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixIcon: prefixIcon,
            prefixIconConstraints: prefixIconConstraints,
            hintText: hintText,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: AppColors.paymentTxtColor1),
                    onPressed: onSuffixPressed ?? onTap,
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _referenceController.dispose();
    _accountTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
