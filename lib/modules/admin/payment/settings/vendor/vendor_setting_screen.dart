import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';
import 'package:linkschool/modules/services/admin/payment/vendor_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/admin/payment/settings/vendor/vendor_transaction_screen.dart';


class VendorSettingsScreen extends StatefulWidget {
  const VendorSettingsScreen({super.key});

  @override
  State<VendorSettingsScreen> createState() => _VendorSettingsScreenState();
}


class _VendorSettingsScreenState extends State<VendorSettingsScreen> {
  late double opacity;
  List<Vendor> vendors = [];
  List<Vendor> filteredVendors = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final VendorService _vendorService = locator<VendorService>();

  @override
  void initState() {
    super.initState();
    _fetchVendors();
    _searchController.addListener(_filterVendors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVendors() async {
    setState(() {
      isLoading = true;
    });
    final response = await _vendorService.fetchVendors();
    if (response.success && response.data != null) {
      setState(() {
        // Sort vendors by ID in descending order to show newest first
        vendors = response.data!.reversed.toList();
        filteredVendors = vendors;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      CustomToaster.toastError(context, 'Error', response.message);
    }
  }

  void _filterVendors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredVendors = vendors.where((vendor) =>
          vendor.vendorName.toLowerCase().contains(query)).toList();
    });
  }

  void _showAddVendorModal(BuildContext context) {
    final vendorNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneNumberController = TextEditingController();
    final addressController = TextEditingController();
    final referenceController = TextEditingController();
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
                      'Add Vendor',
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
                                final response = await _vendorService.addVendor(
                                  vendorName: vendorNameController.text,
                                  phoneNumber: phoneNumberController.text,
                                  email: emailController.text,
                                  address: addressController.text,
                                  reference: referenceController.text,
                                );
                                if (response.success) {
                                  CustomToaster.toastSuccess(
                                      context, 'Success', 'Vendor added successfully');
                                  Navigator.pop(context);
                                  _fetchVendors();
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
                              'Add vendor',
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

  Future<void> _deleteVendor(int vendorId, String vendorName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $vendorName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await _vendorService.deleteVendor(vendorId);
      if (response.success) {
        CustomToaster.toastSuccess(context, 'Success', 'Vendor deleted successfully');
        _fetchVendors();
      } else {
        CustomToaster.toastError(context, 'Error', response.message);
      }
    }
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
        title: Text(
          'Vendor Settings',
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Vendor...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredVendors.isEmpty
                      ? const Center(child: Text('No vendors found'))
                      : ListView.builder(
                          itemCount: filteredVendors.length,
                          itemBuilder: (context, index) {
                            final vendor = filteredVendors[index];
                            return Column(
                              children: [
                                Dismissible(
                                  key: Key(vendor.id.toString()),
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  secondaryBackground: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    return await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: Text(
                                            'Are you sure you want to delete ${vendor.vendorName}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onDismissed: (direction) async {
                                    await _deleteVendor(
                                        vendor.id, vendor.vendorName);
                                  },
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.paymentTxtColor1,
                                      child: Text(
                                        vendor.vendorName[0],
                                        style:
                                            const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(vendor.vendorName),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VendorTransactionScreen(
                                            vendor: vendor,
                                          ),
                                        ),
                                      );
                                    },
                                    onLongPress: () => _deleteVendor(
                                        vendor.id, vendor.vendorName),
                                  ),
                                ),
                                if (index != filteredVendors.length - 1)
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Divider(),
                                  )
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVendorModal(context),
        backgroundColor: AppColors.videoColor4,
        child: const Icon(
          Icons.add,
          color: AppColors.backgroundLight,
          size: 24,
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/constants.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';
// import 'package:linkschool/modules/services/admin/payment/vendor_service.dart';
// // import 'package:linkschool/modules/model/vendor.dart';
// // import 'package:linkschool/modules/services/admin/vendor_service.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';
// import 'package:linkschool/modules/common/custom_toaster.dart';
// import 'package:linkschool/modules/admin/payment/settings/vendor/vendor_transaction_screen.dart';

// class VendorSettingsScreen extends StatefulWidget {
//   const VendorSettingsScreen({super.key});

//   @override
//   State<VendorSettingsScreen> createState() => _VendorSettingsScreenState();
// }

// class _VendorSettingsScreenState extends State<VendorSettingsScreen> {
//   late double opacity;
//   List<Vendor> vendors = [];
//   List<Vendor> filteredVendors = [];
//   bool isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//   final VendorService _vendorService = locator<VendorService>();

//   @override
//   void initState() {
//     super.initState();
//     _fetchVendors();
//     _searchController.addListener(_filterVendors);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchVendors() async {
//     setState(() {
//       isLoading = true;
//     });
//     final response = await _vendorService.fetchVendors();
//     if (response.success && response.data != null) {
//       setState(() {
//         vendors = response.data!;
//         filteredVendors = vendors;
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       CustomToaster.toastError(context, 'Error', response.message);
//     }
//   }

//   void _filterVendors() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       filteredVendors = vendors.where((vendor) =>
//           vendor.vendorName.toLowerCase().contains(query)).toList();
//     });
//   }

//   void _showAddVendorModal(BuildContext context) {
//     final vendorNameController = TextEditingController();
//     final emailController = TextEditingController();
//     final phoneNumberController = TextEditingController();
//     final addressController = TextEditingController();
//     final referenceController = TextEditingController();
//     final formKey = GlobalKey<FormState>();

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
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Add Vendor',
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
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildFormField(
//                           'Vendor name',
//                           'Enter vendor name',
//                           vendorNameController,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Vendor name is required';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         _buildFormField(
//                           'Email (optional)',
//                           'Enter email',
//                           emailController,
//                           validator: (value) {
//                             if (value != null && value.isNotEmpty) {
//                               if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                                   .hasMatch(value)) {
//                                 return 'Enter a valid email';
//                               }
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         _buildFormField(
//                           'Phone number',
//                           'Enter phone number',
//                           phoneNumberController,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Phone number is required';
//                             }
//                             if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
//                               return 'Enter a valid phone number';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         _buildFormField(
//                           'Address',
//                           'Enter address',
//                           addressController,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Address is required';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         _buildFormField(
//                           'Reference number',
//                           'Enter reference number',
//                           referenceController,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Reference number is required';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 24),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               if (formKey.currentState!.validate()) {
//                                 final response = await _vendorService.addVendor(
//                                   vendorName: vendorNameController.text,
//                                   phoneNumber: phoneNumberController.text,
//                                   email: emailController.text,
//                                   address: addressController.text,
//                                   reference: referenceController.text,
//                                 );
//                                 if (response.success) {
//                                   CustomToaster.toastSuccess(
//                                       context, 'Success', 'Vendor added successfully');
//                                   Navigator.pop(context);
//                                   _fetchVendors();
//                                 } else {
//                                   CustomToaster.toastError(
//                                       context, 'Error', response.message);
//                                 }
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.paymentTxtColor1,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Text(
//                               'Add vendor',
//                               style: AppTextStyles.normal600(
//                                 fontSize: 16.0,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _deleteVendor(int vendorId, String vendorName) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Delete'),
//         content: Text('Are you sure you want to delete $vendorName?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       final response = await _vendorService.deleteVendor(vendorId);
//       if (response.success) {
//         CustomToaster.toastSuccess(context, 'Success', 'Vendor deleted successfully');
//         _fetchVendors();
//       } else {
//         CustomToaster.toastError(context, 'Error', response.message);
//       }
//     }
//   }

//   Widget _buildFormField(
//     String label,
//     String hint,
//     TextEditingController controller, {
//     String? Function(String?)? validator,
//   }) {
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
//         TextFormField(
//           controller: controller,
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
//           validator: validator,
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
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
//           'Vendor Settings',
//           style: AppTextStyles.normal600(
//             fontSize: 24.0,
//             color: AppColors.paymentTxtColor1,
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
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search Vendor...',
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : filteredVendors.isEmpty
//                       ? const Center(child: Text('No vendors found'))
//                       : ListView.builder(
//                           itemCount: filteredVendors.length,
//                           itemBuilder: (context, index) {
//                             final vendor = filteredVendors[index];
//                             return Column(
//                               children: [
//                                 ListTile(
//                                   leading: CircleAvatar(
//                                     backgroundColor: AppColors.paymentTxtColor1,
//                                     child: Text(
//                                       vendor.vendorName[0],
//                                       style: const TextStyle(color: Colors.white),
//                                     ),
//                                   ),
//                                   title: Text(vendor.vendorName),
//                                   trailing: IconButton(
//                                     icon: const Icon(Icons.delete, color: Colors.red),
//                                     onPressed: () => _deleteVendor(vendor.id, vendor.vendorName),
//                                   ),
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => VendorTransactionScreen(
//                                           vendor: vendor,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 if (index != filteredVendors.length - 1)
//                                   const Padding(
//                                     padding: EdgeInsets.symmetric(horizontal: 16.0),
//                                     child: Divider(),
//                                   )
//                               ],
//                             );
//                           },
//                         ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddVendorModal(context),
//         backgroundColor: AppColors.videoColor4,
//         child: const Icon(
//           Icons.add,
//           color: AppColors.backgroundLight,
//           size: 24,
//         ),
//       ),
//     );
//   }
// }