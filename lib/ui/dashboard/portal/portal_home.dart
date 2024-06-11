import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/ui/dashboard/portal/portal_news_item.dart';

import '../../../common/app_colors.dart';
import '../../../common/text_styles.dart';
import '../explore/custom_button.dart';
import 'history_item.dart';

class PortalHome extends StatefulWidget {
  const PortalHome({super.key});

  @override
  State<PortalHome> createState() => _PortalHomeState();
}

class _PortalHomeState extends State<PortalHome> {
  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    final opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(
            'assets/images/img.png',
          ),
          opacity: opacity,
        ),
      ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Watch history',
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
                      child: CustomButton(
                        backgroundColor: AppColors.portalButton1Light,
                        borderColor: AppColors.portalButton1BorderLight,
                        text: 'Check\nResults',
                        iconPath: 'assets/icons/result.svg',
                        height: 40.0,
                        width: 36.0,
                      ),
                    ),
                    SizedBox(width: 14.0),
                    Expanded(
                      child: CustomButton(
                        backgroundColor: AppColors.portalButton2Light,
                        borderColor: AppColors.portalButton2BorderLight,
                        text: 'Make\nPayment',
                        iconPath: 'assets/icons/payment.svg',
                        height: 40.0,
                        width: 36.0,
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
