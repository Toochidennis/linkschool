import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class SeeAllHistory extends StatefulWidget{
  const SeeAllHistory({super.key});

  @override
  State<SeeAllHistory> createState() => _SeeAllHistoryState();
}

class _SeeAllHistoryState extends State<SeeAllHistory>{
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
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: AppColors.regBgColor1,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('History',
                  style: AppTextStyles.normal600(
                      fontSize: 16, color: AppColors.backgroundDark)),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 90,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('2015/2016 academic session',
                            style: AppTextStyles.normal700(
                                fontSize: 14, color: AppColors.backgroundDark)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text('345',
                            style: AppTextStyles.normal600(
                                fontSize: 12, color: AppColors.regTextGray)),
                        const SizedBox(width: 10),
                        Text('students registered',
                            style: AppTextStyles.normal600(
                                fontSize: 11, color: AppColors.regTextGray)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}