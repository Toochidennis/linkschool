// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/admin_portal/payment/settings/fee_setting/fee_setting_details_screen.dart';


class FeeSettingScreen extends StatefulWidget {
  const FeeSettingScreen({super.key});

  @override
  State<FeeSettingScreen> createState() => _FeeSettingScreenState();
}

class _FeeSettingScreenState extends State<FeeSettingScreen> {
  late double opacity;
  bool isRequired = false;
  String selectedClass = '';

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        title: Text(
          'Fee Settings',
          style: AppTextStyles.normal600(
            fontSize: 24.0,
            color: AppColors.eLearningBtnColor1,
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFeeOverlay(context),
        backgroundColor: AppColors.videoColor4,
        child: Icon(
          Icons.add,
          color: AppColors.backgroundLight,
          size: 24,
        ),
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
          backgroundColor: AppColors.eLearningBtnColor1,
          child: SvgPicture.asset('assets/icons/profile/fee.svg',
              color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(
          isRequired ? 'Required' : 'Not Required',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  void _showAddFeeOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add Fee',
                      style: AppTextStyles.normal600(
                          fontSize: 18, color: AppColors.eLearningBtnColor1)),
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
                        value: isRequired,
                        onChanged: (value) {
                          setState(() {
                            isRequired = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      Text('Required'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
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
                          onPressed: () => _showClassSelectionOverlay(context),
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
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

void _showClassSelectionOverlay(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundLight,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Class',
                  style: AppTextStyles.normal600(
                    fontSize: 20,
                    color: const Color.fromRGBO(47, 85, 221, 1),
                  ),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: ListView.builder(
                    itemCount: 3, // Replace with your actual class list length
                    itemBuilder: (context, index) {
                      // Replace with your actual class list data
                      List<String> classes = ['Basic One A', 'Basic One B', 'Basic Two A'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            _navigateToFeeDetailsScreen(context, classes[index]);
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
                            classes[index],
                            style: const TextStyle(fontSize: 16),
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
      );
    },
  );
}

  void _navigateToFeeDetailsScreen(BuildContext context, String className) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeeSettingDetailsScreen(className: className),
      ),
    );
  }
}