import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/dash_line.dart';

class InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 396,
      height: 190,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCardHeader(),
              const SizedBox(height: 16),
              const DashedLine(color: Colors.grey),
              const SizedBox(height: 16),
              _buildCardDate(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        _buildCardIcon(),
        const SizedBox(width: 16),
        _buildCardInfo(),
      ],
    );
  }

  Widget _buildCardIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
      child: Center(child: SvgPicture.asset('assets/icons/result/study_book.svg', width: 30, height: 30)),
    );
  }

  Widget _buildCardInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTermContainer(),
        const SizedBox(height: 4),
        Text('JSS2 A', style: AppTextStyles.normal600(fontSize: 22, color: AppColors.primaryLight)),
        const SizedBox(height: 4),
        Text('2015/2016 Academic session', style: AppTextStyles.normal500(fontSize: 14, color: AppColors.textGray)),
      ],
    );
  }

  Widget _buildTermContainer() {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.videoColor4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text('Third Term', style: AppTextStyles.normal600(fontSize: 12, color: AppColors.videoColor4)),
      ),
    );
  }

  Widget _buildCardDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text('Date :', style: AppTextStyles.normal500(fontSize: 16, color: AppColors.textGray)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text('20 July, 2024', style: AppTextStyles.normal600(fontSize: 18, color: AppColors.primaryLight)),
        ),
      ],
    );
  }
}