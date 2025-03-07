import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';

class StaffProfileScreen extends StatelessWidget {
  late double opacity;
  final String name;
  final String mobile = '+234 819 567 000'; // Sample mobile number
  final String email = 'joraphkeke@gmail.com'; // Sample email
  final String guardianName =
      'Mrs Chioma Josephine Okeke'; // Sample guardian name
  final List<String> phoneNumbers = [
    '+234 819 567 000',
    '+234 819 567 000'
  ]; // Sample phone numbers
  final String address = '425 Wallaby Way, Sydney, Australia'; // Sample address

  StaffProfileScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.paymentTxtColor1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset('assets/icons/arrow_back.png',
              color: AppColors.backgroundLight, width: 34.0, height: 34.0),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            decoration: const BoxDecoration(
              color: AppColors.paymentTxtColor1,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Column(
              children: [
                // Circle with icon
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.paymentTxtColor1,
                  ),
                ),
                const SizedBox(height: 10.0),
                // Name and Mobile
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  'Mobile $mobile',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20.0),
                // Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconColumn('assets/icons/staff/phone_icon.svg'),
                    const SizedBox(
                      height: 30, // Match the height of your icons
                      child: VerticalDivider(
                        color: AppColors.backgroundLight,
                        thickness: 2,
                        width: 20, // Add some width to make it more visible
                      ),
                    ),
                    _buildIconColumn('assets/icons/staff/message_icon.svg'),
                    const SizedBox(
                      height: 30, // Match the height of your icons
                      child: VerticalDivider(
                        color: AppColors.backgroundLight,
                        thickness: 2,
                        width: 20, // Add some width to make it more visible
                      ),
                    ),
                    _buildIconColumn(
                        'assets/icons/staff/whatsapp_call_icon.svg'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          // Bottom Section
          Expanded(
            child: Container(
              decoration: Constants.customBoxDecoration(context),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              // color: Colors.white,
              child: ListView(
                children: [
                  // Email Address
                  _buildSectionHeader('Email address'),
                  _buildRowWithIcon(
                    svgIcon: 'assets/icons/staff/email_icon.svg',
                    text: email,
                  ),
                  const Divider(),

                  // Guardian Information
                  _buildSectionHeader('Guardian Information'),
                  const SizedBox(height: 5.0),
                  _buildSubText('Name'),
                  const SizedBox(height: 5.0),
                  Text(
                    guardianName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  // Phone Numbers
                  _buildSubText('Phone number'),
                  const SizedBox(height: 5.0),
                  for (String phoneNumber in phoneNumbers)
                    Text(
                      phoneNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  const Divider(),

                  // Address
                  _buildSubText('Address'),
                  const SizedBox(height: 5.0),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(),

                  // Button
                  ElevatedButton(
                    onPressed: () {
                      // Action for the button
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.staffCtnColor2,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'See student results',
                          style: TextStyle(
                            color: AppColors.paymentTxtColor1,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/icons/staff/arrow_forward_icon.svg',
                          // color: Colors.blue,
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildIconColumn(String svgPath) {
    return Column(
      children: [
        SvgPicture.asset(
          svgPath,
          // width: 30,
          // height: 30,
          // color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.paymentTxtColor1),
      ),
    );
  }

  Widget _buildRowWithIcon({required String svgIcon, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SvgPicture.asset(svgIcon, width: 24, height: 24),
          const SizedBox(width: 10.0),
          Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildSubText(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}
