import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/custom_dropdown_utils.dart';



class TopContainer extends StatelessWidget {
  final String selectedTerm;
  final Function(String?) onTermChanged;

  const TopContainer({
    Key? key,
    required this.selectedTerm,
    required this.onTermChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: SvgPicture.asset(
                'assets/images/result/top_container.svg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.regBtnColor1,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2016/2017 academic session',
                          style: AppTextStyles.normal600(
                              fontSize: 12, color: AppColors.backgroundDark),
                        ),
                        CustomDropdown(
                          items: const [
                            'First term',
                            'Second term',
                            'Third term'
                          ],
                          value: selectedTerm,
                          onChanged: onTermChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.regAvatarColor,
                        child: Icon(Icons.person, color: AppColors.primaryLight),
                      ),
                      const SizedBox(width: 12),
                      Text('Registered students',
                          style: AppTextStyles.normal500(
                              fontSize: 14, color: AppColors.backgroundLight)),
                      const SizedBox(width: 18),
                      Container(
                          width: 1,
                          height: 40,
                          color: AppColors.backgroundLight),
                      const SizedBox(width: 18),
                      Text(
                        '345',
                        style: AppTextStyles.normal700(
                            fontSize: 24, color: AppColors.backgroundLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
