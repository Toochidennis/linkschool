// ignore_for_file: unused_local_variable

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:linkschool/modules/explore/home/news/all_news_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:linkschool/modules/explore/home/explore_item.dart';
import 'package:linkschool/modules/explore/home/news/news_details.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:linkschool/modules/providers/explore/home/announcement_provider.dart';
import 'package:linkschool/modules/explore/videos/level_subject_selector_modal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/text_styles.dart';
import '../../../modules/explore/videos/videos_dashboard.dart';
import '../../common/app_colors.dart';
import '../../common/constants.dart';
import '../../../modules/explore/cbt/cbt_dashboard.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ExploreHome extends StatefulWidget {
  final Function(bool) onSearchIconVisibilityChanged;

  const ExploreHome({super.key, required this.onSearchIconVisibilityChanged});

  @override
  State<ExploreHome> createState() => _ExploreHomeState();
}

class _ExploreHomeState extends State<ExploreHome> with AutomaticKeepAliveClientMixin {
  late ScrollController _controller;
  bool _showSearchBar = true;
  bool isLoading = true;

  // Keep this screen alive when switching tabs/navigation
  @override
  bool get wantKeepAlive => true;

  // Custom cache manager to retain downloaded images longer
  final CacheManager _exploreCacheManager = CacheManager(
    Config(
      'exploreCacheKey',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
    ),
  );

  bool _imagesPrecached = false;

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

    // Fetch news and announcements data when the widget is initialized
    Future.microtask(() {
      Provider.of<NewsProvider>(context, listen: false).fetchNews();
      Provider.of<AnnouncementProvider>(context, listen: false)
          .fetchAnnouncements();
    });

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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  Future<void> _showLevelSubjectSelector() async {
    // Check if there's a saved level in shared preferences
    final prefs = await SharedPreferences.getInstance();
    final savedLevelId = prefs.getInt('selected_level_id');
    final savedLevelName = prefs.getString('selected_level_name');

    if (savedLevelId != null && savedLevelName != null) {
      // Navigate directly to VideosDashboard with saved level
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideosDashboard(
              levelId: savedLevelId,
              levelName: savedLevelName,
            ),
          ),
        );
      }
    } else {
      // Show modal for first-time users
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => const LevelSubjectSelectorModal(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final newsProvider = Provider.of<NewsProvider>(context);
    final announcementProvider = Provider.of<AnnouncementProvider>(context);

    // Precache images once data is available to avoid re-downloading when returning
    if (!_imagesPrecached && !newsProvider.isLoading && !announcementProvider.isLoading) {
      _imagesPrecached = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _precacheImages(newsProvider, announcementProvider);
      });
    }
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
        destination: null,
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
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Provider.of<NewsProvider>(context, listen: false).fetchNews();
            Provider.of<AnnouncementProvider>(context, listen: false)
                .fetchAnnouncements();
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _controller,
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            SliverToBoxAdapter(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      onTap: item.label == 'Videos'
                          ? _showLevelSubjectSelector
                          : null,
                    );
                  },
                  childCount: exploreItemsList.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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

            // Announcements carousel
            if (announcementProvider.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Skeletonizer(
                    enabled: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 0, 8.0, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 16,
                                      width: 200,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 12,
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (announcementProvider.publishedAnnouncements.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  height: 265.0,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No announcements available',
                          style: AppTextStyles.normal500(
                            fontSize: 14.0,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: CarouselSlider(
                  items: announcementProvider.publishedAnnouncements
                      .map((announcement) {
                    return _buildAnnouncementCard(
                      announcement: announcement,
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 265.0,
                    padEnds: false,
                    viewportFraction: 0.95,
                    autoPlay: true,
                    enableInfiniteScroll:
                        announcementProvider.publishedAnnouncements.length > 1,
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

                  Duration difference = detemethods(news.date_posted);
                  return GestureDetector(
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
                        imageUrl: news.imageUrl,
                        authorName: news.author_name,
                        isRecommended: news.recommended == 1,
                      ));
                },
                childCount: newsProvider.latestNews.length,
              ),
            ),

            const SliverToBoxAdapter(
  child: SizedBox(height: kBottomNavigationBarHeight),
),
          ],
        ),
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

  // Pre-cache images for news and announcements into memory + disk cache
  void _precacheImages(NewsProvider newsProvider, AnnouncementProvider announcementProvider) {
    final urls = <String>{};

    for (final n in newsProvider.latestNews) {
      if (n.imageUrl.isNotEmpty) urls.add(n.imageUrl);
    }

    for (final a in announcementProvider.publishedAnnouncements) {
      if (a.imageUrl.isNotEmpty) urls.add(a.imageUrl);
    }

    for (final url in urls) {
      try {
        precacheImage(
          CachedNetworkImageProvider(url, cacheManager: _exploreCacheManager),
          context,
        );
      } catch (_) {
        // ignore errors while precaching
      }
    }
  }

  Widget _buildAnnouncementCard({
    required announcement,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Announcement Image
          GestureDetector(
            onTap: () => _launchURL(announcement.actionUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    cacheManager: _exploreCacheManager,
                    imageUrl: announcement.imageUrl,
                    fit: BoxFit.cover,
                    height: 180,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                          ],
                        ),
                      ),
                      child: Skeleton.leaf(
                        enabled: true,
                        child: Container(
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.buttonColor2,
                              AppColors.buttonColor3,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.campaign_rounded,
                            size: 60,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      );
                    },
                  ),
                  if (announcement.sponsored)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Sponsored',
                              style: AppTextStyles.normal500(
                                fontSize: 10.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          // Announcement info and action button
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      Text(
                        announcement.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Action button
              if (announcement.actionUrl.isNotEmpty)
                Container(
                  height: 35.0,
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
                      onPressed: () => _launchURL(announcement.actionUrl),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          announcement.actionText.isNotEmpty
                              ? announcement.actionText
                              : 'Learn More',
                          style: AppTextStyles.normal500(
                            fontSize: 14.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget exploreButtonItem({
    required Color backgroundColor,
    required Color borderColor,
    required String subtitle,
    required String label,
    required String iconPath,
    Widget? destination,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
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
                color: Colors.white,
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
    required String authorName,
    required bool isRecommended,
  }) {
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
            child: CachedNetworkImage(
              cacheManager: _exploreCacheManager,
              imageUrl: imageUrl,
              width: 80,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Skeleton.leaf(
                enabled: true,
                child: Container(
                  width: 80,
                  height: 100,
                  color: Colors.grey[300],
                ),
              ),
              errorWidget: (context, url, error) {
                return Container(
                  width: 80,
                  height: 100,
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

                // Author and time
                Row(
                  children: [
                    if (isRecommended)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Recommended',
                              style: AppTextStyles.normal500(
                                fontSize: 10.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 12,
                            color: AppColors.text4Light,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.normal400(
                                fontSize: 11.0,
                                color: AppColors.text4Light,
                              ),
                            ),
                          ),
                        ],
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
