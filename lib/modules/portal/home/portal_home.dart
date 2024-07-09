import 'package:flutter/material.dart';
import 'package:linkschool/modules/portal/home/portal_news_item.dart';
import 'package:linkschool/modules/portal/home/results/grading_settings.dart';
// import 'package:linkschool/modules/portal/home/results/assessment_settings.dart';

import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../common/text_styles.dart';
import '../../explore/home/custom_button_item.dart';
import 'history_item.dart';
import 'results/assessment_settings.dart';

class PortalHome extends StatefulWidget {
  const PortalHome({super.key});

  @override
  State<PortalHome> createState() => _PortalHomeState();
}

class _PortalHomeState extends State<PortalHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: Constants.customBoxDecoration(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search',
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                        color: Color.fromRGBO(139, 139, 139, 1),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: AppColors.textFieldLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                        gapPadding: 4.0,
                      ),
                    ),
                  ),
                ),
              ),
              Constants.headingWithSeeAll600(
                title: 'Watch history',
                titleSize: 16.0,
                titleColor: AppColors.text2Light,
              ),
              SizedBox(
                height: 175,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    HistoryItem(),
                    HistoryItem(),
                    HistoryItem(marginRight: 16.0),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'You can...',
                  style: AppTextStyles.title3Light,
                ),
              ),
              const SizedBox(height: 10.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButtonItem(
                        backgroundColor: AppColors.portalButton1Light,
                        borderColor: AppColors.portalButton1BorderLight,
                        label: 'Check\nResults',
                        iconPath: 'assets/icons/result.svg',
                        iconHeight: 40.0,
                        iconWidth: 36.0,
                        destination: AssessmentSettingScreen(),
                      ),
                    ),
                    SizedBox(width: 14.0),
                    Expanded(
                      child: CustomButtonItem(
                        backgroundColor: AppColors.portalButton2Light,
                        borderColor: AppColors.portalButton2BorderLight,
                        label: 'Make\nPayment',
                        iconPath: 'assets/icons/payment.svg',
                        iconHeight: 40.0,
                        iconWidth: 36.0,
                        destination: GradingSettingsScreen(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'News',
                      style: AppTextStyles.title3Light,
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(),
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Column(
                children: [
                  PortalNewsItem(
                    profileImageUrl:
                        'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
                    name: 'John Doe',
                    newsContent:
                        'This is a mock data showing the info details of a recording.',
                    time: '2 hours ago',
                  ),
                  PortalNewsItem(
                    profileImageUrl:
                        'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
                    name: 'Vanguard news',
                    newsContent:
                        'This is a mock data showing the info details of a recording.',
                    time: '2 minutes ago',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
