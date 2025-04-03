// ignore_for_file: unused_local_variable

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/explore/home/news/all_news_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:linkschool/modules/explore/home/explore_item.dart';
import 'package:linkschool/modules/explore/home/news/news_details.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:provider/provider.dart';
import '../../common/text_styles.dart';
import 'package:intl/intl.dart';
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

  @override
  void _shareURL() {
    Share.share('https://flutter.dev');
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
      ),
      ExploreItem(
        backgroundColor: AppColors.exploreButton3Light,
        borderColor: AppColors.exploreButton3BorderLight,
        label: 'E-Books',
        iconPath: 'assets/icons/e-books.svg',
        destination: const EbooksDashboard(),
      ),
      ExploreItem(
        backgroundColor: AppColors.exploreButton2Light,
        borderColor: AppColors.exploreButton2BorderLight,
        label: 'Videos',
        iconPath: 'assets/icons/video.svg',
        destination: const VideosDashboard(),
      ),
      ExploreItem(
        backgroundColor: AppColors.exploreButton4Light,
        borderColor: AppColors.exploreButton4BorderLight,
        label: 'Games',
        iconPath: 'assets/icons/games.svg',
        destination: const GamesDashboard(),
      ),
    ];

    return Container(
      decoration: Constants.customBoxDecoration(context),
      padding: const EdgeInsets.only(bottom: 90.0, top: 20),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _controller,
        slivers: [
          SliverToBoxAdapter(
            child: CarouselSlider(
              items: [
                _buildSuggestedGameCard(leftPadding: 16.0),
                _buildSuggestedGameCard(),
                _buildSuggestedGameCard(rightPadding: 16.0),
              ],
              options: CarouselOptions(
                height: 280.0,
                padEnds: false,
                viewportFraction: 0.95,
                autoPlay: true,
                enableInfiniteScroll: false,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Constants.heading600(
              title: 'Explore',
              titleSize: 20.0,
              titleColor: AppColors.text2Light,
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
                    destination: item.destination,
                  );
                },
                childCount: exploreItemsList.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Constants.headingWithSeeAll600(
              title: 'News',
              titleSize: 20.0,
              titleColor: AppColors.text2Light,
              onPressed: _navigatorAllNews,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final news = newsProvider.newsmodel[index];
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
                    ));
              },
              childCount: newsProvider.newsmodel.length,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGameInfo(),
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
        height: 200,
      ),
    );
  }

// Widget for the game title and developer information
  Widget _buildGameInfo() {
    return Column(
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
    );
  }

// Widget for the play button
  Widget _buildPlayButton() {
    return Container(
      height: 45.0,
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
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
    required String label,
    required String iconPath,
    required Widget destination,
    Color? textColor, // Make textColor optional and nullable
  }) {
    return CustomButtonItem(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      label: label,
      textColor: textColor ??
          AppColors.backgroundLight, // Provide a default color if null
      iconPath: iconPath,
      destination: destination,
    );
  }

  Widget _buildNewsItem({
    required String title,
    required String newsContent,
    required String time,
    required String imageUrl,
    required dynamic userLikeCounts,
    required dynamic likesCounts,
  }) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        if (newsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (newsProvider.errorMessage.isNotEmpty) {
          return Center(child: Text('Error: ${newsProvider.errorMessage}'));
        }

        if (newsProvider.newsmodel.isEmpty) {
          return const Center(child: Text('No news available'));
        }

        final news =
            newsProvider.newsmodel[0]; // Use the first news item for example
        return Card(
          child: newsProvider.isLoading
              ? Skeletonizer(
                  enabled: true,
                  child: Wrap(children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, top: 4, right: 16, bottom: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.normal500(
                                    fontSize: 16.0,
                                    color: AppColors.text2Light,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  newsContent,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.normal500(
                                    fontSize: 14.0,
                                    color: AppColors.text4Light,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  time,
                                  style: AppTextStyles.normal500(
                                    fontSize: 12.0,
                                    color: AppColors.text4Light,
                                  ),
                                ),
                                _buildActionButtons(),
                                SizedBox(
                                  height: 8,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          _buildNewsImage(imageUrl),
                        ],
                      ),
                    ),
                  ]),
                )
              : Wrap(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, top: 4, right: 16, bottom: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.normal500(
                                  fontSize: 16.0,
                                  color: AppColors.text2Light,
                                ),
                              ),
                              Text(time,
                                  style: AppTextStyles.normal500(
                                    fontSize: 12.0,
                                    color: AppColors.text4Light,
                                  )),
                              const SizedBox(height: 8.0),
                              Text(
                                newsContent,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.normal500(
                                  fontSize: 14.0,
                                  color: AppColors.text4Light,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              // _buildActionButtons(userLikeCounts.toString(),
                              //     likesCounts.toString())
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        _buildNewsImage(imageUrl),
                      ],
                    ),
                  ),
                  _buildActionButtons(),
                ]),
        );
      },
    );
  }

// Widget for action buttons (like, comment, share)
  Widget _buildActionButtons() {
    // final newsProvider = Provider.of<NewsProvider>(context);
    return Wrap(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // IconButton(
            //   icon: const Icon(
            //     Icons.favorite_outline,
            //     size: 15,
            //   ),
            //   onPressed: () {}, // Add your onPressed logic here
            // ),
            // Text(
            //   userLikeCounts,
            //   style: AppTextStyles.normal400L(
            //       fontSize: 10, color: AppColors.admissionTitle),
            // ),
            // // const SizedBox(width: 4.0),
            // IconButton(
            //   icon: SvgPicture.asset(
            //     'assets/icons/comment.svg',
            //     height: 15.0,
            //     width: 15.0,
            //   ),
            //   onPressed: () {},
            // ),
            // Text(
            //   likesCounts,
            //   style: AppTextStyles.normal400L(
            //       fontSize: 10, color: AppColors.admissionTitle),
            // ),
            // const
            IconButton(
                icon: Icon(Icons.share),
                // SvgPicture.asset(
                //   'assets/icons/share.svg',
                //   height: 20.0,
                //   width: 20.0,
                // ),
                onPressed: _shareURL // Add your onPressed logic here
                ),
          ],
        ),
      ],
    );
  }

// Widget for the news image
  Widget _buildNewsImage(String imageUrl) {
    return SizedBox(
      width: 80.0,
      height: 85.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
