import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/model/profile/student_model.dart';

class StudentPaymentDetailsScreen extends StatelessWidget {
  final StudentPayment student;

  const StudentPaymentDetailsScreen({Key? key, required this.student}) : super(key: key);

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
          student.name,
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Card with dynamic content and shadow
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First section: Centralized SVG icon
                      Center(child: SvgPicture.asset('assets/icons/profile/success_receipt_icon.svg', height: 60)),

                      const SizedBox(height: 16),
                      
                      // Second section: Text description
                      const Text(
                        'Second Term Fee Charges for 2017/2018 Session',
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Divider between sections
                      const Divider(),

                      // Third section: Fee rows
                      ListView.builder(
                        shrinkWrap: true, // Allows ListView inside a Column
                        itemCount: 10, // Number of fee items (dummy data)
                        itemBuilder: (context, index) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Bus fee', style: TextStyle(color: Colors.grey)),
                                Text('₦3000', style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          );
                        },
                      ),

                      const Divider(),

                      // Fourth section: Total Amount
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total amount to pay', style: TextStyle(color: Colors.grey)),
                          Text('₦356,870.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Color.fromRGBO(47, 85, 221, 1),
        height: 85,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total amount to pay', style: TextStyle(color: Colors.white)),
                Text('₦356,870.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.white,
                foregroundColor: const Color.fromRGBO(47, 85, 221, 1),
              ),
              child: const Text('Proceed to pay'),
            ),
          ],
        ),
      ),
    );
  }
}
