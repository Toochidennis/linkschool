// New file: modules/admin/payment/widgets/vendor_selection_overlay.dart
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/admin/vendor/vendor_model.dart';

class VendorSelectionOverlay extends StatelessWidget {
  final List<Vendor> vendors;
  final Function(Vendor) onVendorSelected;

  const VendorSelectionOverlay({
    super.key,
    required this.vendors,
    required this.onVendorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Vendor',
                  style: AppTextStyles.normal600(
                    fontSize: 20,
                    color: Color.fromRGBO(47, 85, 221, 1),
                  ),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: vendors.isEmpty
                      ? Center(
                          child: Text(
                            'No vendors available',
                            style: AppTextStyles.normal500(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: vendors.length,
                          itemBuilder: (context, index) {
                            final vendor = vendors[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onVendorSelected(vendor);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  vendor.vendorName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
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
      ),
    );
  }
}