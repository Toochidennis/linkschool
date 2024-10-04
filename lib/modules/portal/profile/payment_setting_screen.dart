import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/text_styles.dart';


class PaymentSettingScreen extends StatelessWidget {
  final double? marginRight;

  const PaymentSettingScreen({super.key, this.marginRight});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(child: Text('data'),)
      ],
    );
  }
}
