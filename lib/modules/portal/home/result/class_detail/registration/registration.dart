import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal_result_register/button_section.dart';
import 'package:linkschool/modules/common/widgets/portal_result_register/history_section.dart';
import 'package:linkschool/modules/common/widgets/portal_result_register/top_container.dart';


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String _selectedTerm = 'First term';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registration',
          style: AppTextStyles.normal600(
              fontSize: 18.0, color: AppColors.primaryLight),
        ),
        centerTitle: true,
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
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopContainer(
              selectedTerm: _selectedTerm,
              onTermChanged: (newValue) {
                setState(() {
                  _selectedTerm = newValue!;
                });
              },
            ),
            ButtonSection(),
            const SizedBox(height: 25),
            HistorySection(),
          ],
        ),
      ),
    );
  }
}