// ignore_for_file: unused_local_variable

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/modules/explore/home/news/all_news_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:linkschool/modules/explore/home/explore_item.dart';
import 'package:linkschool/modules/explore/home/news/news_details.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:provider/provider.dart';
import '../../common/text_styles.dart';
import '../../../modules/explore/games/games_home.dart';
import '../../../modules/explore/videos/videos_dashboard.dart';
import '../../common/app_colors.dart';
import '../../../modules/explore/ebooks/ebooks_dashboard.dart';
import '../../common/constants.dart';
import '../../../modules/explore/cbt/cbt_dashboard.dart';
import 'custom_button_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ExploreHome extends StatefulWidget {
  final Function(bool) onSearchIconVisibilityChanged;

  const ExploreHome({super.key, required this.onSearchIconVisibilityChanged});

  @override
  State<ExploreHome> createState() => _ExploreHomeState();
}

class _ExploreHomeState extends State<ExploreHome> {
  late ScrollController _controller;
  bool _showSearchBar = true;
  bool isLoading = true;

  void _shareNews(String title, String content, String time, String imageUrl) {
    // Format the complete news content for sharing
    String shareText = '''
📰 $title

📅 Published: $time

📝 Content:
$content

${imageUrl.isNotEmpty ? '🖼️ Image: $imageUrl' : ''}

#LinkSchool #News
''';
    
    Share.share(shareText);
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_onScroll);

    // Fetch news data when the widget is initialized
    Future.microtask(
        () => Provider.of<NewsProvider>(context, listen: false).fetchNews());

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  _navigatorAllNews() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AllnewsScreen()));
  }

  void _onScroll() {
    if (_controller.offset > 10 && _showSearchBar) {
      setState(() {
        _showSearchBar = false;
        widget.onSearchIconVisibilityChanged(_showSearchBar);
      });
    } else if (_controller.offset <= 10 && !_showSearchBar) {
      setState(() {
        _showSearchBar = true;
        widget.onSearchIconVisibilityChanged(_showSearchBar);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    // String formattedDate = DateFormat('MMMM d, y')
    //     .format(DateTime.parse(newsProvider.newsmode.datePosted));

   List<ExploreItem> exploreItemsList = [
  ExploreItem(
    backgroundColor: AppColors.exploreButton1Light,
    borderColor: AppColors.exploreButton1BorderLight,
    label: 'CBT',
    textColor: AppColors.backgroundLight,
    iconPath: 'assets/icons/cbt.svg',
    destination: const CBTDashboard(),
    subtitle: 'Practice tests',
  ),
  // ExploreItem(
  //   backgroundColor: AppColors.exploreButton3Light,
  //   borderColor: AppColors.exploreButton3BorderLight,
  //   label: 'E-Books',
  //   iconPath: 'assets/icons/e-books.svg',
  //   destination: const EbooksDashboard(),
  //   subtitle: 'Read & learn',
  // ),
  ExploreItem(
    backgroundColor: AppColors.exploreButton2Light,
    borderColor: AppColors.exploreButton2BorderLight,
    label: 'Videos',
    iconPath: 'assets/icons/video.svg',
    destination: const VideosDashboard(),
    subtitle: 'Watch tutorials',
  ),
  // ExploreItem(
  //   backgroundColor: AppColors.exploreButton4Light,
  //   borderColor: AppColors.exploreButton4BorderLight,
  //   label: 'Games',
  //   iconPath: 'assets/icons/games.svg',
  //   destination: const GamesDashboard(),
  //   subtitle: 'Fun learning',
  // ),
];

    return Container(
      decoration: Constants.customBoxDecoration(context),
    padding: const EdgeInsets.only(bottom: 90.0, ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _controller,
        slivers: [
        
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.text2Light.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.explore_rounded,
                      color: AppColors.text2Light,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Explore',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: AppColors.text2Light,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 14.0,
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 14.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = exploreItemsList[index];
                  return exploreButtonItem(
                    backgroundColor: item.backgroundColor,
                    borderColor: item.backgroundColor,
                    label: item.label,
                    iconPath: item.iconPath,
                    subtitle: item.subtitle,
                    destination: item.destination,
                  );
                },
                childCount: exploreItemsList.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.text2Light.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.gamepad_rounded,
                      color: AppColors.text2Light,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recommendations',
                    style: AppTextStyles.normal600(
                      fontSize: 20,
                      color: AppColors.text2Light,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 10.0)),


            SliverToBoxAdapter(
            child: CarouselSlider(
              items: [
                _buildSuggestedGameCard(leftPadding: 16.0),
                _buildSuggestedGameCard(),
                _buildSuggestedGameCard(rightPadding: 16.0),
              ],
              options: CarouselOptions(
                height: 265.0,
                padEnds: false,
                viewportFraction: 0.95,
                autoPlay: true,
                enableInfiniteScroll: false,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.text2Light.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.article_rounded,
                          color: AppColors.text2Light,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'News',
                        style: AppTextStyles.normal600(
                          fontSize: 20,
                          color: AppColors.text2Light,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _navigatorAllNews,
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: AppColors.text2Light,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final news = newsProvider.latestNews[index];
                // final dop = news.date_posted;

                Duration difference = detemethods(news.date_posted);
                return GestureDetector(
                    // onTap: () => (),
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetails(
                                news: news, time: formatDuration(difference)),
                          ),
                        ),
                    child: _buildNewsItem(
                      title: news.title,
                      newsContent: news.content,
                      time: formatDuration(difference),
                      imageUrl: news.image_url,
                      userLikeCounts: news.user_like,
                      likesCounts: news.likes,
                      category: news.category,
                    ));
              },
              childCount: newsProvider.latestNews.length,
            ),
          ),
        ],
      ),
    );
  }

  Duration detemethods(String dopString) {
    // String dopString = "2024-02-15T12:00:00.000Z"; // Example value from API
    DateTime dop = DateTime.parse(dopString); // Convert to DateTime
    DateTime nowDateTime = DateTime.now();
    // Duration difference = nowDateTime.difference(dop);
    // DateTime nowDateTime = DateTime.now();
    Duration difference = nowDateTime.difference(dop);
    return difference;
  }

  //  String timeAgo = formatDuration(difference);

  String formatDuration(Duration duration) {
    if (duration.isNegative) return 'just now';

    final seconds = duration.inSeconds;
    if (seconds < 60) return '$seconds seconds ago';

    final minutes = duration.inMinutes;
    if (minutes < 60) return '$minutes minutes ago';

    final hours = duration.inHours;
    if (hours < 24) return '$hours hours ago';

    final days = duration.inDays;
    if (days < 7) return '$days days ago';

    return '${days ~/ 7} weeks ago';
  }

  Widget _buildSuggestedGameCard({
    double? leftPadding,
    double? rightPadding,
  }) {
    return Padding(
      padding: EdgeInsets.only(
          left: leftPadding ?? 10.0, right: rightPadding ?? 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGameImage(),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(child: _buildGameInfo()),
              _buildPlayButton(),
            ],
          ),
        ],
      ),
    );
  }

// Widget for the game image
  Widget _buildGameImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.asset(
        'assets/images/millionaire.png',
        fit: BoxFit.cover,
        height: 180,
      ),
    );
  }

// Widget for the game title and developer information
  Widget _buildGameInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Millionaire Game',
            style:TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w300,
              color: Colors.black,
              fontFamily: 'Urbanist',
          ),),
          Text(
            'By Digital Dreams',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
              fontFamily: 'Urbanist',
          ),)
        ],
      ),
    );
  }

// Widget for the play button
  Widget _buildPlayButton() {
    return Container(
      height: 30.0,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.buttonColor2,
            AppColors.buttonColor3,
          ],
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: OutlinedButton(
          onPressed: () {
            // Handle button press
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.buttonColor1,
            shape: RoundedRectangleBorder(

              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              'Play',
              style:
                  AppTextStyles.normal500(fontSize: 14.0, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget exploreButtonItem({
  required Color backgroundColor,
  required Color borderColor,
  required String subtitle,
  required String label,
  required String iconPath,
  required Widget destination,
  Color? textColor,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Urbanist',
                ),
                textAlign: TextAlign.center,
              ),
              SvgPicture.asset(
                iconPath,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  textColor ?? Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
         
          Text(
            subtitle,
            style: TextStyle(
               fontSize: 12,
               color:  Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildNewsItem({
    required String title,
    required String newsContent,
    required String time,
    required String imageUrl,
    required dynamic userLikeCounts,
    required dynamic likesCounts,
    required String category,
  }) {
    // Map category to colors
    Color categoryColor;
    switch (category) {
      case 'WAEC':
        categoryColor = Colors.orange;
        break;
      case 'JAMB':
        categoryColor = Colors.blue;
        break;
      case 'Admission':
        categoryColor = Colors.purple;
        break;
      case 'Scholarships':
        categoryColor = Colors.green;
        break;
      case 'General':
      default:
        categoryColor = Colors.grey;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image thumbnail on the left
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image,
                    size: 30,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // Content on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: AppColors.text2Light,
                  ),
                ),
                const SizedBox(height: 4.0),
                
                // Description
                Text(
                  newsContent,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal400(
                    fontSize: 13.0,
                    color: AppColors.text4Light,
                  ),
                ),
                const SizedBox(height: 8.0),
                
                // Category badge and time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.text4Light,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: AppTextStyles.normal400(
                        fontSize: 11.0,
                        color: AppColors.text4Light,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
