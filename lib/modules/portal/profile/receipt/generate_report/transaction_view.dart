import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 327,
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(209, 219, 255, 1),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Termly report'),
                SvgPicture.asset('assets/icons/profile/filter_icon.svg'),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Handle date picker
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Row(
                      children: [
                        Text('February 2023'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Handle session picker
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('2023/2024 3rd Term'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
       Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 10, // Replace with actual data length
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/profile/payment_icon.svg'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dennis Johnson',
                             style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
                          ),
                          Text(
                            '07-03-2018 17:13',
                            style: AppTextStyles.normal400(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '23,790.00',
                      style: AppTextStyles.normal600(fontSize: 16, color: AppColors.backgroundDark),
                    ),
                  ],
                ),
              );
            },
          ),
        ),        
      ],
    );
  }
}