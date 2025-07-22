import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/profile/add_vendor_overlay.dart';

class AddExpenditureScreen extends StatefulWidget {
  const AddExpenditureScreen({super.key});

  @override
  State<AddExpenditureScreen> createState() => _AddExpenditureScreenState();
}

class _AddExpenditureScreenState extends State<AddExpenditureScreen> {
  String selectedVendor = 'Somtochukwu Raphael';
  List<String> vendorOptions = [
    'Somtochukwu Raphael',
    'John Ifeanyi',
    'Jane Joseph'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                // Show the AddVendorOverlay when the "Add vendor" button is pressed
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddVendorOverlay(),
                );
              },
              child: Text(
                'Add vendor',
                style: AppTextStyles.normal500(
                    fontSize: 16, color: AppColors.paymentTxtColor1),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vendor Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendor Name:',
                  style: AppTextStyles.normal500(
                      fontSize: 14, color: AppColors.backgroundDark),
                ),
                const SizedBox(height: 12,),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: vendorOptions
                              .map((vendor) => ListTile(
                                    title: Text(vendor),
                                    onTap: () {
                                      setState(() {
                                        selectedVendor = vendor;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ))
                              .toList(),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedVendor),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount(₦):',
                  style: AppTextStyles.normal500(
                      fontSize: 14, color: AppColors.backgroundDark),
                ),
                const SizedBox(height: 12,),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date:',
                  style: AppTextStyles.normal500(
                      fontSize: 14, color: AppColors.backgroundDark),
                ),
                const SizedBox(height: 12,),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'dd-mm-yyyy',
                    suffixIcon: const Icon(Icons.calendar_today, color: AppColors.paymentTxtColor1,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Reference Number Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reference number:',
                  style: AppTextStyles.normal500(
                      fontSize: 14, color: AppColors.backgroundDark),
                ),
                const SizedBox(height: 12,),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Account Type Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Type:',
                  style: AppTextStyles.normal500(
                      fontSize: 14, color: AppColors.backgroundDark),
                ),
                const SizedBox(height: 12,),
                InkWell(
                  onTap: () {
                    // Handle account type dropdown
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Select Account Type'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description (required):',
                  style: AppTextStyles.normal500(
                      fontSize: 14, color: AppColors.backgroundDark),
                ),
                const SizedBox(height: 12,),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Record Expenditure Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.paymentTxtColor1,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Record expenditure',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
