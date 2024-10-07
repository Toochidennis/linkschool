// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';

class FeeSettingScreen extends StatefulWidget {
  const FeeSettingScreen({Key? key}) : super(key: key);

  @override
  State<FeeSettingScreen> createState() => _FeeSettingScreenState();
}

class _FeeSettingScreenState extends State<FeeSettingScreen> {
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
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Fee Settings',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.primaryLight,
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
          child: ListView(
            children: [
              _buildFeeRow('Bus Fee', isRequired: true),
              _buildFeeRow('Development Fee', isRequired: false),
              _buildFeeRow('Examination Fee', isRequired: true),
              _buildFeeRow('T-Fair Fee', isRequired: false),
              _buildFeeRow('Bus Fee', isRequired: true),
              _buildFeeRow('Development Fee', isRequired: false),
              _buildFeeRow('Examination Fee', isRequired: true),
              _buildFeeRow('T-Fair Fee', isRequired: false),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: AppColors.backgroundLight,
          size: 24,
        ),
        onPressed: () => _showAddFeeOverlay(context),
        backgroundColor: AppColors.primaryLight,
      ),
    );
  }

  Widget _buildFeeRow(String title, {required bool isRequired}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: SvgPicture.asset('assets/icons/profile/fee.svg',
              color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(
          isRequired ? 'Required' : 'Not Required',
          style: TextStyle(color: Colors.grey),
        ),
        trailing: SvgPicture.asset('assets/icons/profile/edit_pen.svg'),
      ),
    );
  }

  void _showAddFeeOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Fee',
                  style: AppTextStyles.normal600(
                      fontSize: 18, color: AppColors.primaryLight)),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter fee name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: Colors.green,
                  ),
                  Text('Required'),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  // CustomOutlineButton(
                  //     onPressed: () => Navigator.pop(context),
                  //     text: "Cancel",
                  //     borderColor: AppColors.eLearningRedBtnColor,
                  //     textColor: AppColors.eLearningRedBtnColor),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.eLearningRedBtnColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Cancel',
                            style: AppTextStyles.normal500(
                                fontSize: 18,
                                color: AppColors.eLearningRedBtnColor)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.eLearningBtnColor5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Confirm',
                            style: AppTextStyles.normal600(
                                fontSize: 16.0,
                                color: AppColors.backgroundLight)),
                      ),
                    ),
                  ),
                  // CustomMediumElevatedButton(
                  //     text: 'Confirm',
                  //     onPressed: () => Navigator.pop(context),
                  //     backgroundColor: AppColors.eLearningBtnColor5,
                  //     textStyle: AppTextStyles.normal600(
                  //         fontSize: 16, color: AppColors.backgroundLight),
                  //     padding: EdgeInsets.all(8.0))
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
