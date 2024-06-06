import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/common/text_styles.dart';

import '../../../common/app_colors.dart';
import 'custom_button.dart';
import 'news_item.dart';

class ExploreHome extends StatefulWidget {
  const ExploreHome({super.key});

  @override
  State<ExploreHome> createState() => _ExploreHomeState();
}

class _ExploreHomeState extends State<ExploreHome> {
  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    var opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: const AssetImage('assets/images/img.png'),
            fit: BoxFit.cover,
            opacity: opacity),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
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
              const SizedBox(
                height: 16.0
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0)),
                    child: Image.asset(
                      'assets/images/millionaire.png',
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Millionaire Game',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'By Digital Dreams',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                              color: AppColors.buttonBorderColor1,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            'Play',
                            style: AppTextStyles.normal5Light,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text('Explore', style: AppTextStyles.title3Light),
              const SizedBox(height: 16.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        CustomButton(
                          backgroundColor: AppColors.exploreButton1Light,
                          borderColor: AppColors.exploreButton1BorderLight,
                          text: 'CBT',
                          iconPath: 'assets/icons/cbt.svg',
                        ),
                        SizedBox(height: 14.0),
                        CustomButton(
                          backgroundColor: AppColors.exploreButton2Light,
                          borderColor: AppColors.exploreButton2BorderLight,
                          text: 'Videos',
                          iconPath: 'assets/icons/video.svg',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      children: [
                        CustomButton(
                          backgroundColor: AppColors.exploreButton3Light,
                          borderColor: AppColors.exploreButton3BorderLight,
                          text: 'E-Books',
                          iconPath: 'assets/icons/e-books.svg',
                        ),
                        SizedBox(height: 14.0),
                        CustomButton(
                          backgroundColor: AppColors.exploreButton4Light,
                          borderColor: AppColors.exploreButton4BorderLight,
                          text: 'Games',
                          iconPath: 'assets/icons/games.svg',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
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
                      style:
                      TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              const Column(
                children:  [
                  NewsItem(
                    profileImageUrl: 'https://via.placeholder.com/150',
                    name: 'John Doe',
                    newsContent: 'This is a news content example.',
                    time: '2 hours ago',
                    imageUrl: 'https://via.placeholder.com/300',
                  ),
                  NewsItem(
                    profileImageUrl: 'https://via.placeholder.com/150',
                    name: 'Jane Smith',
                    newsContent: 'Another news content example.',
                    time: '3 hours ago',
                    imageUrl: 'https://via.placeholder.com/300',
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
