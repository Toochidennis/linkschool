import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class TermRow extends StatelessWidget {
  final String term;
  final double percent;
  final Color indicatorColor;
  final VoidCallback onTap;
  final bool showTopBorder;

  const TermRow({
    super.key,
    required this.term,
    required this.percent,
    required this.indicatorColor,
    required this.onTap,
    this.showTopBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 75,
        decoration: BoxDecoration(
  border: showTopBorder
      ? const Border(
          top: BorderSide(color: AppColors.borderGray, width: 1),
        )
      : null,
),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                term,
                style:
                    AppTextStyles.normal700(fontSize: 14, color: Colors.black),
              ),
              CircularPercentIndicator(
                radius: 20.0,
                lineWidth: 4.92,
                percent: percent,
                center: Text(
                  "${(percent * 100).toInt()}%",
                  style: AppTextStyles.normal600(
                      fontSize: 10, color: Colors.black),
                ),
                progressColor: indicatorColor,
                backgroundColor: Colors.transparent,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
