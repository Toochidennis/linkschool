// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin_portal/profile/settings/vendor/vendor_setting_screen.dart';
import 'package:linkschool/modules/admin_portal/profile/settings/account_setting_screen.dart';
import 'package:linkschool/modules/admin_portal/profile/settings/fee_setting/fee_setting_screen.dart';

class PaymentSettingScreen extends StatefulWidget {
  const PaymentSettingScreen({super.key});

  @override
  State<PaymentSettingScreen> createState() => _PaymentSettingScreenState();
}

class _PaymentSettingScreenState extends State<PaymentSettingScreen> {
  late double opacity;

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
          'Settings',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSettingsRow(
                icon: 'assets/icons/profile/account.svg',
                title: 'Account',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountSettingScreen()),
                ),
              ),
              _buildSettingsRow(
                icon: 'assets/icons/profile/fee.svg',
                title: 'Fee Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeeSettingScreen()),
                ),
              ),
              _buildSettingsRow(
                icon: 'assets/icons/profile/fee_amount.svg',
                title: 'Vendor',
                // onTap: () {}
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VendorSettingsScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.eLearningBtnColor1,
          child: SvgPicture.asset(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: SvgPicture.asset('assets/icons/profile/next_page.svg'),
        onTap: onTap,
      ),
    );
  }
}