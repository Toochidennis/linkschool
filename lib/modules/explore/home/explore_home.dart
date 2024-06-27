import 'package:flutter/material.dart';

import '../../common/text_styles.dart';
import '../../../modules/explore/games/games_home.dart';
import '../../../modules/explore/videos/videos_home.dart';
import '../../common/app_colors.dart';
import '../../../modules/explore/ebooks/ebooks_dashboard.dart';
import '../../common/constants.dart';
import '../../../modules/explore/cbt/cbt_home.dart';
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
    return Container(
      height: double.infinity,
      decoration: Constants.customBoxDecoration(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: SingleChildScrollView(
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
                padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0,),
                child: Column(
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
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleLarge,
                            ),
                            Text(
                              'By Digital Dreams',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleSmall,
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
                                color: AppColors.buttonColor2,
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
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Explore', style: AppTextStyles.title3Light),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          CustomIconButton(
                            backgroundColor: AppColors.exploreButton1Light,
                            borderColor: AppColors.exploreButton1BorderLight,
                            text: 'CBT',
                            iconPath: 'assets/icons/cbt.svg',
                            destination: CBTHome(),
                          ),
                          SizedBox(height: 14.0),
                          CustomIconButton(
                            backgroundColor: AppColors.exploreButton2Light,
                            borderColor: AppColors.exploreButton2BorderLight,
                            text: 'Videos',
                            iconPath: 'assets/icons/video.svg',
                            destination: VideosHome(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        children: [
                          CustomIconButton(
                            backgroundColor: AppColors.exploreButton3Light,
                            borderColor: AppColors.exploreButton3BorderLight,
                            text: 'E-Books',
                            iconPath: 'assets/icons/e-books.svg',
                            destination: BooksHome(),
                          ),
                          SizedBox(height: 14.0),
                          CustomIconButton(
                            backgroundColor: AppColors.exploreButton4Light,
                            borderColor: AppColors.exploreButton4BorderLight,
                            text: 'Games',
                            iconPath: 'assets/icons/games.svg',
                            destination: GamesHome(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
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
                  NewsItem(
                    profileImageUrl: 'https://via.placeholder.com/300',
                    name: 'John Doe',
                    newsContent:
                    'This is a mock data showing the info details of a recording.',
                    time: '2 hours ago',
                    imageUrl:
                    'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
                  ),
                  NewsItem(
                    profileImageUrl:
                    'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
                    name: 'Vanguard news',
                    newsContent:
                    'This is a mock data showing the info details of a recording.',
                    time: '2 minutes ago',
                    imageUrl: 'https://via.placeholder.com/300',
                  ),
                  NewsItem(
                    profileImageUrl:
                    'https://img.freepik.com/free-vector/gradient-human-rights-day-background_52683-149974.jpg?t=st=1717832829~exp=1717833429~hmac=3e938edcacd7fef2a791b36c7d3decbf64248d9760dd7da0a304acee382b8a86',
                    name: 'Vanguard news',
                    newsContent:
                    'This is a mock data showing the info details of a recording.',
                    time: '2 minutes ago',
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
