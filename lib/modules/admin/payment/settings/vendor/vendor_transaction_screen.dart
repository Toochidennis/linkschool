// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';
import 'package:linkschool/modules/model/profile/vendor_transaction_model.dart';
import 'package:linkschool/modules/services/admin/payment/vendor_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/admin/payment/expenditure/add_expenditure_screen.dart';
import 'package:linkschool/modules/admin/payment/settings/vendor/vendor_transaction_details_screen.dart';

class VendorTransactionScreen extends StatefulWidget {
  final Vendor vendor;

  const VendorTransactionScreen({
    super.key,
    required this.vendor,
  });

  @override
  State<VendorTransactionScreen> createState() => _VendorTransactionScreenState();
}

class _VendorTransactionScreenState extends State<VendorTransactionScreen> {
  late double opacity;
  final VendorService _vendorService = locator<VendorService>();
  late Vendor _currentVendor;

  // Sample transaction data
  final List<VendorTransaction> transactions = [
    VendorTransaction(
      period: '2022/2023',
      dateTime: '07-03-2018  17:23',
      amount: 23790.00,
      description: 'Clinical medication',
      name: 'Joseph Raphael',
      phoneNumber: '+234 819 567 000',
      reference: 'REF123456',
      session: '2022/2023',
    ),
    VendorTransaction(
      period: '2022/2023',
      dateTime: '08-03-2018  10:45',
      amount: 15600.00,
      description: 'Laboratory supplies',
      name: 'Joseph Raphael',
      phoneNumber: '+234 819 567 000',
      reference: 'REF123457',
      session: '2022/2023',
    ),
    VendorTransaction(
      period: '2022/2023',
      dateTime: '09-03-2018  14:30',
      amount: 31250.00,
      description: 'Medical equipment',
      name: 'Joseph Raphael',
      phoneNumber: '+234 819 567 000',
      reference: 'REF123458',
      session: '2022/2023',
    ),
    VendorTransaction(
      period: '2022/2023',
      dateTime: '10-03-2018  09:15',
      amount: 18900.00,
      description: 'Pharmaceutical supplies',
      name: 'Joseph Raphael',
      phoneNumber: '+234 819 567 000',
      reference: 'REF123459',
      session: '2022/2023',
    ),
    VendorTransaction(
      period: '2022/2023',
      dateTime: '11-03-2018  16:20',
      amount: 27500.00,
      description: 'Medical consumables',
      name: 'Joseph Raphael',
      phoneNumber: '+234 819 567 000',
      reference: 'REF123460',
      session: '2022/2023',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentVendor = widget.vendor;
  }

  void _navigateToTransactionDetails(
      BuildContext context, VendorTransaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorTransactionDetailsScreen(
          transaction: transaction,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showAddVendorModal(BuildContext context, {bool isEdit = false}) {
    final vendorNameController = TextEditingController(text: isEdit ? _currentVendor.vendorName : '');
    final emailController = TextEditingController(text: isEdit ? _currentVendor.email : '');
    final phoneNumberController = TextEditingController(text: isEdit ? _currentVendor.phoneNumber : '');
    final addressController = TextEditingController(text: isEdit ? _currentVendor.address : '');
    final referenceController = TextEditingController(text: isEdit ? _currentVendor.reference : '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Vendor' : 'Vendor Info',
                      style: AppTextStyles.normal600(
                        fontSize: 20.0,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.primaryLight,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormField(
                          'Vendor name',
                          'Enter vendor name',
                          vendorNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vendor name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Email (optional)',
                          'Enter email',
                          emailController,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Phone number',
                          'Enter phone number',
                          phoneNumberController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Address',
                          'Enter address',
                          addressController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Address is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Reference number',
                          'Enter reference number',
                          referenceController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Reference number is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final response = await _vendorService.updateVendor(
                                  vendorId: _currentVendor.id,
                                  vendorName: vendorNameController.text,
                                  phoneNumber: phoneNumberController.text,
                                  email: emailController.text,
                                  address: addressController.text,
                                  reference: referenceController.text,
                                );
                                if (response.success) {
                                  setState(() {
                                    _currentVendor = Vendor(
                                      id: _currentVendor.id,
                                      vendorName: vendorNameController.text,
                                      phoneNumber: phoneNumberController.text,
                                      email: emailController.text,
                                      address: addressController.text,
                                      reference: referenceController.text,
                                    );
                                  });
                                  CustomToaster.toastSuccess(
                                      context, 'Success', 'Vendor updated successfully');
                                  Navigator.pop(context);
                                } else {
                                  CustomToaster.toastError(
                                      context, 'Error', response.message);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.paymentTxtColor1,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Update Vendor',
                              style: AppTextStyles.normal600(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormField(
    String label,
    String hint,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.normal500(
            fontSize: 14.0,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
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
            color: AppColors.paymentTxtColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Vendor Info',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.paymentTxtColor1,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // First Section - Profile Container
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 25),
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _currentVendor.vendorName,
                            style: AppTextStyles.normal600(
                                fontSize: 18, color: AppColors.paymentTxtColor1),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/profile/location.svg',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _currentVendor.address ?? 'No address provided',
                                style: AppTextStyles.normal400(
                                    fontSize: 14, color: AppColors.backgroundDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Phone',
                                style: AppTextStyles.normal400(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _currentVendor.phoneNumber,
                                style: AppTextStyles.normal500(
                                    fontSize: 14, color: AppColors.backgroundDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.paymentTxtColor1,
                      child: SvgPicture.asset(
                        'assets/icons/profile/profile_icon.svg',
                        color: Colors.white,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),

                // Second Section - Buttons
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddVendorModal(context, isEdit: true),
                        icon: SvgPicture.asset(
                          'assets/icons/profile/edit_pen.svg',
                          color: AppColors.backgroundLight,
                          width: 20,
                          height: 20,
                        ),
                        label: Text('Edit details', style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundLight)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.paymentTxtColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExpenditureScreen(vendor: _currentVendor,),
                            ),
                          );
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/profile/add_icon.svg',
                          color: AppColors.paymentTxtColor1,
                          width: 20,
                          height: 20,
                        ),
                        label: Text('Expenditure', style: AppTextStyles.normal600(fontSize: 14, color: AppColors.paymentTxtColor1)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.paymentTxtColor1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Third Section - Transaction History
                const SizedBox(height: 64),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction history',
                      style: AppTextStyles.normal600(
                          fontSize: 18, color: AppColors.backgroundDark),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => _navigateToTransactionDetails(
                            context,
                            transactions[index],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/profile/payment_icon.svg',
                                  width: 36,
                                  height: 36,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transactions[index].period,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        transactions[index].dateTime,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₦${transactions[index].amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      transactions[index].description,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/profile/vendor_transaction_model.dart';
// import 'package:linkschool/modules/admin/payment/expenditure/add_expenditure_screen.dart';
// import 'package:linkschool/modules/admin/payment/settings/vendor/vendor_transaction_details_screen.dart';

// class VendorTransactionScreen extends StatefulWidget {
//   final String vendorName;


//   const VendorTransactionScreen({
//     super.key,
//     required this.vendorName,
//   });

//   @override
//   State<VendorTransactionScreen> createState() => _VendorTransactionScreenState();
// }

// class _VendorTransactionScreenState extends State<VendorTransactionScreen> {
//   late double opacity;

// // Sample transaction data
//   final List<VendorTransaction> transactions = [
//     VendorTransaction(
//       period: '2022/2023',
//       dateTime: '07-03-2018  17:23',
//       amount: 23790.00,
//       description: 'Clinical medication',
//       name: 'Joseph Raphael',
//       phoneNumber: '+234 819 567 000',
//       reference: 'REF123456',
//       session: '2022/2023',
//     ),
//     VendorTransaction(
//       period: '2022/2023',
//       dateTime: '08-03-2018  10:45',
//       amount: 15600.00,
//       description: 'Laboratory supplies',
//       name: 'Joseph Raphael',
//       phoneNumber: '+234 819 567 000',
//       reference: 'REF123457',
//       session: '2022/2023',
//     ),
//     VendorTransaction(
//       period: '2022/2023',
//       dateTime: '09-03-2018  14:30',
//       amount: 31250.00,
//       description: 'Medical equipment',
//       name: 'Joseph Raphael',
//       phoneNumber: '+234 819 567 000',
//       reference: 'REF123458',
//       session: '2022/2023',
//     ),
//     VendorTransaction(
//       period: '2022/2023',
//       dateTime: '10-03-2018  09:15',
//       amount: 18900.00,
//       description: 'Pharmaceutical supplies',
//       name: 'Joseph Raphael',
//       phoneNumber: '+234 819 567 000',
//       reference: 'REF123459',
//       session: '2022/2023',
//     ),
//     VendorTransaction(
//       period: '2022/2023',
//       dateTime: '11-03-2018  16:20',
//       amount: 27500.00,
//       description: 'Medical consumables',
//       name: 'Joseph Raphael',
//       phoneNumber: '+234 819 567 000',
//       reference: 'REF123460',
//       session: '2022/2023',
//     ),
//   ];

//   void _navigateToTransactionDetails(
//       BuildContext context, VendorTransaction transaction) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VendorTransactionDetailsScreen(
//           transaction: transaction,
//         ),
//       ),
//     );
//   }

//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey)),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
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
//             color: AppColors.paymentTxtColor1,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         title: Text(
//           'Vendor Info',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.paymentTxtColor1,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         centerTitle: true,
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
//                 // First Section - Profile Container
//                 Stack(
//                   alignment: Alignment.topCenter,
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.only(top: 25),
//                       padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           Text(
//                             widget.vendorName,
//                             style: AppTextStyles.normal600(
//                                 fontSize: 18, color: AppColors.paymentTxtColor1),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/icons/profile/location.svg',
//                                 width: 16,
//                                 height: 16,
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '20, Ogui Road Houston, TX',
//                                 style: AppTextStyles.normal400(
//                                     fontSize: 14, color: AppColors.backgroundDark),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'Phone',
//                                 style: AppTextStyles.normal400(
//                                   fontSize: 14,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '+234 819 567 000',
//                                 style: AppTextStyles.normal500(
//                                     fontSize: 14, color: AppColors.backgroundDark),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     CircleAvatar(
//                       radius: 25,
//                       backgroundColor: AppColors.paymentTxtColor1,
//                       child: SvgPicture.asset(
//                         'assets/icons/profile/profile_icon.svg',
//                         color: Colors.white,
//                         width: 24,
//                         height: 24,
//                       ),
//                     ),
//                   ],
//                 ),
        
//                 // Second Section - Buttons
//                 const SizedBox(height: 24),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _showAddVendorModal(context),
//                         icon: SvgPicture.asset(
//                           'assets/icons/profile/edit_pen.svg',
//                           color: AppColors.backgroundLight,
//                           width: 20,
//                           height: 20,
//                         ),
//                         label: Text('Edit details', style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundLight),),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.paymentTxtColor1,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 32,
//                             vertical: 12,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AddExpenditureScreen(),
//                             ),
//                           );
//                         },
//                         icon: SvgPicture.asset(
//                           'assets/icons/profile/add_icon.svg',
//                           color: AppColors.paymentTxtColor1,
//                           width: 20,
//                           height: 20,
//                         ),
//                         label: Text('Expenditure', style: AppTextStyles.normal600(fontSize: 14, color: AppColors.paymentTxtColor1),),
//                         style: OutlinedButton.styleFrom(
//                           side: const BorderSide(
//                               color: AppColors.paymentTxtColor1),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 32,
//                             vertical: 12,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
        
//                 // Third Section - Transaction History
//                 const SizedBox(height: 64),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Transaction history',
//                       style: AppTextStyles.normal600(
//                           fontSize: 18, color: AppColors.backgroundDark),
//                     ),
//                     const SizedBox(height: 16),
//                     ListView.separated(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: transactions.length,
//                       separatorBuilder: (context, index) => const Divider(),
//                       itemBuilder: (context, index) {
//                         return InkWell(
//                           onTap: () => _navigateToTransactionDetails(
//                             context,
//                             transactions[index],
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: Row(
//                               children: [
//                                 SvgPicture.asset(
//                                   'assets/icons/profile/payment_icon.svg',
//                                   width: 36,
//                                   height: 36,
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         transactions[index].period,
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       Text(
//                                         transactions[index].dateTime,
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       '₦${transactions[index].amount.toStringAsFixed(2)}',
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                     Text(
//                                       transactions[index].description,
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAddVendorModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.75,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             children: [
//               // Header section
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Vendor Info',
//                       style: AppTextStyles.normal600(
//                         fontSize: 20.0,
//                         color: AppColors.primaryLight,
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close),
//                       color: AppColors.primaryLight,
//                     ),
//                   ],
//                 ),
//               ),
//               // const Divider(),
//               // Form section
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildFormField('Vendor name', 'Vendor name'),
//                       const SizedBox(height: 16),
//                       _buildFormField('Email (optional)', 'Email (optional)'),
//                       const SizedBox(height: 16),
//                       _buildFormField('Phone number', 'Phone number'),
//                       const SizedBox(height: 16),
//                       _buildFormField('Address', 'Address'),
//                       const SizedBox(height: 16),
//                       _buildFormField('Reference number', 'Reference number'),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             // Handle record payment
//                             Navigator.pop(context);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.paymentTxtColor1,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Text(
//                             'Add Vendor',
//                             style: AppTextStyles.normal600(
//                               fontSize: 16.0,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFormField(String label, String hint) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.normal500(
//             fontSize: 14.0,
//             color: AppColors.primaryLight,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           decoration: InputDecoration(
//             hintText: hint,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }