import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/home/news/news_details.dart';
import 'package:linkschool/modules/model/explore/home/news/news_model.dart';
import 'package:linkschool/modules/providers/explore/home/news_provider.dart';

import 'package:provider/provider.dart';

class AllnewsScreen extends StatefulWidget {
  const AllnewsScreen({super.key});

  @override
  State<AllnewsScreen> createState() => _AllnewsScreenState();
}

class _AllnewsScreenState extends State<AllnewsScreen>
    with WidgetsBindingObserver {
  Set<String> selectedCategories = {};
  late final ScrollController _scrollController;
  final Map<int, NativeAd?> _nativeAds = {};
  final List<int> _adPositions = [];
  int _lastAdNewsCount = -1;
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoaded = false;
  bool _shouldShowAdOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchNews(refresh: true);
    });
    _loadAppOpenAd();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _shouldShowAdOnResume = true;
    } else if (state == AppLifecycleState.resumed) {
      if (_shouldShowAdOnResume) {
        _showAppOpenAd();
        _shouldShowAdOnResume = false;
      }
    }
  }

void _loadNativeAds(int newsCount) {
  // Clear existing ads
  _disposeAds();
  _adPositions.clear();
  
  // Calculate ad positions in the list (ads after every 5 news items)
  final listItemCount = _getListItemCount(newsCount);
  for (int position = 5; position < listItemCount; position += 6) {
    _adPositions.add(position);
  }

  // Load native ads for each position
  for (int position in _adPositions) {
    final nativeAd = NativeAd(
      
      adUnitId: EnvConfig.newsNativeAds,
      
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('✅ Native ad loaded at position $position');
          if (mounted) {
            setState(() {
              _nativeAds[position] = ad as NativeAd;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Native ad failed at position $position');
          print('Error message: ${error.message}');
          print('Error code: ${error.code}');
          print('Error domain: ${error.domain}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _nativeAds[position] = null;
            });
          }
        },
      ),
      request: const AdRequest(),
     // factoryId: 'newsCardAdFactory',
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small
      )
    );
    
    nativeAd.load();
  }

  if (mounted) {
    setState(() {});
  }
}

  void _disposeAds() {
    for (var ad in _nativeAds.values) {
      ad?.dispose();
    }
    _nativeAds.clear();
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: EnvConfig.newsAdsOpenApiKey,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          if (mounted) {
            setState(() {
              _isAppOpenAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (mounted) {
            setState(() {
              _isAppOpenAdLoaded = false;
            });
          }
        },
      ),
    );
  }

  void _showAppOpenAd() {
    if (!_isAppOpenAdLoaded || _appOpenAd == null) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdLoaded = false;
        _loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
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

  List<NewsModel> getFilteredNews(List<NewsModel> allNews, NewsProvider provider) {
    if (selectedCategories.isEmpty) {
      return allNews;
    }
    return allNews.where((news) {
      final category = provider.getCategoryForNews(news.id);
      return category != null && selectedCategories.contains(category);
    }).toList();
  }

  void _showFilterBottomSheet() {
    final provider = Provider.of<NewsProvider>(context, listen: false);
    final availableCategories = provider.availableCategories;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Category',
                        style: AppTextStyles.normal600(
                          fontSize: 20.0,
                          color: AppColors.text2Light,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: availableCategories.map((category) {
                      final isSelected = selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                          setState(() {});
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: getCategoryColor(category).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? getCategoryColor(category) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontFamily: 'Urbanist',
                        ),
                        side: BorderSide(
                          color: isSelected ? getCategoryColor(category) : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              selectedCategories.clear();
                            });
                            setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.text2Light),
                          ),
                          child: Text(
                            'Clear All',
                            style: AppTextStyles.normal600(
                              fontSize: 14.0,
                              color: AppColors.text2Light,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.text2Light,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Apply',
                            style: AppTextStyles.normal600(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final allNews = getFilteredNews(newsProvider.newsmodel, newsProvider);
    
    if (newsProvider.isLoading && allNews.isEmpty) {
      return Scaffold(
        appBar: Constants.customAppBar(
            context: context, title: 'All News', centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Check if we have news items
    if (allNews.isEmpty) {
      return Scaffold(
        appBar: Constants.customAppBar(
            context: context, title: 'All News', centerTitle: true),
        body: const Center(child: Text('No news available')),
      );
    }

    // First news as headline
    final headlineNews = allNews.first;
    // Remaining news for Latest News section
    final latestNews = allNews.skip(1).toList();
    
    // Load ads when news list changes
    if (latestNews.length != _lastAdNewsCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _lastAdNewsCount = latestNews.length;
        _loadNativeAds(latestNews.length);
      });
    }
    
    return Scaffold(
      appBar: Constants.customAppBar(
          context: context, title: 'All News', centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Provider.of<NewsProvider>(context, listen: false)
                .fetchNews(refresh: true);
            _lastAdNewsCount = -1;
          }
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline News Card
            GestureDetector(
              onTap: () {
                Duration difference = detemethods(headlineNews.date_posted);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetails(
                      news: headlineNews,
                      time: formatDuration(difference),
                    ),
                  ),
                );
              },
              child: _buildHeadlineCard(
                headlineNews,
                formatDuration(detemethods(headlineNews.date_posted)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Latest News Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        'Latest News',
                        style: AppTextStyles.normal700(
                          fontSize: 20.0,
                          color: AppColors.text2Light,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          size: 35,
                          color: AppColors.text2Light,
                        ),
                        onPressed: _showFilterBottomSheet,
                      ),
                      if (selectedCategories.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                '${selectedCategories.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Latest News List with Ads
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _getListItemCount(latestNews.length),
              itemBuilder: (context, index) {
                // Check if this position should show an ad
                if (_shouldShowAdAtPosition(index, latestNews.length)) {
                  final ad = _nativeAds[index];
                
                  if (ad != null) {
                 
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      height: 100,
                      child: AdWidget(ad: ad),
                    );
                  }else{
                    print("leeeee ${ad?.responseInfo}");
                  }
                  // Return empty container if ad hasn't loaded yet
                  return const SizedBox.shrink();
                }
                
                // Calculate the actual news index (accounting for ads)
                final newsIndex = _getNewsIndex(index, latestNews.length);
                if (newsIndex >= latestNews.length) {
                  return const SizedBox.shrink();
                }
                
                final news = latestNews[newsIndex];
                Duration difference = detemethods(news.date_posted);
                return GestureDetector(
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetails(
                                news: news, time: formatDuration(difference)),
                          ),
                        ),
                  child: allNwesSections(
                      news, formatDuration(difference)),
                );
              },
            ),

            if (newsProvider.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: CircularProgressIndicator(),
              ),

            if (!newsProvider.hasNextPage && newsProvider.newsmodel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No more news to load',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }

  // Calculate total item count including ads
  int _getListItemCount(int newsCount) {
    if (newsCount == 0) return 0;
    int adCount = (newsCount / 5).floor();
    return newsCount + adCount;
  }

  // Check if current position should show an ad
  bool _shouldShowAdAtPosition(int position, int newsCount) {
    // Ad positions: 5 (after 5 items), 11 (after 10 items), 17 (after 15 items), etc.
    // Pattern: 5, 11, 17, 23...
    return position >= 5 && (position - 5) % 6 == 0;
  }

  // Get the actual news index from list position (accounting for ads)
  int _getNewsIndex(int position, int newsCount) {
    if (_shouldShowAdAtPosition(position, newsCount)) return -1;
    // Calculate how many ads appear before this position (ads after every 5 items)
    int adsBeforePosition = ((position + 1) / 6).floor();
    return position - adsBeforePosition;
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      final provider = Provider.of<NewsProvider>(context, listen: false);
      if (provider.hasNextPage && !provider.isLoadingMore) {
        provider.loadMore();
        // Reload ads when more news is loaded
        _lastAdNewsCount = -1;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _disposeAds();
    _appOpenAd?.dispose();
    super.dispose();
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

  Widget _buildHeadlineCard(NewsModel news, String timeAgo) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final category = newsProvider.getCategoryForNews(news.id) ?? 'General';
    final categoryColor = getCategoryColor(category);
    
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            Image.network(
              news.imageUrl,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 280,
                  color: Colors.grey.shade300,
                  child: Icon(
                    Icons.image,
                    size: 60,
                    color: Colors.grey.shade500,
                  ),
                );
              },
            ),
            
            // Gradient overlay
            Positioned.fill(
              child: Container(
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
            ),
            
            // Content overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge and time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
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
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Urbanist',
                        height: 1.3,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      news.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontFamily: 'Urbanist',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget allNwesSections(NewsModel news, String timeAgo) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    final category = newsProvider.getCategoryForNews(news.id) ?? 'General';
    final categoryColor = getCategoryColor(category);
    
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
              news.imageUrl,
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
                  news.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.normal600(
                    fontSize: 16.0,
                    color: AppColors.text2Light,
                  ),
                ),
                const SizedBox(height: 8.0),
                
                // Description
                Text(
                  news.content,
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
                    Expanded(
                      child: Text(
                        timeAgo,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
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
