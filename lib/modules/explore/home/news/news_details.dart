import 'package:flutter/material.dart';
import 'package:linkfy_text/linkfy_text.dart';
// import 'package:linkschool/modules/explore/home/news/allnews_screen.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/home/news/all_news_screen.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NewsDetails extends StatefulWidget {
  final NewsModel news;
  final dynamic time;

  const NewsDetails({
    super.key,
    required this.news,
    required this.time,
  });

  @override
  State<NewsDetails> createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> with TickerProviderStateMixin {

  late NewsModel currentNews;
  List<NewsModel> allNewsList = [];
  int currentIndex = 0;
  String selectedCategory = 'All';
  List<String> categories = ['All'];

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  @override
  void initState() {
    super.initState();
    currentNews = widget.news;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Slide from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    Future.microtask(() {
      final provider = Provider.of<NewsProvider>(context, listen: false);
      if (provider.newsmodel.isEmpty) {
        provider.fetchNews();
      }
      setState(() {
        allNewsList = provider.newsmodel;
        currentIndex = allNewsList.indexWhere((news) => news.id == currentNews.id);
        // Load available categories from provider
        categories = ['All', ...provider.availableCategories];
      });
      _animationController.forward();
    });

    // Initialize banner ad
    _loadBannerAd();
    // Initialize interstitial ad
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: EnvConfig.googleBannerAdsApiKey,
      size:  AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = false;
            });
          }
        },
        onAdOpened: (Ad ad) {},
        onAdClosed: (Ad ad) {},
        onAdImpression: (Ad ad) {},
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: EnvConfig.NewsInterstitialAdsApiKey,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          if (mounted) {
            setState(() {
              _isInterstitialAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (mounted) {
            setState(() {
              _isInterstitialAdLoaded = false;
            });
          }
        },
      ),
    );
  }

  void _showInterstitialAdAndNavigateBack() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          // Navigate back after ad is dismissed
          if (mounted) {
            Navigator.pop(context);
          }
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          // Navigate back if ad fails to show
          if (mounted) {
            Navigator.pop(context);
          }
        },
      );
      _interstitialAd!.show();
      // Reload for next back action
      _loadInterstitialAd();
    } else {
      // If ad is not loaded, just navigate back
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void navigateToNews(NewsModel news) {
    setState(() {
      currentNews = news;
      currentIndex = allNewsList.indexWhere((n) => n.id == news.id);
    });
  }

  List<NewsModel> getFilteredNews() {
    if (selectedCategory == 'All') {
      return allNewsList;
    }
    final provider = Provider.of<NewsProvider>(context, listen: false);
    return provider.getNewsByCategory(selectedCategory);
  }

   void launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  } 

  Color getCategoryColor(String category) {
    switch (category) {
      case 'WAEC':
        return Colors.orange;
      case 'JAMB':
        return Colors.blue;
      case 'Admission':
        return Colors.purple;
      case 'Scholarships':
        return Colors.green;
      case 'General':
      default:
        return Colors.grey;
    }
  }

  _navigatorAllNews() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AllnewsScreen()));
  }

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
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    String? category = newsProvider.getCategoryForNews(currentNews.id);
    Color categoryColor = getCategoryColor(category ?? 'General');

    List<NewsModel> recommendedNews = newsProvider.recommendedNews
        .where((news) => news.id != currentNews.id)
        .toList();

    List<NewsModel> relatedNews = newsProvider.relatedNews
        .where((news) => news.id != currentNews.id)
        .toList();

    return Stack(
      children: [
        // Optional: Dimmed background for popup effect
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.25),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.98,
                ),
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: CustomScrollView(
                    slivers: [
                      // ...existing code...
                      SliverAppBar(
                        expandedHeight: 300,
                        pinned: true,
                        backgroundColor: AppColors.text2Light,
                        leading: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          onPressed: () => _showInterstitialAdAndNavigateBack(),
                        ),
                        actions: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.share,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                            onPressed: () => _shareNews(
                              widget.news.title,
                              widget.news.content,
                              widget.time.toString(),
                              widget.news.imageUrl,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              // ...existing code...
                              Image.network(
                                widget.news.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: Icon(
                                      Icons.image,
                                      size: 80,
                                      color: Colors.grey.shade500,
                                    ),
                                  );
                                },
                              ),
                              // ...existing code...
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.8),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                              // ...existing code...
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.news.title,
                                        style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontFamily: 'Urbanist',
                                          height: 1.3,
                                        ),
                                      ),
                                      // ...existing code...
                                      SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: categoryColor,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              category ?? "General",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Urbanist',
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                widget.time.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Urbanist',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // space before ad
                      SliverToBoxAdapter(
                        child: SizedBox(height:  16),
                      ),

                      // Banner Ad - Displays after the image
                      if (_isBannerAdLoaded)
                        SliverToBoxAdapter(
                          child: Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: _bannerAd!.size.width.toDouble(),
                              height: _bannerAd!.size.height.toDouble(),
                              child: AdWidget(ad: _bannerAd!),
                            ),
                          ),
                        ),
                      // ...existing code...
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinkifyText(
                                  currentNews.content,
                                  textStyle: AppTextStyles.normal400(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ).copyWith(height: 1.7),
                                  linkStyle: TextStyle(
                                    color: AppColors.primaryLight,
                                    decoration: TextDecoration.underline,
                                  ),
                                  onTap: (link) {
                                    launchURL(link.value.toString());
                                  },
                                ),
                                const SizedBox(height: 40),
                                if (recommendedNews.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.text2Light.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.star_rounded,
                                          color: AppColors.text2Light,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Recommended for You',
                                        style: AppTextStyles.normal600(
                                          fontSize: 18.0,
                                          color: AppColors.text2Light,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...recommendedNews.map((news) => _buildNewsCard(news, context)),
                                  const SizedBox(height: 32),
                                ],
                                if (relatedNews.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.text2Light.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.article_rounded,
                                          color: AppColors.text2Light,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Related News',
                                        style: AppTextStyles.normal600(
                                          fontSize: 18.0,
                                          color: AppColors.text2Light,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...relatedNews.map((news) => relatedCard(news, context)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget relatedCard(NewsModel news, BuildContext context) {
  final newsProvider = Provider.of<NewsProvider>(context, listen: false);
  final category = newsProvider.getCategoryForNews(news.id) ?? 'General';
  final categoryColor = getCategoryColor(category);
  DateTime dop = DateTime.parse(news.date_posted);
  DateTime nowDateTime = DateTime.now();
  Duration difference = nowDateTime.difference(dop);
  String timeAgo = formatDuration(difference);

  return GestureDetector(
    onTap: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewsDetails(
            news: news,
            time: timeAgo,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------------- IMAGE ----------------
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              news.imageUrl,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 160,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          /// ---------------- TITLE ----------------
          Text(
            news.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.normal600(
              fontSize: 15.0,
              color: AppColors.text2Light,
            ),
          ),

          const SizedBox(height: 10),

          /// ---------------- CATEGORY + TIME ----------------
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                timeAgo,
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
  );
}


  Widget _buildNewsCard(NewsModel news, BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final category = newsProvider.getCategoryForNews(news.id) ?? 'General';
    final categoryColor = getCategoryColor(category);
    DateTime dop = DateTime.parse(news.date_posted);
    DateTime nowDateTime = DateTime.now();
    Duration difference = nowDateTime.difference(dop);
    String timeAgo = formatDuration(difference);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetails(
              news: news,
              time: timeAgo,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                news.imageUrl,
                width: 80,
                height: 80,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.normal600(
                      fontSize: 14.0,
                      color: AppColors.text2Light,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        timeAgo,
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
      ),
    );
  }

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
}
