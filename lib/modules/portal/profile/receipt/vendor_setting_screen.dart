import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/profile/vendor_transaction_model.dart';
import 'package:linkschool/modules/portal/profile/receipt/vendor_transaction_screen.dart';

class VendorSettingsScreen extends StatelessWidget {
  final List<String> vendorNames = [
    'Okoro Ifeanyi',
    'Joe Nwachi',
    'Charles Uche',
    'Samuel Ikechi',
    'Ugonna Emma',
    'Francis Mike',
    'George Akanny',
    'Helen Ibe',
    'Mike Ifeanyi',
    'Juliet Ikenna',
  ];

  VendorSettingsScreen({Key? key}) : super(key: key);

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
        title: Text(
          'Vendor Settings',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextField(
          //     decoration: InputDecoration(
          //       hintText: 'Search vendors...',
          //       prefixIcon: const Icon(Icons.search),
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(8.0),
          //       ),
          //     ),
          //   ),
          // ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Vendor...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  // onChanged: (value) {
                  //   setState(() {
                  //     searchQuery = value;
                  //   });
                  // },
                ),
              ),
          Expanded(
            child: ListView.builder(
              itemCount: vendorNames.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.paymentTxtColor1,
                        child: Text(
                          vendorNames[index][0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(vendorNames[index]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VendorTransactionScreen(
                              vendorName: vendorNames[index],
                            ),
                          ),
                        );
                      },
                    ),
                    // Add Divider unless it's the last item
                    if (index != vendorNames.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(),
                      )
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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

