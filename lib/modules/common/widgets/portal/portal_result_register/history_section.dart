import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/portal/result/class_detail/registration/see_all_history.dart';


class HistorySection extends StatelessWidget {
  const HistorySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SeeAllHistory()));
                },
                child: Text(
                  'See all',
                  style: AppTextStyles.normal500(
                          fontSize: 14, color: AppColors.barTextGray)
                      .copyWith(decoration: TextDecoration.underline),
                ),
              ),
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
                        SizedBox(
                          height: 24,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 0),
                              backgroundColor: AppColors.backgroundLight,
                              side: const BorderSide(
                                  color: AppColors.primaryLight),
                            ),
                            child: Text('See details',
                                style: AppTextStyles.normal500(
                                    fontSize: 12,
                                    color: AppColors.primaryLight)),
                            onPressed: () {},
                          ),
                        ),
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
