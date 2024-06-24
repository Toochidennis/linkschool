import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:linkschool/common/text_styles.dart';

import '../../common/app_colors.dart';
import '../../common/constants.dart';

class CBTHome extends StatefulWidget {
  const CBTHome({super.key});

  @override
  State<CBTHome> createState() => _CBTHomeState();
}

class _CBTHomeState extends State<CBTHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.customAppBar(context),
      body: Container(
        decoration: Constants.customBoxDecoration(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dropDownButton(),
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/icons/search.png',
                        width: 24.0,
                        height: 24.0,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildPerformanceCard(
                        imagePath: 'assets/icons/test.png',
                        title: 'Tests',
                        completionRate: '123',
                        backgroundColor: AppColors.cbtColor1,
                        borderColor: AppColors.cbtBorderColor1,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildPerformanceCard(
                        imagePath: 'assets/icons/success.png',
                        title: 'Success',
                        completionRate: '123%',
                        backgroundColor: AppColors.cbtColor2,
                        borderColor: AppColors.cbtColor2,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildPerformanceCard(
                        imagePath: 'assets/icons/average.png',
                        title: 'Average',
                        completionRate: '123%',
                        backgroundColor: AppColors.cbtColor3,
                        borderColor: AppColors.cbtColor3,
                        marginEnd: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropDownButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: AppColors.text6Light,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'WAEC',
              style: AppTextStyles.normal600(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(width: 10.0),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard({
    required String title,
    required String completionRate,
    required String imagePath,
    required Color backgroundColor,
    required Color borderColor,
    double? marginEnd,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      height: 130.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            spreadRadius: 0,
            offset: const Offset(0, 1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.25),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: 24.0,
            height: 24.0,
          ),
          const SizedBox(height: 4.0),
          Text(
            completionRate,
            style: AppTextStyles.normal600(
              fontSize: 24.0,
              color: AppColors.backgroundLight,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            title,
            style: AppTextStyles.normal600(
              fontSize: 16.0,
              color: AppColors.backgroundLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container();
  }
}
